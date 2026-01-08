import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/saved_repository.dart';
import 'data/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(SavedRepositoryAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  await Hive.openBox<SavedRepository>('saved_repositories');
  await Hive.openBox<AppSettings>('app_settings');
  await Hive.openBox<String>('user_data');
  
  runApp(
    const ProviderScope(
      child: GitTrendApp(),
    ),
  );
}
