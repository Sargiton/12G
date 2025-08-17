#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОШИБКИ CHEERIO"
echo "=============================="

# Переходим в папку проекта
cd /root/12G

# Останавливаем боты
echo "🛑 Останавливаем боты..."
pm2 stop all

# Исправляем импорт cheerio
echo "🔧 Исправляем импорт cheerio..."
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' config.js

# Проверяем синтаксис
echo "🔍 Проверяем синтаксис..."
node -c config.js
node -c index.js

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

# Показываем результат
echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
pm2 list
echo ""
echo "📱 Теперь отправьте /qr в Telegram бота"
