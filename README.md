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

## 重要な注意事項

### バージョン更新時のチェックリスト

1. **pubspec.yaml**: `version: X.X.X+Y` を更新
2. **settings_screen.dart**: `value: 'X.X.X'` のバージョン表示も手動更新が必要
3. **ビルド番号(+Y)**: Google Playは前回より大きい数値が必要

### ローカル環境の注意

- **Flutter SDKがPATHに設定されていない**: Android StudioのGUIビルドまたはGitHub Actionsを使用
- **Android StudioのBuildメニューがグレーアウト**: Flutter Pluginが未設定の可能性。GitHub Actionsでビルド推奨

### Closed Test (テスター配布)

1. Google Groups: https://groups.google.com/g/gittrend-jp-testers
2. テスター登録URL: https://play.google.com/apps/testing/com.gittrend.gittrend_jp
3. **重要**: テスターはPCブラウザでテスター登録 → その後スマホでダウンロード

### アイコン設定

- Adaptive Icon対応済み（Android 8.0+）
- アイコン変更時は `android/app/src/main/res/mipmap-*/` の全画像を更新

### Google Play Console リリース作成時の注意

- **旧バージョンのAABを削除する**: 新しいAABをアップロードする際、リリースに旧バージョンが残っているとエラーになる
- エラーメッセージ: 「このAPKは、バージョンコードがより高い1つ以上のAPKで完全にブロックされているため、ユーザーに配信されません」
- **対処法**: リリース作成画面で旧バージョンのAAB/APKを削除し、新バージョンのみを残す

### GitHub Actions ビルド後のAAB取得

- **ローカルの`release-artifacts/`フォルダは自動更新されない**: GitHub Actionsはリモートで実行されるため、ビルド成果物はGitHubのアーティファクトとして保存される
- **取得手順**:
  1. https://github.com/tenormusica2024/gittrend-jp/actions にアクセス
  2. 「Build Release AAB」（緑チェック）をクリック
  3. 下部の「Artifacts」から`release-aab`をダウンロード
  4. ZIPを解凍して`app-release.aab`を取得
- **注意**: ダウンロードしたZIP内のファイルのタイムスタンプがUTC表示になる場合がある（日本時間より9時間前に見える）

### url_launcher（外部リンク）設定

- **Android 11以降**: `AndroidManifest.xml`に`<queries>`を追加しないと外部URLが開けない
- 設定場所: `android/app/src/main/AndroidManifest.xml`
- 必要な設定:
  ```xml
  <queries>
      <intent>
          <action android:name="android.intent.action.VIEW"/>
          <data android:scheme="https"/>
      </intent>
      <intent>
          <action android:name="android.intent.action.VIEW"/>
          <data android:scheme="http"/>
      </intent>
  </queries>
  ```

## セキュリティに関する注意事項（要対応）

### 現状の問題点

| 問題 | リスク | 深刻度 |
|------|--------|--------|
| APIサーバーに認証なし | 誰でもAPIを叩ける | 🟡 中 |
| APKからAPI URL取得可能 | 逆コンパイルで5分で発見される | 🟡 中 |
| レート制限が緩い | DDoS攻撃でCloud Run課金爆発 | 🔴 高 |
| userIdが推測可能 | 他人のブックマークにアクセスされる可能性 | 🟡 中 |

### 推奨対策（優先度順）

1. **Firebase App Check 導入**（優先度: 高）
   - 正規アプリからのリクエストのみ許可
   - 不正なAPIアクセスをブロック

2. **Cloud Run レート制限強化**（優先度: 高）
   - IP単位でのリクエスト制限
   - Cloud Armor の導入検討

3. **ユーザー認証の必須化**（優先度: 中）
   - Firebase Auth のトークン検証をAPI側で実施
   - 匿名ユーザーでもFirebase Auth経由にする

4. **userIdの安全化**（優先度: 中）
   - Firebase Auth のUID（推測困難なUUID形式）を使用
   - 現状のuserIdが推測可能な形式なら変更

5. **コード難読化**（優先度: 低）
   - ProGuard/R8 の設定強化
   - API URLの難読化（根本解決にはならない）

### 現状で許容できる理由

- トレンドデータは元々公開情報（GitHubから誰でも取得可能）
- 個人情報は保存していない
- ブックマークは機密性の低いデータ
- テスト段階でユーザー数が限定的
