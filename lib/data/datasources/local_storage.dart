import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/saved_repository.dart';
import '../models/app_settings.dart';

class LocalStorage {
  static const String _savedReposBoxName = 'saved_repositories';
  static const String _settingsBoxName = 'app_settings';
  static const String _userBoxName = 'user_data';
  static const String _settingsKey = 'settings';
  static const String _userIdKey = 'user_id';

  Box<SavedRepository>? get _savedReposBox {
    try {
      return Hive.box<SavedRepository>(_savedReposBoxName);
    } catch (e) {
      return null;
    }
  }

  Box<AppSettings>? get _settingsBox {
    try {
      return Hive.box<AppSettings>(_settingsBoxName);
    } catch (e) {
      return null;
    }
  }

  Box<String>? get _userBox {
    try {
      return Hive.box<String>(_userBoxName);
    } catch (e) {
      return null;
    }
  }

  String? getUserId() {
    try {
      return _userBox?.get(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _userBox?.put(_userIdKey, userId);
    } catch (e) {
      // Silently fail - non-critical operation
    }
  }

  List<SavedRepository> getSavedRepositories() {
    try {
      return _savedReposBox?.values.toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRepository(SavedRepository repo) async {
    try {
      await _savedReposBox?.put(repo.repositoryId, repo);
    } catch (e) {
      // Silently fail - will be retried on next sync
    }
  }

  Future<void> removeRepository(String repositoryId) async {
    try {
      await _savedReposBox?.delete(repositoryId);
    } catch (e) {
      // Silently fail - will be retried on next sync
    }
  }

  bool isRepositorySaved(String repositoryId) {
    try {
      return _savedReposBox?.containsKey(repositoryId) ?? false;
    } catch (e) {
      return false;
    }
  }

  AppSettings getSettings() {
    try {
      return _settingsBox?.get(_settingsKey) ?? AppSettings();
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _settingsBox?.put(_settingsKey, settings);
    } catch (e) {
      // Silently fail - settings will use defaults
    }
  }
}
