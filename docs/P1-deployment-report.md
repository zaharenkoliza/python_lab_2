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

## 6. Память (шаг 12)
`USER.md` и `MEMORY.md` лежат в `~/.hermes/memories/`. В `MEMORY.md` записана контрольная фраза проекта «янтарный сурок 7421», которой нет нигде в промпте или тексте вопроса. Прямой вопрос через `hermes chat -q` на первой проверке дал ответ с подхватом данных из файлов (язык ответов, ключевое слово из MEMORY.md). Проверка уникальной фразой через Telegram: **[заполнить после ответа бота]**.

## 7. Навык и расписание (шаги 14–15)
Навык `arxiv-digest` лежит в `~/.hermes/skills/research/arxiv-digest/SKILL.md` и виден агенту: `hermes skills list` показывает `arxiv-digest | research | local | enabled`. Исходный текст: [skills/arxiv-digest/SKILL.md](../skills/arxiv-digest/SKILL.md).

Задача планировщика: `hermes cron create "every 5m" … --name arxiv-digest --skill arxiv-digest --deliver telegram --repeat 3`. Результат доставляется в Telegram. Все три запуска произошли по расписанию, без ручного вмешательства (ручной запуск был один, он упал с 429 и в зачёт не идёт).

| Прогон | Старт (UTC) | Длительность, с | prompt-токены | completion-токены | Всего токенов | Результат |
|---|---|---|---|---|---|---|
| 1 | 14:51:33 | 112,3 | 114 261 | 8 099 | 122 360 | дайджест доставлен |
| 2 | 14:58:33 | 112,8 | 99 145 | 9 537 | 108 682 | дайджест доставлен (10 работ) |
| 3 | 15:05:35 | 283,0 | 390 732 | 20 788 | 411 520 | дайджест доставлен |
| (ручной) | 14:45:25 | 11,6 | — | — | — | 429, ошибка |

Условия замера: модель `google/gemma-4-31b-it:free`, провайдер OpenRouter, ВМ Lima 2 vCPU / 2 ГиБ, данные — журнал `usage_audit.jsonl` ([logs/cron/usage_audit.jsonl](logs/cron/usage_audit.jsonl)). Тексты дайджестов: [logs/cron/](logs/cron/). Скриншоты: [img/cron-run1-digest.png](img/cron-run1-digest.png), [img/cron-run2-digest.png](img/cron-run2-digest.png), [img/cron-run2-digest-end.png](img/cron-run2-digest-end.png).

Наблюдения:
- Расход токенов нестабилен: третий прогон израсходовал в 3,4 раза больше второго при том же промпте. Из трёх замеров причину установить нельзя (вероятно, лишние шаги и повторные обращения к API).
- Стоимость фактическая нулевая, модель бесплатная.
- В прогоне 1 есть иероглифы в русском тексте, см. [debug-log.md](debug-log.md), запись 3.
- Ссылки в дайджесте имеют вид `arxiv.org/abs/<id>`; в тексте навыка требуется брать их только из ответа API.

## 8. Автономность: перезагрузка (P1)
Процедура: `limactl stop hermes` в 15:11:14 UTC (ВМ выключена), `limactl start hermes` в 15:11:25. После этого никаких команд запуска агенту не отдавалось.

Результат через 46 секунд после старта ВМ:
- `docker ps`: `hermes_agent  Up 46 seconds`;
- в логах `58 total bundled`, `[Telegram] Connected to Telegram (polling mode)` в 15:11:39;
- политика перезапуска контейнера: `restart=unless-stopped`.

Ограничение: это перезагрузка ВМ, а не физического сервера. Хост (Mac) при этом оставался включённым.

## 9. Журналирование (шаг 16)
Ротация логов контейнера задана в [compose.yaml](../compose.yaml) и подтверждена `docker inspect`: драйвер `json-file`, `max-size=10m`, `max-file=5` (до 50 МБ на контейнер, самые старые файлы удаляются). Журналы агента лежат в `~/.hermes/logs`, журнал cron — в `~/.hermes/cron` (`usage_audit.jsonl`, `executions.db`).
