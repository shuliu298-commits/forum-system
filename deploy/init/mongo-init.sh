#!/bin/sh
# MongoDB 容器首次启动初始化:加载 mock 数据(load.js 读取 mock-data.json)
set -e
echo "[mongo-init] importing mock data via load.js ..."
mongosh --quiet --file /docker-entrypoint-initdb.d/load.js
echo "[mongo-init] done."
