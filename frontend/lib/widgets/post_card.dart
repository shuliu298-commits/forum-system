import 'package:flutter/material.dart';

import '../models/post_models.dart';

/// 帖子卡片(列表项)。
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final PostSummary post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title?.isNotEmpty == true ? post.title! : '无标题',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(post.authorName, style: TextStyle(color: Colors.grey.shade700)),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${post.commentCount}', style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
