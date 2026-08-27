#!/usr/bin/env bash
# scripts/docker.sh —— Docker 环境统一入口
#
# 用法:
#   scripts/docker.sh <dev|test|admin> <up|down|reset|logs> [--build]
#
#   dev   开发环境    deploy/docker-compose.yml        (MySQL:3307, MongoDB:27017)
#   test  测试环境    deploy/docker-compose-test.yml   (MySQL:3308, MongoDB:27018, backend:8081)
#   admin 可视化工具  deploy/docker-compose-admin.yml  (Adminer:8082, mongo-express:8083)
#
# 子命令:
#   up      启动(--wait 等待健康;test 环境可用 --build 重新构建镜像)
#   down    停止并清理容器(--remove-orphans)
#   reset   停止并删除数据卷,重新启动(重新执行数据库初始化)
#   logs    跟踪日志
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

ENV_NAME="${1:-}"
ACTION="${2:-}"
EXTRA="${3:-}"
COMPOSE_OPTS=()

case "$ENV_NAME" in
  dev)   COMPOSE_FILE="$ROOT/deploy/docker-compose.yml";        PROJECT="forum-dev" ;;
  test)  COMPOSE_FILE="$ROOT/deploy/docker-compose-test.yml";   PROJECT="forum-test" ;;
  admin) COMPOSE_FILE="$ROOT/deploy/docker-compose-admin.yml";  PROJECT="forum-dev" ;;
  *)     usage; exit 1 ;;
esac

compose() {
  docker compose -f "$COMPOSE_FILE" -p "$PROJECT" "$@"
}

case "$ACTION" in
  up)
    [ "$EXTRA" = "--build" ] && COMPOSE_OPTS+=(--build)
    compose up -d "${COMPOSE_OPTS[@]}"
    if [ "$ENV_NAME" != "admin" ]; then
      echo "==> 等待服务健康 ..."
      # --wait 偶发因健康检查窗口超时返回非 0,重试一次以提升稳定性
      if ! compose up -d --wait; then
        echo "!! 首次健康等待超时,重试一次 ..."
        compose up -d --wait
      fi
    fi
    ;;
  down)
    compose down --remove-orphans
    ;;
  reset)
    compose down -v --remove-orphans
    compose up -d --wait
    ;;
  logs)
    compose logs -f --tail=100
    ;;
  *)
    usage
    exit 1
    ;;
esac
