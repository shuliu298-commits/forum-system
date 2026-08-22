package com.forum;

import com.fasterxml.jackson.databind.JsonNode;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 用户与认证集成测试(用例对应设计文档 T01~T06、T11、T14)。
 */
class UserApiIntegrationTest extends AbstractApiTest {

    private final List<Long> createdUserIds = new ArrayList<>();

    @AfterEach
    void cleanup() {
        createdUserIds.forEach(id -> userRepository.deleteById(id));
    }

    /**
     * 创建测试用户并登录,返回 (id, token, name)。
     */
    private UserSession createUser(String prefix) throws Exception {
        String name = uniqueName(prefix);
        long id = data(register(name)).get("id").asLong();
        createdUserIds.add(id);
        String token = loginToken(name, PASSWORD);
        return new UserSession(id, token, name);
    }

    private record UserSession(long id, String token, String name) {
    }

    @Test
    @DisplayName("T01 注册新用户 -> code 0,返回用户信息")
    void registerSuccess() throws Exception {
        String name = uniqueName("u_register");
        JsonNode resp = register(name);
        assertThat(data(resp).get("username").asText()).isEqualTo(name);
        assertThat(data(resp).get("id").asLong()).isPositive();
        createdUserIds.add(data(resp).get("id").asLong());
    }

    @Test
    @DisplayName("T02 重复注册同名用户 -> 40901")
    void registerDuplicate() throws Exception {
        String name = uniqueName("u_dup");
        register(name);

        JsonNode resp = post("/api/auth/register",
                Map.of("username", name, "password", PASSWORD), null);
        assertCode(resp, 40901);
    }

    @Test
    @DisplayName("T03 登录成功 -> 返回 token")
    void loginSuccess() throws Exception {
        String name = uniqueName("u_login");
        long id = data(register(name)).get("id").asLong();
        createdUserIds.add(id);

        JsonNode resp = login(name, PASSWORD);
        assertCode(resp, 0);
        assertThat(data(resp).get("token").asText()).isNotBlank();
        assertThat(data(resp).get("userId").asLong()).isEqualTo(id);
        assertThat(data(resp).get("username").asText()).isEqualTo(name);
    }

    @Test
    @DisplayName("T04 密码错误 -> 40101")
    void loginWrongPassword() throws Exception {
        String name = uniqueName("u_wrongpw");
        register(name);

        assertCode(login(name, "bad-password-1"), 40101);
    }

    @Test
    @DisplayName("T05 查询用户信息 -> 200")
    void getUser() throws Exception {
        UserSession session = createUser("u_get");

        JsonNode resp = get("/api/users/" + session.id(), null);
        assertCode(resp, 0);
        assertThat(data(resp).get("id").asLong()).isEqualTo(session.id());
    }

    @Test
    @DisplayName("T06 查询不存在的用户 -> 40401")
    void getUserNotFound() throws Exception {
        JsonNode resp = get("/api/users/99999999", null);
        assertCode(resp, 40401);
    }

    @Test
    @DisplayName("T11 更新用户名 -> 生效且切换登录")
    void updateUsername() throws Exception {
        UserSession session = createUser("u_update");

        String newName = uniqueName("u_update_x");
        JsonNode resp = put("/api/users/" + session.id(),
                Map.of("username", newName), session.token());
        assertCode(resp, 0);
        assertThat(data(resp).get("username").asText()).isEqualTo(newName);

        assertCode(login(newName, PASSWORD), 0);
    }

    @Test
    @DisplayName("T11b 修改密码:旧密码错误 -> 40300,旧密码正确 -> 新密码可登录")
    void updatePassword() throws Exception {
        UserSession session = createUser("u_pw");

        JsonNode wrong = put("/api/users/" + session.id(),
                Map.of("password", "newpass123", "oldPassword", "wrong"), session.token());
        assertCode(wrong, 40300);

        JsonNode ok = put("/api/users/" + session.id(),
                Map.of("password", "newpass123", "oldPassword", PASSWORD), session.token());
        assertCode(ok, 0);
        assertCode(login(session.name(), "newpass123"), 0);
    }

    @Test
    @DisplayName("T14 注销用户 -> 查询 40401,原密码无法登录")
    void deleteUser() throws Exception {
        String name = uniqueName("u_delete");
        UserSession session = createUser(name);

        assertCode(delete("/api/users/" + session.id(), session.token()), 0);
        assertCode(get("/api/users/" + session.id(), null), 40401);
        assertCode(login(name, PASSWORD), 40101);
    }
}
