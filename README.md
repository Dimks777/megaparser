# Telegram Parser

Self-hosted web service for parsing public Telegram channels, AI-rewriting posts, and publishing them to your own channels via Bot API.

**Stack:** FastAPI + SQLAlchemy async, React 18 + Vite + TypeScript, PostgreSQL.

## Requirements

- Python 3.11+
- Node.js 18+
- PostgreSQL 14+
- Telegram API credentials ([my.telegram.org](https://my.telegram.org))
- Telegram Bot token ([@BotFather](https://t.me/BotFather))
- OpenAI API key ([platform.openai.com](https://platform.openai.com))

## Getting Started

### 1. Clone the repository

```bash
git clone git@github.com:Dimks777/megaparser.git
cd megaparser
```

### 2. Create the database

```sql
CREATE DATABASE telegram_parser;
```

### 3. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` and fill in all values:

| Variable | Description |
|---|---|
| `TELEGRAM_API_ID` | App `api_id` from [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_API_HASH` | App `api_hash` from [my.telegram.org](https://my.telegram.org) |
| `TELEGRAM_BOT_TOKEN` | Bot token from [@BotFather](https://t.me/BotFather). The bot must be added as **admin** to all target channels |
| `OPENAI_API_KEY` | API key from [platform.openai.com](https://platform.openai.com) |
| `DATABASE_URL` | PostgreSQL connection string, e.g. `postgresql+asyncpg://user:password@localhost:5432/telegram_parser` |
| `ALLOWED_USER_ID` | Your numeric Telegram user ID (get it from [@userinfobot](https://t.me/userinfobot)). Only this user can log in |

### 4. Start the backend

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
alembic upgrade head
uvicorn main:app --reload --port 8000
```

### 5. Start the frontend

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173

## Usage

1. Log in with your Telegram phone number (QR code or SMS)
2. Add your target channel(s) under "My Channels"
3. Add source channels and link them to your channels
4. Click a source channel → "Fetch Posts" to parse latest posts
5. Click a post → "Rewrite with AI" → edit if needed → "Publish"

## Production Deployment

Example configs for deployment on a Linux server are in the `deploy/` directory:

- `nginx.conf` — Nginx reverse proxy with SSL
- `megaparser.service` — systemd unit for the backend
- `deploy.sh` — pull, build, and restart script

```bash
# Build frontend for production
cd frontend
npm run build

# Run backend with uvicorn
cd backend
uvicorn main:app --host 127.0.0.1 --port 8000 --workers 1
```

## Project Structure

```
backend/
  main.py              # FastAPI app, startup, CORS
  config.py            # Pydantic settings from .env
  models.py            # SQLAlchemy models
  database.py          # Async engine & session
  telegram_client.py   # Telethon MTProto client (parsing & media download)
  bot_publisher.py     # Bot API publisher (sendMessage / sendPhoto / sendMediaGroup)
  ai_rewriter.py       # OpenAI GPT-4o rewriter
  routers/
    auth.py            # Phone login, QR login, session management
    channels.py        # My channels & source channels CRUD
    posts.py           # Post list, rewrite, publish, discard
    admin.py           # Admin panel endpoints
  alembic/             # Database migrations
frontend/
  src/
    pages/             # Login, Dashboard, Admin
    components/        # Sidebar, PostCard, PostEditor
    api/client.ts      # Axios client
deploy/                # Nginx, systemd, deploy script
```

## License

MIT

---

> Developed and maintained by [hamster.club](https://hamster.club)
