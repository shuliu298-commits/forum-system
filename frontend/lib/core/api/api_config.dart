/// 后端 API 配置。
///
/// 后端默认运行在 WSL Linux 的 8080 端口;Windows 上调试请改为
/// http://<WSL-IP>:8080/api(如 http://192.168.x.x:8080/api)。
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:8080/api';
}
