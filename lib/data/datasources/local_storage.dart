import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/saved_repository.dart';
import '../models/app_settings.dart';
import '../../core/utils/logger.dart';

class LocalStorage {
  static const String _tag = 'LocalStorage';
  static const String _savedReposBoxName = 'saved_repositories';
  static const String _settingsBoxName = 'app_settings';
  static const String _userBoxName = 'user_data';
  static const String _settingsKey = 'settings';
  static const String _userIdKey = 'user_id';

  Box<SavedRepository>? get _savedReposBox {
    try {
      return Hive.box<SavedRepository>(_savedReposBoxName);
    } catch (e) {
      Logger.warning(_tag, 'Failed to get saved_repositories box', e);
      return null;
    }
  }

  Box<AppSettings>? get _settingsBox {
    try {
      return Hive.box<AppSettings>(_settingsBoxName);
    } catch (e) {
      Logger.warning(_tag, 'Failed to get app_settings box', e);
      return null;
    }
  }

  Box<String>? get _userBox {
    try {
      return Hive.box<String>(_userBoxName);
    } catch (e) {
      Logger.warning(_tag, 'Failed to get user_data box', e);
      return null;
    }
  }

  String? getUserId() {
    try {
      return _userBox?.get(_userIdKey);
    } catch (e) {
      Logger.warning(_tag, 'Failed to get userId', e);
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _userBox?.put(_userIdKey, userId);
    } catch (e) {
      Logger.warning(_tag, 'Failed to save userId', e);
    }
  }

  List<SavedRepository> getSavedRepositories() {
    try {
      return _savedReposBox?.values.toList() ?? [];
    } catch (e) {
      Logger.warning(_tag, 'Failed to get saved repositories', e);
      return [];
    }
  }

  Future<void> saveRepository(SavedRepository repo) async {
    try {
      await _savedReposBox?.put(repo.repositoryId, repo);
    } catch (e) {
      Logger.warning(_tag, 'Failed to save repository: ${repo.repositoryId}', e);
    }
  }

  Future<void> removeRepository(String repositoryId) async {
    try {
      await _savedReposBox?.delete(repositoryId);
    } catch (e) {
      Logger.warning(_tag, 'Failed to remove repository: $repositoryId', e);
    }
  }

  bool isRepositorySaved(String repositoryId) {
    try {
      return _savedReposBox?.containsKey(repositoryId) ?? false;
    } catch (e) {
      Logger.warning(_tag, 'Failed to check if repository is saved: $repositoryId', e);
      return false;
    }
  }

  AppSettings getSettings() {
    try {
      return _settingsBox?.get(_settingsKey) ?? AppSettings();
    } catch (e) {
      Logger.warning(_tag, 'Failed to get settings', e);
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      await _settingsBox?.put(_settingsKey, settings);
    } catch (e) {
      Logger.warning(_tag, 'Failed to save settings', e);
    }
  }
}
