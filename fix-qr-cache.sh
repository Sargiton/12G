#!/bin/bash

echo "🔧 Исправление проблемы с QR кэшем..."

echo "📋 Остановка всех процессов..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null

echo "🧹 Очистка QR кэша..."
node clear-qr-cache.js

echo "🗑️ Очистка временных файлов..."
rm -rf tmp/*
mkdir -p tmp

echo "🗑️ Удаление QR файлов..."
rm -f qr.png qr.jpg *.png

echo "🧹 Очистка кэша npm..."
npm cache clean --force

echo "🔄 Перезапуск бота..."
pm2 start ecosystem-simple.config.cjs

echo "✅ Готово! Теперь QR код будет генерироваться заново."
echo "📋 Проверьте логи: pm2 logs"
