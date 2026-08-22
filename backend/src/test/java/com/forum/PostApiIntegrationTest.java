package com.forum;

import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 帖子与评论集成测试(用例对应设计文档 T07~T10、T12、T13 及持久化)。
 */
class PostApiIntegrationTest extends AbstractApiTest {

    private final List<Long> createdUserIds = new ArrayList<>();
    private final List<String> createdPostIds = new ArrayList<>();

    private String token;
    private long userId;

    @BeforeEach
    void setUp() throws Exception {
        String name = uniqueName("p_user");
        JsonNode resp = register(name);
        userId = data(resp).get("id").asLong();
        createdUserIds.add(userId);
        token = loginToken(name, PASSWORD);
    }

    @AfterEach
    void cleanup() {
        createdPostIds.forEach(id -> postRepository.deleteById(id));
        createdUserIds.forEach(id -> userRepository.deleteById(id));
    }

    @Test
    @DisplayName("T07 发帖(需登录) -> 返回帖子 id 与作者快照")
    void createPost() throws Exception {
        JsonNode resp = post("/api/posts",
                Map.of("title", "集成测试帖", "content", "测试内容"), token);
        assertCode(resp, 0);
        assertThat(data(resp).get("id").asText()).isNotBlank();
        assertThat(data(resp).get("authorId").asLong()).isEqualTo(userId);
        assertThat(data(resp).get("authorName").asText()).isNotBlank();
        createdPostIds.add(data(resp).get("id").asText());
    }

    @Test
    @DisplayName("T07b 未登录发帖 -> 40100")
    void createPostUnauthorized() throws Exception {
        JsonNode resp = post("/api/posts", Map.of("content", "游客发帖"), null);
        assertCode(resp, 40100);
    }

    @Test
    @DisplayName("T08 帖子列表分页排序 -> 200")
    void listPosts() throws Exception {
        post("/api/posts", Map.of("content", "列表测试1"), token);
        post("/api/posts", Map.of("content", "列表测试2"), token);

        JsonNode resp = get("/api/posts?page=0&size=10", null);
        assertCode(resp, 0);
        assertThat(data(resp).get("total").asLong()).isGreaterThanOrEqualTo(2);
        assertThat(data(resp).get("items")).isNotEmpty();
        // 第一项应为最新发布的帖子
        assertThat(data(resp).get("items").get(0).get("content").asText()).isEqualTo("列表测试2");
    }

    @Test
    @DisplayName("T09 详情包含评论 -> 评论后可见")
    void detailContainsComment() throws Exception {
        String postId = data(post("/api/posts", Map.of("content", "有评论的帖子"), token))
                .get("id").asText();
        createdPostIds.add(postId);

        JsonNode comment = post("/api/posts/" + postId + "/comments",
                Map.of("content", "第一条评论"), token);
        assertCode(comment, 0);
        String commentId = data(comment).get("id").asText();

        JsonNode detail = get("/api/posts/" + postId, null);
        assertCode(detail, 0);
        assertThat(data(detail).get("comments")).hasSize(1);
        assertThat(data(detail).get("comments").get(0).get("id").asText()).isEqualTo(commentId);
        assertThat(data(detail).get("comments").get(0).get("content").asText()).isEqualTo("第一条评论");
    }

    @Test
    @DisplayName("T09b 未登录评论 -> 40100;评论内容为空 -> 40001")
    void commentValidation() throws Exception {
        String postId = data(post("/api/posts", Map.of("content", "校验帖"), token))
                .get("id").asText();
        createdPostIds.add(postId);

        assertCode(post("/api/posts/" + postId + "/comments", Map.of("content", "x"), null), 40100);
        assertCode(post("/api/posts/" + postId + "/comments", Map.of("content", ""), token), 40001);
    }

    @Test
    @DisplayName("T10 删除评论 -> 详情中不再出现")
    void deleteComment() throws Exception {
        String postId = data(post("/api/posts", Map.of("content", "删评论帖"), token))
                .get("id").asText();
        createdPostIds.add(postId);
        String commentId = data(post("/api/posts/" + postId + "/comments",
                Map.of("content", "待删除"), token)).get("id").asText();

        assertCode(delete("/api/comments/" + postId + "/" + commentId, token), 0);

        JsonNode detail = get("/api/posts/" + postId, null);
        assertThat(data(detail).get("comments")).isEmpty();
    }

    @Test
    @DisplayName("T13 删除他人帖子 -> 40300")
    void deleteOtherUsersPost() throws Exception {
        String ownPostId = data(post("/api/posts", Map.of("content", "别人的帖子"), token))
                .get("id").asText();
        createdPostIds.add(ownPostId);

        String otherUser = uniqueName("p_other");
        long otherId = data(register(otherUser)).get("id").asLong();
        createdUserIds.add(otherId);
        String otherToken = loginToken(otherUser, PASSWORD);

        assertCode(delete("/api/posts/" + ownPostId, otherToken), 40300);
    }

    @Test
    @DisplayName("T14b 注销用户 -> 其帖子被清理")
    void deleteUserRemovesPosts() throws Exception {
        post("/api/posts", Map.of("content", "注销前的帖子"), token);

        assertCode(delete("/api/users/" + userId, token), 0);

        JsonNode list = get("/api/posts?page=0&size=50", null);
        JsonNode items = data(list).get("items");
        for (JsonNode item : items) {
            assertThat(item.get("authorId").asLong()).as("帖子 authorId").isNotEqualTo(userId);
        }
    }
}
