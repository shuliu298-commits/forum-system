import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// 统一 API 客户端:
/// - 自动附加 Bearer Token
/// - 统一解析 ApiResponse,code != 0 抛 [ApiException]
/// - 40100 时触发 [unauthorizedHandler](由 App 注册:清登录态、跳登录页)
class ApiClient {
  /// 401 处理回调(在 main 中注册)
  static void Function()? unauthorizedHandler;

  /// 当前登录 token
  static String? _token;

  static void setToken(String? token) => _token = token;

  static String? get currentToken => _token;

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null && _token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));

  Future<T> _request<T>(Future<Response<dynamic>> Function(Dio dio) fn,
      T Function(dynamic data) parse) async {
    try {
      final response = await fn(_dio);
      final body = response.data as Map<String, dynamic>;
      final code = body['code'] as int? ?? -1;
      if (code != 0) {
        final message = body['message'] as String? ?? '未知错误';
        if (code == 40100) {
          unauthorizedHandler?.call();
        }
        throw ApiException(code, message);
      }
      return parse(body['data']);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as int? ?? 50000;
        if (code == 40100) {
          unauthorizedHandler?.call();
        }
        throw ApiException(code, data['message'] as String? ?? '网络错误');
      }
      throw ApiException(50000, '网络错误: ${e.message}');
    }
  }

  Future<T> get<T>(String path, T Function(dynamic) parse) {
    return _request((dio) => dio.get(path), parse);
  }

  Future<T> post<T>(String path, Object? body, T Function(dynamic) parse) {
    return _request((dio) => dio.post(path, data: body), parse);
  }

  Future<T> put<T>(String path, Object? body, T Function(dynamic) parse) {
    return _request((dio) => dio.put(path, data: body), parse);
  }

  Future<T> delete<T>(String path, T Function(dynamic) parse) {
    return _request((dio) => dio.delete(path), parse);
  }
}
