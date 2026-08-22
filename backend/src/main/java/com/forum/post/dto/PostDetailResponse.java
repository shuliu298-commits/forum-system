package com.forum.post.dto;

import com.forum.post.entity.Post;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 帖子详情(含评论)。
 */
public record PostDetailResponse(String id, Long authorId, String authorName, String title,
                                 String content, LocalDateTime createTime,
                                 List<CommentResponse> comments) {

    public static PostDetailResponse from(Post post) {
        List<CommentResponse> comments = post.getComments() == null
                ? List.of()
                : post.getComments().stream().map(CommentResponse::from).toList();
        return new PostDetailResponse(post.getId(), post.getAuthorId(), post.getAuthorName(),
                post.getTitle(), post.getContent(), post.getCreateTime(), comments);
    }
}
