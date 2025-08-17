#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ПРОВЕРКА СТАТУСА БОТОВ      ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем PM2 статус
echo -e "${YELLOW}📋 Статус PM2 процессов:${NC}"
pm2 list

echo ""
echo -e "${YELLOW}🔍 Проверяем логи WhatsApp бота:${NC}"
pm2 logs whatsapp-old --lines 20

echo ""
echo -e "${YELLOW}🔍 Проверяем логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 20

echo ""
echo -e "${YELLOW}📁 Проверяем файлы в папке 123:${NC}"
ls -la 123/

echo ""
echo -e "${YELLOW}📁 Проверяем node_modules:${NC}"
if [ -d "123/node_modules" ]; then
    echo -e "${GREEN}✅ node_modules существует${NC}"
    ls 123/node_modules | head -10
else
    echo -e "${RED}❌ node_modules не найден${NC}"
fi

echo ""
echo -e "${YELLOW}📄 Проверяем package.json:${NC}"
if [ -f "123/package.json" ]; then
    echo -e "${GREEN}✅ package.json найден${NC}"
    grep -A 5 -B 5 "dependencies" 123/package.json
else
    echo -e "${RED}❌ package.json не найден${NC}"
fi

echo ""
echo -e "${YELLOW}🔧 Проверяем index.js:${NC}"
if [ -f "123/index.js" ]; then
    echo -e "${GREEN}✅ index.js найден${NC}"
    head -5 123/index.js
else
    echo -e "${RED}❌ index.js не найден${NC}"
fi

echo ""
echo -e "${YELLOW}📊 Проверяем использование памяти:${NC}"
pm2 monit --no-daemon &
sleep 3
pkill -f "pm2 monit"

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}🔧 Команды для диагностики:${NC}"
echo -e "  Перезапуск WhatsApp: ${GREEN}pm2 restart whatsapp-old${NC}"
echo -e "  Перезапуск Telegram: ${GREEN}pm2 restart telegram-bot${NC}"
echo -e "  Логи WhatsApp: ${GREEN}pm2 logs whatsapp-old --lines 50${NC}"
echo -e "  Логи Telegram: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Удалить и переустановить: ${GREEN}pm2 delete all && pm2 start ecosystem-old.config.cjs && pm2 start ecosystem-telegram.cjs${NC}"
echo -e "${BLUE}================================${NC}"
