#!/bin/bash

echo "🚀 ИСПРАВЛЕНИЕ ПРОСТОГО TELEGRAM БОТА"

# Останавливаем все Telegram боты
echo "🛑 Останавливаем старые боты..."
pm2 stop simple-telegram 2>/dev/null || true
pm2 delete simple-telegram 2>/dev/null || true
pm2 stop new-telegram-bot 2>/dev/null || true
pm2 delete new-telegram-bot 2>/dev/null || true
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Устанавливаем зависимости в папке 123
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Создаем конфиг PM2
echo "⚙️ Создаем конфиг PM2..."
cat > ecosystem-simple-telegram.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'simple-telegram',
            script: 'simple-telegram.js',
            cwd: './123',
            autorestart: true,
            watch: false,
            env: {
                NODE_ENV: 'production'
            }
        }
    ]
}
EOF

# Проверяем файл бота
echo "🔍 Проверяем файл бота..."
if [ ! -f "123/simple-telegram.js" ]; then
    echo "❌ Файл 123/simple-telegram.js не найден!"
    echo "📥 Скачиваем файл..."
    curl -o 123/simple-telegram.js https://raw.githubusercontent.com/Sargiton/12G/master/123/simple-telegram.js
fi

# Запускаем простой бот
echo "🤖 Запускаем простой Telegram бот..."
pm2 start ecosystem-simple-telegram.cjs

# Сохраняем
pm2 save

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Статус:"
pm2 list

echo ""
echo "📋 Логи:"
pm2 logs simple-telegram --lines 10

echo ""
echo "🎯 Готово! Простой Telegram бот запущен!"
echo "Команды: /start, /test, /status, /qr, /help"
