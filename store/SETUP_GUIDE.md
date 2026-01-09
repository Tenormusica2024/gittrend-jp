# GitTrend JP - Google Play Store 初回セットアップガイド

## 準備完了項目

| 項目 | 状態 | ファイル |
|------|------|----------|
| 署名キーストア | 完了 | `android/upload-keystore.jks` |
| AABファイル | 完了 | `release/release-aab/app-release.aab` |
| 512x512アイコン | 完了 | `web/icons/icon-512.png` |
| ストア掲載文(日本語) | 完了 | `store/store-listing-ja.md` |
| プライバシーポリシー | 完了 | https://gittrend-jp.vercel.app/privacy-policy.html |
| 利用規約 | 完了 | https://gittrend-jp.vercel.app/terms-of-service.html |
| 自動デプロイワークフロー | 完了 | `.github/workflows/deploy-playstore.yml` |

## 初回リリース手順（手動必須）

### 1. Google Play Consoleでアプリ作成

1. https://play.google.com/console にログイン
2. 「アプリを作成」をクリック
3. 以下を入力：
   - アプリ名: `GitTrend JP`
   - デフォルト言語: `日本語`
   - アプリまたはゲーム: `アプリ`
   - 無料または有料: `無料`

### 2. AABをアップロード

1. 「リリース」→「本番」→「新しいリリースを作成」
2. `release/release-aab/app-release.aab` をアップロード
3. リリースノートを入力（例：初回リリース）

### 3. ストア掲載情報を入力

`store/store-listing-ja.md` の内容をコピペ：
- 短い説明文（80文字以内）
- 詳しい説明文

### 4. グラフィック素材をアップロード

| 種類 | サイズ | ファイル |
|------|--------|----------|
| アプリアイコン | 512x512 | `web/icons/icon-512.png` |
| フィーチャーグラフィック | 1024x500 | （要作成） |
| スクリーンショット | 最低2枚 | （要作成） |

**スクリーンショット作成方法：**
- https://gittrend-jp.vercel.app をスマホで開く
- スクリーンショットを撮影（推奨サイズ: 1080x1920）

### 5. コンテンツのレーティング

質問に回答（暴力なし、ギャンブルなし等）

### 6. プライバシーポリシー設定

URL: `https://gittrend-jp.vercel.app/privacy-policy.html`

### 7. 審査に提出

---

## 次回以降の自動デプロイ設定

### サービスアカウント作成

1. Google Cloud Console → IAM → サービスアカウント作成
2. JSON キーをダウンロード
3. GitHub Secrets に `PLAY_STORE_SERVICE_ACCOUNT_JSON` として登録

### Play Console権限設定

1. Play Console → ユーザーと権限 → 新しいユーザーを招待
2. サービスアカウントのメールを追加
3. 「リリース管理」権限を付与

### 自動デプロイ

タグをプッシュするだけで自動的にPlay Storeにアップロード：

```bash
git tag v1.0.1
git push origin v1.0.1
```

これで `deploy-playstore.yml` ワークフローが起動し、
内部テストトラックに自動アップロードされます。
