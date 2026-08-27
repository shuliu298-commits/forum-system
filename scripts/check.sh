#!/usr/bin/env bash
# scripts/check.sh —— 质量检查统一入口
#
# 用法:
#   scripts/check.sh [lint|test|e2e|all]
#
#   lint  静态检查:Checkstyle + SpotBugs + Java 文件行数(≤800)
#   test  后端集成测试:mvn verify(需先 scripts/docker.sh dev up)
#   e2e   端到端测试:起 test 环境(含构建)→ API 断言 → 自动清理
#   all   lint + test(默认,无参数执行)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACTION="${1:-all}"

cd "$ROOT/backend"

step() {
  echo ""
  echo "########################################################"
  echo "# $1"
  echo "########################################################"
}

fail() {
  echo "!! $1"
  exit 1
}

run_lint() {
  step "1/3 Checkstyle"
  mvn -B -q checkstyle:check || fail "Checkstyle 未通过,详见上方输出"

  step "2/3 SpotBugs"
  mvn -B -q com.github.spotbugs:spotbugs-maven-plugin:check || fail "SpotBugs 未通过"

  step "3/3 Java 文件行数检查 (≤800 行)"
  local failed=0 count=0
  while IFS= read -r -d '' file; do
    count=$((count + 1))
    lines=$(wc -l < "$file")
    if [ "$lines" -gt 800 ]; then
      echo "FAILED: ${file#*src/main/java/} : ${lines} lines > 800 limit"
      failed=1
    fi
  done < <(find . -name '*.java' -path '*/src/*' -print0)
  echo "扫描 $count 个 Java 文件"
  [ "$failed" -eq 0 ] || fail "行数检查未通过"
}

run_test() {
  step "后端集成测试 mvn verify"
  mvn -B verify || fail "测试未通过(请确认已执行 scripts/docker.sh dev up)"
}

run_e2e() {
  step "E2E:启动 test 环境(构建后端镜像)"
  bash "$ROOT/scripts/docker.sh" test up --build || fail "test 环境启动失败"

  step "E2E:API 断言"
  bash "$ROOT/scripts/api-tests.sh"
  local rc=$?

  step "E2E:清理环境"
  bash "$ROOT/scripts/docker.sh" test down

  [ "$rc" -eq 0 ] || fail "E2E 未通过"
}

case "$ACTION" in
  lint) run_lint ;;
  test) run_test ;;
  e2e)  run_e2e ;;
  all)
    run_lint
    run_test
    ;;
  *)
    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac

echo ""
echo "==== scripts/check.sh $ACTION 全部通过 ===="
