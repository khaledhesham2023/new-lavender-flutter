sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  final String message;
  const ApiSuccess(this.data, {this.message = ''});
}

sealed class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure();

  /// Same failure, typed as another result so a repository can forward it.
  ApiFailure<R> cast<R>();
}

final class ServerFailure<T> extends ApiFailure<T> {
  final int code;
  final String message;
  const ServerFailure(this.code, this.message);

  @override
  ApiFailure<R> cast<R>() => ServerFailure<R>(code, message);
}

final class NetworkFailure<T> extends ApiFailure<T> {
  const NetworkFailure();

  @override
  ApiFailure<R> cast<R>() => NetworkFailure<R>();
}

final class UnknownFailure<T> extends ApiFailure<T> {
  final String message;
  const UnknownFailure([this.message = '']);

  @override
  ApiFailure<R> cast<R>() => UnknownFailure<R>(message);
}

enum ViewStatus { initial, loading, success, failure }
