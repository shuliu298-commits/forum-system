/// 后端 API 配置。
///
/// 默认连接本机后端,支持编译/运行时覆盖:
///
/// ```bash
/// # 后端在 WSL 本机(默认,无需参数)
/// flutter run -d Edge
///
/// # 后端部署在远程服务器(替换为实际 IP/域名)
/// flutter run -d Edge --dart-define=API_BASE_URL=http://192.168.1.100:8080/api
/// flutter build web --dart-define=API_BASE_URL=https://forum.example.com/api
/// ```
class ApiConfig {
  ApiConfig._();

  /// 可用 --dart-define=API_BASE_URL=... 覆盖;默认本机后端
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
}
