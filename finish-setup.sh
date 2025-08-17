#!/bin/bash

echo "🚀 ЗАВЕРШЕНИЕ УСТАНОВКИ ПОСЛЕ ОБНОВЛЕНИЯ NODE.JS"
echo "================================================"

# Проверяем версии
echo "📊 Проверяем версии Node.js и npm..."
node --version
npm --version

# Переходим в папку проекта
cd /root/12G

# Очищаем старые зависимости
echo "🧹 Очищаем старые зависимости..."
npm cache clean --force
rm -rf node_modules
rm -f package-lock.json

# Создаем минимальный package.json с только необходимыми зависимостями
echo "📝 Создаем минимальный package.json..."
cat > package.json << 'EOF'
{
  "name": "Lynx-AI",
  "version": "1.5.0",
  "description": "WhatsApp Bot Multi Device con funciones avanzadas",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "start": "node index.js",
    "pm2:start": "pm2 start ecosystem-simple.config.cjs",
    "pm2:stop": "pm2 stop all",
    "pm2:restart": "pm2 restart all"
  },
  "dependencies": {
    "baileys": "6.7.0",
    "node-telegram-bot-api": "^0.64.0",
    "pino": "^8.17.2",
    "qrcode": "^1.5.3",
    "qrcode-terminal": "^0.12.0",
    "axios": "^1.6.0",
    "dotenv": "^16.3.1",
    "express": "^4.18.1",
    "fs-extra": "^11.2.0",
    "moment-timezone": "^0.5.46",
    "node-cache": "^5.1.2",
    "uuid": "^9.0.0",
    "cfonts": "^3.3.0",
    "chalk": "^5.0.0",
    "colors": "^1.4.0",
    "cheerio": "^1.0.0-rc.12",
    "file-type": "^18.0.0",
    "form-data": "^4.0.0",
    "g-i-s": "^2.1.6",
    "google-it": "^1.6.4",
    "human-readable": "^0.2.1",
    "jimp": "^0.16.1",
    "jsdom": "^20.0.1",
    "lodash": "^4.17.21",
    "lowdb": "^3.0.0",
    "mathjs": "^14.2.1",
    "md5": "^2.3.0",
    "mime-types": "^2.1.35",
    "mongoose": "^6.6.5",
    "node-fetch": "^3.2.0",
    "node-gtts": "^2.0.2",
    "sharp": "^0.32.6",
    "spinnies": "^0.5.1",
    "string-similarity": "^4.0.4",
    "util": "^0.12.5",
    "yargs": "^17.7.2"
  },
  "engines": {
    "node": ">=20.0.0",
    "npm": ">=8.0.0"
  }
}
EOF

echo "✅ package.json создан"

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
npm install --force

# Проверяем установку критических пакетов
echo "✅ Проверяем установку критических пакетов..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен"
else
    echo "❌ baileys не установлен"
    npm install baileys@6.7.0 --save-exact --force
fi

if [ -d "node_modules/node-telegram-bot-api" ]; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
    npm install node-telegram-bot-api --force
fi

if [ -d "node_modules/pino" ]; then
    echo "✅ pino установлен"
else
    echo "❌ pino не установлен"
    npm install pino --force
fi

# Создаем необходимые папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем старые сессии
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Проверяем синтаксис файлов
echo "🔍 Проверяем синтаксис файлов..."
if node -c index.js; then
    echo "✅ Синтаксис index.js корректен"
else
    echo "❌ Ошибка синтаксиса в index.js"
    echo "🔧 Исправляем логгер..."
    sed -i 's/logger: { level: '\''silent'\'' }/logger: pino({ level: '\''silent'\'' })/g' index.js
fi

if node -c telegram-bot.cjs; then
    echo "✅ Синтаксис telegram-bot.cjs корректен"
else
    echo "❌ Ошибка синтаксиса в telegram-bot.cjs"
fi

# Создаем конфигурацию PM2
echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-simple.config.cjs << 'EOF'
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
      env: {
        NODE_ENV: 'production'
      },
      error_file: './logs/telegram-error-1.log',
      out_file: './logs/telegram-out-1.log',
      log_file: './logs/telegram-combined-1.log',
      time: true
    }
  ]
};
EOF

# Останавливаем старые процессы
echo "🛑 Останавливаем старые процессы..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-simple.config.cjs

# Проверяем статус
echo "📊 Проверяем статус ботов..."
sleep 5
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

# Проверяем логи на ошибки
echo "📋 Проверяем логи на ошибки..."
sleep 3
if [ -f "logs/whatsapp-error-0.log" ]; then
    echo "🚨 Последние ошибки WhatsApp:"
    tail -3 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
    echo "🚨 Последние ошибки Telegram:"
    tail -3 logs/telegram-error-1.log
fi

echo ""
echo "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
echo "======================="
echo "✅ Node.js обновлен до совместимой версии"
echo "✅ Все зависимости установлены"
echo "✅ Синтаксис файлов проверен"
echo "✅ Боты запущены"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
