# Telegram WebApp auth + orders (Node.js backend)

## Минимальные требования

- Node.js >= 20.11
- Supabase Postgres (service role ключ)
- Telegram Bot Token

## Запуск

```bash
cd server
pnpm install
cp .env.example .env
pnpm dev
```

## Переменные окружения

| Переменная | Назначение |
| --- | --- |
| `PORT` | Порт API |
| `CORS_ORIGIN` | Разрешённый origin для web |
| `SUPABASE_URL` | URL Supabase проекта |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (нужен для записи) |
| `TELEGRAM_BOT_TOKEN` | Bot Token для проверки initData |
| `TELEGRAM_AUTH_MAX_AGE_SECONDS` | TTL initData (секунды) |
| `AUTH_JWT_SECRET` | Секрет для JWT сессии |
| `ADMIN_API_KEY` | Ключ администратора для обновления настроек |

## API

### POST /auth/telegram

Тело:
```json
{ "initData": "<telegram-init-data>" }
```

Ответ:
```json
{ "token": "<jwt>", "profile": { "...": "..." } }
```

### GET /ordering-settings

Ответ:
```json
{ "id": 1, "ordering_enabled": true, "preorder_enabled": true }
```

### PATCH /ordering-settings

Заголовок:
```
x-admin-key: <ADMIN_API_KEY>
```

Тело:
```json
{ "ordering_enabled": false, "preorder_enabled": true }
```

### POST /orders

Заголовок:
```
Authorization: Bearer <jwt>
```

Тело:
```json
{
  "items": [{ "sku": "pizza-1", "title": "Маргарита", "quantity": 1, "price": 550 }],
  "note": "Без лука"
}
```

Если приём заказов выключен, но разрешён предзаказ — заказ создаётся как `order_type=preorder`.
