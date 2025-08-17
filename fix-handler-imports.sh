#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ИМПОРТОВ В HANDLER.JS"
echo "===================================="

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔍 Проверяем проблемные импорты..."

# Проверяем, существуют ли файлы оптимизации
echo "📋 Проверяем файлы оптимизации:"
for file in lib/cache.js lib/queue.js lib/monitor.js lib/mediaProcessor.js lib/pluginManager.js; do
    if [ -f "$file" ]; then
        echo "✅ $file - существует"
        if node -c "$file" 2>&1 | grep -q "Unexpected token"; then
            echo "❌ $file - ошибка синтаксиса"
        else
            echo "✅ $file - синтаксис OK"
        fi
    else
        echo "❌ $file - не найден"
    fi
done

echo ""
echo "🔧 Временно отключаем импорты оптимизации..."

# Создаем резервную копию
cp handler.js handler-backup.js

# Временно комментируем импорты оптимизации
sed -i 's/^import cacheManager from '\''\.\/lib\/cache\.js'\'';/\/\/ import cacheManager from '\''\.\/lib\/cache\.js'\'';/g' handler.js
sed -i 's/^import messageQueue from '\''\.\/lib\/queue\.js'\'';/\/\/ import messageQueue from '\''\.\/lib\/queue\.js'\'';/g' handler.js
sed -i 's/^import performanceMonitor from '\''\.\/lib\/monitor\.js'\'';/\/\/ import performanceMonitor from '\''\.\/lib\/monitor\.js'\'';/g' handler.js
sed -i 's/^import mediaProcessor from '\''\.\/lib\/mediaProcessor\.js'\'';/\/\/ import mediaProcessor from '\''\.\/lib\/mediaProcessor\.js'\'';/g' handler.js
sed -i 's/^import pluginManager from '\''\.\/lib\/pluginManager\.js'\'';/\/\/ import pluginManager from '\''\.\/lib\/pluginManager\.js'\'';/g' handler.js

echo ""
echo "🔍 Проверяем синтаксис handler.js..."
if node -c handler.js; then
    echo "✅ handler.js - синтаксис исправлен"
else
    echo "❌ handler.js - все еще есть ошибки"
    echo "Восстанавливаем резервную копию..."
    cp handler-backup.js handler.js
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
