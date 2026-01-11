import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { ja, en }

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.ja);

class AppLocalizations {
  final AppLocale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(AppLocale.ja);
  }

  String get appTitle => _get('appTitle');
  String get today => _get('today');
  String get weekly => _get('weekly');
  String get monthly => _get('monthly');
  String get japanese => _get('japanese');
  String get todaysTrending => _get('todaysTrending');
  String get thisWeek => _get('thisWeek');
  String get thisMonth => _get('thisMonth');
  String get japaneseRepos => _get('japaneseRepos');
  String get noJapaneseRepos => _get('noJapaneseRepos');
  String get savedRepositories => _get('savedRepositories');
  String get noSavedRepositories => _get('noSavedRepositories');
  String get tapToSave => _get('tapToSave');
  String get clearAll => _get('clearAll');
  String get clearAllSaved => _get('clearAllSaved');
  String get clearAllConfirm => _get('clearAllConfirm');
  String get cancel => _get('cancel');
  String get clear => _get('clear');
  String get settings => _get('settings');
  String get notifications => _get('notifications');
  String get dailyTrendingAlert => _get('dailyTrendingAlert');
  String get dailyTrendingAlertDesc => _get('dailyTrendingAlertDesc');
  String get notificationTime => _get('notificationTime');
  String get japaneseReposOnly => _get('japaneseReposOnly');
  String get japaneseReposOnlyDesc => _get('japaneseReposOnlyDesc');
  String get filters => _get('filters');
  String get defaultLanguage => _get('defaultLanguage');
  String get minimumStars => _get('minimumStars');
  String get about => _get('about');
  String get version => _get('version');
  String get privacyPolicy => _get('privacyPolicy');
  String get termsOfService => _get('termsOfService');
  String get language => _get('language');
  String get languageJapanese => _get('languageJapanese');
  String get languageEnglish => _get('languageEnglish');
  String get all => _get('all');
  String get newLabel => _get('newLabel');
  String stars(int count) => _get('stars').replaceAll('{count}', count.toString());
  String starsToday(int count) => _get('starsToday').replaceAll('{count}', count.toString());
  String get loading => _get('loading');
  String get readmeSummary => _get('readmeSummary');
  String get description => _get('description');
  String get japaneseSummary => _get('japaneseSummary');
  String get viewOnGitHub => _get('viewOnGitHub');
  String get noDescriptionAvailable => _get('noDescriptionAvailable');
  String get translationFailed => _get('translationFailed');
  String get translationUnavailable => _get('translationUnavailable');
  String get summaryUnavailable => _get('summaryUnavailable');
  String get retry => _get('retry');
  String get couldNotOpenUrl => _get('couldNotOpenUrl');
  String get addBookmark => _get('addBookmark');
  String get removeBookmark => _get('removeBookmark');

  String _get(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues[AppLocale.en]![key]!;
  }

  static const Map<AppLocale, Map<String, String>> _localizedValues = {
    AppLocale.ja: {
      'appTitle': 'GitTrend JP',
      'today': '今日',
      'weekly': '週間',
      'monthly': '月間',
      'japanese': '日本語',
      'todaysTrending': '今日のトレンド',
      'thisWeek': '今週のトレンド',
      'thisMonth': '今月のトレンド',
      'japaneseRepos': '日本語リポジトリ',
      'noJapaneseRepos': '日本語リポジトリが見つかりません',
      'savedRepositories': '保存済みリポジトリ',
      'noSavedRepositories': '保存済みリポジトリはありません',
      'tapToSave': 'ブックマークアイコンをタップして保存',
      'clearAll': 'すべて削除',
      'clearAllSaved': '保存を全て削除',
      'clearAllConfirm': '保存済みのリポジトリをすべて削除しますか？',
      'cancel': 'キャンセル',
      'clear': '削除',
      'settings': '設定',
      'notifications': '通知',
      'dailyTrendingAlert': 'デイリートレンド通知',
      'dailyTrendingAlertDesc': 'トレンドリポジトリを通知',
      'notificationTime': '通知時刻',
      'japaneseReposOnly': '日本語リポジトリのみ',
      'japaneseReposOnlyDesc': '日本語リポジトリのみ通知',
      'filters': 'フィルター',
      'defaultLanguage': 'デフォルト言語',
      'minimumStars': '最小スター数',
      'about': 'アプリについて',
      'version': 'バージョン',
      'privacyPolicy': 'プライバシーポリシー',
      'termsOfService': '利用規約',
      'language': '言語',
      'languageJapanese': 'JA',
      'languageEnglish': 'EN',
      'all': 'すべて',
      'newLabel': 'NEW',
      'stars': '{count}',
      'starsToday': '+{count} 今日',
      'loading': '読み込み中...',
      'readmeSummary': 'README 要約',
      'description': '説明',
      'japaneseSummary': '日本語要約',
      'viewOnGitHub': 'GitHubで見る',
      'noDescriptionAvailable': '説明がありません',
      'translationFailed': '翻訳の取得に失敗しました',
      'translationUnavailable': '翻訳が利用できません',
      'summaryUnavailable': '要約が利用できません',
      'retry': '再試行',
      'couldNotOpenUrl': 'URLを開けませんでした',
      'addBookmark': 'ブックマークに追加',
      'removeBookmark': 'ブックマークを解除',
    },
    AppLocale.en: {
      'appTitle': 'GitTrend JP',
      'today': 'Today',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'japanese': 'Japanese',
      'todaysTrending': "Today's Trending",
      'thisWeek': 'This Week',
      'thisMonth': 'This Month',
      'japaneseRepos': 'Japanese Repos',
      'noJapaneseRepos': 'No Japanese repos found',
      'savedRepositories': 'Saved Repositories',
      'noSavedRepositories': 'No saved repositories',
      'tapToSave': 'Tap the bookmark icon to save repos',
      'clearAll': 'Clear All',
      'clearAllSaved': 'Clear All Saved',
      'clearAllConfirm': 'Are you sure you want to remove all saved repositories?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'dailyTrendingAlert': 'Daily Trending Alert',
      'dailyTrendingAlertDesc': 'Get notified about trending repos',
      'notificationTime': 'Notification Time',
      'japaneseReposOnly': 'Japanese Repos Only',
      'japaneseReposOnlyDesc': 'Only notify for Japanese repos',
      'filters': 'Filters',
      'defaultLanguage': 'Default Language',
      'minimumStars': 'Minimum Stars',
      'about': 'About',
      'version': 'Version',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'language': 'Language',
      'languageJapanese': '日本語',
      'languageEnglish': 'English',
      'all': 'All',
      'newLabel': 'NEW',
      'stars': '{count}',
      'starsToday': '+{count} today',
      'loading': 'Loading...',
      'readmeSummary': 'README Summary',
      'description': 'Description',
      'japaneseSummary': 'Japanese Summary',
      'viewOnGitHub': 'View on GitHub',
      'noDescriptionAvailable': 'No description available',
      'translationFailed': 'Failed to load translation',
      'translationUnavailable': 'Translation unavailable',
      'summaryUnavailable': 'Summary unavailable',
      'retry': 'Retry',
      'couldNotOpenUrl': 'Could not open URL',
      'addBookmark': 'Add bookmark',
      'removeBookmark': 'Remove bookmark',
    },
  };
}

extension LocalizationsExtension on WidgetRef {
  AppLocalizations get l10n => AppLocalizations(watch(localeProvider));
}
