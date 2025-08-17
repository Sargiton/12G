#!/bin/bash

echo "🔧 ПОЛНОЕ ИСПРАВЛЕНИЕ ОШИБОК БОТА"

# Останавливаем бота
echo "🛑 Останавливаем бота..."
pm2 stop whatsapp-old 2>/dev/null || true

# Создаем необходимые папки
echo "📁 Создаем необходимые папки..."
mkdir -p tmp
mkdir -p logs
mkdir -p storage/img
mkdir -p storage/data

# Устанавливаем права доступа
echo "🔐 Устанавливаем права доступа..."
chmod 755 tmp
chmod 755 logs
chmod 755 storage
chmod 755 storage/img
chmod 755 storage/data

# Проверяем и создаем файлы если их нет
echo "📄 Проверяем файлы..."
touch storage/data/database.json
echo "{}" > storage/data/database.json

# Очищаем временные файлы
echo "🧹 Очищаем временные файлы..."
rm -f tmp/*.jpg
rm -f tmp/*.png
rm -f tmp/*.mp4
rm -f tmp/*.webp

# Создаем .gitkeep файлы
echo "📝 Создаем .gitkeep файлы..."
touch tmp/.gitkeep
touch logs/.gitkeep

# Копируем исправленные файлы
echo "📋 Копируем исправленные файлы..."
cp plugins/main-menu18.js 123/plugins/main-menu18.js
cp plugins/main-menu1.js 123/plugins/main-menu1.js

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Запускаем бота
echo "🤖 Запускаем бота..."
pm2 start ecosystem-old.config.cjs

echo "⏳ Ждем запуска..."
sleep 5

echo "✅ Исправления завершены!"
echo "📁 Созданные папки:"
echo "• tmp/ - для временных файлов"
echo "• logs/ - для логов"
echo "• storage/img/ - для изображений"
echo "• storage/data/ - для данных"

echo ""
echo "🔧 Исправленные файлы:"
echo "• main-menu18.js - убрано изображение"
echo "• main-menu1.js - убрано изображение"

echo ""
echo "📊 Статус бота:"
pm2 list | grep whatsapp-old || echo "Бот не запущен"

echo ""
echo "🎯 Теперь команда 'меню' должна работать без ошибок!"
echo "📋 Для проверки логов: pm2 logs whatsapp-old"
