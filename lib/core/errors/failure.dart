/// Domain-level failure representations for clean architecture return types.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred', String? code])
    : super(code: code);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([
    super.message = 'No internet connection',
    String? code,
  ]) : super(code: code);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', String? code])
    : super(code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Local cache access failed',
    String? code,
  ]) : super(code: code);
}
