#!/usr/bin/env bash

set -e

echo "== WSMessenger Healthcheck =="
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

echo "[INFO] Disk Usage"
df -h

echo

echo "[INFO] Memory"
free -m

echo

echo "[DONE] Healthcheck complete"
