#!/usr/bin/env bash

set -Eeuo pipefail

FASTPANEL_PROXY_IP="${FASTPANEL_PROXY_IP:-192.168.0.221}"
MATRIX_PORT="${MATRIX_PORT:-8008}"
ALLOW_SSH="${ALLOW_SSH:-yes}"
SSH_PORT="${SSH_PORT:-22}"
APPLY_UFW_DEFAULTS="${APPLY_UFW_DEFAULTS:-no}"

log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
fail() { echo "[ERROR] $*" >&2; exit 1; }

need_root() {
    if [ "$(id -u)" -ne 0 ]; then
        fail "Run as root: sudo FASTPANEL_PROXY_IP=$FASTPANEL_PROXY_IP bash scripts/firewall_private_proxy.sh"
    fi
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

main() {
    need_root
    need_command ufw

    log "Configuring UFW for Matrix private reverse proxy"
    echo "  FastPanel proxy IP: $FASTPANEL_PROXY_IP"
    echo "  Matrix port:        $MATRIX_PORT"

    if [ "$ALLOW_SSH" = "yes" ]; then
        ufw allow "$SSH_PORT"/tcp comment 'allow SSH'
    else
        warn "ALLOW_SSH is not yes, SSH rule was not added"
    fi

    ufw allow from "$FASTPANEL_PROXY_IP" to any port "$MATRIX_PORT" proto tcp comment 'Pulse Matrix from FastPanel proxy'
    ufw deny "$MATRIX_PORT"/tcp comment 'deny public Matrix direct access'

    if [ "$APPLY_UFW_DEFAULTS" = "yes" ]; then
        ufw default deny incoming
        ufw default allow outgoing
    else
        warn "UFW default policy not changed. Set APPLY_UFW_DEFAULTS=yes if this is a clean Core server."
    fi

    ufw --force enable

    echo
    log "Current UFW status"
    ufw status numbered

    echo
    log "Done. Verify from FastPanel proxy: curl http://<CORE_PRIVATE_IP>:$MATRIX_PORT/_matrix/client/versions"
}

main "$@"
