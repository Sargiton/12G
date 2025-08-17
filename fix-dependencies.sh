#!/bin/bash

echo "🔧 ПРИНУДИТЕЛЬНАЯ УСТАНОВКА ЗАВИСИМОСТЕЙ"
echo "=========================================="

# Очищаем все
echo "🧹 Очищаем кэш и модули..."
rm -rf node_modules
rm -f package-lock.json
npm cache clean --force

# Устанавливаем основные зависимости
echo "📦 Устанавливаем основные зависимости..."
npm install --force

# Проверяем и устанавливаем критичные пакеты
echo "🔍 Проверяем критичные пакеты..."

# Baileys
if [ ! -d "node_modules/@whiskeysockets" ]; then
    echo "📱 Устанавливаем @whiskeysockets/baileys..."
    npm install @whiskeysockets/baileys --force
fi

# QR код
if [ ! -d "node_modules/qrcode-terminal" ]; then
    echo "📱 Устанавливаем qrcode-terminal..."
    npm install qrcode-terminal --force
fi

if [ ! -d "node_modules/qrcode" ]; then
    echo "📱 Устанавливаем qrcode..."
    npm install qrcode --force
fi

# Проверяем результат
echo "✅ Проверяем установку..."
if [ -d "node_modules/@whiskeysockets" ]; then
    echo "✅ @whiskeysockets/baileys установлен"
else
    echo "❌ @whiskeysockets/baileys НЕ установлен"
fi

if [ -d "node_modules/qrcode-terminal" ]; then
    echo "✅ qrcode-terminal установлен"
else
    echo "❌ qrcode-terminal НЕ установлен"
fi

if [ -d "node_modules/qrcode" ]; then
    echo "✅ qrcode установлен"
else
    echo "❌ qrcode НЕ установлен"
fi

echo "🎉 Установка зависимостей завершена!"
