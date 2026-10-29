# P1. Развёртывание Hermes Agent: отчёт

## 1. Окружение (шаг 1 «Хода работы»)
Вместо аренды VPS использована локальная виртуальная машина (допускается заданием).

| Параметр | Значение |
|---|---|
| Гипервизор | Lima 2.2.1 (vmType `vz`, Apple Virtualization.framework) на Mac с Apple Silicon |
| ОС гостя | Ubuntu 24.04.5 LTS (aarch64) |
| Ресурсы | 2 vCPU, 2 ГиБ RAM, диск 20 ГиБ |
| Стоимость | 0 ₽ (локально) |
| Изоляция | каталоги хоста в ВМ не смонтированы (`--mount-none`): `/Users` в госте отсутствует |
| Пользователь | непривилегированный (uid 501), агент не от root на уровне ВМ |
| Создание | `limactl start --name=hermes --cpus=2 --memory=2 --disk=20 --mount-none template:ubuntu-24.04` |

Ограничение, которое нужно учитывать при оценке автономности: ВМ работает, пока включён и не спит хост.

## 2. Базовая настройка (шаг 2)
- Обновление пакетов: `apt-get update && apt-get upgrade`.
- Вход только по SSH-ключу: ключ создаёт Lima, парольной аутентификации для пользователя нет, порт проброшен только на 127.0.0.1.
- Firewall: `ufw default deny incoming`, `default allow outgoing`, `allow 22/tcp`, статус `active`.

## 3. Docker (шаг 3)
Docker Engine через get.docker.com, Compose v5.6.1. Проверка `docker run --rm hello-world` вывела «Hello from Docker!».

## 4. LLM-провайдер (шаги 4–5)
| Параметр | Значение |
|---|---|
| Провайдер | OpenRouter (агрегатор) |
| Модель | `google/gemma-4-31b-it:free` |
| Контекстное окно | 262 144 токена (по `/api/v1/models`, требование ≥ 64 000 выполнено) |
| Поддержка tools | да (`tools` в `supported_parameters`) |
| Тариф | бесплатный, баланс 0, расход невозможен |
| Лимит расходов | см. скриншот панели ключа (раздел Keys) |

Модель выбрана программным фильтром по каталогу OpenRouter: `:free`, контекст ≥ 64k, поддержка `tools`.

## 5. Агент и шлюз (шаги 6–9)
- Образ: `nousresearch/hermes-agent:latest`, дайджест `sha256:9c5561579f3ffdf333401797094ac3a743738d6c25d40f4331c7bf77b694238d`, Hermes Agent v0.22.5 (2026.9.24).
- Конфигурация и секреты лежат в `~/.hermes` на ВМ (`.env`, права 600), в репозиторий не попадают.
- В `.env` заданы `TELEGRAM_ALLOWED_USERS` (один идентификатор) и `GATEWAY_ALLOW_ALL_USERS=false`.
- Конфиг записан именно в смонтированный каталог: проверено, что `config.yaml` и `.env` появились в `~/.hermes` хоста после запуска `hermes config set` с монтированием `-v ~/.hermes:/opt/data`.
- Файл [compose.yaml](../compose.yaml) монтирует `${HERMES_HOME}` в `/opt/data`.

### Контрольные признаки старта
Полный журнал: [logs/startup-first-run.txt](logs/startup-first-run.txt).
- `Done: 0 new, 0 updated, 58 unchanged. 58 total bundled.` — навыки загружены (58, не 0).
- `[Telegram] Connected to Telegram (polling mode)`.
- `Telegram polling confirmed healthy: getUpdates progressing`.
- Предупреждения «No messaging platforms enabled» нет.
