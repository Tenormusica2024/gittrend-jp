import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../datasources/github_api.dart';
import '../datasources/local_storage.dart';
import '../models/repository.dart';
import '../models/saved_repository.dart';
import '../models/app_settings.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../main.dart' show initializedUserIdProvider;

/// レート制限例外: 連続操作を防止するために投げられる
class RateLimitedException implements Exception {
  final Duration remainingTime;
  RateLimitedException(this.remainingTime);

  @override
  String toString() => 'Rate limited. Please wait ${remainingTime.inMilliseconds}ms';
}

/// ストレージ保存失敗例外
class StorageSaveException implements Exception {
  final String operation;
  StorageSaveException(this.operation);

  @override
  String toString() => 'Storage save failed: $operation';
}

final githubApiProvider = Provider<GitHubApi>((ref) => GitHubApi());

final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

/// userIdProvider: main()で初期化されたuserIdを優先使用
/// main()での初期化に失敗した場合のみ、ここでフォールバック生成
final userIdProvider = Provider<String>((ref) {
  // main()から注入されたuserIdを優先
  final initializedUserId = ref.watch(initializedUserIdProvider);
  if (initializedUserId != null && initializedUserId.isNotEmpty) {
    return initializedUserId;
  }

  // フォールバック: main()での初期化が失敗した場合
  Logger.warning('userIdProvider', 'Using fallback userId generation (main initialization may have failed)');
  final storage = ref.watch(localStorageProvider);
  var userId = storage.getUserId();
  if (userId == null || userId.isEmpty) {
    userId = const Uuid().v4();
    // 非同期保存を試行（失敗してもログのみ）
    storage.saveUserId(userId).then((success) {
      if (!success) {
        Logger.warning('userIdProvider', 'Failed to save fallback userId');
      }
    });
  }
  return userId;
});

final trendingRepositoriesProvider = FutureProvider.family<List<Repository>, TrendingSince>(
  (ref, since) async {
    final api = ref.watch(githubApiProvider);
    return api.getTrending(since: since);
  },
);

final japaneseRepositoriesProvider = FutureProvider<List<Repository>>((ref) async {
  final api = ref.watch(githubApiProvider);
  final repos = await api.getTrending();
  return repos.where((repo) => repo.hasJapaneseReadme).toList();
});

final bookmarkedIdsProvider = StateProvider<Set<String>>((ref) => {});

final isBookmarkedProvider = Provider.family<bool, String>((ref, fullName) {
  return ref.watch(bookmarkedIdsProvider).contains(fullName);
});

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<SavedRepository>>>(
  (ref) => BookmarksNotifier(ref),
);

class BookmarksNotifier extends StateNotifier<AsyncValue<List<SavedRepository>>> {
  final Ref _ref;

  // レート制限: 連続リクエストを防止
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 500);

  BookmarksNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    state = const AsyncValue.loading();
    final api = _ref.read(githubApiProvider);
    final userId = _ref.read(userIdProvider);
    final result = await api.getBookmarks(userId);

    // Result型で成功/失敗を明確に判定
    switch (result) {
      case Success(data: final bookmarksData):
        final bookmarks = bookmarksData.map((data) => SavedRepository(
          repositoryId: data['repositoryId'] ?? data['fullName'] ?? '',
          savedAt: data['savedAt'] != null
            ? DateTime.tryParse(data['savedAt']) ?? DateTime.now()
            : DateTime.now(),
          name: data['fullName'] ?? data['name'],
          description: data['description'],
          stars: data['stars'],
          language: data['language'],
          url: data['url'],
          descriptionJa: data['descriptionJa'],
          summaryJa: data['summaryJa'],
        )).toList();

        _ref.read(bookmarkedIdsProvider.notifier).state = bookmarks.map((b) => b.repositoryId).toSet();
        state = AsyncValue.data(bookmarks);

      case Failure(message: final msg, error: final e, stackTrace: final st):
        Logger.error('BookmarksNotifier', 'Failed to load bookmarks: $msg', e);
        state = AsyncValue.error(e ?? msg, st ?? StackTrace.current);
    }
  }

  Future<void> toggleBookmark(Repository repo) async {
    // レート制限チェック（サイレント無視ではなく例外を投げてUIに通知）
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _minRequestInterval) {
      final remaining = _minRequestInterval - now.difference(_lastRequestTime!);
      throw RateLimitedException(remaining);
    }
    _lastRequestTime = now;

    final api = _ref.read(githubApiProvider);
    final userId = _ref.read(userIdProvider);
    final idsNotifier = _ref.read(bookmarkedIdsProvider.notifier);

    final wasBookmarked = idsNotifier.state.contains(repo.fullName);

    // 元の状態を保存（エラー時のロールバック用）
    final originalIds = Set<String>.from(idsNotifier.state);

    try {
      if (wasBookmarked) {
        final newIds = Set<String>.from(idsNotifier.state)..remove(repo.fullName);
        idsNotifier.state = newIds;
        _updateStateOptimistically();

        final success = await api.removeBookmark(userId, repo.fullName);
        if (!success) {
          idsNotifier.state = originalIds;
          _updateStateOptimistically();
        }
      } else {
        final newIds = Set<String>.from(idsNotifier.state)..add(repo.fullName);
        idsNotifier.state = newIds;

        final newBookmark = SavedRepository(
          repositoryId: repo.fullName,
          savedAt: DateTime.now(),
          name: repo.fullName,
          description: repo.description,
          stars: repo.stars,
          language: repo.language,
          url: repo.url,
          descriptionJa: repo.descriptionJa,
          summaryJa: repo.summaryJa,
        );
        _addToStateOptimistically(newBookmark);

        final success = await api.addBookmark(userId, repo);
        if (!success) {
          idsNotifier.state = originalIds;
          _removeFromStateOptimistically(repo.fullName);
        }
      }
    } catch (e) {
      // エラー発生時は元の状態にロールバック
      idsNotifier.state = originalIds;
      if (wasBookmarked) {
        _updateStateOptimistically();
      } else {
        _removeFromStateOptimistically(repo.fullName);
      }
      rethrow;
    }
  }

  void _updateStateOptimistically() {
    final ids = _ref.read(bookmarkedIdsProvider);
    state.whenData((bookmarks) {
      state = AsyncValue.data(
        bookmarks.where((b) => ids.contains(b.repositoryId)).toList(),
      );
    });
  }

  void _addToStateOptimistically(SavedRepository bookmark) {
    state.whenData((bookmarks) {
      state = AsyncValue.data([bookmark, ...bookmarks]);
    });
  }

  void _removeFromStateOptimistically(String repositoryId) {
    state.whenData((bookmarks) {
      state = AsyncValue.data(
        bookmarks.where((b) => b.repositoryId != repositoryId).toList(),
      );
    });
  }

  Future<void> removeBookmark(String repositoryId) async {
    final api = _ref.read(githubApiProvider);
    final userId = _ref.read(userIdProvider);
    final idsNotifier = _ref.read(bookmarkedIdsProvider.notifier);

    // 元の状態を保存（ロールバック用）
    final originalIds = Set<String>.from(idsNotifier.state);

    // 楽観的更新
    final newIds = Set<String>.from(idsNotifier.state)..remove(repositoryId);
    idsNotifier.state = newIds;
    _updateStateOptimistically();

    try {
      // API呼び出し、失敗時はロールバック
      final success = await api.removeBookmark(userId, repositoryId);
      if (!success) {
        idsNotifier.state = originalIds;
        _updateStateOptimistically();
      }
    } catch (e) {
      // エラー発生時は元の状態にロールバック
      idsNotifier.state = originalIds;
      _updateStateOptimistically();
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadBookmarks();
  }

  bool isBookmarked(String repositoryId) {
    return _ref.read(bookmarkedIdsProvider).contains(repositoryId);
  }
}

