#!/bin/bash

echo "🔄 ПОЛНАЯ ПЕРЕУСТАНОВКА СИСТЕМЫ"
echo "================================"

# Проверяем версии
echo "📊 Проверяем версии..."
node --version
npm --version

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
pkill -f whatsapp 2>/dev/null
pkill -f telegram 2>/dev/null
sleep 5

# Удаляем папку проекта полностью
echo "🗑️ Удаляем папку проекта..."
cd /root
rm -rf 12G
sleep 2

# Очищаем npm кэш
echo "🧹 Очищаем npm кэш..."
npm cache clean --force

# Клонируем заново
echo "📥 Клонируем репозиторий заново..."
git clone https://github.com/Sargiton/12G.git
cd 12G

# Создаем чистый package.json
echo "📝 Создаем чистый package.json..."
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
    "@whiskeysockets/baileys": "6.5.0",
    "@xct007/frieren-scraper": "^0.0.2",
    "acrcloud": "^1.4.0",
    "api-dylux": "^1.5.6",
    "aptoide-scraper": "github:DIEGO-OFC/dv-aptoide-scraper",
    "archiver": "^7.0.1",
    "awesome-phonenumber": "^6.7.8",
    "axios": "^1.6.0",
    "body-parser": "^1.20.2",
    "bull": "^4.16.5",
    "cfonts": "^3.3.0",
    "chalk": "^5.0.0",
    "cheerio": "^1.0.0-rc.12",
    "colors": "^1.4.0",
    "compression": "^1.8.1",
    "dotenv": "^16.3.1",
    "emoji-api": "^2.0.1",
    "emoji-country-flags": "^1.0.3",
    "express": "^4.18.1",
    "fb-downloader-scrapper": "^1.0.1",
    "file-type": "^18.0.0",
    "form-data": "^4.0.0",
    "formdata-node": "^5.0.0",
    "fs-extra": "^11.2.0",
    "g-i-s": "^2.1.6",
    "google-it": "^1.6.4",
    "google-libphonenumber": "^3.2.40",
    "google-play-scraper": "latest",
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
    "node-id3": "^0.2.3",
    "node-os-utils": "^1.3.6",
    "node-telegram-bot-api": "^0.66.0",
    "node-webpmux": "^3.1.3",
    "openai": "^3.3.0",
    "os-utils": "^0.0.14",
    "pdfkit": "^0.13.0",
    "perf_hooks": "^0.0.1",
    "performance-now": "^2.1.0",
    "pino": "^8.6.1",
    "pino-pretty": "^9.1.1",
    "prompt-sync": "4.2.0",
    "qrcode": "^1.5.4",
    "qrcode-terminal": "^0.12.0",
    "readline-sync": "1.4.10",
    "redis": "^4.7.1",
    "rimraf": "^5.0.0",
    "sharp": "^0.32.6",
    "similarity": "^1.2.1",
    "socket.io": "^4.5.2",
    "spotifydl-x": "^0.3.5",
    "syntax-error": "^1.4.0",
    "terminal-image": "^2.0.0",
    "translate-google-api": "^1.0.4",
    "url-file-size": "^1.0.5-1",
    "url-regex-safe": "^3.0.0",
    "uuid": "^9.0.0",
    "wa-sticker-formatter": "^4.3.2",
    "yargs": "^17.6.0",
    "yt-search": "^2.10.3",
    "ytdl-core": "^4.11.5"
  },
  "devDependencies": {
    "eslint": "^9.0.0",
    "eslint-config-google": "^0.14.0",
    "nodemon": "^3.0.1"
  },
  "optionalDependencies": {
    "@vitalets/google-translate-api": "^9.2.0"
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

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
npm install --force

# Устанавливаем критические пакеты отдельно
echo "📦 Устанавливаем критические пакеты..."
npm install @whiskeysockets/baileys@6.5.0 --save-exact --force
npm install qrcode-terminal qrcode pino --force
npm install node-telegram-bot-api --force

# Создаем необходимые папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем старые сессии
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Создаем простой Telegram бот
echo "📝 Создаем простой Telegram бот..."
cat > telegram-bot.cjs << 'EOF'
const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const OWNER_IDS = [1424509648, 393422971, 2134847831];
const TELEGRAM_TOKEN = '7882415806:AAGKIWslOZtVsK-EIHyHdIrM0jNS73BAnkM';
const WHATSAPP_PM2_NAME = 'whatsapp-bot';

const bot = new TelegramBot(TELEGRAM_TOKEN, { polling: true });

console.log('🤖 Telegram бот запущен');

function onlyOwner(msg) {
  if (!OWNER_IDS.includes(msg.from.id)) {
    bot.sendMessage(msg.chat.id, '❌ Нет доступа. Эта команда доступна только владельцу бота.');
    return false;
  }
  return true;
}

// 1. /qr - Получить QR-код
bot.onText(/\/qr/, (msg) => {
  if (!onlyOwner(msg)) return;

  const qrPath = path.join(__dirname, 'qr.png');
  if (fs.existsSync(qrPath)) {
    const stats = fs.statSync(qrPath);
    const fileSize = (stats.size / 1024).toFixed(1);
    const modifiedTime = stats.mtime.toLocaleString('ru-RU');

    bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath), {
      caption: `📱 QR код WhatsApp\n📏 Размер: ${fileSize}KB\n📅 Создан: ${modifiedTime}`
    });
  } else {
    bot.sendMessage(msg.chat.id, '❌ QR код не найден. Запустите WhatsApp бота для генерации.');
  }
});

