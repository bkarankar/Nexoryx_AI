#!/usr/bin/env bash

# =========================================================
# AI WORKSPACE INSTALLER v4 ENTERPRISE
# WSL2 + Ubuntu 24.04
#
# FEATURES
# ---------------------------------------------------------
# ✅ Docker
# ✅ Docker Compose
# ✅ Ollama
# ✅ Open WebUI
# ✅ Qdrant
# ✅ Redis
# ✅ PostgreSQL
# ✅ FastAPI Backend
# ✅ WSL Networking Fixes
# ✅ Ollama Auto Binding
# ✅ High-End Server Ready
# ✅ Multi-Model Installation
# ✅ AI Infra Foundation
#
# SUPPORTED HARDWARE
# ---------------------------------------------------------
# - Laptops
# - Workstations
# - AI Servers
# - WSL2
# - Ubuntu 24.04
#
# AUTHOR: ChatGPT
# =========================================================

set -e

GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

WORKSPACE_DIR="$HOME/ai-workspace"

# =========================================================
# MODELS
# =========================================================

MODELS=(
  "phi3:mini"
  "gemma:2b"
  "tinyllama"
  "qwen2.5:3b"
  "mistral"
  "deepseek-coder:6.7b"
  "codellama:7b"
)

# =========================================================
# HELPERS
# =========================================================

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

banner() {

echo -e "${BLUE}"

echo "========================================================"
echo "      AI WORKSPACE INSTALLER v4 ENTERPRISE"
echo "========================================================"

echo -e "${NC}"
}

# =========================================================
# CHECKS
# =========================================================

check_wsl() {

    log "Checking WSL..."

    if grep -qi microsoft /proc/version; then
        log "WSL environment detected."
    else
        warn "Not running in WSL."
    fi
}

check_ubuntu() {

    VERSION=$(lsb_release -rs)

    if [[ "$VERSION" != "24.04" ]]; then
        error "Ubuntu 24.04 required."
        exit 1
    fi

    log "Ubuntu 24.04 detected."
}

show_system_info() {

echo ""
echo "============== SYSTEM INFO =============="

echo ""
echo "CPU:"
lscpu | grep "Model name"

echo ""
echo "RAM:"
free -h

echo ""
echo "DISK:"
df -h /

echo ""
echo "GPU:"
lspci | grep -i vga || true

echo ""
echo "========================================="
echo ""
}

# =========================================================
# BASE PACKAGES
# =========================================================

install_base_packages() {

    log "Installing base packages..."

    sudo apt update

    sudo apt install -y \
        curl \
        wget \
        git \
        unzip \
        zstd \
        jq \
        htop \
        net-tools \
        build-essential \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        python3 \
        python3-pip \
        python3-venv
}

# =========================================================
# DOCKER
# =========================================================

install_docker() {

    if command -v docker >/dev/null 2>&1; then
        warn "Docker already installed."
        return
    fi

    log "Installing Docker..."

    sudo install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update

    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    sudo usermod -aG docker $USER

    sudo service docker start || true

    log "Docker installation completed."
}

verify_docker() {

    log "Verifying Docker..."

    if ! docker info >/dev/null 2>&1; then

        warn "Docker permission issue."

        echo ""
        echo "RUN:"
        echo ""
        echo "newgrp docker"
        echo ""
        echo "THEN rerun installer."
        echo ""

        exit 1
    fi

    log "Docker working correctly."
}

# =========================================================
# OLLAMA
# =========================================================

install_ollama() {

    if command -v ollama >/dev/null 2>&1; then
        warn "Ollama already installed."
        return
    fi

    log "Installing Ollama..."

    curl -fsSL https://ollama.com/install.sh | sh

    log "Ollama installed."
}

configure_ollama_service() {

    log "Configuring Ollama..."

    pkill ollama || true

    nohup env OLLAMA_HOST=0.0.0.0:11434 ollama serve \
        > "$WORKSPACE_DIR/logs/ollama.log" 2>&1 &

    sleep 10

    if ! curl -s http://127.0.0.1:11434/api/tags >/dev/null; then
        error "Ollama failed to start."
        exit 1
    fi

    log "Ollama running successfully."
}

# =========================================================
# MODELS
# =========================================================

install_models() {

    log "Installing AI models..."

    for MODEL in "${MODELS[@]}"
    do
        echo ""
        echo "Installing model: $MODEL"
        echo ""

        ollama pull "$MODEL"
    done

    log "All models installed."
}

# =========================================================
# WORKSPACE
# =========================================================

create_workspace() {

    log "Creating workspace..."

    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR/logs"
    mkdir -p "$WORKSPACE_DIR/backend"
    mkdir -p "$WORKSPACE_DIR/data"
}

# =========================================================
# DOCKER COMPOSE
# =========================================================

