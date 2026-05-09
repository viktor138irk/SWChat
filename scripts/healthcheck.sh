#!/usr/bin/env bash

set -e

ENV_FILE="${ENV_FILE:-/opt/swchat/.env}"
SERVER_NAME="matrix.stackworks.ru"
MATRIX_BIND_HOST="127.0.0.1"

if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
fi

echo "== SWChat/Pulse Healthcheck =="
echo

echo "[INFO] Docker"
docker --version || true

echo

echo "[INFO] Docker Compose"
docker compose version || true

echo

echo "[INFO] Containers"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || true

echo

echo "[INFO] Matrix Bind"
echo "SERVER_NAME=${SERVER_NAME}"
echo "MATRIX_BIND_HOST=${MATRIX_BIND_HOST}"

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

echo "[INFO] Matrix Bound Endpoint"
if [ "$MATRIX_BIND_HOST" != "127.0.0.1" ]; then
    curl -s "http://${MATRIX_BIND_HOST}:8008/_matrix/client/versions" || true
else
    echo "MATRIX_BIND_HOST is localhost-only, skipping private LAN endpoint check"
fi

echo

echo "[INFO] Public Matrix HTTPS Endpoint"
curl -s "https://${SERVER_NAME}/_matrix/client/versions" || true

echo

echo "[INFO] UFW"
if command -v ufw >/dev/null 2>&1; then
    ufw status numbered || true
else
    echo "ufw not installed"
fi

echo

echo "[INFO] Disk Usage"
df -h

echo

echo "[INFO] Memory"
free -m

echo

echo "[DONE] SWChat/Pulse healthcheck complete"