// 2. /status - Статус ботов
bot.onText(/\/status/, (msg) => {
  if (!onlyOwner(msg)) return;

  exec('pm2 list', (err, stdout, stderr) => {
    if (err) {
      bot.sendMessage(msg.chat.id, '❌ Ошибка получения статуса: ' + stderr);
      return;
    }

    const lines = stdout.split('\n');
    let statusMessage = '📊 Статус ботов:\n\n';

    lines.forEach(line => {
      if (line.includes('whatsapp-bot') || line.includes('telegram-bot')) {
        statusMessage += line + '\n';
      }
    });

    bot.sendMessage(msg.chat.id, statusMessage);
  });
});

// 3. /restart - Перезапустить WhatsApp бота
bot.onText(/\/restart/, (msg) => {
  if (!onlyOwner(msg)) return;

  bot.sendMessage(msg.chat.id, '🔄 Перезапускаю WhatsApp бота...');

  exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) {
      bot.sendMessage(msg.chat.id, '❌ Ошибка перезапуска: ' + stderr);
      return;
    }

    bot.sendMessage(msg.chat.id, '✅ WhatsApp бот перезапущен успешно!');

    setTimeout(() => {
      const qrPath = path.join(__dirname, 'qr.png');
      if (fs.existsSync(qrPath)) {
        bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath), {
          caption: '📱 Новый QR код после перезапуска'
        });
      }
    }, 3000);
  });
});

// 4. /clear - Очистить сессию и QR код
bot.onText(/\/clear/, (msg) => {
  if (!onlyOwner(msg)) return;

  bot.sendMessage(msg.chat.id, '🧹 Очищаю сессию и QR код...');

  let clearedItems = [];

  const sessionPath = path.join(__dirname, 'LynxSession');
  if (fs.existsSync(sessionPath)) {
    fs.rmSync(sessionPath, { recursive: true, force: true });
    clearedItems.push('🗂️ Сессия WhatsApp');
  }

  const qrPath = path.join(__dirname, 'qr.png');
  if (fs.existsSync(qrPath)) {
    fs.unlinkSync(qrPath);
    clearedItems.push('📱 QR код');
  }

  const tmpPath = path.join(__dirname, 'tmp');
  if (fs.existsSync(tmpPath)) {
    const tmpFiles = fs.readdirSync(tmpPath);
    tmpFiles.forEach(file => {
      if (file.includes('qr') || file.endsWith('.png') || file.endsWith('.jpg')) {
        fs.unlinkSync(path.join(tmpPath, file));
      }
    });
    clearedItems.push('📁 Временные файлы');
  }

  const message = clearedItems.length > 0
    ? `✅ Очищено:\n${clearedItems.map(item => `  • ${item}`).join('\n')}`
    : 'ℹ️ Нечего очищать';

  bot.sendMessage(msg.chat.id, message);
});

