package com.forum.post.dto;

import com.forum.post.entity.Comment;

import java.time.LocalDateTime;

/**
 * 评论响应。
 */
public record CommentResponse(String id, Long userId, String userName, String content, LocalDateTime createTime) {

    public static CommentResponse from(Comment comment) {
        return new CommentResponse(comment.getCommentId(), comment.getUserId(), comment.getUserName(),
                comment.getContent(), comment.getCreateTime());
    }
}
