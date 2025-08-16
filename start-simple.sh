#!/bin/bash

# Простой скрипт для запуска бота на сервере с 1 ГБ RAM
echo "🚀 Запуск бота на сервере с 1 ГБ RAM..."

# Создаем папку для логов
mkdir -p logs

# Очищаем временные файлы
echo "🧹 Очистка временных файлов..."
rm -rf tmp/* 2>/dev/null || true

# Останавливаем все процессы PM2
echo "⏹️ Остановка всех процессов..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Проверяем свободную память
echo "📊 Проверка памяти:"
free -h

# Запускаем боты с простой конфигурацией
echo "🚀 Запуск WhatsApp бота..."
pm2 start ecosystem-simple.config.cjs --only whatsapp-bot

# Ждем немного
sleep 3

echo "🚀 Запуск Telegram бота..."
pm2 start ecosystem-simple.config.cjs --only telegram-bot

# Проверяем статус
echo "📋 Статус процессов:"
pm2 list

echo "✅ Боты запущены с простой конфигурацией!"
echo "📱 Проверьте команды в Telegram: /help_me, /quick_check"
echo "📊 Мониторинг: pm2 logs"
