/// API呼び出しの結果を表すResult型
/// 成功（データあり）、成功（データなし）、失敗を明確に区別できる
sealed class Result<T> {
  const Result();

  /// 成功時のデータを取得（失敗時はnull）
  T? get dataOrNull;

  /// 成功かどうか
  bool get isSuccess;

  /// 失敗かどうか
  bool get isFailure;

  /// 成功時の処理を実行
  Result<R> map<R>(R Function(T data) transform);

  /// 失敗時のデフォルト値を返す
  T getOrElse(T Function() defaultValue);
}

/// 成功（データあり）
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  T? get dataOrNull => data;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  Result<R> map<R>(R Function(T data) transform) => Success(transform(data));

  @override
  T getOrElse(T Function() defaultValue) => data;

  @override
  String toString() => 'Success($data)';
}

/// 失敗（エラー情報付き）
class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});

  @override
  T? get dataOrNull => null;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  Result<R> map<R>(R Function(T data) transform) =>
      Failure(message, error: error, stackTrace: stackTrace);

  @override
  T getOrElse(T Function() defaultValue) => defaultValue();

  @override
  String toString() => 'Failure($message)';
}
