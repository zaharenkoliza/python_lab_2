#!/usr/bin/env bash
# Запуск от пользователя agent (с sudo)
set -euo pipefail
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"
echo "Перелогиньтесь, затем: docker run --rm hello-world && docker compose version"
