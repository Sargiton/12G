#!/bin/bash

echo "🚀 ЗАПУСК TELEGRAM БОТА НАПРЯМУЮ"

# Останавливаем все PM2 процессы
echo "🛑 Останавливаем все PM2 процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save

# Проверяем файл бота
echo "🔍 Проверяем файл бота..."
if [ ! -f "simple-telegram.js" ]; then
    echo "❌ Файл simple-telegram.js не найден!"
    echo "📥 Скачиваем файл..."
    curl -o simple-telegram.js https://raw.githubusercontent.com/Sargiton/12G/master/123/simple-telegram.js
fi

# Запускаем бота напрямую
echo "🤖 Запускаем Telegram бота напрямую..."
echo "✅ Бот запущен! Нажмите Ctrl+C для остановки"
node simple-telegram.js
