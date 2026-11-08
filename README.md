# Задание 2: Hermes Agent на VPS

Развёртывание Hermes Agent (Docker, Telegram-шлюз) + навык `arxiv-digest`.

Сравнение платформ и обоснование выбора для P1: [T1. Сравнительный анализ платформ автономных агентов](docs/T1-platform-comparison.md).

## Порядок
1. Арендовать VPS (Ubuntu 22.04+, 1 vCPU/1 ГБ), отдельный, без личных данных. Лимит расходов у LLM-провайдера — до первого запуска.
2. `PUBKEY='...' bash scripts/01-harden-server.sh` (root), далее входить как `agent`.
3. `bash scripts/02-install-docker.sh`
4. @BotFather -> `/newbot` (токен); свой числовой id — через @Getmyid_Work_Bot.
5. `bash scripts/03-setup-agent.sh` (провайдер, ключ, модель с контекстом >= 64k, токен бота, свой id)
6. Скопировать `memory/*.md` и `skills/*` в `~/.hermes` (точные подпапки проверить после setup: `ls -R ~/.hermes`).
7. `bash scripts/04-verify.sh`
8. Заполнить `docs/p1-evidence.md` и `docs/debug-log.md`.

## Безопасность
Доступ к боту = доступ к серверу. Только свой id в `TELEGRAM_ALLOWED_USERS`, `GATEWAY_ALLOW_ALL_USERS` не включать, не запускать от root, ключи не коммитить (`.gitignore`).

## Отчёт и материалы
- Отчёт по разделу «Ход работы» и P1: [docs/P1-deployment-report.md](docs/P1-deployment-report.md)
- Сравнение платформ (T1): [docs/T1-platform-comparison.md](docs/T1-platform-comparison.md)
- Журнал отладки: [docs/debug-log.md](docs/debug-log.md)
- Журналы старта и cron: [docs/logs/](docs/logs/); скриншоты: [docs/img/](docs/img/)

Фактический запуск выполнен на локальной виртуальной машине (Lima, Ubuntu 24.04). Скрипты `scripts/01-harden-server.sh` и `scripts/03-setup-agent.sh` рассчитаны на арендованный VPS; порядок действий для виртуальной машины описан в отчёте, раздел 6. Секреты (`OPENROUTER_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_ALLOWED_USERS`) хранятся в `~/.hermes/.env` вне репозитория, навыки лежат в `~/.hermes/skills/`, память в `~/.hermes/memories/`.
