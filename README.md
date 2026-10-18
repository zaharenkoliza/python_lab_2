# Задание 2: Hermes Agent на VPS

Развёртывание Hermes Agent (Docker, Telegram-шлюз) + навык `arxiv-digest`.

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
