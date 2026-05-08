#!/usr/bin/env bash

set -e

echo "== WSMessenger Installer =="

echo "[1/5] Creating directories"
mkdir -p /opt/swmessenger
mkdir -p /opt/swmessenger/backups
mkdir -p /opt/swmessenger/source

echo "[2/5] Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker not installed"
    exit 1
fi

echo "[3/5] Checking Docker Compose"
docker compose version >/dev/null

echo "[4/5] Starting containers"
docker compose up -d

echo "[5/5] Done"

echo

echo "WSMessenger base stack installed"
echo "IMPORTANT: FastPanel configs were NOT modified"
