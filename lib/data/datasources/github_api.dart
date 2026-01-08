import 'package:dio/dio.dart';
import '../models/repository.dart';

enum TrendingSince { daily, weekly, monthly }

class GitHubApi {
  final Dio _dio;
  static const String _baseUrl = 'https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/getTrending';
  static const String _summaryUrl = 'https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/getRepoSummary';
  static const String _addBookmarkUrl = 'https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/addBookmark';
  static const String _removeBookmarkUrl = 'https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/removeBookmark';
  static const String _getBookmarksUrl = 'https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/getBookmarks';
  
  GitHubApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Repository>> getTrending({
    TrendingSince since = TrendingSince.daily,
    String? language,
    int limit = 30,
    bool withSummary = true,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
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
          return data.map((json) => _parseRepository(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('[GitHubApi] getTrending error: $e');
      return _getMockData();
    }
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

  Future<Map<String, String?>> getRepoSummary(String fullName, String description) async {
    print('[GitHubApi] getRepoSummary called for: $fullName');
    try {
      final response = await _dio.get(
        _summaryUrl,
        queryParameters: {
          'repo': fullName,
          'description': description,
        },
      );

      print('[GitHubApi] Response status: ${response.statusCode}');
      print('[GitHubApi] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print('[GitHubApi] Success! descriptionJa: ${data['descriptionJa']}');
        return {
          'descriptionJa': data['descriptionJa'],
          'summaryJa': data['readmeSummaryJa'],
        };
      }
    } catch (e) {
      print('[GitHubApi] Error: $e');
    }
    return {'descriptionJa': null, 'summaryJa': null};
  }

  Future<List<Map<String, dynamic>>> getBookmarks(String userId) async {
    try {
      final response = await _dio.get(
        _getBookmarksUrl,
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
    } catch (e) {
      print('[GitHubApi] getBookmarks error: $e');
    }
    return [];
  }

  Future<bool> addBookmark(String userId, Repository repo) async {
    try {
      final response = await _dio.post(
        '$_addBookmarkUrl?userId=$userId',
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
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('[GitHubApi] addBookmark error: $e');
      return false;
    }
  }

  Future<bool> removeBookmark(String userId, String repositoryId) async {
    try {
      final response = await _dio.delete(
        _removeBookmarkUrl,
        queryParameters: {
          'userId': userId,
          'repositoryId': repositoryId,
        },
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('[GitHubApi] removeBookmark error: $e');
      return false;
    }
  }

  List<Repository> _getMockData() {
    return [
      const Repository(
        id: 'openai/whisper-jp',
        name: 'whisper-jp',
        fullName: 'openai/whisper-jp',
        owner: 'openai',
        description: 'Japanese-optimized speech recognition model with improved accuracy for business conversations',
        stars: 2847,
        starsToday: 123,
        language: 'Python',
        url: 'https://github.com/openai/whisper-jp',
      ),
      const Repository(
        id: 'vercel/next-intl',
        name: 'next-intl',
        fullName: 'vercel/next-intl',
        owner: 'vercel',
        description: 'Internationalization for Next.js with full Japanese support and RTL layouts',
        stars: 1523,
        starsToday: 45,
        language: 'TypeScript',
        url: 'https://github.com/vercel/next-intl',
      ),
      const Repository(
        id: 'line/armeria',
        name: 'armeria',
        fullName: 'line/armeria',
        owner: 'line',
        description: 'Your go-to microservice framework for any situation',
        stars: 4201,
        starsToday: 32,
        language: 'Java',
        hasJapaneseReadme: true,
        url: 'https://github.com/line/armeria',
      ),
      const Repository(
        id: 'nicklockwood/SwiftFormat',
        name: 'SwiftFormat',
        fullName: 'nicklockwood/SwiftFormat',
        owner: 'nicklockwood',
        description: 'A command-line tool and Xcode Extension for formatting Swift code',
        stars: 7892,
        starsToday: 28,
        language: 'Swift',
        url: 'https://github.com/nicklockwood/SwiftFormat',
      ),
      const Repository(
        id: 'rust-lang/rustlings',
        name: 'rustlings',
        fullName: 'rust-lang/rustlings',
        owner: 'rust-lang',
        description: 'Small exercises to get you used to reading and writing Rust code!',
        stars: 52400,
        starsToday: 156,
        language: 'Rust',
        url: 'https://github.com/rust-lang/rustlings',
      ),
    ];
  }
}
