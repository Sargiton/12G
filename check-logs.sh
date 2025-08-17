#!/bin/bash

echo "🔍 ДИАГНОСТИКА ПРОБЛЕМЫ QR КОДА"
echo "================================"

# Переходим в папку проекта
cd /root/12G

echo "📋 Статус ботов:"
pm2 list

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-bot --lines 20

echo ""
echo "📋 Логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "📋 Проверка файлов:"
ls -la qr.png 2>/dev/null || echo "❌ QR файл не найден"
ls -la LynxSession/ 2>/dev/null || echo "❌ Папка LynxSession не найдена"

echo ""
echo "📋 Проверка ошибок:"
if [ -f "logs/whatsapp-error-0.log" ]; then
    echo "🚨 Последние ошибки WhatsApp:"
    tail -10 logs/whatsapp-error-0.log
else
    echo "✅ Файл ошибок WhatsApp не найден"
fi

echo ""
echo "📋 Проверка конфигурации:"
echo "Node.js версия: $(node --version)"
echo "NPM версия: $(npm --version)"
echo "PM2 версия: $(pm2 --version)"

echo ""
echo "📋 Проверка зависимостей:"
if [ -d "node_modules/baileys" ]; then
    echo "✅ Baileys установлен"
    echo "Версия: $(cat node_modules/baileys/package.json | grep '"version"' | cut -d'"' -f4)"
else
    echo "❌ Baileys не найден"
fi

echo ""
echo "🔧 РЕКОМЕНДАЦИИ:"
echo "1. Отправьте /qr в Telegram бота"
echo "2. Если не работает, попробуйте: pm2 restart whatsapp-bot"
echo "3. Проверьте логи: pm2 logs whatsapp-bot"
