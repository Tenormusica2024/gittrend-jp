# GitTrend JP

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

## 開発

```bash
# 依存関係インストール
flutter pub get

# 開発サーバー起動
flutter run

# ビルド
flutter build apk --release
```

## ライセンス

MIT License

---

*Created: 2026-01-05*
