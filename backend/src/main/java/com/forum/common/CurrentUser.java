package com.forum.common;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 从 SecurityContext 读取当前登录用户。
 */
public final class CurrentUser {

    private CurrentUser() {
    }

    /**
     * @return 当前登录用户 id,未登录返回 null
     */
    public static Long getId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getPrincipal())) {
            return null;
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof Long userId) {
            return userId;
        }
        if (principal instanceof String s) {
            try {
                return Long.parseLong(s);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    /**
     * @return 当前登录用户名,未登录返回 null
     */
    public static String getUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getPrincipal())) {
            return null;
        }
        Object credentials = authentication.getCredentials();
        return credentials instanceof String s ? s : null;
    }

    /**
     * @return 当前登录用户 id,未登录抛出 401
     */
    public static Long requiredId() {
        Long id = getId();
        if (id == null) {
            throw new BizException(ErrorCode.UNAUTHORIZED);
        }
        return id;
    }
}
