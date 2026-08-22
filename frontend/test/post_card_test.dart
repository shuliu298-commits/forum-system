import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forum_frontend/models/post_models.dart';
import 'package:forum_frontend/widgets/post_card.dart';

void main() {
  testWidgets('PostCard 渲染作者/内容/评论数', (tester) async {
    final post = PostSummary(
      id: 'post-001',
      authorId: 1,
      authorName: 'Tom',
      title: '今天学习Spring Boot',
      content: '整理自动配置原理',
      commentCount: 2,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PostCard(post: post)),
    ));

    expect(find.text('今天学习Spring Boot'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('无标题帖子显示默认标题', (tester) async {
    final post = PostSummary(
      id: 'post-002',
      authorId: 2,
      authorName: 'Alice',
      content: '内容',
      commentCount: 0,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PostCard(post: post)),
    ));

    expect(find.text('无标题'), findsOneWidget);
  });
}
