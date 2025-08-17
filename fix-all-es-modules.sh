#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ВСЕХ ES МОДУЛЕЙ"
echo "=============================="

# Переходим в папку проекта
cd /root/12G

# Останавливаем боты
echo "🛑 Останавливаем боты..."
pm2 stop all

# Сохраняем локальные изменения
echo "💾 Сохраняем локальные изменения..."
git stash

# Обновляем код
echo "📥 Обновляем код..."
git pull origin master

# Применяем сохраненные изменения
echo "📋 Применяем сохраненные изменения..."
git stash pop

# Исправляем импорты cheerio во всех файлах
echo "🔧 Исправляем импорты cheerio..."

# config.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' config.js

# lib/scraper.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' lib/scraper.js

# plugins/dl-mediafire.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-mediafire.js

# plugins/search-google.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/search-google.js

# plugins/scraper.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/scraper.js

# plugins/dl-play2.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-play2.js

# plugins/prueba-sfile.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/prueba-sfile.js

# plugins/dl-apksearch.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-apksearch.js

# plugins/nsfw-adult-xnxxsearch.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/nsfw-adult-xnxxsearch.js

# Проверяем синтаксис
echo "🔍 Проверяем синтаксис..."
node -c config.js
node -c index.js
node -c handler.js
node -c lib/sticker.js

# Очищаем старые сессии
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -f qr.png

# Переустанавливаем зависимости
echo "📦 Переустанавливаем зависимости..."
npm install

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

# Ждем немного
sleep 5

# Показываем результат
echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
pm2 list

echo ""
echo "📋 Проверяем логи..."
pm2 logs whatsapp-bot --lines 10

echo ""
echo "📱 Теперь отправьте /qr в Telegram бота"
