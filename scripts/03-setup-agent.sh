#!/usr/bin/env bash
# Мастер настройки; конфиг пишется в ~/.hermes, который compose монтирует в /opt/data
set -euo pipefail
mkdir -p ~/.hermes
docker run -it --rm -v ~/.hermes:/opt/data nousresearch/hermes-agent:latest setup
ls -la ~/.hermes   # убедиться, что конфиг записан именно сюда
