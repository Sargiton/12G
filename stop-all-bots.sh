#!/bin/bash

echo "🛑 Остановка всех ботов..."

echo "📋 Остановка PM2 процессов..."
pm2 stop all
pm2 delete all

echo "🔪 Принудительная остановка Node.js процессов..."
pkill -f node
pkill -f pm2

echo "🧹 Очистка временных файлов..."
rm -rf tmp/*
rm -rf storage/data/cache/*

echo "✅ Все боты остановлены!"
echo ""
echo "Для запуска используйте: pm2 start ecosystem-simple.config.cjs"
