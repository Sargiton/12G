#!/bin/bash

echo "🚀 ЗАПУСК ПРОСТОГО TELEGRAM БОТА"

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
