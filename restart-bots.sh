#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ПОЛНЫЙ ПЕРЕЗАПУСК БОТОВ     ${NC}"
echo -e "${BLUE}================================${NC}"

# Останавливаем все боты
echo -e "${YELLOW}🛑 Останавливаем все боты...${NC}"
pm2 stop all
pm2 delete all

# Ждем немного
sleep 2

# Проверяем, что мы в правильной директории
if [ ! -d "123" ]; then
    echo -e "${RED}❌ Папка 123 не найдена!${NC}"
    echo -e "${YELLOW}Убедитесь, что вы находитесь в корне проекта 12G${NC}"
    exit 1
fi

# Проверяем зависимости
echo -e "${YELLOW}🔍 Проверяем зависимости...${NC}"
cd 123

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Устанавливаем зависимости...${NC}"
    npm install --production --ignore-scripts
fi

cd ..

# Запускаем WhatsApp бота
echo -e "${YELLOW}🚀 Запускаем WhatsApp бота...${NC}"
if [ -f "ecosystem-old.config.cjs" ]; then
    pm2 start ecosystem-old.config.cjs
else
    echo -e "${RED}❌ Файл ecosystem-old.config.cjs не найден${NC}"
    exit 1
fi

# Ждем немного
sleep 3

# Запускаем Telegram бота
echo -e "${YELLOW}🤖 Запускаем Telegram бота...${NC}"
if [ -f "ecosystem-telegram.cjs" ]; then
    pm2 start ecosystem-telegram.cjs
else
    echo -e "${YELLOW}⚠️ Файл ecosystem-telegram.cjs не найден, создаем...${NC}"
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
    pm2 start ecosystem-telegram.cjs
fi

# Сохраняем PM2
echo -e "${YELLOW}💾 Сохраняем PM2 конфигурацию...${NC}"
pm2 save

# Ждем запуска
echo -e "${YELLOW}⏳ Ждем запуска ботов...${NC}"
sleep 5

# Показываем статус
echo -e "${GREEN}✅ Статус ботов:${NC}"
pm2 list

echo ""
echo -e "${GREEN}📋 Логи WhatsApp бота:${NC}"
pm2 logs whatsapp-old --lines 10

echo ""
echo -e "${GREEN}📋 Логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 10

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ БОТЫ ПЕРЕЗАПУЩЕНЫ!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды управления:${NC}"
echo -e "  WhatsApp логи: ${GREEN}pm2 logs whatsapp-old --lines 50${NC}"
echo -e "  Telegram логи: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Перезапуск всех: ${GREEN}pm2 restart all${NC}"
echo -e "  Остановка всех: ${GREEN}pm2 stop all${NC}"
echo ""
echo -e "${BLUE}================================${NC}"
