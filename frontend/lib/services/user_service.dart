import '../core/api/api_client.dart';
import '../models/user_model.dart';

/// 登录结果。
class LoginResult {
  final String token;
  final int userId;
  final String username;

  const LoginResult({required this.token, required this.userId, required this.username});
}

/// 用户服务:注册、登录、CRUD。
class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<UserModel> register(String username, String password) {
    return _client.post(
      '/auth/register',
      {'username': username, 'password': password},
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 登录成功后自动保存 token。
  Future<LoginResult> login(String username, String password) async {
    final data = await _client.post(
      '/auth/login',
      {'username': username, 'password': password},
      (json) => json as Map<String, dynamic>,
    );
    final result = LoginResult(
      token: data['token'] as String,
      userId: data['userId'] as int,
      username: data['username'] as String,
    );
    ApiClient.setToken(result.token);
    return result;
  }

  Future<List<UserModel>> list() {
    return _client.get(
      '/users',
      (data) => (data as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<UserModel> getById(int id) {
    return _client.get(
      '/users/$id',
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UserModel> update(int id, {String? username, String? password, String? oldPassword}) {
    return _client.put(
      '/users/$id',
      {
        if (username != null) 'username': username,
        if (password != null) 'password': password,
        if (oldPassword != null) 'oldPassword': oldPassword,
      },
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) {
    return _client.delete('/users/$id', (_) => null);
  }
}
