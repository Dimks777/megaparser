#!/bin/bash
# MegaParser — Установщик v1.0
# Парсер Telegram-каналов с AI-переписыванием для участников InvestClub

# === Цвета ===
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[32m"
CYAN="\033[36m"
RED="\033[31m"
YELLOW="\033[33m"
CHECK="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"
ARROW="${CYAN}→${RESET}"

# ============================================================
#  ЛИЦЕНЗИОННАЯ ПРОВЕРКА (InvestClub)
#  Этот установщик предназначен только для участников клуба.
#  Лицензию выдаёт бот @aiclub10_bot после проверки членства.
# ============================================================

GATE_VERIFY_URL="${GATE_VERIFY_URL:-http://humsterclub.duckdns.org/gate-full/verify}"
LICENSE_FILE_HOME="$HOME/.openclaw/.aiclub-license"
LICENSE_FILE_LOCAL="$(pwd)/.aiclub-license"

# Получаем ключ из env, локального файла или из home
LICENSE_KEY="${AICLUB_LICENSE_KEY:-}"
if [ -z "$LICENSE_KEY" ] && [ -f "$LICENSE_FILE_LOCAL" ]; then
  LICENSE_KEY=$(cat "$LICENSE_FILE_LOCAL" 2>/dev/null | tr -d '[:space:]')
fi
if [ -z "$LICENSE_KEY" ] && [ -f "$LICENSE_FILE_HOME" ]; then
  LICENSE_KEY=$(cat "$LICENSE_FILE_HOME" 2>/dev/null | tr -d '[:space:]')
fi

if [ -z "$LICENSE_KEY" ]; then
  echo ""
  echo -e "  ${RED}❌ Лицензионный ключ не найден${RESET}"
  echo ""
  echo -e "  Этот установщик MegaParser предназначен только для участников ${BOLD}клуба InvestClub${RESET}."
  echo ""
  echo -e "  ${BOLD}Получи персональный ключ:${RESET}"
  echo -e "    1. Открой бота ${CYAN}@aiclub10_bot${RESET} в Telegram"
  echo -e "    2. Напиши команду ${CYAN}/megaparser${RESET}"
  echo -e "    3. Бот проверит твоё членство в группе и пришлёт готовую команду установки"
  echo ""
  echo -e "  ${DIM}Документация: https://humster.club/aiclub/tools/megaparser.html${RESET}"
  echo ""
  exit 1
fi

# Проверка лицензии через gate-сервер
echo ""
echo -e "  ${ARROW} Проверяю лицензию MegaParser..."
RESULT=$(curl -sf --max-time 10 "${GATE_VERIFY_URL}?key=${LICENSE_KEY}" 2>/dev/null || echo "")

if echo "$RESULT" | grep -q '"valid":true'; then
  MEMBER=$(echo "$RESULT" | sed -n 's/.*"member":"\([^"]*\)".*/\1/p')
  echo -e "  ${CHECK} Лицензия активна (участник: ${BOLD}${MEMBER:-unknown}${RESET})"
elif echo "$RESULT" | grep -q '"valid":false'; then
  REASON=$(echo "$RESULT" | sed -n 's/.*"reason":"\([^"]*\)".*/\1/p')
  echo -e "  ${CROSS} Лицензия не действительна (${REASON:-unknown})"
  echo ""
  echo -e "  Возможно, ты вышел из группы Десятки. Получи новый ключ:"
  echo -e "  → @aiclub10_bot → /megaparser"
  echo ""
  exit 1
else
  echo -e "  ${CROSS} Не удалось связаться с gate-сервером ($GATE_VERIFY_URL)"
  echo -e "  Проверь интернет и повтори установку."
  exit 1
fi
echo ""

# ============================================================
#  ОСНОВНАЯ УСТАНОВКА
# ============================================================

clear 2>/dev/null || true
echo ""
echo -e "  ${BOLD}${CYAN}📡 MegaParser${RESET}"
echo -e "  ${BOLD}Парсер Telegram-каналов с AI-переписыванием${RESET}"
echo -e "  ═══════════════════════════════════════"
echo ""

# === Проверка зависимостей ===
echo -e "  ${ARROW} Проверяю системные зависимости..."
MISSING=""
for cmd in git python3 node npm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING="$MISSING $cmd"
  fi
done

if ! command -v psql >/dev/null 2>&1 && ! command -v pg_isready >/dev/null 2>&1; then
  MISSING="$MISSING postgresql"
fi

if [ -n "$MISSING" ]; then
  echo -e "  ${YELLOW}⚠${RESET} Не хватает:$MISSING"
  echo ""
  echo -e "  ${BOLD}Ubuntu / Debian:${RESET}"
  echo -e "  ${CYAN}sudo apt update${RESET}"
  echo -e "  ${CYAN}sudo apt install -y git python3 python3-venv python3-pip postgresql postgresql-contrib${RESET}"
  echo -e "  ${CYAN}curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -${RESET}"
  echo -e "  ${CYAN}sudo apt install -y nodejs${RESET}"
  echo ""
  exit 1
fi
echo -e "  ${CHECK} git, python3, node, npm, postgresql"

# === Сохранение лицензии локально ===
echo "$LICENSE_KEY" > "$(pwd)/.aiclub-license"
chmod 644 "$(pwd)/.aiclub-license"

# Добавляем в .gitignore
if [ -f ".gitignore" ] && ! grep -q '^\.aiclub-license' .gitignore; then
  echo ".aiclub-license" >> .gitignore
fi

# === Подготовка .env ===
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo -e "  ${CHECK} Создан .env из .env.example"
  fi
fi

# === Backend dependencies ===
if [ -d "backend" ]; then
  echo -e "  ${ARROW} Устанавливаю Python-зависимости..."
  cd backend
  python3 -m venv venv 2>/dev/null || true
  source venv/bin/activate
  pip install --quiet --upgrade pip
  pip install --quiet -r requirements.txt && echo -e "  ${CHECK} Backend готов" || {
    echo -e "  ${YELLOW}⚠${RESET} pip install вернул ошибки — проверь вручную"
  }
  deactivate 2>/dev/null || true
  cd ..
fi

echo ""
echo -e "  ${GREEN}✨ Базовая установка завершена!${RESET}"
echo ""
echo -e "  ${BOLD}Дальнейшие шаги — см. полный гайд:${RESET}"
echo -e "  ${CYAN}https://humster.club/aiclub/tools/megaparser.html${RESET}"
echo ""
echo -e "  Кратко:"
echo -e "  1. Заполни ${CYAN}.env${RESET} — Telegram API, Bot token, OpenAI key, DATABASE_URL"
echo -e "  2. Создай PostgreSQL базу и примени миграции: ${CYAN}alembic upgrade head${RESET}"
echo -e "  3. Запусти backend: ${CYAN}uvicorn main:app --host 127.0.0.1 --port 8000${RESET}"
echo -e "  4. Собери frontend: ${CYAN}cd frontend && npm install && npm run build${RESET}"
echo ""
echo -e "  💬 По вопросам: ${CYAN}@algot888${RESET}"
echo ""
