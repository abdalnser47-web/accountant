sealed class Result<T> {
  const Result();
  static Result<T> success<T>(T data) => _Success<T>(data);
  static Result<T> failure<T>(String message) => _Failure<T>(message);
}

final class _Success<T> extends Result<T> {
  final T data;
  const _Success(this.data);
}

final class _Failure<T> extends Result<T> {
  final String message;
  const _Failure(this.message);
}
