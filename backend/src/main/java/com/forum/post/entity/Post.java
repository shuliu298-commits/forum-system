package com.forum.post.entity;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 帖子文档(MongoDB post 集合)。
 */
@Document("post")
@Getter
@Setter
public class Post {

    @Id
    private String id;

    @Indexed
    private Long authorId;

    /** 作者用户名快照,避免跨库查询 */
    private String authorName;

    private String title;

    private String content;

    @Indexed
    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    private List<Comment> comments = new ArrayList<>();

    public int commentCount() {
        return comments == null ? 0 : comments.size();
    }
}
