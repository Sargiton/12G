#!/bin/bash

echo "🚀 ЗАПУСК ОБОИХ БОТОВ"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Запускаем WhatsApp бота
echo "🤖 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

# Ждем немного
sleep 2

# Запускаем Telegram бота в фоне
echo "📱 Запускаем Telegram бота..."
cd 123
nohup node telegram-bot.mjs > telegram-bot.log 2>&1 &
TELEGRAM_PID=$!
cd ..

# Сохраняем PM2
echo "💾 Сохраняем PM2 конфигурацию..."
pm2 save

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Статус:"
pm2 list

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-old --lines 5

echo ""
echo "📋 Логи Telegram бота:"
if [ -f "123/telegram-bot.log" ]; then
    tail -10 123/telegram-bot.log
else
    echo "Логи Telegram бота пока не созданы"
fi

echo ""
echo "🎯 Готово! Оба бота запущены!"
echo "• WhatsApp бот: whatsapp-old (через PM2)"
echo "• Telegram бот: telegram-bot.mjs (в фоне)"
echo ""
echo "Telegram команды:"
echo "• /get_qr - Получить QR код"
echo "• /reset_session - Сбросить сессию"
echo "• /restart_whatsapp - Перезапустить WhatsApp"
echo "• /start_whatsapp - Запустить WhatsApp"
echo "• /stop_whatsapp - Остановить WhatsApp"
echo "• /status - Статус WhatsApp"
echo "• /logs - Логи WhatsApp"
echo "• /update_code - Обновить код"
echo "• /npm_install - Установить зависимости"
