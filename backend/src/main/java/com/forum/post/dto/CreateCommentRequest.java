package com.forum.post.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 发表评论请求。
 */
public record CreateCommentRequest(
        @NotBlank(message = "评论内容不能为空")
        @Size(max = 2000, message = "评论不能超过 2000 字")
        String content) {
}
