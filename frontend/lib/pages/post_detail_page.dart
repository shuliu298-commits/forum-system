import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api/api_exception.dart';
import '../models/post_models.dart';
import '../services/auth_state.dart';
import '../services/post_service.dart';

/// 帖子详情页:作者、内容、评论列表、发表评论。
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  PostDetail? _detail;
  String? _error;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final detail = await context.read<PostService>().getDetail(widget.postId);
      setState(() {
        _detail = detail;
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

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showMessage('评论不能为空');
      return;
    }
    final auth = context.read<AuthState>();
    if (!auth.loggedIn) {
      _showMessage('请先登录');
      return;
    }
    setState(() => _submitting = true);
    try {
      await context.read<PostService>().addComment(widget.postId, content);
      _commentController.clear();
      await _load();
    } on ApiException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除评论'),
        content: Text('确定删除 ${comment.userName} 的这条评论吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await context.read<PostService>().deleteComment(widget.postId, comment.id);
      await _load();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        detail!.title?.isNotEmpty == true ? detail.title! : '无标题',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(detail.authorName,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(detail.content, style: Theme.of(context).textTheme.bodyMedium),
                      const Divider(height: 32),
                      Text('评论(${detail.comments.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      ...detail.comments.map(
                        (comment) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.adjust, size: 12),
                          title: Text(comment.userName),
                          subtitle: Text(comment.content),
                          trailing: auth.userId == comment.userId
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: () => _deleteComment(comment),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '写下你的评论…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submitting ? null : _submitComment,
                child: const Text('评论'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
