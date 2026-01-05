# GitTrend JP - 技術仕様書

**バージョン**: 1.0.0  
**作成日**: 2026-01-05  
**ステータス**: 設計中

---

## 1. プロダクト概要

| 項目 | 内容 |
|------|------|
| **アプリ名** | GitTrend JP |
| **コンセプト** | 日本人開発者向けGitHubトレンド毎日配信アプリ |
| **プラットフォーム** | Android（Google Play）→ 将来iOS対応 |
| **デザインテーマ** | Ocean Breeze（ティール×ブルー・ライトモード） |

### 1.1 解決する課題

- GitHub Trendingは英語圏向け、日本語リポジトリが見つけにくい
- 毎日手動でTrendingをチェックするのが面倒
- 日本発OSSの情報がまとまっていない

### 1.2 ターゲットユーザー

| ペルソナ | 特徴 |
|---------|------|
| 日本人エンジニア | 日本語READMEのリポジトリを探したい |
| OSS初心者 | 何がトレンドか分からない、キュレーションが欲しい |
| 朝のルーティン派 | 毎朝5分で技術トレンドをキャッチしたい |
| 日本発OSS応援者 | LINE/Yahoo/CyberAgent等の日本企業OSSを追いたい |

---

## 2. 技術スタック

### 2.1 フロントエンド

| 技術 | バージョン | 用途 |
|------|-----------|------|
| **Flutter** | 3.x | UIフレームワーク |
| **Dart** | 3.x | プログラミング言語 |
| **Riverpod** | 2.x | 状態管理 |
| **go_router** | - | ルーティング |
| **dio** | - | HTTP通信 |
| **hive** | - | ローカルDB（お気に入り保存） |
| **flutter_local_notifications** | - | ローカル通知 |

### 2.2 バックエンド/インフラ

| 技術 | 用途 |
|------|------|
| **GitHub API v4 (GraphQL)** | トレンドデータ取得 |
| **Firebase Cloud Messaging** | プッシュ通知 |
| **Firebase Analytics** | 利用状況分析 |
| **Cloud Functions** | 定期実行（トレンド収集） |
| **Skills定期実行** | 毎朝のデータ収集・キュレーション |

### 2.3 開発ツール

| ツール | 用途 |
|--------|------|
| **VS Code** | エディタ |
| **Android Studio** | エミュレータ/ビルド |
| **Figma** | デザイン |
| **GitHub Actions** | CI/CD |

---

## 3. デザインシステム

### 3.1 カラーパレット（Ocean Breeze）

```dart
// Primary Colors
static const Color primary = Color(0xFF0EA5E9);      // Sky 500
static const Color primaryDark = Color(0xFF0284C7);  // Sky 600
static const Color secondary = Color(0xFF14B8A6);    // Teal 500

// Background
static const Color background = Color(0xFFF8FAFC);   // Slate 50
static const Color surface = Color(0xFFFFFFFF);      // White
static const Color cardBorder = Color(0xFFE2E8F0);   // Slate 200

// Text
static const Color textPrimary = Color(0xFF1E293B);  // Slate 800
static const Color textSecondary = Color(0xFF64748B); // Slate 500

// Accent
static const Color star = Color(0xFFF59E0B);         // Amber 500
static const Color success = Color(0xFF22C55E);      // Green 500
static const Color error = Color(0xFFEF4444);        // Red 500

// Gradient
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### 3.2 タイポグラフィ

```dart
// Font Family: System Default (San Francisco / Roboto)

// Heading
static const TextStyle h1 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: textPrimary,
);

// Subtitle
static const TextStyle subtitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

// Body
static const TextStyle body = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: textSecondary,
  height: 1.5,
);

