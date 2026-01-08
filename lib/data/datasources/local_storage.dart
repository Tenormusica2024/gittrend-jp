import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_repository.dart';
import '../models/app_settings.dart';

class LocalStorage {
  static const String _savedReposBoxName = 'saved_repositories';
  static const String _settingsBoxName = 'app_settings';
  static const String _userBoxName = 'user_data';
  static const String _settingsKey = 'settings';
  static const String _userIdKey = 'user_id';

  Box<SavedRepository> get _savedReposBox => Hive.box<SavedRepository>(_savedReposBoxName);
  Box<AppSettings> get _settingsBox => Hive.box<AppSettings>(_settingsBoxName);
  Box<String> get _userBox => Hive.box<String>(_userBoxName);

  String? getUserId() {
    return _userBox.get(_userIdKey);
  }

  Future<void> saveUserId(String userId) async {
    await _userBox.put(_userIdKey, userId);
  }

  List<SavedRepository> getSavedRepositories() {
    return _savedReposBox.values.toList();
  }

  Future<void> saveRepository(SavedRepository repo) async {
    await _savedReposBox.put(repo.repositoryId, repo);
  }

  Future<void> removeRepository(String repositoryId) async {
    await _savedReposBox.delete(repositoryId);
  }

  bool isRepositorySaved(String repositoryId) {
    return _savedReposBox.containsKey(repositoryId);
  }

  AppSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings);
  }
}
