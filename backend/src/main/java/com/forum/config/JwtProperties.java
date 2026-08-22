package com.forum.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * JWT 配置项(application.yml 中 forum.jwt.*)。
 */
@ConfigurationProperties(prefix = "forum.jwt")
public record JwtProperties(String secret, long expireHours) {

    public JwtProperties {
        if (secret == null || secret.getBytes(java.nio.charset.StandardCharsets.UTF_8).length < 32) {
            throw new IllegalArgumentException("forum.jwt.secret 长度必须 >= 32 字节(HS256 要求)");
        }
        if (expireHours <= 0) {
            throw new IllegalArgumentException("forum.jwt.expire-hours 必须为正数");
        }
    }
}
