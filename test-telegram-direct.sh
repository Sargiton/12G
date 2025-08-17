#!/bin/bash

echo "🧪 ТЕСТИРОВАНИЕ TELEGRAM БОТА НАПРЯМУЮ"

# Останавливаем PM2 процессы
echo "🛑 Останавливаем PM2 процессы..."
pm2 stop all 2>/dev/null || true

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

# Запускаем WhatsApp бота в фоне
echo "🤖 Запускаем WhatsApp бота в фоне..."
pm2 start ecosystem-old.config.cjs

# Ждем
sleep 2

# Запускаем Telegram бота напрямую
echo "📱 Запускаем Telegram бота напрямую..."
echo "✅ Бот запущен! Нажмите Ctrl+C для остановки"
echo "Отправьте команду /status в Telegram для проверки"
cd 123
node telegram-bot.cjs
