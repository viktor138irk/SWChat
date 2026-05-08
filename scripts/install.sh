#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_NAME="SWChat"
INSTALL_DIR="${INSTALL_DIR:-/opt/swchat}"
SOURCE_DIR="${SOURCE_DIR:-$INSTALL_DIR/source}"
DATA_DIR="${DATA_DIR:-$INSTALL_DIR/data}"
BACKUP_DIR="${BACKUP_DIR:-$INSTALL_DIR/backups}"
ENV_FILE="${ENV_FILE:-$INSTALL_DIR/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$SOURCE_DIR/docker-compose.yml}"
SERVER_NAME="${SERVER_NAME:-matrix.stackworks.ru}"
REPORT_STATS="${REPORT_STATS:-no}"
AUTO_START="${AUTO_START:-yes}"
AUTO_INSTALL_DOCKER="${AUTO_INSTALL_DOCKER:-yes}"

log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
fail() { echo "[ERROR] $*" >&2; exit 1; }

need_root() {
    if [ "$(id -u)" -ne 0 ]; then
        fail "Run as root: sudo bash scripts/install.sh"
    fi
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

random_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 32
    else
        tr -dc 'a-f0-9' </dev/urandom | head -c 64
    fi
}

detect_os() {
    [ -f /etc/os-release ] || fail "Cannot detect OS: /etc/os-release not found"
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_CODENAME="${VERSION_CODENAME:-}"

    case "$OS_ID" in
        ubuntu|debian) ;;
        *) fail "Unsupported OS for automatic Docker install: $OS_ID. Install Docker manually or use Ubuntu/Debian." ;;
    esac

    [ -n "$OS_CODENAME" ] || fail "Cannot detect OS codename"
}

install_docker() {
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        log "Docker and Docker Compose plugin already installed"
        return
    fi

    if [ "$AUTO_INSTALL_DOCKER" != "yes" ]; then
        fail "Docker is not installed and AUTO_INSTALL_DOCKER is not yes"
    fi

    detect_os
    log "Installing Docker Engine and Docker Compose plugin for $OS_ID $OS_CODENAME"

    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings

    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL "https://download.docker.com/linux/$OS_ID/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
    else
        warn "Docker GPG key already exists, keeping it"
    fi

    DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
    if [ ! -f "$DOCKER_LIST" ]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $OS_CODENAME stable" > "$DOCKER_LIST"
    else
        warn "Docker apt source already exists, keeping it"
    fi

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker >/dev/null 2>&1 || true
    systemctl start docker >/dev/null 2>&1 || true

    command -v docker >/dev/null 2>&1 || fail "Docker installation failed"
    docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin installation failed"
}

safe_mkdirs() {
    log "Creating project directories"
    mkdir -p "$INSTALL_DIR" "$SOURCE_DIR" "$DATA_DIR" "$BACKUP_DIR"
    mkdir -p "$DATA_DIR/postgres" "$DATA_DIR/synapse" "$DATA_DIR/coturn"
}

check_protected_assets() {
    log "Protected assets policy"
    echo "  - FastPanel configs will NOT be modified"
    echo "  - ArtistFlow will NOT be modified"
    echo "  - widget.stackworks.ru will NOT be modified"
}

check_requirements() {
    log "Checking requirements"
    install_docker
    need_command docker
    docker compose version >/dev/null 2>&1 || fail "Docker Compose plugin is required"
    need_command sed
    need_command grep
    need_command ss
}

write_env() {
    if [ -f "$ENV_FILE" ]; then
        warn ".env already exists, keeping it: $ENV_FILE"
        return
    fi

    log "Creating .env"
    POSTGRES_PASSWORD="$(random_secret)"
    REGISTRATION_SHARED_SECRET="$(random_secret)"
    MACAROON_SECRET_KEY="$(random_secret)"
    FORM_SECRET="$(random_secret)"

    cat > "$ENV_FILE" <<EOF
SERVER_NAME=$SERVER_NAME
REPORT_STATS=$REPORT_STATS
POSTGRES_DB=synapse
POSTGRES_USER=synapse
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
REGISTRATION_SHARED_SECRET=$REGISTRATION_SHARED_SECRET
MACAROON_SECRET_KEY=$MACAROON_SECRET_KEY
FORM_SECRET=$FORM_SECRET
EOF

    chmod 600 "$ENV_FILE"
}

ensure_compose_file() {
    [ -f "$COMPOSE_FILE" ] || fail "docker-compose.yml not found: $COMPOSE_FILE"
}

generate_synapse_config() {
    if [ -f "$DATA_DIR/synapse/homeserver.yaml" ]; then
        warn "Synapse config already exists, keeping it"
        return
    fi

    log "Generating Synapse config for $SERVER_NAME"
    docker run --rm \
        -v "$DATA_DIR/synapse:/data" \
        -e SYNAPSE_SERVER_NAME="$SERVER_NAME" \
        -e SYNAPSE_REPORT_STATS="$REPORT_STATS" \
        matrixdotorg/synapse:latest generate

    [ -f "$DATA_DIR/synapse/homeserver.yaml" ] || fail "Synapse config was not generated"
}

patch_synapse_config() {
    if grep -q "SWChat managed PostgreSQL database config" "$DATA_DIR/synapse/homeserver.yaml" 2>/dev/null; then
        warn "Synapse config already patched, skipping"
        return
    fi

    log "Patching Synapse config for PostgreSQL and reverse proxy"
    cp "$DATA_DIR/synapse/homeserver.yaml" "$BACKUP_DIR/homeserver.yaml.$(date +%F_%H-%M-%S).bak"

    cat >> "$DATA_DIR/synapse/homeserver.yaml" <<'EOF'

# SWChat managed PostgreSQL database config
database:
  name: psycopg2
  args:
    user: synapse
    password: __POSTGRES_PASSWORD__
    database: synapse
    host: postgres
    cp_min: 5
    cp_max: 10

# SWChat reverse proxy mode
public_baseurl: https://__SERVER_NAME__/
trusted_key_servers:
  - server_name: matrix.org
EOF

    . "$ENV_FILE"
    sed -i "s|__POSTGRES_PASSWORD__|$POSTGRES_PASSWORD|g" "$DATA_DIR/synapse/homeserver.yaml"
    sed -i "s|__SERVER_NAME__|$SERVER_NAME|g" "$DATA_DIR/synapse/homeserver.yaml"
}

start_stack() {
    if [ "$AUTO_START" != "yes" ]; then
        warn "AUTO_START is not yes, skipping docker compose up"
        return
    fi

    log "Starting SWChat containers"
    cd "$SOURCE_DIR"
    docker compose --env-file "$ENV_FILE" up -d
}

show_next_steps() {
    echo
    echo "== Installation complete =="
    echo
    echo "Matrix local endpoint: http://127.0.0.1:8008"
    echo "Server name: $SERVER_NAME"
    echo "Install dir: $INSTALL_DIR"
    echo
    echo "FastPanel was NOT modified. Configure reverse proxy manually when ready:"
    echo "  https://$SERVER_NAME -> http://127.0.0.1:8008"
    echo
    echo "Healthcheck:"
    echo "  sudo bash $SOURCE_DIR/scripts/healthcheck.sh"
    echo
}

main() {
    echo "== $PROJECT_NAME Auto Installer =="
    need_root
    check_protected_assets
    safe_mkdirs
    check_requirements
    ensure_compose_file
    write_env
    generate_synapse_config
    patch_synapse_config
    start_stack
    show_next_steps
}

main "$@"
