# GitTrend JP トラブルシューティングガイド

## エラーハンドリングとデバッグ

### 1. 「Loading...」が表示され続ける問題

#### 症状
リポジトリカードで日本語説明が表示されず、「Loading...」のままになる。

#### 原因の特定フロー

```
Loading... 表示
    ↓
descriptionJa と summaryJa が両方 null
    ↓
原因は以下のいずれか:
  1. API呼び出し失敗 → モックデータにフォールバック
  2. Cloud Functions側でGemini API Key未設定
  3. Flutterホットリロードが正しく反映されていない
```

#### 診断手順

**Step 1: APIの直接確認**
```bash
curl -s "https://gettrending-z272xsgkhq-an.a.run.app?since=daily&limit=3&withSummary=true" | head -c 500
```

期待される結果:
- `descriptionJa` と `summaryJa` フィールドが含まれている
- 日本語テキストが返ってくる

**Step 2: Cloud Functions環境変数確認**
```bash
# functions/.env ファイルの存在確認
cat functions/.env

# 期待される内容
GEMINI_API_KEY=AIzaSy...（有効なAPIキー）
```

**Step 3: Flutter側のAPI URL確認**
`lib/data/datasources/github_api.dart` の以下の定数を確認:
```dart
static const String _baseUrl = 'https://gettrending-z272xsgkhq-an.a.run.app';
static const String _summaryUrl = 'https://getreposummary-z272xsgkhq-an.a.run.app';
```

**Step 4: ブラウザコンソールでCORSエラー確認**
- F12 → Console タブ
- `CORS policy` や `Access-Control-Allow-Origin` エラーがないか確認

#### 解決方法

| 原因 | 解決方法 |
|------|----------|
| API URL不一致 | `github_api.dart` のURLを正しいCloud Functions URLに修正 |
| GEMINI_API_KEY未設定 | `functions/.env` にキーを追加し、Cloud Functionsを再デプロイ |
| CORSエラー | Cloud Functions側のCORS設定を確認・修正 |
| ホットリロード問題 | Flutter完全再起動（Ctrl+C → `flutter run -d chrome`） |

---

### 2. Material Iconsが□（四角）で表示される問題

#### 症状
アイコンが正しく表示されず、□や文字化けになる。

#### 原因
- `flutter clean` 実行後のフォントキャッシュ破損
- `web/index.html` のフォント読み込み設定問題

#### 解決方法

```bash
# 1. Flutter完全クリーンビルド
flutter clean
flutter pub get
flutter run -d chrome

# 2. それでも直らない場合はgit resetで安定版に戻す
git checkout -- .
git clean -fd
flutter pub get
flutter run -d chrome
```

---

### 3. git reset後の注意事項

#### `git checkout -- .` と `git clean -fd` の影響範囲

| コマンド | 影響 |
|----------|------|
| `git checkout -- .` | 追跡されているファイルの変更を破棄 |
| `git clean -fd` | 追跡されていないファイル・ディレクトリを削除 |

#### 注意: `.gitignore` に含まれるファイルも削除される

以下のファイルは `.gitignore` で無視されているため、`git clean -fd` で削除される:

```
functions/.env          # ← GEMINI_API_KEYが消える！
.dart_tool/
build/
```

#### git reset後の必須復旧手順

```bash
# 1. functions/.env を再作成
echo "GEMINI_API_KEY=YOUR_API_KEY_HERE" > functions/.env

# 2. 依存関係の再インストール
flutter pub get
cd functions && npm install && cd ..

# 3. Flutter再起動
flutter run -d chrome
```

---

### 4. APIエラーハンドリングの仕組み

#### フォールバック動作 (`lib/data/datasources/github_api.dart`)

```dart
Future<List<Repository>> getTrending(...) async {
  try {
    final response = await _dio.get(_baseUrl, ...);
    // 正常時: APIからのデータを返す
    return data.map((json) => _parseRepository(json)).toList();
  } catch (e) {
    // エラー時: モックデータを返す
    print('[GitHubApi] getTrending error: $e');
    return _getMockData();  // ← descriptionJa/summaryJa は null
  }
}
```

#### モックデータの特徴
- `descriptionJa`: **常にnull**
- `summaryJa`: **常にnull**
- 結果: `repository_card.dart` で `isLoading = true` と判定される

```dart
// repository_card.dart:45
final isLoading = widget.descriptionJa == null && widget.summaryJa == null;
```

---

### 5. Cloud Functions デバッグ

#### ログ確認方法

```bash
# Firebase CLIでログ確認
firebase functions:log --project gittrend-jp-2026

# または Google Cloud Console
# https://console.cloud.google.com/logs?project=gittrend-jp-2026
```

#### よくあるエラー

| エラー | 原因 | 解決策 |
|--------|------|--------|
| `GEMINI_API_KEY not set` | 環境変数未設定 | `.env` ファイル作成 + 再デプロイ |
| `CORS error` | オリジン許可なし | Cloud Functions の CORS 設定を確認 |
| `429 Too Many Requests` | Gemini APIレート制限 | 待機してリトライ |

---

### 6. 開発時のベストプラクティス

1. **変更前にバックアップ**: 大きな変更前は `git stash` または新ブランチ作成
2. **`.env` ファイル管理**: ローカルに `.env.example` を作成し、必要な環境変数を文書化
3. **段階的テスト**: 変更ごとに動作確認、一度に多くの変更を入れない
4. **Flutter完全再起動**: ホットリロードで反映されない場合は完全再起動

---

## 2026-01-09 インシデント記録

### 発生事象
セキュリティ強化作業中に「Loading...」問題が発生

### 根本原因（確定）

**GitHub上のコードが古いCloud Functions URLを指していた**

```diff
# 古いURL（GitHub上のコード）
- https://asia-northeast1-yt-transcript-demo-2025.cloudfunctions.net/getTrending

# 正しいURL（実際のCloud Functions）
+ https://gettrending-z272xsgkhq-an.a.run.app
```

#### 問題の流れ
1. セキュリティ強化作業で複数の変更を実施
2. 問題発生 → `git checkout -- .` で「安定版」に戻そうとした
3. **しかしGitHub上のコードは古いAPI URLを持っていた**
4. 古いURLはCloud Functions Gen1形式で、実際のサービスはGen2（Cloud Run）に移行済み
5. API呼び出し失敗 → catchブロック → モックデータ → `descriptionJa`/`summaryJa`がnull → 「Loading...」表示

### なぜcurlでは成功したのか
```bash
# これは成功する（正しいURLを直接叩いている）
curl "https://gettrending-z272xsgkhq-an.a.run.app?since=daily&limit=3"
```

curlは正しいURLを叩いていたが、Flutterアプリは古いURL（GitHub版）を使っていた。

### 解決方法
1. `github_api.dart` のAPI URLを正しいCloud Run URLに修正
2. Flutter完全再起動

### 教訓
1. **Cloud Functions移行時はクライアント側のURLも更新が必要**
2. **GitHubにプッシュする前にAPI URLが最新か確認する**
3. **問題切り分け時は「API直接叩く」→「クライアントコード確認」の順で**
4. **`git checkout`で戻す前に、戻る先のコードが本当に「安定版」か確認する**

### 今後の対策
- API URLは環境変数または設定ファイルで管理を検討
- Cloud Functions移行時のチェックリストを作成