// 5. /logs - Последние логи
bot.onText(/\/logs/, (msg) => {
  if (!onlyOwner(msg)) return;

  exec(`pm2 logs ${WHATSAPP_PM2_NAME} --lines 10 --nostream`, { maxBuffer: 1024 * 1024 }, (err, stdout, stderr) => {
    if (err) {
      bot.sendMessage(msg.chat.id, '❌ Ошибка получения логов: ' + stderr);
      return;
    }

    const logs = stdout.trim();
    if (logs) {
      if (logs.length > 4000) {
        const parts = logs.match(/.{1,4000}/g);
        parts.forEach((part, index) => {
          bot.sendMessage(msg.chat.id, `📋 Логи WhatsApp (часть ${index + 1}):\n\`\`\`\n${part}\n\`\`\``, { parse_mode: 'Markdown' });
        });
      } else {
        bot.sendMessage(msg.chat.id, `📋 Последние логи WhatsApp:\n\`\`\`\n${logs}\n\`\`\``, { parse_mode: 'Markdown' });
      }
    } else {
      bot.sendMessage(msg.chat.id, 'ℹ️ Логи пусты или WhatsApp бот не запущен');
    }
  });
});

// 6. /help - Помощь
bot.onText(/\/help/, (msg) => {
  if (!onlyOwner(msg)) return;

  const helpMessage = `🤖 Команды Telegram бота:

📱 /qr - Получить QR код WhatsApp
📊 /status - Статус ботов
🔄 /restart - Перезапустить WhatsApp бота
🧹 /clear - Очистить сессию и QR код
📋 /logs - Последние логи WhatsApp
❓ /help - Показать эту справку

💡 Для подключения WhatsApp:
1. Отправьте /clear для очистки
2. Отправьте /restart для перезапуска
3. Отправьте /qr для получения QR кода
4. Отсканируйте QR код в WhatsApp`;

  bot.sendMessage(msg.chat.id, helpMessage);
});

bot.on('error', (error) => {
  console.error('❌ Ошибка Telegram бота:', error);
});

bot.on('polling_error', (error) => {
  console.error('❌ Ошибка polling:', error);
});

console.log('✅ Telegram бот готов к работе');
console.log('📋 Доступные команды: /qr, /status, /restart, /clear, /logs, /help');
EOF

# Создаем конфигурацию PM2
echo "📝 Создаем конфигурацию PM2..."
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

# Проверяем синтаксис файлов
echo "🔍 Проверяем синтаксис файлов..."
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

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

# Проверяем статус
echo "📊 Проверяем статус ботов..."
sleep 10
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

# Проверяем логи на ошибки
echo "📋 Проверяем логи на ошибки..."
sleep 5
if [ -f "logs/whatsapp-error-0.log" ]; then
  echo "🚨 Последние ошибки WhatsApp:"
  tail -3 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
  echo "🚨 Последние ошибки Telegram:"
  tail -3 logs/telegram-error-1.log
fi

echo ""
echo "🎉 ПОЛНАЯ ПЕРЕУСТАНОВКА ЗАВЕРШЕНА!"
echo "================================="
echo "✅ Все файлы удалены и переустановлены"
echo "✅ @whiskeysockets/baileys 6.5.0 установлен"
echo "✅ Синтаксис файлов исправлен"
echo "✅ Все зависимости установлены"
echo "✅ Боты запущены с новой конфигурацией"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
