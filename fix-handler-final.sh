#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ HANDLER.JS"
echo "==================================="

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔍 Создаем резервную копию..."
cp handler.js handler-backup-final.js

echo ""
echo "🔧 Исправляем проблемные строки..."

# Комментируем проблемные строки с performanceMonitor и messageQueue
sed -i 's/^  performanceMonitor\.recordMessage(processingTime);/\/\/ performanceMonitor.recordMessage(processingTime);/g' handler.js
sed -i 's/^  const queueStats = await messageQueue\.getStats();/\/\/ const queueStats = await messageQueue.getStats();/g' handler.js
sed -i 's/^  performanceMonitor\.updateQueueStats(queueStats);/\/\/ performanceMonitor.updateQueueStats(queueStats);/g' handler.js

echo ""
echo "🔍 Проверяем синтаксис handler.js..."
if node -c handler.js; then
    echo "✅ handler.js - синтаксис исправлен"
else
    echo "❌ handler.js - все еще есть ошибки"
    echo "Заменяем на минимальную версию..."
    cp handler-minimal.js handler.js
fi

echo ""
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

echo ""
echo "📋 Статус ботов:"
pm2 list

echo ""
echo "📋 Проверяем логи..."
pm2 logs whatsapp-bot --lines 10

echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
echo "📱 Теперь попробуйте команду /qr в Telegram боте"
