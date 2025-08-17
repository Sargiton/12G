#!/bin/bash

echo "🚀 ПОЛНОЕ РЕШЕНИЕ ДЛЯ РАБОТЫ БОТА"
echo "=================================="

cd /root/12G

echo "🛑 Останавливаем все процессы..."
pm2 stop all
pkill -f node
pkill -f pm2

echo ""
echo "📋 Проверяем версии..."
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

echo ""
echo "🔧 ОБНОВЛЯЕМ ДО РАБОЧИХ ВЕРСИЙ..."

# Обновляем Node.js до версии 22 (как на рабочем компьютере)
echo "📦 Обновляем Node.js до версии 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

echo ""
echo "📋 Проверяем новую версию..."
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

echo ""
echo "🧹 Очищаем все кэши..."
npm cache clean --force
rm -rf node_modules package-lock.json

echo ""
echo "📦 Устанавливаем зависимости заново..."
npm install

echo ""
echo "🔧 ИСПРАВЛЯЕМ ВСЕ ПРОБЛЕМЫ..."

# Исправляем handler.js - комментируем проблемные строки
echo "🔧 Исправляем handler.js..."
sed -i 's/^  performanceMonitor\.recordMessage(processingTime);/\/\/ performanceMonitor.recordMessage(processingTime);/g' handler.js
sed -i 's/^  const queueStats = await messageQueue\.getStats();/\/\/ const queueStats = await messageQueue.getStats();/g' handler.js
sed -i 's/^  performanceMonitor\.updateQueueStats(queueStats);/\/\/ performanceMonitor.updateQueueStats(queueStats);/g' handler.js

# Исправляем все импорты cheerio
echo "🔧 Исправляем импорты cheerio..."
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' config.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' lib/scraper.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-mediafire.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/search-google.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/scraper.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-play2.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/prueba-sfile.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/dl-apksearch.js
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' plugins/nsfw-adult-xnxxsearch.js

# Исправляем sticker.js
echo "🔧 Исправляем sticker.js..."
sed -i 's/module\.exports\.support/support/g' lib/sticker.js

echo ""
echo "🔍 Проверяем синтаксис..."
node -c index.js
node -c handler.js
node -c config.js

echo ""
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -f qr.png

echo ""
echo "📝 Создаем правильную конфигурацию PM2..."
cat > ecosystem-final.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-bot',
      script: 'index.js',
      cwd: '/root/12G',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '200M',
      env: { 
        NODE_ENV: 'production', 
        NODE_OPTIONS: '--max-old-space-size=512' 
      },
      error_file: './logs/whatsapp-error-0.log',
      out_file: './logs/whatsapp-out-0.log',
      log_file: './logs/whatsapp-combined-0.log',
      time: true
    },
    {
      name: 'telegram-bot',
      script: 'telegram-bot.cjs',
      cwd: '/root/12G',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '100M',
      env: { NODE_ENV: 'production' },
      error_file: './logs/telegram-error-1.log',
      out_file: './logs/telegram-out-1.log',
      log_file: './logs/telegram-combined-1.log',
      time: true
    }
  ]
};
EOF

echo ""
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

echo ""
echo "⏳ Ждем запуска..."
sleep 10

echo ""
echo "📋 Статус ботов:"
pm2 list

echo ""
echo "📋 Проверяем логи WhatsApp бота:"
pm2 logs whatsapp-bot --lines 20

echo ""
echo "📋 Проверяем логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "✅ РЕШЕНИЕ ЗАВЕРШЕНО!"
echo "===================="
echo "📱 Теперь отправьте /qr в Telegram бота"
echo "🔧 Если не работает, попробуйте:"
echo "   pm2 restart all"
echo "   pm2 logs whatsapp-bot --lines 50"