// Caption
static const TextStyle caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: textSecondary,
);
```

### 3.3 コンポーネント

| コンポーネント | スタイル |
|--------------|---------|
| Card | border-radius: 16px, border: 1px solid cardBorder, shadow: 0 2px 8px rgba(0,0,0,0.06) |
| Button | border-radius: 12px, height: 48px |
| Tag | border-radius: 20px, padding: 6px 12px |
| Tab | active: primary color + bottom border 2px |
| Bottom Nav | height: 80px, padding-bottom: 20px (safe area) |

---

## 4. 画面設計

### 4.1 画面一覧

```
App
├── SplashScreen（起動画面）
├── MainScreen（メイン）
│   ├── HomeTab（トレンド一覧）
│   │   ├── TodayTab
│   │   ├── WeeklyTab
│   │   └── JapaneseTab
│   ├── SearchTab（検索）※v1.1
│   ├── SavedTab（お気に入り）
│   └── SettingsTab（設定）
└── RepositoryDetailScreen（リポジトリ詳細）※v1.1
```

### 4.2 HomeTab（トレンド一覧）

```
┌─────────────────────────────────────┐
│ 9:41                            5G  │ Status Bar
├─────────────────────────────────────┤
│ GitTrend JP              [🔔] [👤]  │ App Bar
├─────────────────────────────────────┤
│ [Today] [Weekly] [Japanese]         │ Tab Bar
├─────────────────────────────────────┤
│ ▌Today's Trending         [NEW]     │ Section Title
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ openai/whisper-jp      ★ 2,847 │ │ Repository Card
│ │ Japanese-optimized speech...   │ │
│ │ [Python] [AI] [Speech]         │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ vercel/next-intl       ★ 1,523 │ │
│ │ Internationalization for...    │ │
│ │ [TypeScript] [i18n] [Next.js]  │ │
│ └─────────────────────────────────┘ │
│ ...                                 │
├─────────────────────────────────────┤
│ [Home] [Search] [Saved] [Settings]  │ Bottom Nav
└─────────────────────────────────────┘
```

### 4.3 SavedTab（お気に入り）

```
┌─────────────────────────────────────┐
│ Saved Repositories          [Edit]  │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [★] line/armeria       ★ 4,201 │ │
│ │ Your go-to microservice...     │ │
│ │ [Java] [Microservices]    [×]  │ │
│ └─────────────────────────────────┘ │
│ ...                                 │
└─────────────────────────────────────┘
```

### 4.4 SettingsTab（設定）

```
┌─────────────────────────────────────┐
│ Settings                            │
├─────────────────────────────────────┤
│ Notifications                       │
│ ├── Daily Trending Alert    [ON]    │
│ ├── Notification Time     [08:00]   │
│ └── Include Japanese Only   [OFF]   │
├─────────────────────────────────────┤
│ Filters                             │
│ ├── Default Language      [All]     │
│ └── Minimum Stars         [100]     │
├─────────────────────────────────────┤
│ About                               │
│ ├── Version               1.0.0     │
│ ├── Privacy Policy              →   │
│ └── Terms of Service            →   │
└─────────────────────────────────────┘
```

---

## 5. データモデル

### 5.1 Repository

```dart
@freezed
class Repository with _$Repository {
  const factory Repository({
    required String id,              // "owner/repo"
    required String name,            // "whisper-jp"
    required String fullName,        // "openai/whisper-jp"
    required String owner,           // "openai"
    required String description,     // 説明文
    required int stars,              // 2847
    required int starsToday,         // 今日の増加数 (+123)
    required int forks,
    required String language,        // "Python"
    required String? languageColor,  // "#3572A5"
    required bool hasJapaneseReadme, // 日本語README有無
    required String url,             // GitHub URL
    required DateTime updatedAt,
  }) = _Repository;

  factory Repository.fromJson(Map<String, dynamic> json) =>
      _$RepositoryFromJson(json);
}
```

### 5.2 SavedRepository（ローカル保存）

```dart
@HiveType(typeId: 0)
class SavedRepository extends HiveObject {
  @HiveField(0)
  final String repositoryId;  // "owner/repo"

  @HiveField(1)
  final DateTime savedAt;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final int? stars;

  @HiveField(5)
  final String? language;