create_docker_compose() {

log "Creating Docker Compose stack..."

cat > "$WORKSPACE_DIR/docker-compose.yml" <<'EOF'
services:

  open-webui:
    image: ghcr.io/open-webui/open-webui:main

    container_name: open-webui

    ports:
      - "3000:8080"

    environment:
      - OLLAMA_BASE_URL=http://172.17.0.1:11434

    volumes:
      - open-webui:/app/backend/data

    restart: unless-stopped

  qdrant:
    image: qdrant/qdrant

    container_name: qdrant

    ports:
      - "6333:6333"

    volumes:
      - qdrant_data:/qdrant/storage

    restart: unless-stopped

  redis:
    image: redis:7

    container_name: redis

    ports:
      - "6379:6379"

    restart: unless-stopped

  postgres:
    image: postgres:16

    container_name: postgres

    environment:
      POSTGRES_USER: aiuser
      POSTGRES_PASSWORD: aipassword
      POSTGRES_DB: aidb

    ports:
      - "5432:5432"

    volumes:
      - postgres_data:/var/lib/postgresql/data

    restart: unless-stopped

volumes:
  open-webui:
  qdrant_data:
  postgres_data:
EOF
}

# =========================================================
# START CONTAINERS
# =========================================================

start_containers() {

    log "Starting containers..."

    cd "$WORKSPACE_DIR"

    docker compose down || true

    docker rm -f open-webui || true

    docker compose up -d

    sleep 20

    log "Containers started."
}

# =========================================================
# VERIFY NETWORK
# =========================================================

verify_container_connectivity() {

    log "Testing Open WebUI connectivity..."

    if docker exec open-webui curl -s \
        http://172.17.0.1:11434/api/tags >/dev/null; then

        log "Container connectivity successful."

    else

        error "Open WebUI cannot reach Ollama."

        echo ""
        echo "Try:"
        echo ""
        echo "wsl --shutdown"
        echo ""
        echo "Then reopen Ubuntu and rerun script."
        echo ""

        exit 1
    fi
}

# =========================================================
# FASTAPI BACKEND
# =========================================================

create_fastapi_backend() {

log "Creating FastAPI backend..."

cat > "$WORKSPACE_DIR/backend/main.py" <<'EOF'
from fastapi import FastAPI
import subprocess

app = FastAPI()

@app.get("/")
def root():
    return {"status": "AI Workspace Running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/models")
def models():

    result = subprocess.run(
        ["ollama", "list"],
        capture_output=True,
        text=True
    )

    return {"models": result.stdout}
EOF

cat > "$WORKSPACE_DIR/backend/requirements.txt" <<'EOF'
fastapi
uvicorn
EOF

cd "$WORKSPACE_DIR/backend"

python3 -m venv venv

source venv/bin/activate

pip install --upgrade pip

pip install -r requirements.txt

nohup ./venv/bin/uvicorn main:app \
    --host 0.0.0.0 \
    --port 8000 \
    > "$WORKSPACE_DIR/logs/fastapi.log" 2>&1 &
}

# =========================================================
# MANAGEMENT SCRIPT
# =========================================================

create_manage_script() {

cat > "$WORKSPACE_DIR/manage.sh" <<'EOF'
#!/usr/bin/env bash

case "$1" in

start)
    docker compose up -d
    ;;

stop)
    docker compose down
    ;;

restart)
    docker compose restart
    ;;

status)
    docker ps
    ;;

logs)
    docker compose logs -f
    ;;

models)
    ollama list
    ;;

ollama)
    curl http://127.0.0.1:11434/api/tags
    ;;

*)
    echo ""
    echo "Usage:"
    echo "./manage.sh {start|stop|restart|status|logs|models|ollama}"
    echo ""
    ;;
esac
EOF

chmod +x "$WORKSPACE_DIR/manage.sh"
}

# =========================================================
# FINAL
# =========================================================

show_final_info() {

echo ""

echo -e "${GREEN}"
echo "========================================================"
echo "          INSTALLATION SUCCESSFUL"
echo "========================================================"
echo -e "${NC}"

echo ""
echo "Open WebUI:"
echo "http://localhost:3000"

echo ""
echo "FastAPI Backend:"
echo "http://localhost:8000"

echo ""
echo "Qdrant:"
echo "http://localhost:6333/dashboard"

echo ""
echo "Installed Models:"
printf '%s\n' "${MODELS[@]}"

echo ""
echo "Workspace:"
echo "$WORKSPACE_DIR"

echo ""
echo "Management:"
echo ""
echo "cd ~/ai-workspace"
echo "./manage.sh status"
echo "./manage.sh logs"
echo "./manage.sh models"

echo ""
echo "If browser does not load:"
echo ""
echo "PowerShell:"
echo "wsl --shutdown"

echo ""
echo "Then reopen Ubuntu."
echo ""
}

# =========================================================
# MAIN
# =========================================================

main() {

    banner

    check_wsl

    check_ubuntu

    show_system_info

    create_workspace

    install_base_packages

    install_docker

    verify_docker

    install_ollama

    configure_ollama_service

    install_models

    create_docker_compose

    start_containers

    verify_container_connectivity

    create_fastapi_backend

    create_manage_script

    show_final_info
}

main