#!/bin/bash

echo "🧹 ПРИНУДИТЕЛЬНАЯ ОЧИСТКА QR КЭША"
echo "=================================="

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node
pkill -f pm2

# Ждем полной остановки
sleep 5

# Переходим в папку проекта
cd /root/12G

# Очищаем ВСЕ кэши и сессии
echo "🧹 Очищаем все кэши и сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png
rm -f qr.jpg
rm -rf tmp/*
rm -rf storage/data/cache/*
rm -rf logs/*

# Очищаем кэш Node.js
echo "🧹 Очищаем кэш Node.js..."
npm cache clean --force

# Удаляем node_modules и переустанавливаем
echo "📦 Переустанавливаем зависимости..."
rm -rf node_modules
rm -f package-lock.json
npm install --force

# Создаем новые папки
echo "📁 Создаем новые папки..."
mkdir -p LynxSession
mkdir -p BackupSession
mkdir -p tmp
mkdir -p logs

# Принудительно генерируем новый QR код
echo "📱 Принудительно генерируем новый QR код..."
if [ -f "simple-qr.js" ]; then
    # Запускаем генерацию QR в фоне
    node simple-qr.js &
    QR_PID=$!
    
    # Ждем 20 секунд
    echo "⏳ Ждем генерации QR кода..."
    sleep 20
    
    # Останавливаем процесс
    kill $QR_PID 2>/dev/null
    
    # Проверяем результат
    if [ -f "qr.png" ]; then
        echo "✅ Новый QR код создан!"
        ls -la qr.png
    else
        echo "❌ QR код не создался"
    fi
else
    echo "❌ Файл simple-qr.js не найден"
fi

# Запускаем боты заново
echo "🚀 Запускаем боты заново..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    pm2 start index.js --name "whatsapp-bot"
fi

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 5
pm2 list

echo ""
echo "🎉 Очистка завершена!"
echo "📱 Проверьте новый QR код в Telegram"
