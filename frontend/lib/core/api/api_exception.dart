/// 业务异常:code 非 0 时抛出。
class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException(this.code, this.message);

  bool get unauthorized => code == 40100;

  @override
  String toString() => 'ApiException($code): $message';
}
