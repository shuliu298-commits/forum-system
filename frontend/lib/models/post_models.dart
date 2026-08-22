/// 帖子列表项(对应后端 PostSummaryResponse)。
class PostSummary {
  final String id;
  final int authorId;
  final String authorName;
  final String? title;
  final String content;
  final int commentCount;
  final String? createTime;

  const PostSummary({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.commentCount,
    this.title,
    this.createTime,
  });

  factory PostSummary.fromJson(Map<String, dynamic> json) => PostSummary(
        id: json['id'] as String,
        authorId: json['authorId'] as int? ?? 0,
        authorName: json['authorName'] as String? ?? '未知用户',
        content: json['content'] as String? ?? '',
        commentCount: json['commentCount'] as int? ?? 0,
        title: json['title'] as String?,
        createTime: json['createTime'] as String?,
      );
}

/// 评论(对应后端 CommentResponse)。
class CommentModel {
  final String id;
  final int userId;
  final String userName;
  final String content;
  final String? createTime;

  const CommentModel({
    required this.id,
    required this.userName,
    required this.content,
    this.userId = 0,
    this.createTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        userId: json['userId'] as int? ?? 0,
        userName: json['userName'] as String? ?? '未知用户',
        content: json['content'] as String? ?? '',
        createTime: json['createTime'] as String?,
      );
}

/// 帖子详情(对应后端 PostDetailResponse)。
class PostDetail {
  final String id;
  final int authorId;
  final String authorName;
  final String? title;
  final String content;
  final String? createTime;
  final List<CommentModel> comments;

  const PostDetail({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.title,
    this.createTime,
    this.comments = const [],
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) => PostDetail(
        id: json['id'] as String,
        authorId: json['authorId'] as int? ?? 0,
        authorName: json['authorName'] as String? ?? '未知用户',
        content: json['content'] as String? ?? '',
        title: json['title'] as String?,
        createTime: json['createTime'] as String?,
        comments: (json['comments'] as List<dynamic>? ?? [])
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// 分页结果(对应后端 PageResponse)。
class PageResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;

  const PageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) =>
      PageResult(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => itemParser(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 0,
        size: json['size'] as int? ?? 10,
      );
}
