import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api/api_exception.dart';
import '../models/post_models.dart';
import '../services/auth_state.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'login_page.dart';
import 'post_detail_page.dart';

/// 页面 1:论坛帖子页(列表 + 发帖入口)。
class PostListPage extends StatefulWidget {
  static const routeName = '/';

  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final List<PostSummary> _posts = [];
  int _page = 0;
  int _total = 0;
  bool _loading = false;
  bool _reachedEnd = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore({bool refresh = false}) async {
    if (_loading) return;
    if (!refresh && _reachedEnd) return;
    setState(() => _loading = true);
    try {
      final result = await context.read<PostService>().list(
            page: refresh ? 0 : _page,
            size: 10,
          );
      setState(() {
        if (refresh) {
          _posts.clear();
          _page = 0;
        }
        _posts.addAll(result.items);
        _page += 1;
        _total = result.total;
        _reachedEnd = _posts.length >= _total;
        _error = null;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '加载失败: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPost() async {
    final auth = context.read<AuthState>();
    if (!auth.loggedIn) {
      _goLogin();
      return;
    }
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发布新帖子'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '标题(可选)'),
            ),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '内容'),
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
            child: const Text('发布'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (contentController.text.trim().isEmpty) {
      _showMessage('内容不能为空');
      return;
    }
    try {
      await context.read<PostService>().create(
            title: titleController.text.trim(),
            content: contentController.text.trim(),
          );
      _showMessage('发布成功');
      _loadMore(refresh: true);
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _goLogin() {
    Navigator.of(context).pushNamed(LoginPage.routeName);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('论坛帖子'),
        actions: [
          IconButton(
            tooltip: '用户管理 Demo',
            icon: const Icon(Icons.group_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(UserListPageRoute.routeName),
          ),
          IconButton(
            tooltip: auth.loggedIn ? '退出登录(${auth.username})' : '登录',
            icon: Icon(auth.loggedIn ? Icons.logout : Icons.login),
            onPressed: () async {
              if (auth.loggedIn) {
                await auth.logout();
              } else {
                _goLogin();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadMore(refresh: true),
        child: _error != null && _posts.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  Text(_error!, textAlign: TextAlign.center),
                ],
              )
            : ListView.builder(
                itemCount: _posts.length + (_reachedEnd ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= _posts.length) {
                    // 触底加载,延后到帧结束以避免 build 期间 setState
                    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final post = _posts[index];
                  return PostCard(
                    post: post,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(postId: post.id),
                        ),
                      );
                      _loadMore(refresh: true);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.edit),
        label: const Text('发帖'),
      ),
    );
  }
}

/// 用户管理页路由常量(避免与页面类产生循环 import)。
class UserListPageRoute {
  static const routeName = '/users';
}
