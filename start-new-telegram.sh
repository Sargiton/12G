#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ЗАПУСК НОВОГО TELEGRAM БОТА ${NC}"
echo -e "${BLUE}================================${NC}"

# Останавливаем старые Telegram боты
echo -e "${YELLOW}🛑 Останавливаем старые Telegram боты...${NC}"
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true
pm2 stop new-telegram-bot 2>/dev/null || true
pm2 delete new-telegram-bot 2>/dev/null || true

# Ждем
sleep 2

# Проверяем файл нового бота
echo -e "${YELLOW}🔍 Проверяем новый Telegram бот...${NC}"
if [ ! -f "new-telegram-bot.js" ]; then
    echo -e "${RED}❌ Файл new-telegram-bot.js не найден!${NC}"
    exit 1
fi

# Устанавливаем зависимости
echo -e "${YELLOW}📦 Устанавливаем зависимости...${NC}"
npm install node-telegram-bot-api --save

# Создаем папку для логов
echo -e "${YELLOW}📁 Создаем папку для логов...${NC}"
mkdir -p logs

# Запускаем новый Telegram бот
echo -e "${YELLOW}🤖 Запускаем новый Telegram бот...${NC}"
pm2 start ecosystem-new-telegram.cjs

# Сохраняем PM2
echo -e "${YELLOW}💾 Сохраняем PM2 конфигурацию...${NC}"
pm2 save

# Ждем запуска
echo -e "${YELLOW}⏳ Ждем запуска...${NC}"
sleep 5

# Показываем статус
echo -e "${GREEN}✅ Статус всех ботов:${NC}"
pm2 list

echo ""
echo -e "${GREEN}📋 Логи нового Telegram бота:${NC}"
pm2 logs new-telegram-bot --lines 15

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ НОВЫЙ TELEGRAM БОТ ЗАПУЩЕН!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления:${NC}"
echo -e "  Логи: ${GREEN}pm2 logs new-telegram-bot --lines 50${NC}"
echo -e "  Перезапуск: ${GREEN}pm2 restart new-telegram-bot${NC}"
echo -e "  Остановка: ${GREEN}pm2 stop new-telegram-bot${NC}"
echo ""
echo -e "${YELLOW}🤖 Telegram команды бота:${NC}"
echo -e "  /start - Меню бота"
echo -e "  /qr - Получить QR код"
echo -e "  /status - Статус WhatsApp бота"
echo -e "  /logs - Логи WhatsApp бота"
echo -e "  /restart - Перезапустить WhatsApp бота"
echo -e "  /stop - Остановить WhatsApp бота"
echo -e "  /start_wa - Запустить WhatsApp бота"
echo -e "  /reset - Сбросить сессию WhatsApp"
echo ""
echo -e "${BLUE}================================${NC}"
