#!/bin/bash

echo "🚀 ЗАПУСК TELEGRAM БОТА В ФОНЕ (NOHUP)"

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

# Создаем папку для логов
echo "📁 Создаем папку для логов..."
mkdir -p logs

# Запускаем WhatsApp бота через PM2
echo "🤖 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

# Ждем
sleep 3

# Запускаем Telegram бота в фоне через nohup
echo "📱 Запускаем Telegram бота в фоне..."
cd 123
nohup node telegram-bot.cjs > ../logs/telegram-nohup.log 2>&1 &
TELEGRAM_PID=$!
cd ..

echo "✅ Telegram бот запущен с PID: $TELEGRAM_PID"

# Сохраняем PID в файл
echo $TELEGRAM_PID > logs/telegram.pid

echo "⏳ Ждем запуска..."
sleep 5

echo "✅ Статус:"
echo "• WhatsApp бот: PM2 (whatsapp-old)"
echo "• Telegram бот: Фон (PID: $TELEGRAM_PID)"

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-old --lines 3

echo ""
echo "📋 Логи Telegram бота:"
tail -10 logs/telegram-nohup.log

echo ""
echo "🎯 Готово! Оба бота запущены!"
echo "• WhatsApp бот: whatsapp-old (PM2)"
echo "• Telegram бот: PID $TELEGRAM_PID (nohup)"
echo ""
echo "🔍 Для проверки Telegram бота отправьте /status в Telegram"
echo "📋 Для просмотра логов: tail -f logs/telegram-nohup.log"
echo "🛑 Для остановки: kill $TELEGRAM_PID"
