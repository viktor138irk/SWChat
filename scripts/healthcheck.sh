#!/usr/bin/env bash

set -e

echo "== SWChat Healthcheck =="
echo

echo "[INFO] Docker"
docker --version || true

echo

echo "[INFO] Docker Compose"
docker compose version || true

echo

echo "[INFO] Containers"
docker ps || true

echo

echo "[INFO] Matrix Port"
ss -tulpn | grep 8008 || true

echo

echo "[INFO] Public HTTP/HTTPS Ports"
ss -tulpn | grep -E ':80|:443' || true

echo

echo "[INFO] Matrix Local Endpoint"
curl -s http://127.0.0.1:8008/_matrix/client/versions || true

echo

echo "[INFO] Disk Usage"
df -h

echo

echo "[INFO] Memory"
free -m

echo

echo "[DONE] SWChat healthcheck complete"
