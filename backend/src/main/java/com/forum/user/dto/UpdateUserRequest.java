package com.forum.user.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * 更新用户请求:用户名与密码均可选,但不能同时为空;
 * 修改密码时必须提供旧密码。
 */
public record UpdateUserRequest(
        @Pattern(regexp = "^[a-zA-Z0-9_]{3,20}$", message = "用户名须为 3~20 位字母、数字或下划线")
        String username,

        @Size(min = 6, max = 32, message = "密码长度须为 6~32 位")
        String password,

        String oldPassword) {

    public boolean hasAnyField() {
        return username != null || password != null;
    }
}
