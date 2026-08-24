# Forum-System 全栈论坛系统

Flutter + Spring Boot 的全栈论坛系统(教学/演示级),单仓库(Monorepo)管理。

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Flutter / Dart(Windows 开发与编译) |
| 后端 | Spring Boot 3.5.x + Maven + Java 21 |
| 数据库 | MySQL 8.4(用户域)+ MongoDB 7(帖子/评论域) |
| 认证 | JWT + Spring Security(BCrypt) |
| 部署 | Docker Compose(WSL Linux) |
| 质量 | Checkstyle + SpotBugs + 文件行数检查(≤800 行/文件) |
| 测试 | JUnit 5 + MockMvc 集成测试 + 端到端 API 脚本 |

设计文档见 [`docs/初版设计.md`](docs/初版设计.md)。

## 目录结构

```
Forum-System
├── frontend/            # Flutter 前端(pages / services / models / core)
├── backend/             # Spring Boot 后端(common / config / user / auth / post)
├── deploy/              # docker-compose、Dockerfile、init.sql、mock-data.json
├── scripts/             # lint / check / docker-test 工程化脚本
├── docs/                # 设计文档、checkstyle.xml、sonar 规则映射
├── .github/workflows/   # CI 流水线
└── README.md
```

## 快速开始

> 前置:Java 21、Maven、Docker + Docker Compose、Flutter SDK(前端)。

### 1. 启动开发环境数据库

```bash
cd deploy
docker compose up -d --wait
# MySQL: localhost:3307 (root / forum123, 库 forum_user)
# MongoDB: localhost:27017 (库 forum_content, 自动载入 mock 数据)
```

### 2. 启动后端

```bash
cd backend
mvn spring-boot:run
# http://localhost:8080/api/health
```

### 3. 运行后端测试(集成测试,需数据库已启动)

```bash
mvn verify
```

### 4. 工程化检查

```bash
bash scripts/check/check.sh                      # lint + 行数 + 测试
bash scripts/lint/run-checkstyle.sh              # Checkstyle
bash scripts/lint/run-spotbugs.sh                # SpotBugs
bash scripts/check/check-line-count.sh           # ≤800 行/文件
```

### 5. Docker 端到端测试

```bash
bash scripts/docker-test/start-env.sh            # 起 mysql/mongo/backend(8081)
bash scripts/docker-test/run-api-tests.sh        # 接口测试(输出 report/e2e-report.json)
bash scripts/docker-test/stop-env.sh             # 清理(含数据卷)
```

### 6. 前端(Windows)

```bash
cd frontend
flutter pub get
flutter run -d windows
# 后端地址默认 http://localhost:8080/api,可在 lib/core/api/api_config.dart 修改
flutter test                                        # widget 测试
```

## API 一览

| 方法 | 路径 | 说明 | 认证 |
|---|---|---|---|
| GET | /api/health | 健康检查 | 公开 |
| POST | /api/auth/register | 注册 | 公开 |
| POST | /api/auth/login | 登录(返回 JWT) | 公开 |
| GET | /api/users | 用户列表 | 登录 |
| GET | /api/users/{id} | 用户详情 | 登录 |
| PUT | /api/users/{id} | 更新用户名/密码 | 本人 |
| DELETE | /api/users/{id} | 注销(软删+清帖) | 本人 |
| GET | /api/posts?page=&size= | 帖子列表(分页) | 公开 |
| GET | /api/posts/{id} | 帖子详情(含评论) | 公开 |
| POST | /api/posts | 发帖 | 登录 |
| DELETE | /api/posts/{id} | 删帖 | 作者 |
| POST | /api/posts/{id}/comments | 评论 | 登录 |
| DELETE | /api/comments/{postId}/{commentId} | 删评论 | 评论者/作者 |

统一响应:`{ "code": 0, "message": "success", "data": ... }`,业务错误码见 `common/ErrorCode.java`。

## CI

`.github/workflows/ci.yml` 三阶段:

1. **Lint**:Checkstyle + SpotBugs + 行数检查(≤800)
2. **Test**:`mvn verify`(集成测试连 GitHub Actions 的 MySQL/Mongo 服务)
3. **Docker E2E**:测试环境起全链路 + 端到端 API 测试

> Flutter Windows 构建依赖本地 SDK,CI 不做编译;本地执行 `flutter analyze` + `flutter test`。

## Git 规范

分支:`main`(稳定)/ `develop`(集成)/ `feature/*`。提交规范 Conventional Commits:

```
feat(user): 新增用户 CRUD 接口
fix(post): 修复分页越界问题
docs: 更新设计文档
```

## 服务器部署与前端 API 地址配置

后端部署到远程服务器后,前端(浏览器)不再能访问 `localhost`,按需选择一种方式:

**方式一:运行时注入(推荐,无需改代码)**

```bash
# 开发调试
flutter run -d Edge --dart-define=API_BASE_URL=http://<服务器IP>:8080/api

# 构建部署(nginx 托管静态产物)
flutter build web --dart-define=API_BASE_URL=https://forum.example.com/api
```

**方式二:直接修改** `frontend/lib/core/api/api_config.dart` 的 `baseUrl`。

后端侧确保:

- Spring Boot 监听 `0.0.0.0`(默认);部署用 `docker-compose-test.yml` 时,容器内 8080 已映射宿主机 8081;
- 云服务器安全组/防火墙放行对应端口(如 `ufw allow 8080/tcp`);
- 跨域:初版 CORS 允许所有来源(`SecurityConfig`),生产建议收紧为具体域名。

## 数据库可视化工具

**方案一:Web 版(docker 一键,适合服务器/WSL)**

```bash
docker compose -f deploy/docker-compose.yml up -d                # 先启动数据库
docker compose -f deploy/docker-compose-admin.yml up -d          # 启动可视化工具
# MySQL   web 端: http://localhost:8082  (系统 MySQL,host: host.docker.internal:3307,root/forum123)
# MongoDB web 端: http://localhost:8083  (用户名 forum / 密码 forum123)
```

**方案二:桌面客户端(Windows)**

- [DBeaver Community](https://dbeaver.io/download/)(免费):一个客户端同时连 MySQL 与 MongoDB
  - MySQL:localhost:3307,user root / password forum123,数据库 forum_user
  - MongoDB:localhost:27017,直连,数据库 forum_content
- 或 MongoDB 官方 [Compass](https://www.mongodb.com/products/compass) + MySQL 自带 [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

## 已知说明

- 帖子中冗余 `authorName` 快照(避免跨库 join),用户改名不影响历史帖子显示。
- 注销用户为软删除(用户名仍占用),其帖子/评论物理删除。
- 开发环境下 MySQL 使用宿主机 **3307** 端口(避免与常见 3306 冲突),端口修改需同步 `application.yml` 与 `deploy/docker-compose.yml`。
