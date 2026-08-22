package com.forum.auth;

/**
 * JWT 解析出的认证主体。
 */
public record AuthPrincipal(Long userId, String username) {
}
