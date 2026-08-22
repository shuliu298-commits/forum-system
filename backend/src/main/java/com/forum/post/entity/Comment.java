package com.forum.post.entity;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * 帖子内嵌评论。
 */
@Getter
@Setter
public class Comment {

    private String commentId;

    private Long userId;

    /** 评论者用户名快照 */
    private String userName;

    private String content;

    private LocalDateTime createTime;
}
