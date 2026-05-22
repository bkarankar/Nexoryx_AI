# Nexoryx AI Workspace

Nexoryx-grade local AI platform installer for:

- WSL2
- Ubuntu 24.04
- AI Workstations
- GPU Servers
- Developer Laptops

This installer automatically deploys:

- Docker
- Ollama
- Open WebUI
- PostgreSQL
- Redis
- Qdrant
- FastAPI Backend
- AI Models
- Docker Compose Stack

---


# Features

## AI Infrastructure

- Ollama LLM Runtime
- Open WebUI Chat Interface
- Vector Database (Qdrant)
- PostgreSQL Database
- Redis Cache
- FastAPI API Backend

## AI Models

Automatically installs:

- phi3
- gemma
- tinyllama
- qwen2.5
- mistral
- deepseek-coder
- codellama

## Nexoryx Features

- WSL2 networking fixes
- Auto Docker setup
- AI server ready
- Multi-model deployment
- Persistent storage
- Simple management scripts

---

# Requirements

## OS

- Ubuntu 24.04

## Hardware

Recommended:

- 16GB+ RAM
- NVIDIA GPU optional
- 100GB+ storage

---

# Installation

## Clone Repository

```bash
git clone https://github.com/bkarankar/Nexoryx_AI.git

cd Nexoryx-ai-workspace
```

## Run Installer

```bash
chmod +x install.sh

./install.sh
```

---

# Access URLs

## Open WebUI

http://localhost:3000

## FastAPI Backend

http://localhost:8000

## Qdrant Dashboard

http://localhost:6333/dashboard

---

# Management Commands

```bash
cd ~/ai-workspace

./manage.sh status
./manage.sh logs
./manage.sh models
./manage.sh restart
```

---

# Future Roadmap

- Kubernetes Support
- GPU Auto Detection
- AI Marketplace
- One-click Model Installer
- Multi-user Authentication
- Monitoring Dashboard
- Grafana Integration
- Prometheus Integration

---

# License

MIT License
