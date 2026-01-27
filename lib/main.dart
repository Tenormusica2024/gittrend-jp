import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'app.dart';
import 'data/models/saved_repository.dart';
import 'data/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hiveInitialized = false;
  String? hiveError;
  String? initializedUserId;

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(SavedRepositoryAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    await Hive.openBox<SavedRepository>('saved_repositories');
    await Hive.openBox<AppSettings>('app_settings');
    final userBox = await Hive.openBox<String>('user_data');

    // userId初期化: 起動時に確実に保存（リトライ付き）
    initializedUserId = await _initializeUserId(userBox);

    hiveInitialized = true;
  } catch (e) {
    debugPrint('Hive initialization error: $e');
    hiveError = e.toString();
  }

  runApp(
    ProviderScope(
      overrides: [
        // main()で初期化したuserIdをProviderに注入
        if (initializedUserId != null)
          initializedUserIdProvider.overrideWithValue(initializedUserId),
      ],
      child: hiveInitialized
          ? const GitTrendApp()
          : _HiveErrorApp(error: hiveError),
    ),
  );
}

/// userId初期化: 既存のIDを取得、なければ新規生成して保存（リトライ付き）
Future<String> _initializeUserId(Box<String> userBox) async {
  const userIdKey = 'user_id';
  const maxRetries = 3;

  // 既存のuserIdを確認
  var userId = userBox.get(userIdKey);
  if (userId != null && userId.isNotEmpty) {
    debugPrint('UserId loaded: $userId');
    return userId;
  }

  // 新規生成してリトライ付きで保存
  userId = const Uuid().v4();
  for (var attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await userBox.put(userIdKey, userId);
      debugPrint('UserId created and saved: $userId (attempt $attempt)');
      return userId;
    } catch (e) {
      debugPrint('Failed to save userId (attempt $attempt): $e');
      if (attempt == maxRetries) {
        // 最終的に失敗しても、メモリ上のuserIdは返す（次回起動時に再試行）
        debugPrint('UserId save failed after $maxRetries attempts, using memory-only userId');
      }
      await Future.delayed(Duration(milliseconds: 100 * attempt));
    }
  }
  return userId;
}

/// main()から初期化されたuserIdを保持するProvider
final initializedUserIdProvider = Provider<String?>((ref) => null);

/// Hive初期化失敗時に表示するエラー画面
class _HiveErrorApp extends StatelessWidget {
  final String? error;
  const _HiveErrorApp({this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'データベースの初期化に失敗しました',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'アプリを再起動してください。問題が続く場合は、アプリを再インストールしてください。',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
