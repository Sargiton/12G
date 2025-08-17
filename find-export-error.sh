#!/bin/bash

echo "🔍 ПОИСК ФАЙЛА С ОШИБКОЙ EXPORT"
echo "================================"

cd /root/12G

echo "📋 Проверяем основные файлы..."

# Проверяем основные файлы по очереди
echo "🔍 index.js..."
if node -c index.js 2>&1 | grep -q "Unexpected token 'export'"; then
    echo "❌ Ошибка в index.js"
    node -c index.js
else
    echo "✅ index.js - OK"
fi

echo "🔍 config.js..."
if node -c config.js 2>&1 | grep -q "Unexpected token 'export'"; then
    echo "❌ Ошибка в config.js"
    node -c config.js
else
    echo "✅ config.js - OK"
fi

echo "🔍 handler.js..."
if node -c handler.js 2>&1 | grep -q "Unexpected token 'export'"; then
    echo "❌ Ошибка в handler.js"
    node -c handler.js
else
    echo "✅ handler.js - OK"
fi

echo "🔍 lib/sticker.js..."
if node -c lib/sticker.js 2>&1 | grep -q "Unexpected token 'export'"; then
    echo "❌ Ошибка в lib/sticker.js"
    node -c lib/sticker.js
else
    echo "✅ lib/sticker.js - OK"
fi

echo "🔍 lib/simple.js..."
if node -c lib/simple.js 2>&1 | grep -q "Unexpected token 'export'"; then
    echo "❌ Ошибка в lib/simple.js"
    node -c lib/simple.js
else
    echo "✅ lib/simple.js - OK"
fi

echo ""
echo "📋 Проверяем файлы оптимизации..."

# Проверяем файлы оптимизации
for file in lib/cache.js lib/queue.js lib/pluginManager.js lib/monitor.js; do
    if [ -f "$file" ]; then
        echo "🔍 $file..."
        if node -c "$file" 2>&1 | grep -q "Unexpected token 'export'"; then
            echo "❌ Ошибка в $file"
            node -c "$file"
        else
            echo "✅ $file - OK"
        fi
    fi
done

echo ""
echo "📋 Проверяем package.json..."
echo "🔍 Type модуля: $(grep '"type"' package.json)"

echo ""
echo "📋 Проверяем импорты в index.js..."
grep -n "import.*from" index.js | head -10

echo ""
echo "✅ ПОИСК ЗАВЕРШЕН"
