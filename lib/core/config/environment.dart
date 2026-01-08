import 'package:flutter/foundation.dart';

class Environment {
  static const String _defaultBaseUrl = 'https://gettrending-z272xsgkhq-an.a.run.app';
  static const String _defaultSummaryUrl = 'https://getreposummary-z272xsgkhq-an.a.run.app';
  static const String _defaultAddBookmarkUrl = 'https://addbookmark-z272xsgkhq-an.a.run.app';
  static const String _defaultRemoveBookmarkUrl = 'https://removebookmark-z272xsgkhq-an.a.run.app';
  static const String _defaultGetBookmarksUrl = 'https://getbookmarks-z272xsgkhq-an.a.run.app';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String summaryUrl = String.fromEnvironment(
    'API_SUMMARY_URL',
    defaultValue: _defaultSummaryUrl,
  );

  static const String addBookmarkUrl = String.fromEnvironment(
    'API_ADD_BOOKMARK_URL',
    defaultValue: _defaultAddBookmarkUrl,
  );

  static const String removeBookmarkUrl = String.fromEnvironment(
    'API_REMOVE_BOOKMARK_URL',
    defaultValue: _defaultRemoveBookmarkUrl,
  );

  static const String getBookmarksUrl = String.fromEnvironment(
    'API_GET_BOOKMARKS_URL',
    defaultValue: _defaultGetBookmarksUrl,
  );

  static bool get isProduction => !kDebugMode;
  
  static void printConfig() {
    if (kDebugMode) {
      print('[Environment] API Configuration:');
      print('  Base URL: $baseUrl');
      print('  Summary URL: $summaryUrl');
      print('  Add Bookmark URL: $addBookmarkUrl');
      print('  Remove Bookmark URL: $removeBookmarkUrl');
      print('  Get Bookmarks URL: $getBookmarksUrl');
      print('  Is Production: $isProduction');
    }
  }
}
