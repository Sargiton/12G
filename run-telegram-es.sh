#!/bin/bash

echo "🚀 ЗАПУСК TELEGRAM БОТА (ES МОДУЛИ)"

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
if [ ! -f "simple-telegram.mjs" ]; then
    echo "❌ Файл simple-telegram.mjs не найден!"
    echo "📥 Скачиваем файл..."
    curl -o simple-telegram.mjs https://raw.githubusercontent.com/Sargiton/12G/master/123/simple-telegram.mjs
fi

# Запускаем бота напрямую
echo "🤖 Запускаем Telegram бота напрямую..."
echo "✅ Бот запущен! Нажмите Ctrl+C для остановки"
node simple-telegram.mjs
