package com.forum.post.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 发帖请求。
 */
public record CreatePostRequest(
        @Size(max = 100, message = "标题不能超过 100 字")
        String title,

        @NotBlank(message = "内容不能为空")
        @Size(max = 2000, message = "内容不能超过 2000 字")
        String content) {
}
