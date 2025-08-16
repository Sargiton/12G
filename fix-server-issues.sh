#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ПРОБЛЕМ СЕРВЕРА"
echo "================================"

# 1. Остановка всех процессов
echo "🛑 Останавливаю все процессы..."
pm2 stop all
pm2 delete all
pkill -f node
pkill -f pm2

# 2. Очистка кэша и временных файлов
echo "🧹 Очищаю кэш и временные файлы..."
rm -rf node_modules/.cache
rm -rf tmp/*
rm -rf storage/data/cache/*
npm cache clean --force

# 3. Удаление устаревших зависимостей
echo "🗑️ Удаляю устаревшие зависимости..."
rm -rf node_modules package-lock.json

# 4. Обновление кода
echo "📥 Обновляю код с GitHub..."
git pull origin master

# 5. Переустановка зависимостей
echo "📦 Переустанавливаю зависимости..."
npm install

# 6. Исправление уязвимостей
echo "🔒 Исправляю уязвимости..."
npm audit fix --force
npm update

# 7. Запуск с простой конфигурацией
echo "🚀 Запускаю боты..."
pm2 start ecosystem-simple.config.cjs

# 8. Проверка статуса
echo "📊 Проверяю статус..."
sleep 5
pm2 list

echo "✅ Исправление завершено!"
echo "📋 Проверьте логи: pm2 logs"
