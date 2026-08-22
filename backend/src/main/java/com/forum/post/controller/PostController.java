package com.forum.post.controller;

import com.forum.common.ApiResponse;
import com.forum.common.CurrentUser;
import com.forum.common.PageResponse;
import com.forum.post.dto.CreatePostRequest;
import com.forum.post.dto.PostDetailResponse;
import com.forum.post.dto.PostSummaryResponse;
import com.forum.post.service.PostService;
import com.forum.user.entity.User;
import com.forum.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 帖子接口:列表(游客可读)、详情(游客可读)、发帖、删帖。
 */
@RestController
@RequestMapping("/api/posts")
public class PostController {

    private final PostService postService;
    private final UserService userService;

    public PostController(PostService postService, UserService userService) {
        this.postService = postService;
        this.userService = userService;
    }

    @GetMapping
    public ApiResponse<PageResponse<PostSummaryResponse>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<PostSummaryResponse> result = postService.listPosts(page, Math.min(size, 50))
                .map(PostSummaryResponse::from);
        return ApiResponse.success(PageResponse.of(result.getContent(), result.getTotalElements(),
                page, Math.min(size, 50)));
    }

    @GetMapping("/{id}")
    public ApiResponse<PostDetailResponse> get(@PathVariable String id) {
        return ApiResponse.success(postService.getDetail(id));
    }

    @PostMapping
    public ApiResponse<PostDetailResponse> create(@Valid @RequestBody CreatePostRequest request) {
        User current = userService.getEntity(CurrentUser.requiredId());
        return ApiResponse.success(postService.create(request, current.getId(), current.getUsername()));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable String id) {
        postService.delete(id, CurrentUser.requiredId());
        return ApiResponse.success();
    }
}