  SavedRepository({
    required this.repositoryId,
    required this.savedAt,
    this.name,
    this.description,
    this.stars,
    this.language,
  });
}
```

### 5.3 AppSettings（設定）

```dart
@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool notificationEnabled;

  @HiveField(1)
  int notificationHour;  // 0-23

  @HiveField(2)
  int notificationMinute;  // 0-59

  @HiveField(3)
  String? defaultLanguageFilter;

  @HiveField(4)
  int minimumStars;

  @HiveField(5)
  bool japaneseOnlyNotification;

  AppSettings({
    this.notificationEnabled = true,
    this.notificationHour = 8,
    this.notificationMinute = 0,
    this.defaultLanguageFilter,
    this.minimumStars = 100,
    this.japaneseOnlyNotification = false,
  });
}
```

---

## 6. API仕様

### 6.1 GitHub Trending取得

GitHub公式APIにはTrendingエンドポイントがないため、以下の方法で取得:

**方法1: github-trending-api（非公式）**
```
GET https://api.gitterapp.com/repositories
?language=python
&since=daily
```

**方法2: GitHub GraphQL + スクレイピング**
```graphql
query TrendingRepositories($query: String!) {
  search(query: $query, type: REPOSITORY, first: 30) {
    nodes {
      ... on Repository {
        nameWithOwner
        description
        stargazerCount
        forkCount
        primaryLanguage {
          name
          color
        }
        url
        updatedAt
      }
    }
  }
}
```

**方法3: Skills定期実行でキュレーション**
- 毎朝6:00にGitHub Trendingをスクレイピング
- 日本語README判定を実行
- 結果をJSON/Firestoreに保存
- アプリはキャッシュされたデータを取得

### 6.2 日本語README判定

```dart
Future<bool> hasJapaneseReadme(String owner, String repo) async {
  final readme = await githubApi.getReadme(owner, repo);
  if (readme == null) return false;
  
  // 日本語文字（ひらがな・カタカナ・漢字）を含むか判定
  final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');
  return japaneseRegex.hasMatch(readme);
}
```

---

## 7. 状態管理（Riverpod）

### 7.1 Provider構成

```dart
// リポジトリ一覧
final trendingRepositoriesProvider = FutureProvider.family<List<Repository>, TrendingFilter>((ref, filter) async {
  final api = ref.watch(githubApiProvider);
  return api.getTrending(filter);
});

// お気に入り
final savedRepositoriesProvider = StateNotifierProvider<SavedRepositoriesNotifier, List<SavedRepository>>((ref) {
  return SavedRepositoriesNotifier();
});

// 設定
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

// 選択中のタブ
final selectedTabProvider = StateProvider<TrendingTab>((ref) => TrendingTab.today);
```

---

## 8. ディレクトリ構成

```
gittrend_jp/
├── android/                    # Android設定
├── ios/                        # iOS設定（将来用）
├── lib/
│   ├── main.dart              # エントリーポイント
│   ├── app.dart               # App Widget
│   ├── core/
│   │   ├── constants/         # 定数
│   │   ├── theme/             # テーマ・カラー
│   │   ├── utils/             # ユーティリティ
│   │   └── extensions/        # 拡張メソッド
│   ├── data/
│   │   ├── models/            # データモデル
│   │   ├── repositories/      # リポジトリ層
│   │   ├── datasources/       # API・ローカルDB
│   │   └── providers/         # Riverpod Provider
│   ├── presentation/
│   │   ├── screens/           # 画面
│   │   │   ├── home/
│   │   │   ├── saved/
│   │   │   └── settings/
│   │   ├── widgets/           # 共通Widget
│   │   └── router/            # ルーティング
│   └── services/
│       ├── notification_service.dart
│       └── analytics_service.dart
├── test/                       # テスト
├── pubspec.yaml               # 依存関係
└── README.md
```

---

## 9. MVP機能一覧

### 9.1 v1.0（MVP）

| # | 機能 | 画面 | 優先度 |
|---|------|------|:------:|
| F1 | トレンド一覧表示 | Home | 必須 |
| F2 | 日本語フィルター | Home (Japanese Tab) | 必須 |
| F3 | 言語フィルター | Home | 必須 |
| F4 | お気に入り保存 | Home / Saved | 必須 |
| F5 | GitHub連携（外部ブラウザ） | Home / Saved | 必須 |
| F6 | プッシュ通知（毎朝8時） | - | 必須 |
| F7 | 通知設定 | Settings | 必須 |

### 9.2 v1.1（追加機能）

| # | 機能 | 優先度 |
|---|------|:------:|
| F8 | 日本企業タブ | 高 |
| F9 | 検索機能 | 中 |
| F10 | ダークモード | 中 |
| F11 | スター履歴グラフ | 低 |
| F12 | ホーム画面ウィジェット | 低 |

---

## 10. 非機能要件

| 項目 | 要件 |
|------|------|
| **レスポンス** | 一覧表示 < 2秒 |
| **オフライン** | 最後に取得したデータをキャッシュ表示 |
| **対応OS** | Android 8.0+ (API 26+) |
| **対応画面** | 360dp〜 |
| **言語** | 日本語UI |
| **アクセシビリティ** | TalkBack対応、コントラスト比4.5:1以上 |

---

## 11. リリース計画

| フェーズ | 期間 | 内容 |
|---------|------|------|
| Phase 1 | Week 1-2 | 環境構築、基本UI実装 |
| Phase 2 | Week 3-4 | API連携、お気に入り機能 |
| Phase 3 | Week 5 | プッシュ通知、Settings |
| Phase 4 | Week 6 | テスト、バグ修正、Google Play申請 |

---

## 12. 参考リソース

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [Material Design 3](https://m3.material.io/)

---

## 13. セキュリティ要件

### 13.1 システムアーキテクチャ（セキュリティ観点）

```
┌─────────────────┐      HTTPS       ┌──────────────────────┐
│   Flutter App   │ ───────────────→ │   Cloud Functions    │
│   (Frontend)    │                  │     (Backend)        │
└─────────────────┘                  └──────────────────────┘
        │                                      │
        │                                      │ GitHub API Token
        ↓                                      │ (Secret Manager)
