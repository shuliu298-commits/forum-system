package com.forum.user.repository;

import com.forum.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * 用户仓库。
 */
public interface UserRepository extends JpaRepository<User, Long> {

    boolean existsByUsername(String username);

    Optional<User> findByUsername(String username);

    Optional<User> findByUsernameAndDeleted(String username, Integer deleted);

    List<User> findAllByDeleted(Integer deleted);
}
