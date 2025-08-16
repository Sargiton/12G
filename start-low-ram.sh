#!/bin/bash

# Скрипт для запуска бота на сервере с 1 ГБ RAM
echo "🚀 Запуск бота на сервере с ограниченной RAM..."

# Создаем папку для логов
mkdir -p logs

# Очищаем временные файлы
echo "🧹 Очистка временных файлов..."
rm -rf tmp/*
rm -rf storage/media-cache/*

# Останавливаем все процессы PM2
echo "⏹️ Остановка всех процессов..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Очищаем кэш Node.js
echo "🧹 Очистка кэша Node.js..."
node --max-old-space-size=256 -e "if (global.gc) global.gc()" 2>/dev/null || true

# Проверяем свободную память
echo "📊 Проверка памяти:"
free -h

# Запускаем боты с ограничениями памяти
echo "🚀 Запуск WhatsApp бота..."
pm2 start ecosystem-low-ram.config.js --only whatsapp-bot

# Ждем немного
sleep 5

echo "🚀 Запуск Telegram бота..."
pm2 start ecosystem-low-ram.config.js --only telegram-bot

# Ждем запуска
sleep 10

# Проверяем статус
echo "📊 Статус процессов:"
pm2 list

echo "📊 Использование памяти:"
pm2 monit --no-daemon &
MONIT_PID=$!

# Ждем 30 секунд для мониторинга
sleep 30

# Останавливаем мониторинг
kill $MONIT_PID 2>/dev/null || true

echo "✅ Боты запущены с оптимизацией для низкой RAM!"
echo "📱 Проверьте команды в Telegram: /help_me, /quick_check"
