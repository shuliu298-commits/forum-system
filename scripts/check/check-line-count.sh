#!/usr/bin/env bash
# 代码规模检查:单个 Java 文件不得超过 LIMIT 行(默认 800)
# 超出时输出 "xxx.java: N lines > LIMIT limit" 并以退出码 1 结束(CI 失败)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIMIT="${1:-800}"
FAILED=0
COUNT=0

while IFS= read -r -d '' file; do
  COUNT=$((COUNT + 1))
  lines=$(wc -l < "$file")
  if [ "$lines" -gt "$LIMIT" ]; then
    echo "FAILED: ${file#*src/main/java/} : ${lines} lines > ${LIMIT} limit"
    FAILED=1
  fi
done < <(find "$ROOT/backend/src" -name '*.java' -print0)

echo "==> [check] 扫描 $COUNT 个 Java 文件, 限制 ${LIMIT} 行/文件"
if [ "$FAILED" -ne 0 ]; then
  echo "==> [check] 行数检查 FAILED"
  exit 1
fi
echo "==> [check] 行数检查 OK"
