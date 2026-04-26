# Quickstart from Fork

この文書は、`gittrend-jp` を **fork / clone した直後に最短で状態確認するための導線**。

目的:

1. Flutter アプリとして依存解決できる
2. ローカルで静的解析 / テストが通る
3. 必要ならその後に `flutter run` へ進める

---

## 前提

- Flutter SDK
- Dart SDK（Flutter 同梱）
- Android Studio or Android SDK（実機 / emulator で起動したい場合）

この repo は public だが、**Play Store 配布や署名の完全再現は quickstart の対象外**。

---

## 最短手順

### 1. clone

```bash
git clone https://github.com/Tenormusica2024/gittrend-jp.git
cd gittrend-jp
```

### 2. 依存関係を取得

```bash
flutter pub get
```

### 3. 静的解析

```bash
flutter analyze
```

### 4. テスト

```bash
flutter test
```

### 5. 必要なら起動

```bash
flutter run
```

---

## 最初に確認できれば十分なこと

- `pubspec.yaml` が解決できる
- Riverpod / Hive / router 周りの依存が壊れていない
- widget test が最低限通る
- ローカル開発に進める状態かどうかが分かる

---

## まだ quickstart に含めないもの

- keystore 設定
- Play Store 配布
- Firebase 本番運用設定
- release artifact の完全再現

これらは **ローカル起動が確認できた後** に見る。

---

## 詰まりやすい点

### 1. Flutter が入っていない

この repo 単体では解決できない。  
まず Flutter SDK を入れて `flutter doctor` を通す。

### 2. Android 配布設定を最初から再現しようとする

quickstart では不要。  
まず `flutter analyze` / `flutter test` / `flutter run` を優先する。

### 3. keystore / log / screenshot などの作業残骸を public artifact と誤解する

それらは本体機能ではなく、公開向け quickstart の主対象でもない。

---

## 次の段階

この quickstart が通ったら:

1. `docs/SPECIFICATION.md`
2. `docs/TROUBLESHOOTING.md`
3. `.github/workflows/`

の順に読むと理解しやすい。
