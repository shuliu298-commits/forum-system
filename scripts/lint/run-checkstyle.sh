#!/usr/bin/env bash
# Java 代码质量检查:Checkstyle(命名规范、格式、导入顺序)
# 配置:docs/checkstyle.xml
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/backend"

echo "==> [lint] Checkstyle ..."
mvn -B -q checkstyle:check
echo "==> [lint] Checkstyle OK"
