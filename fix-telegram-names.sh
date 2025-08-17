#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ИСПРАВЛЕНИЕ ИМЕН PM2 В TELEGRAM БОТЕ ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем файл telegram-bot.cjs
echo -e "${YELLOW}🔍 Проверяем файл telegram-bot.cjs...${NC}"
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo -e "${RED}❌ Файл 123/telegram-bot.cjs не найден!${NC}"
    exit 1
fi

# Показываем текущие имена PM2
echo -e "${YELLOW}📋 Текущие процессы PM2:${NC}"
pm2 list

echo ""
echo -e "${YELLOW}🔧 Исправляем имена в telegram-bot.cjs...${NC}"

# Создаем резервную копию
cp 123/telegram-bot.cjs 123/telegram-bot.cjs.backup

# Исправляем имя WhatsApp бота с 'whatsapp-bot' на 'whatsapp-old'
sed -i "s/WHATSAPP_PM2_NAME = 'whatsapp-bot'/WHATSAPP_PM2_NAME = 'whatsapp-old'/g" 123/telegram-bot.cjs

echo -e "${GREEN}✅ Имя WhatsApp бота исправлено на 'whatsapp-old'${NC}"

# Показываем изменения
echo -e "${YELLOW}📄 Проверяем изменения:${NC}"
grep -n "WHATSAPP_PM2_NAME" 123/telegram-bot.cjs

echo ""
echo -e "${YELLOW}🛑 Останавливаем все процессы...${NC}"
pm2 stop all
pm2 delete all

# Ждем
sleep 2

# Создаем правильные конфиги
echo -e "${YELLOW}⚙️ Создаем правильные конфиги...${NC}"

# Конфиг для WhatsApp бота
cat > ecosystem-old.config.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'whatsapp-old',
            script: 'index.js',
            cwd: './123',
            autorestart: true,
            watch: false,
            time: true,
            node_args: '',
            env: {
                NODE_ENV: 'production',
                PORT: '3300'
            },
            out_file: './123/logs/whatsapp-old-out.log',
            error_file: './123/logs/whatsapp-old-error.log',
            log_date_format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
        }
    ]
}
EOF

# Конфиг для Telegram бота
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
pm2 start ecosystem-old.config.cjs

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
echo -e "${GREEN}✅ ИМЕНА PM2 ИСПРАВЛЕНЫ!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления:${NC}"
echo -e "  Логи WhatsApp: ${GREEN}pm2 logs whatsapp-old --lines 50${NC}"
echo -e "  Логи Telegram: ${GREEN}pm2 logs telegram-bot --lines 50${NC}"
echo -e "  Перезапуск всех: ${GREEN}pm2 restart all${NC}"
echo -e "  Остановка всех: ${GREEN}pm2 stop all${NC}"
echo ""
echo -e "${YELLOW}🤖 Telegram команды бота (теперь работают):${NC}"
echo -e "  /get_qr - Получить QR код"
echo -e "  /reset_session - Сбросить сессию"
echo -e "  /restart_whatsapp - Перезапустить WhatsApp бота"
echo -e "  /start_whatsapp - Запустить WhatsApp бота"
echo -e "  /stop_whatsapp - Остановить WhatsApp бота"
echo -e "  /status - Статус WhatsApp бота"
echo -e "  /logs - Логи WhatsApp бота"
echo ""
echo -e "${BLUE}================================${NC}"
