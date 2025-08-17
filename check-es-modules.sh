#!/bin/bash

echo "🔍 ПРОВЕРКА ES МОДУЛЕЙ"
echo "====================="

# Переходим в папку проекта
cd /root/12G

echo "📋 Проверяем синтаксис основных файлов..."

# Проверяем основные файлы
echo "🔍 index.js..."
node -c index.js

echo "🔍 config.js..."
node -c config.js

echo "🔍 handler.js..."
node -c handler.js

echo "🔍 lib/sticker.js..."
node -c lib/sticker.js

echo "🔍 lib/simple.js..."
node -c lib/simple.js

echo ""
echo "📋 Проверяем проблемные файлы..."

# Ищем файлы с module.exports в ES модулях
echo "🔍 Поиск module.exports в JS файлах..."
grep -r "module\.exports" --include="*.js" . | head -10

echo ""
echo "📋 Проверяем импорты..."

# Ищем неправильные импорты
echo "🔍 Поиск неправильных импортов..."
grep -r "import.*from.*'cheerio'" --include="*.js" .

echo ""
echo "✅ ПРОВЕРКА ЗАВЕРШЕНА"
