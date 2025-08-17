#!/bin/bash

echo "🚀 ЗАПУСК TELEGRAM БОТА ЧЕРЕЗ PM2 (ИСПРАВЛЕННЫЙ)"

# Останавливаем старые Telegram боты
echo "🛑 Останавливаем старые Telegram боты..."
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Создаем папку для логов
echo "📁 Создаем папку для логов..."
mkdir -p 123/logs

# Создаем конфиг PM2
echo "⚙️ Создаем конфиг PM2..."
cat > ecosystem-telegram-pm2.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'telegram-bot',
            script: 'telegram-bot.mjs',
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

# Запускаем Telegram бота через PM2
echo "🤖 Запускаем Telegram бота через PM2..."
pm2 start ecosystem-telegram-pm2.cjs

# Сохраняем PM2
echo "💾 Сохраняем PM2 конфигурацию..."
pm2 save

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Статус всех ботов:"
pm2 list

echo ""
echo "📋 Логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "🎯 Готово! Telegram бот запущен через PM2!"
echo "Теперь у вас работают оба бота через PM2:"
echo "• WhatsApp бот: whatsapp-old"
echo "• Telegram бот: telegram-bot"
echo ""
echo "Команды управления:"
echo "• pm2 list - Статус всех ботов"
echo "• pm2 logs telegram-bot - Логи Telegram бота"
echo "• pm2 restart telegram-bot - Перезапуск Telegram бота"
echo "• pm2 stop telegram-bot - Остановка Telegram бота"
