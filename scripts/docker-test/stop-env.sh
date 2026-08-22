#!/usr/bin/env bash
# 停止并清理测试环境(含数据卷)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_FILE="$ROOT/deploy/docker-compose-test.yml"
PROJECT="forum-test"

echo "==> [docker-test] 停止测试环境 ..."
docker compose -f "$COMPOSE_FILE" -p "$PROJECT" down -v --remove-orphans
echo "==> [docker-test] done."
