package com.forum.user.service;

import com.forum.auth.dto.RegisterRequest;
import com.forum.common.BizException;
import com.forum.common.ErrorCode;
import com.forum.post.service.PostService;
import com.forum.user.dto.UpdateUserRequest;
import com.forum.user.dto.UserResponse;
import com.forum.user.entity.User;
import com.forum.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 用户业务逻辑:注册、查询、更新、注销。
 */
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PostService postService;

    public UserService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       PostService postService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.postService = postService;
    }

    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new BizException(ErrorCode.CONFLICT, "用户名已存在");
        }
        User user = new User();
        user.setUsername(request.username());
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setDeleted(0);
        return UserResponse.from(userRepository.save(user));
    }

    /**
     * 登录校验:用户名存在且未注销,密码匹配。
     */
    public User login(String username, String password) {
        User user = userRepository.findByUsernameAndDeleted(username, 0)
                .orElseThrow(() -> new BizException(ErrorCode.AUTH_FAILED));
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BizException(ErrorCode.AUTH_FAILED);
        }
        return user;
    }

    public User getEntity(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.NOT_FOUND, "用户不存在"));
        if (user.getDeleted() != 0) {
            throw new BizException(ErrorCode.NOT_FOUND, "用户不存在");
        }
        return user;
    }

    public UserResponse getById(Long id) {
        return UserResponse.from(getEntity(id));
    }

    public List<UserResponse> list() {
        return userRepository.findAllByDeleted(0).stream().map(UserResponse::from).toList();
    }

    @Transactional
    public UserResponse update(Long id, UpdateUserRequest request) {
        if (!request.hasAnyField()) {
            throw new BizException(ErrorCode.PARAM_ERROR, "用户名与密码不能同时为空");
        }
        User user = getEntity(id);

        if (request.username() != null && !request.username().equals(user.getUsername())) {
            if (userRepository.existsByUsername(request.username())) {
                throw new BizException(ErrorCode.CONFLICT, "用户名已存在");
            }
            user.setUsername(request.username());
        }

        if (request.password() != null) {
            if (request.oldPassword() == null
                    || !passwordEncoder.matches(request.oldPassword(), user.getPassword())) {
                throw new BizException(ErrorCode.FORBIDDEN, "旧密码不正确");
            }
            user.setPassword(passwordEncoder.encode(request.password()));
        }
        return UserResponse.from(userRepository.save(user));
    }

    /**
     * 注销(软删除),同时删除该用户的全部帖子。
     */
    @Transactional
    public void delete(Long id) {
        User user = getEntity(id);
        user.setDeleted(1);
        userRepository.save(user);
        postService.deleteByAuthorId(id);
    }
}
