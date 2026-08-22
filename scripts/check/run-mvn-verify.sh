#!/usr/bin/env bash
# 后端测试:mvn verify(含集成测试,需本地 MySQL(3307)/Mongo(27017) 或 docker-test 环境)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/backend"
mvn -B verify
