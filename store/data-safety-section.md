# Data Safety Section - Google Play Console設定ガイド

## 概要
Google Play Consoleの「Data safety」セクションで設定すべき項目のガイド。
GitTrend JPアプリが収集・共有するデータについての正確な申告が必要。

## 設定項目

### 1. Data collection（データ収集）
**Is any of the data collected by your app from users?**
- 回答: **Yes**

### 2. Data types collected（収集するデータの種類）

#### Device or other IDs（デバイスまたはその他のID）
- **収集する**: Yes
- **詳細**: 匿名UUID（アプリインストール時に生成）
- **目的**: ブックマーク同期のためのユーザー識別
- **共有**: サーバー（Firebase）に送信
- **暗号化**: Yes（HTTPS経由）
- **ユーザーは削除をリクエストできるか**: Yes（アプリ再インストールで新しいUUIDが生成）

#### App activity - App interactions（アプリアクティビティ - アプリ操作）
- **収集する**: Yes
- **詳細**: ブックマークしたリポジトリ情報
- **目的**: ユーザーのブックマーク機能提供
- **共有**: サーバー（Firebase）に送信
- **暗号化**: Yes（HTTPS経由）
- **必須/オプション**: オプション（ブックマーク機能を使わなければ送信されない）

### 3. Data sharing（データ共有）
**Is any of the data shared with third parties?**
- 回答: **No**
- 理由: データはFirebase（自社管理サーバー）にのみ保存され、第三者には共有しない

### 4. Security practices（セキュリティ対策）

#### Data is encrypted in transit（転送時の暗号化）
- 回答: **Yes**
- 詳細: すべてのAPI通信はHTTPS経由

#### Data can be deleted（データ削除）
- 回答: **Yes**
- 方法: アプリを再インストールすることで新しいUUIDが生成され、古いデータは孤立する

### 5. 収集しないデータ
以下のデータは収集しない：
- 位置情報
- 個人情報（名前、メールアドレス、電話番号など）
- 財務情報
- 健康・フィットネス情報
- メッセージ
- 写真・動画
- オーディオファイル
- ファイル・ドキュメント
- カレンダー
- 連絡先
- ウェブ閲覧履歴

## 申告時の注意点

1. **正直に申告する**: 実際に収集するデータのみを申告
2. **目的を明確に**: 各データの収集目的を明確に説明
3. **プライバシーポリシーとの整合性**: アプリ内プライバシーポリシーと矛盾しないこと
4. **更新を忘れずに**: 機能追加でデータ収集が変わったら更新

## Google Play Consoleでの設定手順

1. Google Play Console > アプリを選択
2. 「Policy」 > 「App content」
3. 「Data safety」セクションを選択
4. 上記の項目に従って回答
5. 保存して審査を待つ

## 関連ファイル
- `web/privacy-policy.html` - アプリ内プライバシーポリシー
- `store/store-listing-ja.md` - ストア掲載情報
