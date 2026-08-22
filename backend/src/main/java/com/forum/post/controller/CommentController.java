package com.forum.post.controller;

import com.forum.common.ApiResponse;
import com.forum.common.CurrentUser;
import com.forum.post.dto.CommentResponse;
import com.forum.post.dto.CreateCommentRequest;
import com.forum.post.service.PostService;
import com.forum.user.entity.User;
import com.forum.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 评论接口(需登录)。
 */
@RestController
@RequestMapping("/api")
public class CommentController {

    private final PostService postService;
    private final UserService userService;

    public CommentController(PostService postService, UserService userService) {
        this.postService = postService;
        this.userService = userService;
    }

    @PostMapping("/posts/{id}/comments")
    public ApiResponse<CommentResponse> add(@PathVariable String id,
                                            @Valid @RequestBody CreateCommentRequest request) {
        User current = userService.getEntity(CurrentUser.requiredId());
        return ApiResponse.success(postService.addComment(id, request,
                current.getId(), current.getUsername()));
    }

    @DeleteMapping("/comments/{postId}/{commentId}")
    public ApiResponse<Void> delete(@PathVariable String postId, @PathVariable String commentId) {
        postService.deleteComment(postId, commentId, CurrentUser.requiredId());
        return ApiResponse.success();
    }
}
