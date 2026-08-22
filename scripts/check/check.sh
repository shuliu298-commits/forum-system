#!/usr/bin/env bash
# check.sh —— 本地 CI 汇总入口(等价于 CI Stage 1/2)
# 流程:后端 lint(Checkstyle + SpotBugs) → 文件行数检查 → 后端测试(mvn verify)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAILED=0
run() {
  echo ""
  echo "################################################################"
  echo "# $1"
  echo "################################################################"
  if ! bash "$2"; then
    echo "!! [check] 步骤失败: $1"
    FAILED=1
  fi
}

run "1/4 Checkstyle"            "$ROOT/scripts/lint/run-checkstyle.sh"
run "2/4 SpotBugs"              "$ROOT/scripts/lint/run-spotbugs.sh"
run "3/4 文件行数检查 (<=800)"   "$ROOT/scripts/check/check-line-count.sh"
run "4/4 后端测试 mvn verify"    "$ROOT/scripts/check/run-mvn-verify.sh"

echo ""
if [ "$FAILED" -ne 0 ]; then
  echo "!!!!!! check.sh FAILED"
  exit 1
fi
echo "!!!!!! check.sh ALL PASSED"
