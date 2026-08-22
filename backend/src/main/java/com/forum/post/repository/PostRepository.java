package com.forum.post.repository;

import com.forum.post.entity.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

/**
 * 帖子仓库。
 */
public interface PostRepository extends MongoRepository<Post, String> {

    Page<Post> findByOrderByCreateTimeDesc(Pageable pageable);

    List<Post> findByAuthorId(Long authorId);
}
