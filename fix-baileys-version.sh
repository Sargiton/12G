#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ВЕРСИИ BAILEYS"
echo "=============================="

cd /root/12G

echo "🛑 Останавливаем ботов..."
pm2 stop all
pm2 delete all

echo "📦 Удаляем старые зависимости..."
rm -rf node_modules package-lock.json

echo "📝 Обновляем package.json..."
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
  "homepage": "https://github.com/Sargiton/12G",
  "author": "DARK-CODE",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/Sargiton/12G.git"
  },
  "bugs": {
    "url": "https://github.com/Sargiton/12G/issues"
  },
  "license": "GPL-3.0-or-later",
  "dependencies": {
    "@adiwajshing/keyed-db": "^0.2.4",
    "@brandond/findthelyrics": "^2.0.5",
    "@distube/ytdl-core": "^4.16.12",
    "@green-code/music-track-data": "^2.0.3",
    "@ibaraki-douji/pixivts": "^2.4.1",
    "@shineiichijo/marika": "^2.0.6",
    "acrcloud": "^1.4.0",
    "api-dylux": "^1.5.6",
    "archiver": "^7.0.1",
    "awesome-phonenumber": "^6.7.8",
    "axios": "^1.6.0",
    "baileys": "latest",
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
    "node-telegram-bot-api": "^0.66.0",
    "pino": "^8.17.2",
    "qrcode": "^1.5.3",
    "qrcode-terminal": "^0.12.0",
    "sharp": "^0.32.6",
    "spinnies": "^0.5.1",
    "string-similarity": "^4.0.4",
    "syntax-error": "^1.4.0",
    "uuid": "^9.0.0",
    "wa-sticker-formatter": "^4.3.2",
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
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
EOF

echo "📦 Устанавливаем зависимости с новой версией Baileys..."
npm install

echo "📝 Создаем рабочий бот..."
cat > final-working-bot.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

const logger = pino({ level: 'silent' })

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
    
    const sock = makeWASocket({
        printQRInTerminal: true,
        logger,
        auth: state,
        browser: ['DarkCore Bot', 'Chrome', '1.0.0']
    })

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update
        
        if (qr) {
            console.log('🔐 QR КОД ПОЛУЧЕН!')
            qrcode.generate(qr, { small: true })
        }
        
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
            console.log('❌ Соединение закрыто из-за ', lastDisconnect?.error, ', переподключение ', shouldReconnect)
            if (shouldReconnect) {
                setTimeout(connectToWhatsApp, 3000)
            }
        } else if (connection === 'open') {
            console.log('✅ Соединение установлено!')
        }
    })

    sock.ev.on('creds.update', saveCreds)
}

console.log('🚀 Запуск финального рабочего бота...')
connectToWhatsApp()
EOF

echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-working.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-working',
      script: 'final-working-bot.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: { NODE_ENV: 'production' },
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_file: './logs/combined.log',
      time: true
    },
    {
      name: 'telegram-working',
      script: 'telegram-bot.cjs',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: { NODE_ENV: 'production' },
      out_file: './logs/telegram-out.log',
      error_file: './logs/telegram-error.log',
      log_file: './logs/telegram-combined.log',
      time: true
    }
  ]
};
EOF

echo "🤖 Запускаем ботов..."
pm2 start ecosystem-working.config.cjs

sleep 10

echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-working --lines 10

echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "🔐 QR код должен появиться в логах WhatsApp бота"
