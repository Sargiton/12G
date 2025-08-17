#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "🔧 Подготовка старого бота (папка 123)"

# Создаем каталог логов
mkdir -p 123/logs

echo "🛑 Останавливаю возможные запущенные процессы whatsapp-old"
pm2 delete whatsapp-old || true

echo "📦 Устанавливаю зависимости для старого бота"
cd 123
npm install --production || npm install

echo "⬅️ Возвращаюсь в корень проекта"
cd ..

echo "🚀 Запускаю whatsapp-old через PM2"
pm2 start ecosystem-old.config.cjs

echo "💾 Сохраняю PM2"
pm2 save

echo "📋 Логи (последние 20 строк):"
pm2 logs whatsapp-old --lines 20

echo "✅ Готово. Бот из папки 123 запущен как whatsapp-old"


