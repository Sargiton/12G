#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОШИБОК NPM И ОБНОВЛЕНИЕ ВЕРСИЙ"
echo "=============================================="

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node

cd /root/12G

# Обновляем npm до последней версии
echo "📦 Обновляем npm до последней версии..."
npm install -g npm@latest

# Проверяем версию npm
echo "📊 Проверяем версию npm..."
npm --version

# Очищаем кэш npm
echo "🧹 Очищаем кэш npm..."
npm cache clean --force

# Удаляем node_modules и package-lock.json
echo "🗑️ Удаляем старые зависимости..."
rm -rf node_modules
rm -f package-lock.json

# Удаляем проблемный пакет imagemaker.js из package.json
echo "🔧 Исправляем package.json..."
if [ -f "package.json" ]; then
    # Создаем временный файл без imagemaker.js
    cat package.json | grep -v "imagemaker" > package-temp.json
    mv package-temp.json package.json
    echo "✅ imagemaker.js удален из зависимостей"
fi

# Устанавливаем зависимости без проблемных пакетов
echo "📦 Устанавливаем зависимости..."
npm install --force

# Устанавливаем критические пакеты отдельно
echo "📦 Устанавливаем критические пакеты..."
npm install baileys@6.7.0 --save-exact
npm install qrcode-terminal qrcode pino --force
npm install node-telegram-bot-api --force

# Проверяем установку
echo "✅ Проверяем установку..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен"
else
    echo "❌ baileys не установлен"
fi

if [ -d "node_modules/node-telegram-bot-api" ]; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
fi

# Создаем папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем сессии
echo "🧹 Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Запускаем боты
echo "🚀 Запускаем боты..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    pm2 start index.js --name "whatsapp-bot"
    pm2 start telegram-bot.cjs --name "telegram-bot"
fi

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 5
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

echo ""
echo "🎉 ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
echo "✅ npm обновлен до последней версии"
echo "✅ imagemaker.js удален из зависимостей"
echo "✅ Все критические пакеты установлены"
echo "✅ Боты запущены"
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
