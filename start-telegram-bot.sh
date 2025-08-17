#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ЗАПУСК TELEGRAM БОТА        ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем, что мы в правильной директории
if [ ! -d "123" ]; then
    echo -e "${RED}❌ Папка 123 не найдена!${NC}"
    echo -e "${YELLOW}Убедитесь, что вы находитесь в корне проекта 12G${NC}"
    exit 1
fi

# Проверяем, что telegram-bot.cjs существует
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo -e "${RED}❌ Файл telegram-bot.cjs не найден в папке 123!${NC}"
    exit 1
fi

# Останавливаем существующий Telegram бот если запущен
echo -e "${YELLOW}🛑 Останавливаем существующий Telegram бот...${NC}"
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Создаем PM2 конфиг для Telegram бота
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

# Ждем немного для запуска
echo -e "${YELLOW}⏳ Ждем запуска Telegram бота...${NC}"
sleep 3

# Показываем статус
echo -e "${GREEN}✅ Статус всех ботов:${NC}"
pm2 list

echo ""
echo -e "${GREEN}📋 Последние логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 10

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ TELEGRAM БОТ ЗАПУЩЕН!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления Telegram ботом:${NC}"
echo -e "  Логи: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Перезапуск: ${GREEN}pm2 restart telegram-bot${NC}"
echo -e "  Остановка: ${GREEN}pm2 stop telegram-bot${NC}"
echo -e "  Удаление: ${GREEN}pm2 delete telegram-bot${NC}"
echo ""
echo -e "${YELLOW}🤖 Telegram команды бота:${NC}"
echo -e "  /get_qr - Получить QR код"
echo -e "  /reset_session - Сбросить сессию"
echo -e "  /restart_whatsapp - Перезапустить WhatsApp бота"
echo -e "  /start_whatsapp - Запустить WhatsApp бота"
echo -e "  /stop_whatsapp - Остановить WhatsApp бота"
echo -e "  /status - Статус WhatsApp бота"
echo -e "  /logs - Логи WhatsApp бота"
echo -e "  /update_code - Обновить код (git pull)"
echo -e "  /npm_install - Установить зависимости"
echo ""
echo -e "${YELLOW}📁 Файлы:${NC}"
echo -e "  Telegram бот: ${GREEN}123/telegram-bot.cjs${NC}"
echo -e "  Логи: ${GREEN}123/logs/telegram-bot-*.log${NC}"
echo ""
echo -e "${BLUE}================================${NC}"