final savedRepositoriesProvider = StateNotifierProvider<SavedRepositoriesNotifier, List<SavedRepository>>(
  (ref) => SavedRepositoriesNotifier(ref.watch(localStorageProvider)),
);

class SavedRepositoriesNotifier extends StateNotifier<List<SavedRepository>> {
  final LocalStorage _storage;

  SavedRepositoriesNotifier(this._storage) : super([]) {
    _loadSavedRepositories();
  }

  void _loadSavedRepositories() {
    state = _storage.getSavedRepositories();
  }

  Future<void> toggleSave(Repository repo) async {
    bool success;
    // ID基準をfullNameに統一（BookmarksNotifierと一貫性を保つ）
    final repositoryId = repo.fullName;
    if (_storage.isRepositorySaved(repositoryId)) {
      success = await _storage.removeRepository(repositoryId);
    } else {
      success = await _storage.saveRepository(SavedRepository(
        repositoryId: repositoryId,
        savedAt: DateTime.now(),
        name: repo.fullName,
        description: repo.description,
        stars: repo.stars,
        language: repo.language,
        url: repo.url,
        descriptionJa: repo.descriptionJa,
        summaryJa: repo.summaryJa,
      ));
    }
    if (!success) {
      throw StorageSaveException('toggleSave');
    }
    _loadSavedRepositories();
  }

  Future<void> removeSaved(String repositoryId) async {
    final success = await _storage.removeRepository(repositoryId);
    if (!success) {
      throw StorageSaveException('removeSaved');
    }
    _loadSavedRepositories();
  }

  Future<void> clearAll() async {
    bool anyFailed = false;
    for (final saved in state) {
      final success = await _storage.removeRepository(saved.repositoryId);
      if (!success) {
        anyFailed = true;
      }
    }
    _loadSavedRepositories();
    if (anyFailed) {
      throw StorageSaveException('clearAll');
    }
  }

  bool isSaved(String repositoryId) {
    return _storage.isRepositorySaved(repositoryId);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(localStorageProvider)),
);

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorage _storage;

  AppSettingsNotifier(this._storage) : super(AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _storage.getSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final success = await _storage.saveSettings(settings);
    if (!success) {
      throw StorageSaveException('updateSettings');
    }
    state = settings;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await updateSettings(state.copyWith(notificationEnabled: enabled));
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    await updateSettings(state.copyWith(notificationHour: hour, notificationMinute: minute));
  }

  Future<void> setJapaneseOnlyNotification(bool value) async {
    await updateSettings(state.copyWith(japaneseOnlyNotification: value));
  }

  Future<void> setDefaultLanguage(String? language) async {
    await updateSettings(state.copyWith(defaultLanguageFilter: language));
  }

  Future<void> setMinimumStars(int value) async {
    await updateSettings(state.copyWith(minimumStars: value));
  }
}

final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Pull-to-Refresh レート制限用のプロバイダー
/// 各タブ(TrendingSince)ごとの最終リフレッシュ時刻を管理
final lastRefreshTimeProvider = StateProvider.family<DateTime?, TrendingSince>((ref, since) => null);

/// リフレッシュ間隔の最小値（秒）
const int minRefreshIntervalSeconds = 10;