┌─────────────────┐                           ↓
│   Hive (Local)  │                  ┌──────────────────────┐
│  - Favorites    │                  │     GitHub API       │
│  - Settings     │                  │     (GraphQL)        │
└─────────────────┘                  └──────────────────────┘
        │                                      │
        │                                      ↓
        │                            ┌──────────────────────┐
        │                            │     Firestore        │
        │                            │  (Trending Cache)    │
        └───────────────────────────→└──────────────────────┘
```

**設計原則:**
- GitHub API Tokenはバックエンド(Cloud Functions)のみで管理
- フロントエンドにはシークレットを一切埋め込まない
- トレンドデータはFirestoreにキャッシュし、APIコール削減

### 13.2 認証・認可

| 項目 | 要件 | 実装方法 |
|------|------|---------|
| GitHub API認証 | Cloud Functions経由 | Secret Managerでトークン管理 |
| ユーザー認証 | v1.0では不要（匿名利用） | - |
| FCM認証 | Firebaseプロジェクト設定 | google-services.json |
| API呼び出し認証 | なし（公開API） | レート制限で保護 |

### 13.3 データ保護

| データ | 保存場所 | 暗号化 | 理由 |
|--------|---------|:------:|------|
| トレンドデータ | Firestore | TLS転送時 | 公開情報、保存時暗号化不要 |
| お気に入り | Hive (ローカル) | なし | 機密性低、ユーザー端末内のみ |
| 通知設定 | Hive (ローカル) | なし | 機密性低 |
| GitHub Token | Secret Manager | あり | 漏洩防止必須 |
| FCMトークン | Firebase管理 | Firebase側 | Firebase標準 |

### 13.4 通信セキュリティ

| 項目 | 要件 |
|------|------|
| プロトコル | HTTPS必須（TLS 1.2以上） |
| 証明書ピンニング | v1.0では不要（Firebase/GitHub信頼） |
| APIエンドポイント | Cloud Functions URL（HTTPS） |

### 13.5 アプリ保護

| 項目 | 要件 | 実装方法 |
|------|------|---------|
| コード難読化 | 有効 | ProGuard/R8（release build） |
| デバッグビルド | リリース時無効 | flutter build --release |
| ログ出力 | リリース時無効 | kReleaseMode分岐 |
| ルート検知 | v1.0では不要 | 将来検討 |

```dart
// ログ出力の制御例
void log(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
```

### 13.6 レート制限・DoS対策

| 対象 | 制限 | 実装場所 |
|------|------|---------|
| GitHub API | 5,000 req/hour | Cloud Functions側 |
| Cloud Functions | Firebase標準制限 | Firebase設定 |
| アプリ→Backend | クライアント側スロットリング | dio interceptor |

```dart
// クライアント側スロットリング
class RateLimitInterceptor extends Interceptor {
  final _lastRequest = <String, DateTime>{};
  final Duration minInterval = Duration(seconds: 1);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = options.path;
    final last = _lastRequest[key];
    
    if (last != null && DateTime.now().difference(last) < minInterval) {
      handler.reject(DioException(
        requestOptions: options,
        error: 'Rate limited',
      ));
      return;
    }
    
    _lastRequest[key] = DateTime.now();
    handler.next(options);
  }
}
```

### 13.7 プライバシー要件

| 項目 | 要件 |
|------|------|
| 収集データ | お気に入りリスト（端末ローカルのみ、サーバー送信なし） |
| 分析データ | Firebase Analytics（匿名化、オプトアウト可能） |
| 広告ID | v1.0では使用しない |
| 位置情報 | 使用しない |
| 連絡先・カメラ等 | 使用しない |

### 13.8 Google Play要件対応

| 要件 | 対応 |
|------|------|
| プライバシーポリシー | 必須（URL設置） |
| データセーフティセクション | 記入必須 |
| ターゲットAPI | Android 14 (API 34) 以上 |
| パーミッション | INTERNET, POST_NOTIFICATIONS のみ |

### 13.9 シークレット管理

```yaml
# 環境別設定（.env は .gitignore に追加）

