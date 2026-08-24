import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api/api_exception.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

/// 页面 2:用户管理 Demo(完整 CRUD 操作界面)。
class UserListPage extends StatefulWidget {
  static const routeName = '/users';

  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final users = await context.read<UserService>().list();
      setState(() {
        _users = users;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _loading = false;
      });
    }
  }

  /// 创建用户(调用 POST /api/auth/register)。
  Future<void> _createUser() async {
    final result = await _showUserForm(
      title: '创建用户',
      usernameController: TextEditingController(),
      passwordController: TextEditingController(),
    );
    if (result == null) return;
    final password = result.$2 ?? '';
    if (password.isEmpty) {
      _showMessage('密码不能为空');
      return;
    }
    try {
      await context.read<UserService>().register(result.$1, password);
      _showMessage('创建成功');
      await _load();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  /// 更新用户(调用 PUT /api/users/{id})。
  Future<void> _updateUser(UserModel user) async {
    final result = await _showUserForm(
      title: '更新用户: ${user.username}',
      usernameController: TextEditingController(text: user.username),
      passwordController: TextEditingController(),
      requireOldPassword: true,
    );
    if (result == null) return;
    try {
      await context.read<UserService>().update(
            user.id,
            username: result.$1,
            password: result.$2?.isNotEmpty == true ? result.$2 : null,
            oldPassword: result.$3,
          );
      _showMessage('更新成功');
      await _load();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  /// 注销用户(调用 DELETE /api/users/{id})。
  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('注销用户'),
        content: Text('确定注销用户 ${user.username} 吗?其帖子将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('注销'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await context.read<UserService>().delete(user.id);
      _showMessage('已注销');
      await _load();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  /// 查询用户详情(调用 GET /api/users/{id})。
  Future<void> _viewUser(UserModel user) async {
    try {
      final detail = await context.read<UserService>().getById(user.id);
      _showMessage('用户: ${detail.username} (ID ${detail.id})');
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<(String, String?, String?)?> _showUserForm({
    required String title,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    bool requireOldPassword = false,
  }) async {
    final oldPasswordController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '用户名'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            if (requireOldPassword)
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '旧密码(修改密码时必填)'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (ok != true) return null;
    return (
      usernameController.text.trim(),
      passwordController.text,
      requireOldPassword ? oldPasswordController.text : null,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户管理 Demo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(user.username),
                          subtitle: Text('ID: ${user.id}'),
                          onTap: () => _viewUser(user),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: '查询',
                                icon: const Icon(Icons.search),
                                onPressed: () => _viewUser(user),
                              ),
                              IconButton(
                                tooltip: '更新',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _updateUser(user),
                              ),
                              IconButton(
                                tooltip: '注销',
                                icon: const Icon(Icons.person_remove_outlined),
                                onPressed: () => _deleteUser(user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        icon: const Icon(Icons.person_add),
        label: const Text('创建用户'),
      ),
    );
  }
}
