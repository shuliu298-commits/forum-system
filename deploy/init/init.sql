-- 论坛系统 MySQL 初始化脚本(docker-entrypoint-initdb.d 自动执行)
-- 建表 + 种子用户(密码均为 123456,BCrypt)
USE forum_user;

CREATE TABLE IF NOT EXISTS user (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(20)  NOT NULL UNIQUE,
    password    VARCHAR(100) NOT NULL,
    deleted     TINYINT      NOT NULL DEFAULT 0 COMMENT '0 正常 1 注销',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

INSERT IGNORE INTO user (id, username, password, deleted)
VALUES (1, 'Tom', '$2b$10$SMBeNXOVY8JcBbZnVGG.S.3M1EjOF0pBXQIlCw9H1.sXDOCYuI8yO', 0),
       (2, 'Alice', '$2b$10$SMBeNXOVY8JcBbZnVGG.S.3M1EjOF0pBXQIlCw9H1.sXDOCYuI8yO', 0),
       (3, 'Bob', '$2b$10$SMBeNXOVY8JcBbZnVGG.S.3M1EjOF0pBXQIlCw9H1.sXDOCYuI8yO', 0);
