#!/usr/bin/env bash
# Java 代码质量检查:SpotBugs(空指针风险、未使用代码、潜在 Bug)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/backend"

echo "==> [lint] SpotBugs ..."
mvn -B -q com.github.spotbugs:spotbugs-maven-plugin:check
echo "==> [lint] SpotBugs OK"
