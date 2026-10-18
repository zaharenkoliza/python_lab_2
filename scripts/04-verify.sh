#!/usr/bin/env bash
# Контрольный признак старта: ненулевое число навыков, нет "No messaging platforms enabled"
docker compose up -d && sleep 15
docker compose logs --tail=100 | tee logs-startup.txt
grep -q "0 total bundled" logs-startup.txt && echo "FAIL: 0 навыков -> проверьте точку монтирования /opt/data"
grep -q "No messaging platforms enabled" logs-startup.txt && echo "FAIL: шлюз не включён"
true
