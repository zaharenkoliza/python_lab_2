# Журнал отладки (минимум 3 реальные ошибки — заполнять по ходу)
| # | Текст ошибки | Гипотеза | Проверка | Решение |
|---|---|---|---|---|
| 1 | `[Telegram] Connect attempt 1/8 failed: Timed out`, `gateway.run: ✗ telegram error: telegram connect timed out after 45s` | Telegram недоступен из сети или контейнера | `curl https://api.telegram.org/` из ВМ и из контейнера вернул 302 за 0,3 с, DNS резолвится в 149.154.166.110. Значит, сеть в порядке, а таймаут вызван первичным обнаружением fallback-адресов через DNS-over-HTTPS | Исправлять не потребовалось: шлюз сам переподключился через ~30 с (`Auto-discovered Telegram fallback IPs`, `Connected to Telegram (polling mode)`). Вывод: после первого старта подождать минуту, прежде чем искать неисправность |
| 2 | | | | |
| 3 | | | | |
Типичные кандидаты: `0 total bundled` / `No messaging platforms enabled` (неверная точка монтирования), HTTP 429 на `:free` модели, `Auxiliary title generation failed`.
