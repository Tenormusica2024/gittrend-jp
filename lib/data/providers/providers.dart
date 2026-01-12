import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../datasources/github_api.dart';
import '../datasources/local_storage.dart';
import '../models/repository.dart';
import '../models/saved_repository.dart';
import '../models/app_settings.dart';

final githubApiProvider = Provider<GitHubApi>((ref) => GitHubApi());

final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final userIdProvider = StateProvider<String>((ref) {
  final storage = ref.watch(localStorageProvider);
  var userId = storage.getUserId();
  if (userId == null) {
    userId = const Uuid().v4();
    storage.saveUserId(userId);
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
    try {
      final api = _ref.read(githubApiProvider);
      final userId = _ref.read(userIdProvider);
      final bookmarksData = await api.getBookmarks(userId);
      
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleBookmark(Repository repo) async {
    // レート制限チェック
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _minRequestInterval) {
      return; // 連続リクエストを無視
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

    // API呼び出し、失敗時はロールバック
    final success = await api.removeBookmark(userId, repositoryId);
    if (!success) {
      idsNotifier.state = originalIds;
      _updateStateOptimistically();
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
    if (_storage.isRepositorySaved(repo.id)) {
      await _storage.removeRepository(repo.id);
    } else {
      await _storage.saveRepository(SavedRepository(
        repositoryId: repo.id,
        savedAt: DateTime.now(),
        name: repo.name,
        description: repo.description,
        stars: repo.stars,
        language: repo.language,
        url: repo.url,
      ));
    }
    _loadSavedRepositories();
  }

  Future<void> removeSaved(String repositoryId) async {
    await _storage.removeRepository(repositoryId);
    _loadSavedRepositories();
  }

  Future<void> clearAll() async {
    for (final saved in state) {
      await _storage.removeRepository(saved.repositoryId);
    }
    _loadSavedRepositories();
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
    await _storage.saveSettings(settings);
    state = settings;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final newSettings = AppSettings(
      notificationEnabled: enabled,
      notificationHour: state.notificationHour,
      notificationMinute: state.notificationMinute,
      defaultLanguageFilter: state.defaultLanguageFilter,
      minimumStars: state.minimumStars,
      japaneseOnlyNotification: state.japaneseOnlyNotification,
    );
    await updateSettings(newSettings);
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    final newSettings = AppSettings(
      notificationEnabled: state.notificationEnabled,
      notificationHour: hour,
      notificationMinute: minute,
      defaultLanguageFilter: state.defaultLanguageFilter,
      minimumStars: state.minimumStars,
      japaneseOnlyNotification: state.japaneseOnlyNotification,
    );
    await updateSettings(newSettings);
  }

  Future<void> setJapaneseOnlyNotification(bool value) async {
    final newSettings = AppSettings(
      notificationEnabled: state.notificationEnabled,
      notificationHour: state.notificationHour,
      notificationMinute: state.notificationMinute,
      defaultLanguageFilter: state.defaultLanguageFilter,
      minimumStars: state.minimumStars,
      japaneseOnlyNotification: value,
    );
    await updateSettings(newSettings);
  }

  Future<void> setDefaultLanguage(String? language) async {
    final newSettings = AppSettings(
      notificationEnabled: state.notificationEnabled,
      notificationHour: state.notificationHour,
      notificationMinute: state.notificationMinute,
      defaultLanguageFilter: language,
      minimumStars: state.minimumStars,
      japaneseOnlyNotification: state.japaneseOnlyNotification,
    );
    await updateSettings(newSettings);
  }

  Future<void> setMinimumStars(int value) async {
    final newSettings = AppSettings(
      notificationEnabled: state.notificationEnabled,
      notificationHour: state.notificationHour,
      notificationMinute: state.notificationMinute,
      defaultLanguageFilter: state.defaultLanguageFilter,
      minimumStars: value,
      japaneseOnlyNotification: state.japaneseOnlyNotification,
    );
    await updateSettings(newSettings);
  }
}

final selectedTabProvider = StateProvider<int>((ref) => 0);
