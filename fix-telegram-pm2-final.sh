#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ TELEGRAM БОТА ЧЕРЕЗ PM2"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Проверяем файл
echo "🔍 Проверяем файл telegram-bot.cjs..."
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo "❌ Файл 123/telegram-bot.cjs не найден!"
    exit 1
fi

# Исправляем имя WhatsApp бота
echo "🔧 Исправляем имя WhatsApp бота..."
sed -i "s/WHATSAPP_PM2_NAME = 'whatsapp-bot'/WHATSAPP_PM2_NAME = 'whatsapp-old'/g" 123/telegram-bot.cjs

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Создаем правильный конфиг PM2 для Telegram бота
echo "⚙️ Создаем конфиг PM2 для Telegram бота..."
cat > ecosystem-telegram-final.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'telegram-bot',
            script: './123/telegram-bot.cjs',
            cwd: '.',
            autorestart: true,
            watch: false,
            time: true,
            env: {
                NODE_ENV: 'production'
            },
            error_file: './logs/telegram-error.log',
            out_file: './logs/telegram-out.log',
            log_file: './logs/telegram-combined.log'
        }
    ]
}
EOF

# Создаем папку для логов
echo "📁 Создаем папку для логов..."
mkdir -p logs

# Запускаем WhatsApp бота
echo "🤖 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

# Ждем
sleep 3

# Запускаем Telegram бота
echo "📱 Запускаем Telegram бота..."
pm2 start ecosystem-telegram-final.cjs

# Сохраняем PM2
echo "💾 Сохраняем PM2 конфигурацию..."
pm2 save

echo "⏳ Ждем запуска..."
sleep 5

echo "✅ Статус всех ботов:"
pm2 list

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-old --lines 3

echo ""
echo "📋 Логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "🎯 Готово! Оба бота запущены!"
echo "• WhatsApp бот: whatsapp-old"
echo "• Telegram бот: telegram-bot"
echo ""
echo "🔍 Для проверки Telegram бота отправьте /status в Telegram"
