const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const OWNER_IDS = [1424509648, 393422971, 2134847831]; // Массив разрешённых Telegram user ID
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
    
    // Ждем 3 секунды и отправляем QR код если есть
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
  
  // Очищаем сессию
  const sessionPath = path.join(__dirname, 'LynxSession');
  if (fs.existsSync(sessionPath)) {
    fs.rmSync(sessionPath, { recursive: true, force: true });
    clearedItems.push('🗂️ Сессия WhatsApp');
  }
  
  // Очищаем QR код
  const qrPath = path.join(__dirname, 'qr.png');
  if (fs.existsSync(qrPath)) {
    fs.unlinkSync(qrPath);
    clearedItems.push('📱 QR код');
  }
  
  // Очищаем временные файлы
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
      // Разбиваем на части если лог слишком длинный
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

// Обработка ошибок
bot.on('error', (error) => {
  console.error('❌ Ошибка Telegram бота:', error);
});

bot.on('polling_error', (error) => {
  console.error('❌ Ошибка polling:', error);
});

console.log('✅ Telegram бот готов к работе');
console.log('📋 Доступные команды: /qr, /status, /restart, /clear, /logs, /help');
