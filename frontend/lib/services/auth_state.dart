import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../services/user_service.dart';

/// 登录态管理:token / 当前用户,持久化到本地。
class AuthState extends ChangeNotifier {
  AuthState(this._userService, this._prefs) {
    _token = _prefs.getString('token');
    _userId = _prefs.getInt('userId');
    _username = _prefs.getString('username');
    ApiClient.setToken(_token);
  }

  static const _tokenKey = 'token';
  static const _userIdKey = 'userId';
  static const _usernameKey = 'username';

  final UserService _userService;
  final SharedPreferences _prefs;

  String? _token;
  int? _userId;
  String? _username;

  bool get loggedIn => _token != null && _token!.isNotEmpty;

  String? get username => _username;

  int? get userId => _userId;

  /// 登录成功:保存 token 与用户信息。
  Future<void> login(String username, String password) async {
    final result = await _userService.login(username, password);
    _token = result.token;
    _userId = result.userId;
    _username = result.username;
    await _prefs.setString(_tokenKey, result.token);
    await _prefs.setInt(_userIdKey, result.userId);
    await _prefs.setString(_usernameKey, result.username);
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    await _userService.register(username, password);
    // 注册成功后自动登录
    await login(username, password);
  }

  /// 退出登录。
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _username = null;
    ApiClient.setToken(null);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_usernameKey);
    notifyListeners();
  }

  /// 供 ApiClient 401 回调使用。
  void onUnauthorized() {
    logout();
  }
}
