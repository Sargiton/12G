#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ИСПРАВЛЕНИЕ ИМЕНИ TELEGRAM БОТА ${NC}"
echo -e "${BLUE}================================${NC}"

# Останавливаем все процессы с telegram в названии
echo -e "${YELLOW}🛑 Останавливаем все Telegram процессы...${NC}"
pm2 stop ecosystem-telegram 2>/dev/null || true
pm2 delete ecosystem-telegram 2>/dev/null || true
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Ждем немного
sleep 2

# Создаем правильный конфиг с правильным именем
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

# Запускаем с правильным именем
echo -e "${YELLOW}🚀 Запускаем Telegram бота с правильным именем...${NC}"
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
echo -e "${GREEN}📋 Логи Telegram бота:${NC}"
pm2 logs telegram-bot --lines 15

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
