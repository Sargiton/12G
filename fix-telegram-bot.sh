#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ИСПРАВЛЕНИЕ TELEGRAM БОТА   ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем, что мы в правильной директории
if [ ! -d "123" ]; then
    echo -e "${RED}❌ Папка 123 не найдена!${NC}"
    echo -e "${YELLOW}Убедитесь, что вы находитесь в корне проекта 12G${NC}"
    exit 1
fi

# Останавливаем только Telegram бота
echo -e "${YELLOW}🛑 Останавливаем Telegram бота...${NC}"
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Проверяем, что telegram-bot.cjs существует
echo -e "${YELLOW}🔍 Проверяем файл telegram-bot.cjs...${NC}"
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo -e "${RED}❌ Файл telegram-bot.cjs не найден!${NC}"
    exit 1
fi

# Проверяем зависимости для Telegram бота
echo -e "${YELLOW}📦 Проверяем зависимости для Telegram бота...${NC}"
cd 123

# Устанавливаем node-telegram-bot-api если его нет
if ! npm list node-telegram-bot-api >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Устанавливаем node-telegram-bot-api...${NC}"
    npm install node-telegram-bot-api --save
fi

cd ..

# Создаем правильный PM2 конфиг для Telegram бота
echo -e "${YELLOW}⚙️ Создаем конфигурацию PM2 для Telegram бота...${NC}"
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

# Запускаем Telegram бота
echo -e "${YELLOW}🚀 Запускаем Telegram бота...${NC}"
pm2 start ecosystem-telegram.cjs

# Сохраняем PM2
echo -e "${YELLOW}💾 Сохраняем PM2 конфигурацию...${NC}"
pm2 save

# Ждем запуска
echo -e "${YELLOW}⏳ Ждем запуска Telegram бота...${NC}"
sleep 5

# Показываем статус
echo -e "${GREEN}✅ Статус всех ботов:${NC}"
pm2 list

echo ""
echo -e "${GREEN}📋 Логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 20

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ TELEGRAM БОТ ИСПРАВЛЕН!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления:${NC}"
echo -e "  Логи: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Перезапуск: ${GREEN}pm2 restart telegram-bot${NC}"
echo -e "  Остановка: ${GREEN}pm2 stop telegram-bot${NC}"
echo ""
echo -e "${YELLOW}🤖 Telegram команды бота:${NC}"
echo -e "  /get_qr - Получить QR код"
echo -e "  /reset_session - Сбросить сессию"
echo -e "  /restart_whatsapp - Перезапустить WhatsApp бота"
echo -e "  /status - Статус WhatsApp бота"
echo -e "  /logs - Логи WhatsApp бота"
echo ""
echo -e "${BLUE}================================${NC}"
