package com.forum.post.dto;

import com.forum.post.entity.Post;

import java.time.LocalDateTime;

/**
 * 帖子列表项(不含完整评论)。
 */
public record PostSummaryResponse(String id, Long authorId, String authorName, String title,
                                  String content, int commentCount, LocalDateTime createTime) {

    public static PostSummaryResponse from(Post post) {
        return new PostSummaryResponse(post.getId(), post.getAuthorId(), post.getAuthorName(),
                post.getTitle(), post.getContent(), post.commentCount(), post.getCreateTime());
    }
}
