# 📡 MegaParser — Hamster Club

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Часть InvestClub](https://img.shields.io/badge/🐹%20Часть-humster.club-F59E0B)](https://humster.club) [![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi)](https://fastapi.tiangolo.com) [![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://react.dev) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-4169E1?logo=postgresql)](https://www.postgresql.org)

Самостоятельно размещаемый веб-сервис для **парсинга публичных Telegram-каналов**, AI-переписывания постов через GPT и публикации в собственные каналы через Bot API. Один пользователь, один сервер, полный контроль над потоком контента.

> 🎯 **Что даёт:** перестаёшь копировать посты руками. Подключил каналы-источники → MegaParser собирает свежие посты → GPT переписывает их в твоём стиле → публикует в твои каналы автоматически.

---

## 🧱 Стек технологий

| Часть | Технологии |
|---|---|
| **Backend** | FastAPI · SQLAlchemy async · Alembic · Telethon · Python 3.11+ |
| **Frontend** | React 18 · Vite · TypeScript · Axios |
| **База** | PostgreSQL 14+ |
| **AI** | OpenAI GPT-4o для переписывания постов |
| **Публикация** | Telegram Bot API (sendMessage / sendPhoto / sendMediaGroup) |

---

## 📋 Что нужно для установки

- **Python** 3.11+
- **Node.js** 18+
- **PostgreSQL** 14+
- **Telegram API credentials** — `api_id` и `api_hash` с [my.telegram.org](https://my.telegram.org)
- **Telegram Bot Token** от [@BotFather](https://t.me/BotFather) (бот должен быть **администратором** во всех твоих целевых каналах)
- **OpenAI API key** с [platform.openai.com](https://platform.openai.com)

---

## ⚡ Быстрый старт

### 1. Клонировать репозиторий

```bash
git clone https://github.com/Dimks777/megaparser.git
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

Отредактируй `.env` и заполни значения:

| Переменная | Описание |
|---|---|
| `TELEGRAM_API_ID` | `api_id` приложения с [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_API_HASH` | `api_hash` приложения с [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_BOT_TOKEN` | Токен бота от [@BotFather](https://t.me/BotFather). Бот должен быть **администратором** во всех целевых каналах |
| `OPENAI_API_KEY` | API-ключ с [platform.openai.com](https://platform.openai.com) |
| `DATABASE_URL` | Строка подключения PostgreSQL, например `postgresql+asyncpg://user:password@localhost:5432/telegram_parser` |
| `ALLOWED_USER_ID` | Твой числовой Telegram user ID (узнай через [@userinfobot](https://t.me/userinfobot)). Только этот пользователь может войти |

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

Открой [http://localhost:5173](http://localhost:5173) — увидишь страницу входа.

---

## 🎯 Как пользоваться

1. **Войди через номер телефона Telegram** (QR-код или SMS — твой выбор)
2. **Добавь свои целевые каналы** в разделе «Мои каналы» — это те, куда будут публиковаться переписанные посты
3. **Добавь каналы-источники** и привяжи их к своим целевым каналам (один источник может писать в несколько целевых)
4. **Нажми на источник → «Получить посты»** — парсер стянет последние публикации
5. **Нажми на пост → «Переписать с AI»** → отредактируй при желании → **«Опубликовать»**
6. Пост уходит в твой целевой канал через Bot API

---

## 🚢 Деплой на сервер

Готовые конфиги для Linux-сервера в папке `deploy/`:

- `nginx.conf` — Nginx reverse proxy с SSL
- `megaparser.service` — systemd-юнит для бэкенда
- `deploy.sh` — скрипт для `git pull` + сборка + рестарт

```bash
# Сборка фронтенда для продакшена
cd frontend && npm run build

# Запуск бэкенда через uvicorn (1 воркер, только localhost)
cd backend && uvicorn main:app --host 127.0.0.1 --port 8000 --workers 1
```

Nginx проксирует наружу: `/` → статика из `frontend/dist`, `/api/*` → бэкенд `127.0.0.1:8000`.

---

## 🗂 Структура проекта

```
backend/
  main.py              # FastAPI приложение, запуск, CORS
  config.py            # Pydantic настройки из .env
  models.py            # SQLAlchemy модели
  database.py          # Async engine + session
  telegram_client.py   # Telethon MTProto клиент (парсинг, медиа)
  bot_publisher.py     # Bot API паблишер
  ai_rewriter.py       # Переписывание через OpenAI GPT-4o
  routers/
    auth.py            # Вход по телефону, QR, управление сессией
    channels.py        # CRUD каналов и источников
    posts.py           # Список постов, AI, публикация, отклонение
    admin.py           # Эндпоинты админ-панели
  alembic/             # Миграции базы данных

frontend/
  src/
    pages/             # Login, Dashboard, Admin
    components/        # Sidebar, PostCard, PostEditor
    api/client.ts      # Axios клиент

deploy/                # Nginx, systemd, deploy-скрипт
```

---

## 🛡 Безопасность

- **Single-user mode** — только один пользователь может войти (указан в `ALLOWED_USER_ID`). Никто другой не получит доступ даже если узнает адрес
- **MTProto session** хранится локально в зашифрованном виде
- **Bot Token** живёт только в `.env` и памяти процесса, наружу не уходит
- **OpenAI key** — аналогично, только в `.env`
- **Nginx reverse proxy** с SSL (Let's Encrypt) обязателен для прода

---

## 📚 Связанные продукты InvestClub

| Репо | Что это |
|---|---|
| 🤖 [Dimks777/aiclub](https://github.com/Dimks777/aiclub) | Полная Фабрика Контента — 5 AI-агентов |
| 🐹 [Dimks777/aiclublight](https://github.com/Dimks777/aiclublight) | Lite-версия — 1 координатор + 5 скиллов |
| 📊 [Dimks777/content-factory](https://github.com/Dimks777/content-factory) | Контент-завод — веб-дашборд для 8 соцсетей |
| 🧠 [Dimks777/awesome-claude-skills](https://github.com/Dimks777/awesome-claude-skills) | 81 скилл для Claude Code |

---

## 📜 Лицензия

MIT License — свободно используй, модифицируй и распространяй. См. [LICENSE](LICENSE).

---

🐹 Часть проекта **[humster.club](https://humster.club)** — клуб AI-энтузиастов и инвесторов InvestClub.

💬 По вопросам: [@algot888](https://t.me/algot888)
