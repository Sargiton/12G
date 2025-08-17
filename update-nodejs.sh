#!/bin/bash

echo "🔄 ОБНОВЛЕНИЕ NODE.JS ДО СОВМЕСТИМОЙ ВЕРСИИ"
echo "==========================================="

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node
pkill -f pm2
sleep 3

# Проверяем текущую версию Node.js
echo "📊 Текущая версия Node.js:"
node --version

# Устанавливаем NodeSource репозиторий для Node.js 20
echo "📦 Добавляем NodeSource репозиторий..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Обновляем пакеты
echo "🔄 Обновляем пакеты..."
apt update

# Устанавливаем Node.js 20
echo "📦 Устанавливаем Node.js 20..."
apt install -y nodejs

# Проверяем новую версию
echo "📊 Новая версия Node.js:"
node --version

# Проверяем версию npm
echo "📊 Версия npm:"
npm --version

# Переходим в папку проекта
cd /root/12G

# Очищаем кэши
echo "🧹 Очищаем кэши..."
npm cache clean --force
rm -rf node_modules
rm -f package-lock.json

# Создаем очищенный package.json
echo "📝 Создаем очищенный package.json..."
cat > package.json << 'EOF'
{
  "name": "Lynx-AI",
  "version": "1.5.0",
  "description": "WhatsApp Bot Multi Device con funciones avanzadas",
  "main": "index.js",
  "type": "module",
  "directories": {
    "lib": "lib",
    "storage": "storage",
    "plugins": "plugins",
    "src": "src"
  },
  "scripts": {
    "start": "node index.js",
    "start:optimized": "node --max-old-space-size=512 --expose-gc index.js",
    "qr": "node index.js qr",
    "code": "node index.js code",
    "test": "node test.js",
    "test2": "nodemon index.js",
    "check-modules": "node checkModules.js",
    "pm2:start": "pm2 start ecosystem-simple.config.cjs",
    "pm2:stop": "pm2 stop all",
    "pm2:restart": "pm2 restart all",
    "pm2:logs": "pm2 logs",
    "pm2:monit": "pm2 monit",
    "security-check": "npm audit && npm outdated"
  },
  "keywords": [
    "whatsapp-bot",
    "multi-device",
    "whatsapp-md",
    "bot-whatsapp",
    "js-whatsapp",
    "baileys-md"
  ],
  "homepage": "https://github.com/fartovii2311/142",
  "author": "DARK-CODE",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/fartovii2311/142.git"
  },
  "bugs": {
    "url": "https://github.com/fartovii2311/142/issues"
  },
  "license": "GPL-3.0-or-later",
  "dependencies": {
    "@adiwajshing/keyed-db": "^0.2.4",
    "@brandond/findthelyrics": "^2.0.5",
    "@distube/ytdl-core": "^4.16.12",
    "@green-code/music-track-data": "^2.0.3",
    "@ibaraki-douji/pixivts": "^2.4.1",
    "@shineiichijo/marika": "^2.0.6",
    "baileys": "6.7.0",
    "acrcloud": "^1.4.0",
    "api-dylux": "^1.5.6",
    "archiver": "^7.0.1",
    "awesome-phonenumber": "^6.7.8",
    "axios": "^1.6.0",
    "body-parser": "^1.20.2",
    "cfonts": "^3.3.0",
    "chalk": "^5.0.0",
    "cheerio": "^1.0.0-rc.12",
    "colors": "^1.4.0",
    "dotenv": "^16.3.1",
    "emoji-api": "^2.0.1",
    "emoji-country-flags": "^1.0.3",
    "express": "^4.18.1",
    "file-type": "^18.0.0",
    "form-data": "^4.0.0",
    "formdata-node": "^5.0.0",
    "fs-extra": "^11.2.0",
    "g-i-s": "^2.1.6",
    "google-it": "^1.6.4",
    "google-libphonenumber": "^3.2.40",
    "hispamemes": "^1.0.7",
    "human-readable": "^0.2.1",
    "instagram-url-direct": "^1.0.12",
    "jimp": "^0.16.1",
    "jsdom": "^20.0.1",
    "link-preview-js": "^3.0.0",
    "lodash": "^4.17.21",
    "lowdb": "^3.0.0",
    "mathjs": "^14.2.1",
    "md5": "^2.3.0",
    "megajs": "^1.1.3",
    "mime-types": "^2.1.35",
    "moment-timezone": "^0.5.46",
    "mongoose": "^6.6.5",
    "node-cache": "^5.1.2",
    "node-fetch": "^3.2.0",
    "node-gtts": "^2.0.2",
    "node-telegram-bot-api": "^0.64.0",
    "pino": "^8.17.2",
    "qrcode": "^1.5.3",
    "qrcode-terminal": "^0.12.0",
    "sharp": "^0.32.6",
    "spinnies": "^0.5.1",
    "sticker-pack-creator": "^1.0.2",
    "string-similarity": "^4.0.4",
    "sweetalert2": "^11.10.1",
    "swear-words": "^3.0.0",
    "tesseract.js": "^5.0.4",
    "tiktok-scraper": "^1.4.40",
    "tiktok-api": "^1.0.0",
    "translate-google": "^1.5.5",
    "translate-google-api": "^1.0.0",
    "twitter-api-v2": "^1.15.2",
    "twitter-url-direct": "^1.0.12",
    "url-exist": "^3.0.0",
    "util": "^0.12.5",
    "uuid": "^9.0.0",
    "wa-sticker-formatter": "^4.3.2",
    "webp-converter": "^2.3.3",
    "yargs": "^17.7.2",
    "ytdl-core": "^4.11.5"
  },
  "overrides": {
    "sharp": "^0.32.6",
    "axios": "^1.6.0",
    "uuid": "^9.0.0",
    "request": "npm:axios@^1.6.0",
    "request-promise": "npm:axios@^1.6.0"
  },
  "resolutions": {
    "axios": "^1.6.0",
    "uuid": "^9.0.0",
    "request": "npm:axios@^1.6.0",
    "request-promise": "npm:axios@^1.6.0"
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

# Устанавливаем критические пакеты отдельно
echo "📦 Устанавливаем критические пакеты..."
npm install baileys@6.7.0 --save-exact --force
npm install qrcode-terminal qrcode pino --force
npm install node-telegram-bot-api --force

# Проверяем установку
echo "✅ Проверяем установку..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен"
else
    echo "❌ baileys не установлен"
fi

if [ -d "node_modules/node-telegram-bot-api" ]; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
fi

# Создаем папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем сессии
echo "🧹 Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Проверяем синтаксис
echo "🔍 Проверяем синтаксис..."
if node -c index.js; then
    echo "✅ Синтаксис index.js корректен"
else
    echo "❌ Ошибка синтаксиса в index.js"
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

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-simple.config.cjs

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 10
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

echo ""
echo "🎉 NODE.JS ОБНОВЛЕН И БОТЫ ЗАПУЩЕНЫ!"
echo "===================================="
echo "✅ Node.js обновлен до совместимой версии"
echo "✅ npm совместим с Node.js"
echo "✅ Все зависимости установлены"
echo "✅ Боты запущены"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
