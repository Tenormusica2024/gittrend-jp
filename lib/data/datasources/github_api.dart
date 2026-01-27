import 'package:dio/dio.dart';
import '../models/repository.dart';
import '../../core/config/environment.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/api_exception.dart';
import '../../core/utils/result.dart';

enum TrendingSince { daily, weekly, monthly }

class GitHubApi {
  static const String _tag = 'GitHubApi';
  final Dio _dio;
  bool _isHealthy = true;
  DateTime? _lastHealthCheck;
  
  GitHubApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 15),
            )) {
    Environment.printConfig();
  }

  Future<bool> checkHealth() async {
    try {
      Logger.debug(_tag, 'Checking API health...');
      final response = await _dio.get(
        Environment.baseUrl,
        queryParameters: {'since': 'daily', 'limit': 1},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      _isHealthy = response.statusCode == 200;
      _lastHealthCheck = DateTime.now();
      
      Logger.info(_tag, 'Health check result: $_isHealthy');
      return _isHealthy;
    } catch (e) {
      _isHealthy = false;
      _lastHealthCheck = DateTime.now();
      Logger.error(_tag, 'Health check failed', e);
      return false;
    }
  }

  bool get isHealthy => _isHealthy;
  DateTime? get lastHealthCheck => _lastHealthCheck;

  Future<List<Repository>> getTrending({
    TrendingSince since = TrendingSince.daily,
    String? language,
    int limit = 30,
    bool withSummary = true,
  }) async {
    Logger.debug(_tag, 'getTrending called: since=$since, limit=$limit');
    
    try {
      final response = await _dio.get(
        Environment.baseUrl,
        queryParameters: {
          'since': since.name,
          'limit': limit,
          'withSummary': withSummary.toString(),
          if (language != null && language.isNotEmpty) 'language': language,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          Logger.info(_tag, 'getTrending success: ${data.length} repositories');
          _isHealthy = true;
          return data.map((json) => _parseRepository(json)).toList();
        }
        
        Logger.warning(_tag, 'API returned success=false', responseData);
        throw ApiException('API returned unsuccessful response');
      }
      
      Logger.warning(_tag, 'Unexpected status code: ${response.statusCode}');
      throw ApiServerException('Server returned status ${response.statusCode}');
    } on DioException catch (e, stack) {
      _isHealthy = false;
      return _handleDioError(e, stack, 'getTrending');
    } catch (e, stack) {
      Logger.error(_tag, 'Unexpected error in getTrending', e, stack);
      rethrow;
    }
  }

  List<Repository> _handleDioError(DioException e, StackTrace stack, String operation) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      Logger.error(_tag, '$operation: Connection timeout', e, stack);
      throw ApiConnectionException(
        'サーバーへの接続がタイムアウトしました。ネットワーク接続を確認してください。',
        originalError: e,
      );
    }
    
    if (e.type == DioExceptionType.connectionError) {
      Logger.error(_tag, '$operation: Connection error', e, stack);
      throw ApiConnectionException(
        'サーバーに接続できません。ネットワーク接続を確認してください。',
        originalError: e,
      );
    }
    
    if (e.response?.statusCode == 404) {
      Logger.error(_tag, '$operation: API endpoint not found (404)', e, stack);
      throw ApiNotFoundException(
        'APIエンドポイントが見つかりません。設定を確認してください。',
        originalError: e,
      );
    }

    if (e.response?.statusCode == 429) {
      final retryAfter = e.response?.headers.value('retry-after');
      final waitSeconds = retryAfter != null ? int.tryParse(retryAfter) ?? 60 : 60;
      Logger.error(_tag, '$operation: Rate limit exceeded (429), retry after $waitSeconds seconds', e, stack);
      throw ApiRateLimitException(
        'APIリクエスト制限に達しました。$waitSeconds秒後に再試行してください。',
        retryAfterSeconds: waitSeconds,
        originalError: e,
      );
    }

    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      Logger.error(_tag, '$operation: Server error (${e.response?.statusCode})', e, stack);
      throw ApiServerException(
        'サーバーエラーが発生しました。しばらく後でもう一度お試しください。',
        originalError: e,
      );
    }
    
    Logger.error(_tag, '$operation: Unknown Dio error', e, stack);
    throw ApiException(
      'データの取得に失敗しました。',
      originalError: e,
    );
  }

  Repository _parseRepository(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] ?? json['fullName'] ?? '',
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      owner: json['owner'] ?? '',
      description: json['description'] ?? '',
      stars: json['stars'] ?? 0,
      starsToday: json['starsToday'] ?? 0,
      forks: json['forks'] ?? 0,
      language: json['language'],
      languageColor: json['languageColor'],
      url: json['url'] ?? 'https://github.com/${json['fullName']}',
      descriptionJa: json['descriptionJa'],
      summaryJa: json['summaryJa'],
    );
  }

  /// リポジトリのサマリー（日本語翻訳）を取得
  /// Result型で成功/失敗を明確に区別
  Future<Result<Map<String, String?>>> getRepoSummary(String fullName, String description) async {
    Logger.debug(_tag, 'getRepoSummary called for: $fullName');

    try {
      final response = await _dio.get(
        Environment.summaryUrl,
        queryParameters: {
          'repo': fullName,
          'description': description,
        },
      );

      Logger.debug(_tag, 'Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        Logger.info(_tag, 'getRepoSummary success for: $fullName');
        return Success({
          'descriptionJa': data['descriptionJa'] as String?,
          'summaryJa': data['readmeSummaryJa'] as String?,
        });
      }

      Logger.warning(_tag, 'getRepoSummary: Unsuccessful response for $fullName');
      return const Failure('APIからの応答が不正です');
    } on DioException catch (e, stack) {
      Logger.error(_tag, 'getRepoSummary error for $fullName', e, stack);
      return Failure('サマリーの取得に失敗しました', error: e, stackTrace: stack);
    }
  }

  /// ブックマーク一覧を取得
  /// Result型で成功（データあり/なし）と失敗を明確に区別
  Future<Result<List<Map<String, dynamic>>>> getBookmarks(String userId) async {
    Logger.debug(_tag, 'getBookmarks called');

    try {
      final response = await _dio.get(
        Environment.getBookmarksUrl,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookmarks = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
        Logger.info(_tag, 'getBookmarks success: ${bookmarks.length} items');
        // 空リストも「成功」として返す（データなしと失敗を区別）
        return Success(bookmarks);
      }

      Logger.warning(_tag, 'getBookmarks: Unsuccessful response');
      return const Failure('ブックマークの取得に失敗しました');
    } on DioException catch (e, stack) {
      Logger.error(_tag, 'getBookmarks error', e, stack);
      return Failure('ブックマークの取得に失敗しました', error: e, stackTrace: stack);
    }
  }

  Future<bool> addBookmark(String userId, Repository repo) async {
    Logger.debug(_tag, 'addBookmark called for: ${repo.fullName}');
    
    try {
      final response = await _dio.post(
        '${Environment.addBookmarkUrl}?userId=$userId',
        data: {
          'repositoryId': repo.fullName,
          'fullName': repo.fullName,
          'name': repo.name,
          'description': repo.description,
          'descriptionJa': repo.descriptionJa,
          'summaryJa': repo.summaryJa,
          'stars': repo.stars,
          'language': repo.language,
          'url': repo.url,
        },
      );
      
      final success = response.statusCode == 200 && response.data['success'] == true;
      Logger.info(_tag, 'addBookmark ${success ? 'success' : 'failed'} for: ${repo.fullName}');
      return success;
    } on DioException catch (e, stack) {
      Logger.error(_tag, 'addBookmark error for: ${repo.fullName}', e, stack);
      throw ApiException('ブックマークの追加に失敗しました。', originalError: e);
    }
  }

  Future<bool> removeBookmark(String userId, String repositoryId) async {
    Logger.debug(_tag, 'removeBookmark called for: $repositoryId');
    
    try {
      final response = await _dio.delete(
        Environment.removeBookmarkUrl,
        queryParameters: {
          'userId': userId,
          'repositoryId': repositoryId,
        },
      );
      
      final success = response.statusCode == 200 && response.data['success'] == true;
      Logger.info(_tag, 'removeBookmark ${success ? 'success' : 'failed'} for: $repositoryId');
      return success;
    } on DioException catch (e, stack) {
      Logger.error(_tag, 'removeBookmark error for: $repositoryId', e, stack);
      throw ApiException('ブックマークの削除に失敗しました。', originalError: e);
    }
  }
}
