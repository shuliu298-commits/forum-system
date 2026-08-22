package com.forum.user.dto;

import com.forum.user.entity.User;

import java.time.LocalDateTime;

/**
 * 用户响应。
 */
public record UserResponse(Long id, String username, LocalDateTime createTime, LocalDateTime updateTime) {

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getUsername(), user.getCreateTime(), user.getUpdateTime());
    }
}
