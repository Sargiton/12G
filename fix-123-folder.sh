#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ФАЙЛОВ В ПАПКЕ 123"

# Останавливаем бота
echo "🛑 Останавливаем бота..."
pm2 stop whatsapp-old 2>/dev/null || true

# Создаем папку tmp в 123
echo "📁 Создаем папку tmp в 123..."
mkdir -p 123/tmp
chmod 755 123/tmp

# Очищаем временные файлы
echo "🧹 Очищаем временные файлы..."
rm -f 123/tmp/*.jpg
rm -f 123/tmp/*.png
rm -f 123/tmp/*.mp4
rm -f 123/tmp/*.webp

# Создаем .gitkeep
echo "📝 Создаем .gitkeep..."
touch 123/tmp/.gitkeep

# Перезапускаем бота
echo "🤖 Перезапускаем бота..."
pm2 restart whatsapp-old

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Исправления завершены!"
echo "📁 Созданная папка: 123/tmp/"

echo ""
echo "📊 Статус бота:"
pm2 list | grep whatsapp-old || echo "Бот не запущен"

echo ""
echo "🎯 Теперь команда 'меню' должна работать без ошибок!"
echo "📋 Для проверки логов: pm2 logs whatsapp-old"
