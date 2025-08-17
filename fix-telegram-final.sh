#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ TELEGRAM БОТА ${NC}"
echo -e "${BLUE}================================${NC}"

# Останавливаем ВСЕ процессы
echo -e "${YELLOW}🛑 Останавливаем ВСЕ процессы...${NC}"
pm2 stop all
pm2 delete all

# Ждем
sleep 3

# Проверяем файл telegram-bot.cjs
echo -e "${YELLOW}🔍 Проверяем файл telegram-bot.cjs...${NC}"
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo -e "${RED}❌ Файл 123/telegram-bot.cjs не найден!${NC}"
    exit 1
fi

# Устанавливаем зависимости если нужно
echo -e "${YELLOW}📦 Проверяем зависимости...${NC}"
cd 123
if ! npm list node-telegram-bot-api >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Устанавливаем node-telegram-bot-api...${NC}"
    npm install node-telegram-bot-api --save
fi
cd ..

# Создаем правильный конфиг с УНИКАЛЬНЫМ именем
echo -e "${YELLOW}⚙️ Создаем правильный конфиг...${NC}"
cat > ecosystem-telegram.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'telegram-bot',
            script: 'telegram-bot.cjs',
            cwd: './123',
            autorestart: true,
            watch: false,
            time: true,
            node_args: '',
            env: {
                NODE_ENV: 'production'
            },
            out_file: './123/logs/telegram-bot-out.log',
            error_file: './123/logs/telegram-bot-error.log',
            log_date_format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
        }
    ]
}
EOF

# Запускаем WhatsApp бота
echo -e "${YELLOW}🚀 Запускаем WhatsApp бота...${NC}"
if [ -f "ecosystem-old.config.cjs" ]; then
    pm2 start ecosystem-old.config.cjs
else
    echo -e "${RED}❌ Файл ecosystem-old.config.cjs не найден!${NC}"
    exit 1
fi

# Ждем
sleep 2

# Запускаем Telegram бота
echo -e "${YELLOW}🤖 Запускаем Telegram бота...${NC}"
pm2 start ecosystem-telegram.cjs

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
echo -e "${GREEN}📋 Логи WhatsApp бота:${NC}"
pm2 logs whatsapp-old --lines 5

echo ""
echo -e "${GREEN}📋 Логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 15

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ TELEGRAM БОТ ФИНАЛЬНО ИСПРАВЛЕН!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления:${NC}"
echo -e "  Логи WhatsApp: ${GREEN}pm2 logs whatsapp-old --lines 50${NC}"
echo -e "  Логи Telegram: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Перезапуск всех: ${GREEN}pm2 restart all${NC}"
echo -e "  Остановка всех: ${GREEN}pm2 stop all${NC}"
echo ""
echo -e "${YELLOW}🤖 Telegram команды бота:${NC}"
echo -e "  /get_qr - Получить QR код"
echo -e "  /reset_session - Сбросить сессию"
echo -e "  /restart_whatsapp - Перезапустить WhatsApp бота"
echo -e "  /status - Статус WhatsApp бота"
echo -e "  /logs - Логи WhatsApp бота"
echo ""
echo -e "${BLUE}================================${NC}"
