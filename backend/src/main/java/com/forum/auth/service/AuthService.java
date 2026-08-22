package com.forum.auth.service;

import com.forum.auth.JwtService;
import com.forum.auth.dto.LoginResponse;
import com.forum.user.entity.User;
import com.forum.user.service.UserService;
import org.springframework.stereotype.Service;

/**
 * 认证业务:登录并签发 JWT。
 */
@Service
public class AuthService {

    private final UserService userService;
    private final JwtService jwtService;

    public AuthService(UserService userService, JwtService jwtService) {
        this.userService = userService;
        this.jwtService = jwtService;
    }

    public LoginResponse login(String username, String password) {
        User user = userService.login(username, password);
        String token = jwtService.createToken(user.getId(), user.getUsername());
        return new LoginResponse(token, user.getId(), user.getUsername());
    }
}
