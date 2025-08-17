#!/bin/bash

echo "🔍 ДИАГНОСТИКА TELEGRAM БОТА"

echo "📋 Статус PM2 процессов:"
pm2 list

echo ""
echo "📋 Логи Telegram бота (последние 20 строк):"
pm2 logs ecosystem-telegram-commonjs --lines 20

echo ""
echo "📋 Ошибки Telegram бота (последние 20 строк):"
pm2 logs ecosystem-telegram-commonjs --err --lines 20

echo ""
echo "🔍 Проверяем файл telegram-bot.cjs..."
if [ -f "123/telegram-bot.cjs" ]; then
    echo "✅ Файл найден"
    echo "📄 Первые 10 строк файла:"
    head -10 123/telegram-bot.cjs
else
    echo "❌ Файл не найден"
fi

echo ""
echo "🔍 Проверяем зависимости..."
cd 123
if npm list node-telegram-bot-api >/dev/null 2>&1; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
fi
cd ..

echo ""
echo "🔍 Проверяем package.json..."
if [ -f "123/package.json" ]; then
    echo "✅ package.json найден"
    echo "📄 Тип модулей:"
    grep -o '"type": "[^"]*"' 123/package.json || echo "Тип не указан (по умолчанию CommonJS)"
else
    echo "❌ package.json не найден"
fi

echo ""
echo "🎯 РЕКОМЕНДАЦИИ:"
echo "1. Если бот не отвечает, попробуйте перезапустить: pm2 restart ecosystem-telegram-commonjs"
echo "2. Если есть ошибки в логах, покажите их"
echo "3. Проверьте, что токен Telegram бота правильный"
