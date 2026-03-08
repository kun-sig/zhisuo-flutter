class ApiException implements Exception {
  final int code;
  final String message;
  final int? httpStatus;
  final String? requestId;

  const ApiException({
    required this.code,
    required this.message,
    this.httpStatus,
    this.requestId,
  });

  @override
  String toString() {
    final req = requestId == null ? '' : ', requestId: $requestId';
    final hs = httpStatus == null ? '' : ', httpStatus: $httpStatus';
    return 'ApiException(code: $code$hs, message: $message$req)';
  }
}
