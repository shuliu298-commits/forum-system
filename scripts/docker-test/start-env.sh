#!/usr/bin/env bash
# 启动测试环境(数据库 + 后端镜像)并等待就绪
# 用法:start-env.sh [--reset]
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_FILE="$ROOT/deploy/docker-compose-test.yml"
PROJECT="forum-test"

if [ "${1:-}" = "--reset" ]; then
  echo "==> [docker-test] 重置数据卷 ..."
  docker compose -f "$COMPOSE_FILE" -p "$PROJECT" down -v --remove-orphans
fi

echo "==> [docker-test] 构建并启动测试环境 ..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT" up -d --build

echo "==> [docker-test] 等待服务就绪 ..."
for i in $(seq 1 60); do
  if curl -fsS http://localhost:8081/api/health >/dev/null 2>&1; then
    echo "==> [docker-test] 后端就绪 (http://localhost:8081)"
    exit 0
  fi
  sleep 2
done

echo "!! [docker-test] 等待超时,请检查: docker compose -f $COMPOSE_FILE -p $PROJECT logs -f"
exit 1
