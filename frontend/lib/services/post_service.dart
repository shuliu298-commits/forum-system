import '../core/api/api_client.dart';
import '../models/post_models.dart';

/// 帖子服务:列表、详情、发帖、评论、删除。
class PostService {
  final ApiClient _client;

  PostService(this._client);

  Future<PageResult<PostSummary>> list({int page = 0, int size = 10}) {
    return _client.get(
      '/posts?page=$page&size=$size',
      (data) => PageResult.fromJson(
        data as Map<String, dynamic>,
        PostSummary.fromJson,
      ),
    );
  }

  Future<PostDetail> getDetail(String id) {
    return _client.get(
      '/posts/$id',
      (data) => PostDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<PostDetail> create({String? title, required String content}) {
    return _client.post(
      '/posts',
      {if (title != null) 'title': title, 'content': content},
      (data) => PostDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(String id) {
    return _client.delete('/posts/$id', (_) => null);
  }

  Future<CommentModel> addComment(String postId, String content) {
    return _client.post(
      '/posts/$postId/comments',
      {'content': content},
      (data) => CommentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteComment(String postId, String commentId) {
    return _client.delete('/comments/$postId/$commentId', (_) => null);
  }
}
