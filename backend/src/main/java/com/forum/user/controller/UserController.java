package com.forum.user.controller;

import com.forum.common.ApiResponse;
import com.forum.common.BizException;
import com.forum.common.CurrentUser;
import com.forum.common.ErrorCode;
import com.forum.user.dto.UpdateUserRequest;
import com.forum.user.dto.UserResponse;
import com.forum.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 用户管理接口:查询、更新、注销(注册/登录见 AuthController)。
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ApiResponse<List<UserResponse>> list() {
        return ApiResponse.success(userService.list());
    }

    @GetMapping("/{id}")
    public ApiResponse<UserResponse> get(@PathVariable Long id) {
        return ApiResponse.success(userService.getById(id));
    }

    @PutMapping("/{id}")
    public ApiResponse<UserResponse> update(@PathVariable Long id,
                                            @Valid @RequestBody UpdateUserRequest request) {
        requireSelf(id);
        return ApiResponse.success(userService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        requireSelf(id);
        userService.delete(id);
        return ApiResponse.success();
    }

    private void requireSelf(Long id) {
        if (!CurrentUser.requiredId().equals(id)) {
            throw new BizException(ErrorCode.FORBIDDEN);
        }
    }
}
