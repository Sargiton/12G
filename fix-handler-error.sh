#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОШИБКИ handler.js"

# Останавливаем бота
echo "🛑 Останавливаем бота..."
pm2 stop whatsapp-old 2>/dev/null || true

# Копируем исправленный файл
echo "📋 Копируем исправленный handler.js..."
cp handler.js 123/handler.js

# Перезапускаем бота
echo "🤖 Перезапускаем бота..."
pm2 restart whatsapp-old

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Исправления завершены!"
echo "🔧 Исправленная ошибка: ReferenceError: isOwner is not defined"

echo ""
echo "📊 Статус бота:"
pm2 list | grep whatsapp-old || echo "Бот не запущен"

echo ""
echo "🎯 Теперь бот должен работать без ошибок!"
echo "📋 Для проверки логов: pm2 logs whatsapp-old"