# 開発環境 (.env.development)
API_BASE_URL=https://us-central1-gittrend-jp-dev.cloudfunctions.net

# 本番環境 (.env.production)
API_BASE_URL=https://us-central1-gittrend-jp.cloudfunctions.net

# GitHub Token（Cloud Functions側のみ、Secret Manager使用）
# アプリ側には一切含めない
```

```dart
// flutter_dotenv で環境変数読み込み
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
```

### 13.10 セキュリティチェックリスト（リリース前）

- [ ] GitHub TokenがAPKに含まれていないこと確認
- [ ] ProGuard/R8が有効であること確認
- [ ] HTTPSのみ使用していること確認
- [ ] デバッグログが出力されないこと確認
- [ ] google-services.json が正しいプロジェクトであること確認
- [ ] プライバシーポリシーURLが有効であること確認
- [ ] Firebase Security Rulesが適切に設定されていること確認

---

## 14. Backend API仕様

### 14.1 エンドポイント一覧

| Method | Path | 説明 |
|--------|------|------|
| GET | /api/v1/trending | トレンドリポジトリ取得 |
| GET | /api/v1/trending/japanese | 日本語リポジトリのみ取得 |
| GET | /api/v1/languages | 言語一覧取得 |

### 14.2 GET /api/v1/trending

**Request:**
```
GET /api/v1/trending?since=daily&language=python&limit=30
```

| Param | Type | Required | Default | Description |
|-------|------|:--------:|---------|-------------|
| since | string | No | daily | daily / weekly / monthly |
| language | string | No | all | 言語フィルター |
| limit | int | No | 30 | 取得件数 (max: 100) |

**Response:**
```json
{
  "success": true,
  "data": {
    "repositories": [
      {
        "id": "openai/whisper-jp",
        "name": "whisper-jp",
        "fullName": "openai/whisper-jp",
        "owner": "openai",
        "description": "Japanese-optimized speech recognition",
        "stars": 2847,
        "starsToday": 123,
        "forks": 456,
        "language": "Python",
        "languageColor": "#3572A5",
        "hasJapaneseReadme": true,
        "url": "https://github.com/openai/whisper-jp",
        "updatedAt": "2026-01-05T00:00:00Z"
      }
    ],
    "updatedAt": "2026-01-05T06:00:00Z"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests. Please try again later."
  }
}
```

### 14.3 Cloud Functions実装概要

```typescript
// functions/src/trending.ts
import * as functions from 'firebase-functions';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

const secretClient = new SecretManagerServiceClient();

async function getGitHubToken(): Promise<string> {
  const [version] = await secretClient.accessSecretVersion({
    name: 'projects/gittrend-jp/secrets/github-token/versions/latest',
  });
  return version.payload?.data?.toString() || '';
}

export const getTrending = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set('Access-Control-Allow-Origin', '*');
  
  const { since = 'daily', language, limit = 30 } = req.query;
  
  // Firestoreキャッシュ確認
  const cache = await checkCache(since, language);
  if (cache && !isStale(cache.updatedAt)) {
    return res.json({ success: true, data: cache });
  }
  
  // GitHub API呼び出し
  const token = await getGitHubToken();
  const repositories = await fetchTrending(token, { since, language, limit });
  
  // キャッシュ更新
  await updateCache(since, language, repositories);
  
  return res.json({ success: true, data: { repositories, updatedAt: new Date() } });
});
```

---

*最終更新: 2026-01-05*
