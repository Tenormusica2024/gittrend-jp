# GitTrend\n\n![Test Deployment](https://img.shields.io/badge/Status-Verified-brightgreen)\n JP

日本人開発者向けGitHubトレンド毎日配信アプリ

![Design Mockup](docs/design_mockup.png)

## 概要

GitTrend JPは、GitHubのトレンドリポジトリを日本人開発者向けにキュレーションして毎日配信するモバイルアプリです。

### 特徴

- 日本語READMEがあるリポジトリをフィルタリング
- 毎朝8時にプッシュ通知でトレンドをお届け
- お気に入り保存でチェックしたいリポジトリを管理
- LINE/Yahoo/CyberAgent等の日本企業OSSを追跡

## 技術スタック

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Local DB**: Hive
- **API**: GitHub GraphQL API
- **Notifications**: Firebase Cloud Messaging

## ドキュメント

- [技術仕様書](docs/SPECIFICATION.md)
- [トラブルシューティング](docs/TROUBLESHOOTING.md)

## 開発

```bash
# 依存関係インストール
flutter pub get

# 開発サーバー起動
flutter run

# ローカルビルド
flutter build apk --release
flutter build web --release
```

## デプロイ

### Web (Vercel)

```bash
# Webビルド
flutter build web --release

# Vercelにデプロイ
npx vercel --prod --yes
```

**本番URL**: https://gittrend-jp.vercel.app/

### Android (Google Play Store)

GitHub Actionsで自動デプロイ。タグをプッシュするとトリガーされる。

```bash
# 1. pubspec.yamlのバージョンを更新
# version: 1.0.X+Y

# 2. コミット
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.X+Y"

# 3. タグ作成＆プッシュ
git tag -a v1.0.X -m "Release v1.0.X: 変更内容"
git push && git push origin v1.0.X
```

**GitHub Actions確認**:
```bash
gh run list --repo Tenormusica2024/gittrend-jp --limit 3
```

**必要なGitHub Secrets**:
- `KEYSTORE_BASE64` - キーストアのBase64エンコード
- `KEY_STORE_PASSWORD` - キーストアパスワード
- `KEY_PASSWORD` - キーパスワード
- `KEY_ALIAS` - キーエイリアス
- `PLAY_STORE_SERVICE_ACCOUNT_JSON` - Play Store APIサービスアカウント

## ライセンス

MIT License

---

*Created: 2026-01-05*
