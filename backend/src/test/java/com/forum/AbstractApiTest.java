package com.forum;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.forum.post.repository.PostRepository;
import com.forum.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;

/**
 * 集成测试基类:提供统一请求/断言与注册、登录辅助方法。
 * 需要本地 MySQL(3307)与 MongoDB(27017)实例(见 deploy/docker-compose.yml)。
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public abstract class AbstractApiTest {

    protected static final String PASSWORD = "123456";

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper om;

    @Autowired
    protected UserRepository userRepository;

    @Autowired
    protected PostRepository postRepository;

    // ---------- 请求辅助 ----------

    protected JsonNode request(MockHttpServletRequestBuilder builder, Object body, String token) throws Exception {
        if (body != null) {
            builder.contentType(MediaType.APPLICATION_JSON).content(om.writeValueAsString(body));
        }
        if (token != null) {
            builder.header("Authorization", "Bearer " + token);
        }
        String content = mockMvc.perform(builder).andReturn()
                .getResponse().getContentAsString(StandardCharsets.UTF_8);
        return om.readTree(content);
    }

    protected JsonNode getJson(String url, String token) throws Exception {
        return request(get(url), null, token);
    }

    protected JsonNode postJson(String url, Object body, String token) throws Exception {
        return request(post(url), body, token);
    }

    protected JsonNode putJson(String url, Object body, String token) throws Exception {
        return request(put(url), body, token);
    }

    protected JsonNode deleteJson(String url, String token) throws Exception {
        return request(delete(url), null, token);
    }

    // ---------- 断言辅助 ----------

    protected void assertCode(JsonNode resp, int code) {
        assertThat(resp.get("code").asInt()).as("业务 code(实际 message=%s)", resp.get("message").asText())
                .isEqualTo(code);
    }

    protected JsonNode data(JsonNode resp) {
        return resp.get("data");
    }

    // ---------- 业务辅助 ----------

    protected JsonNode register(String username) throws Exception {
        JsonNode resp = postJson("/api/auth/register",
                Map.of("username", username, "password", PASSWORD), null);
        assertCode(resp, 0);
        return resp;
    }

    protected JsonNode login(String username, String password) throws Exception {
        return postJson("/api/auth/login", Map.of("username", username, "password", password), null);
    }

    protected String loginToken(String username, String password) throws Exception {
        JsonNode resp = login(username, password);
        assertCode(resp, 0);
        return data(resp).get("token").asText();
    }

    /** 生成 3~20 字符范围内唯一用户名(受注册校验限制) */
    protected String uniqueName(String prefix) {
        return prefix + "_" + Long.toHexString(System.nanoTime() & 0xFFFFFF);
    }
}
