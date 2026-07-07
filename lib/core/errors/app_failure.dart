class AppFailure implements Exception {
  const AppFailure({
    required this.message,
    this.code,
    this.statusCode,
    this.cause,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'AppFailure($statusCode, $code, $message)';
}
