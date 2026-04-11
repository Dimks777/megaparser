# Telegram Parser

Самостоятельно размещаемый веб-сервис для парсинга публичных Telegram-каналов, AI-переписывания постов и их публикации в собственные каналы через Bot API.

**Стек:** FastAPI + SQLAlchemy async, React 18 + Vite + TypeScript, PostgreSQL.

## Требования

- Python 3.11+
- Node.js 18+
- PostgreSQL 14+
- Telegram API credentials ([my.telegram.org](https://my.telegram.org))
- Telegram Bot token ([@BotFather](https://t.me/BotFather))
- OpenAI API key ([platform.openai.com](https://platform.openai.com))

## Быстрый старт

### 1. Клонировать репозиторий

```bash
git clone git@github.com:Dimks777/megaparser.git
cd megaparser
```

### 2. Создать базу данных

```sql
CREATE DATABASE telegram_parser;
```

### 3. Настроить переменные окружения

```bash
cp .env.example .env
```

Отредактируйте `.env` и заполните все значения:

| Переменная | Описание |
|---|---|
| `TELEGRAM_API_ID` | `api_id` приложения с [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_API_HASH` | `api_hash` приложения с [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_BOT_TOKEN` | Токен бота от [@BotFather](https://t.me/BotFather). Бот должен быть **администратором** во всех целевых каналах |
| `OPENAI_API_KEY` | API-ключ с [platform.openai.com](https://platform.openai.com) |
| `DATABASE_URL` | Строка подключения PostgreSQL, например `postgresql+asyncpg://user:password@localhost:5432/telegram_parser` |
| `ALLOWED_USER_ID` | Ваш числовой Telegram user ID (узнайте через [@userinfobot](https://t.me/userinfobot)). Только этот пользователь может войти |

### 4. Запустить бэкенд

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
alembic upgrade head
uvicorn main:app --reload --port 8000
```

### 5. Запустить фронтенд

```bash
cd frontend
npm install
npm run dev
```

Откройте http://localhost:5173

## Использование

1. Войдите через номер телефона Telegram (QR-код или SMS)
2. Добавьте свои целевые каналы в разделе «Мои каналы»
3. Добавьте каналы-источники и привяжите их к своим каналам
4. Нажмите на канал-источник → «Получить посты» — спарсятся последние публикации
5. Нажмите на пост → «Переписать с AI» → отредактируйте при необходимости → «Опубликовать»

## Деплой на сервер

Примеры конфигурации для деплоя на Linux-сервере находятся в папке `deploy/`:

- `nginx.conf` — Nginx reverse proxy с SSL
- `megaparser.service` — systemd-юнит для бэкенда
- `deploy.sh` — скрипт для pull, сборки и перезапуска

```bash
# Сборка фронтенда для продакшена
cd frontend
npm run build

# Запуск бэкенда через uvicorn
cd backend
uvicorn main:app --host 127.0.0.1 --port 8000 --workers 1
```

## Структура проекта

```
backend/
  main.py              # FastAPI приложение, запуск, CORS
  config.py            # Pydantic настройки из .env
  models.py            # SQLAlchemy модели
  database.py          # Async engine & session
  telegram_client.py   # Telethon MTProto клиент (парсинг и загрузка медиа)
  bot_publisher.py     # Bot API паблишер (sendMessage / sendPhoto / sendMediaGroup)
  ai_rewriter.py       # Переписывание через OpenAI GPT-4o
  routers/
    auth.py            # Вход по телефону, QR-вход, управление сессией
    channels.py        # CRUD каналов и источников
    posts.py           # Список постов, переписывание, публикация, отклонение
    admin.py           # Эндпоинты админ-панели
  alembic/             # Миграции базы данных
frontend/
  src/
    pages/             # Login, Dashboard, Admin
    components/        # Sidebar, PostCard, PostEditor
    api/client.ts      # Axios клиент
deploy/                # Nginx, systemd, деплой-скрипт
```

## Лицензия

MIT

---

> Разработано и поддерживается командой [hamster.club](https://hamster.club)
