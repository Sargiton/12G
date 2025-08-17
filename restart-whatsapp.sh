#!/bin/bash

echo "🚀 ЗАПУСК WHATSAPP БОТА ЧЕРЕЗ PM2"

# Запускаем WhatsApp бота
echo "🤖 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

# Сохраняем PM2
echo "💾 Сохраняем PM2 конфигурацию..."
pm2 save

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Статус всех ботов:"
pm2 list

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-old --lines 10

echo ""
echo "🎯 Готово! WhatsApp бот запущен!"
echo "Теперь у вас работают оба бота:"
echo "• WhatsApp бот: whatsapp-old"
echo "• Telegram бот: simple-telegram.mjs (запущен напрямую)"
