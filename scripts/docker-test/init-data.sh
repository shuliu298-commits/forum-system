#!/usr/bin/env bash
# 强制重建测试环境数据(Mongo/MySQL 初始化脚本会在容器首次启动时自动执行)
# 等价于: stop + 清理数据卷 + start
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_FILE="$ROOT/deploy/docker-compose-test.yml"
PROJECT="forum-test"

echo "==> [docker-test] 清空测试数据卷并重启 ..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT" down -v --remove-orphans
bash "$(dirname "$0")/start-env.sh"
