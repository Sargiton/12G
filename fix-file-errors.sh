#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОШИБОК ФАЙЛОВ"

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

echo "✅ Исправления завершены!"
echo "📁 Созданные папки:"
echo "• tmp/ - для временных файлов"
echo "• logs/ - для логов"
echo "• storage/img/ - для изображений"
echo "• storage/data/ - для данных"

echo ""
echo "🔄 Теперь перезапустите бота:"
echo "pm2 restart whatsapp-old"
