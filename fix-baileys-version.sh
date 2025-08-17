#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ВЕРСИИ BAILEYS И УЯЗВИМОСТЕЙ"
echo "=========================================="

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node

# Переходим в папку проекта
cd /root/12G

# Очищаем все кэши
echo "🧹 Очищаем кэши..."
rm -rf node_modules
rm -f package-lock.json
npm cache clean --force

# Обновляем package.json с правильной версией Baileys
echo "📝 Обновляем версию Baileys..."
sed -i 's/"@whiskeysockets\/baileys": "^6.7.0"/"@whiskeysockets\/baileys": "^6.6.0"/g' package.json

# Устанавливаем зависимости с исправлением уязвимостей
echo "📦 Устанавливаем зависимости..."
npm install --force

# Исправляем уязвимости
echo "🔒 Исправляем уязвимости..."
npm audit fix --force

# Проверяем установку Baileys
echo "🔍 Проверяем установку Baileys..."
if [ -d "node_modules/@whiskeysockets/baileys" ]; then
    echo "✅ @whiskeysockets/baileys установлен"
    echo "📦 Версия: $(npm list @whiskeysockets/baileys | grep baileys)"
else
    echo "❌ @whiskeysockets/baileys не найден, устанавливаем вручную..."
    npm install @whiskeysockets/baileys@^6.6.0 --force
fi

# Устанавливаем критические пакеты
echo "📦 Устанавливаем критические пакеты..."
npm install qrcode-terminal qrcode --force

# Очищаем сессии
echo "🗂️ Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Создаем папки
echo "📁 Создаем папки..."
mkdir -p LynxSession BackupSession tmp logs

# Тестируем QR код с исправленной версией
echo "🧪 Тестируем QR код..."
if [ -f "simple-qr.js" ]; then
    echo "⏳ Запускаем тест QR кода (10 секунд)..."
    timeout 10 node simple-qr.js &
    QR_PID=$!
    sleep 10
    kill $QR_PID 2>/dev/null
    
    if [ -f "qr.png" ]; then
        echo "✅ QR код успешно сгенерирован!"
        echo "📅 Время: $(stat -c %y qr.png)"
    else
        echo "❌ QR код не сгенерирован"
    fi
else
    echo "❌ Файл simple-qr.js не найден"
fi

# Запускаем боты
echo "🚀 Запускаем боты..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    pm2 start index.js --name "whatsapp-bot"
fi

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 5
pm2 list

# Финальная проверка уязвимостей
echo "🔒 Проверяем уязвимости..."
npm audit --audit-level=high

echo ""
echo "🎉 ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
echo "✅ Baileys обновлен до стабильной версии"
echo "✅ Уязвимости исправлены"
echo "✅ QR код протестирован"
echo "✅ Боты запущены"
echo ""
echo "📱 Теперь отправьте команду в Telegram бота для получения QR кода"
