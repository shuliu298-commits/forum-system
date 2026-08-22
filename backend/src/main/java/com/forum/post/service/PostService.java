package com.forum.post.service;

import com.forum.common.BizException;
import com.forum.common.ErrorCode;
import com.forum.post.dto.CommentResponse;
import com.forum.post.dto.CreateCommentRequest;
import com.forum.post.dto.CreatePostRequest;
import com.forum.post.dto.PostDetailResponse;
import com.forum.post.dto.PostSummaryResponse;
import com.forum.post.entity.Comment;
import com.forum.post.entity.Post;
import com.forum.post.repository.PostRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 帖子业务:列表、详情、发帖、删帖、评论。
 */
@Service
public class PostService {

    private final PostRepository postRepository;

    public PostService(PostRepository postRepository) {
        this.postRepository = postRepository;
    }

    public Page<Post> listPosts(int page, int size) {
        return postRepository.findByOrderByCreateTimeDesc(
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createTime")));
    }

    public Post getEntity(String id) {
        return postRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.NOT_FOUND, "帖子不存在"));
    }

    public PostDetailResponse getDetail(String id) {
        return PostDetailResponse.from(getEntity(id));
    }

    public PostDetailResponse create(CreatePostRequest request, Long authorId, String authorName) {
        Post post = new Post();
        post.setAuthorId(authorId);
        post.setAuthorName(authorName);
        post.setTitle(request.title());
        post.setContent(request.content());
        LocalDateTime now = LocalDateTime.now();
        post.setCreateTime(now);
        post.setUpdateTime(now);
        post.setComments(List.of());
        return PostDetailResponse.from(postRepository.save(post));
    }

    /**
     * 删除帖子:仅作者本人可删(初版无管理员角色)。
     */
    public void delete(String id, Long operatorId) {
        Post post = getEntity(id);
        if (!post.getAuthorId().equals(operatorId)) {
            throw new BizException(ErrorCode.FORBIDDEN);
        }
        postRepository.delete(post);
    }

    /**
     * 注销用户时清理其全部帖子。
     */
    public void deleteByAuthorId(Long authorId) {
        postRepository.deleteAll(postRepository.findByAuthorId(authorId));
    }

    public CommentResponse addComment(String postId, CreateCommentRequest request,
                                      Long userId, String userName) {
        Post post = getEntity(postId);
        Comment comment = new Comment();
        comment.setCommentId(UUID.randomUUID().toString());
        comment.setUserId(userId);
        comment.setUserName(userName);
        comment.setContent(request.content());
        comment.setCreateTime(LocalDateTime.now());
        post.getComments().add(comment);
        postRepository.save(post);
        return CommentResponse.from(comment);
    }

    /**
     * 删除评论:评论者本人或帖子作者。
     */
    public void deleteComment(String postId, String commentId, Long operatorId) {
        Post post = getEntity(postId);
        Comment target = post.getComments().stream()
                .filter(c -> commentId.equals(c.getCommentId()))
                .findFirst()
                .orElseThrow(() -> new BizException(ErrorCode.NOT_FOUND, "评论不存在"));
        boolean isAuthor = post.getAuthorId().equals(operatorId);
        boolean isCommenter = target.getUserId() != null && target.getUserId().equals(operatorId);
        if (!isAuthor && !isCommenter) {
            throw new BizException(ErrorCode.FORBIDDEN);
        }
        post.getComments().remove(target);
        postRepository.save(post);
    }
}
