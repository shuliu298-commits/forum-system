# Forum-System 全栈论坛系统

Flutter 前端 + Spring Boot 后端的论坛系统(教学 Demo 级):MySQL 管用户,MongoDB 管帖子与评论,单仓库管理前后端、部署与自动化质量保障。

技术栈:Flutter / Dart · Spring Boot 3.5 + Java 21 + Maven · MySQL 8.4 + MongoDB 7 · Docker Compose · GitHub Actions

## 仓库结构

```
Forum-System
├── frontend/         # Flutter 前端(帖子页 / 用户管理 Demo / 登录注册)
├── backend/          # Spring Boot 后端(user / auth / post 业务域 + 集成测试)
├── deploy/           # Docker 部署:compose 环境、Dockerfile、数据库初始化脚本
├── scripts/          # 工程化入口:check.sh(质量检查)、docker.sh(环境运维)、api-tests.sh
├── docs/             # 设计文档、Checkstyle / SpotBugs 配置、Sonar 规则映射
└── .github/          # CI 流水线(lint → test → docker-e2e)
```

## 常用命令

### 质量检查(scripts/check.sh)

```bash
scripts/check.sh           # = lint + test
scripts/check.sh lint      # Checkstyle + SpotBugs + Java 文件行数(≤800)
scripts/check.sh test      # 后端集成测试 mvn verify(需先启动 dev 环境)
scripts/check.sh e2e       # 全链路:构建并启动 test 环境 → 14 项 API 断言 → 自动清理
```

### Docker 环境(scripts/docker.sh)

```bash
scripts/docker.sh dev up     # 开发库(MySQL:3307 / MongoDB:27017)
scripts/docker.sh dev reset  # 清空数据卷重新初始化(含种子数据与 Mock 帖子)
scripts/docker.sh dev logs   # 查看日志

scripts/docker.sh test up --build  # 测试环境(3308 / 27018 / backend:8081)
scripts/docker.sh test down        # 停止并清理

scripts/docker.sh admin up   # 数据库可视化 Web 工具(Adminer:8082 / mongo-express:8083)
```

### 手动构建

```bash
# 后端
cd backend && mvn spring-boot:run            # 本地运行(连 dev 库)
mvn verify                                   # 编译 + 集成测试

# 前端(Windows)
cd frontend
flutter run -d Edge                          # 默认连 http://localhost:8080/api
flutter run -d Edge --dart-define=API_BASE_URL=http://<服务器IP>:8080/api   # 连远程后端
flutter build web --dart-define=API_BASE_URL=https://forum.example.com/api  # 构建发布版
```

## 配置(环境变量注入)

后端配置全部支持环境变量覆盖(`backend/src/main/resources/application.yml`):

| 环境变量 | 默认值(本地开发) | 说明 |
|---|---|---|
| `DB_URL` | `jdbc:mysql://localhost:3307/forum_user...` | MySQL 连接串 |
| `DB_USERNAME` / `DB_PASSWORD` | `root` / `forum123` | MySQL 账号 |
| `MONGODB_URI` | `mongodb://localhost:27017/forum_content` | MongoDB 连接串 |
| `FORUM_JWT_SECRET` | 开发密钥 | JWT 签名密钥(生产必须覆盖,≥32 字节) |
| `FORUM_JWT_EXPIRE_HOURS` | `24` | Token 有效期(小时) |
| `SERVER_PORT` | `8080` | 服务端口 |

## 更多

- API 设计、数据模型与里程碑见 [docs/初版设计.md](docs/初版设计.md)
- CI 流水线见 [.github/workflows/ci.yml](.github/workflows/ci.yml)(git push/PR 触发)
- 分支模型:main(稳定)/ develop(集成)/ feature/*;提交遵循 Conventional Commits
