const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Конфигурация
const OWNER_IDS = [1424509648, 393422971, 2134847831]; // Ваши Telegram ID
const TELEGRAM_TOKEN = '7882415806:AAGKIWslOZtVsK-EIHyHdIrM0jNS73BAnkM';
const WHATSAPP_PM2_NAME = 'whatsapp-old';

// Создаем бота
const bot = new TelegramBot(TELEGRAM_TOKEN, { polling: true });

console.log('🤖 Новый Telegram бот запущен!');

// Проверка доступа
function onlyOwner(msg) {
    if (!OWNER_IDS.includes(msg.from.id)) {
        bot.sendMessage(msg.chat.id, '❌ Нет доступа. Вы не авторизованы.');
        return false;
    }
    return true;
}

// Команда /start
bot.onText(/\/start/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    const welcomeText = `
🤖 *Новый Telegram Бот*

Доступные команды:
• /qr - Получить QR код
• /status - Статус WhatsApp бота
• /logs - Логи WhatsApp бота
• /restart - Перезапустить WhatsApp бота
• /stop - Остановить WhatsApp бота
• /start_wa - Запустить WhatsApp бота
• /reset - Сбросить сессию WhatsApp

Бот работает с процессом: *${WHATSAPP_PM2_NAME}*
    `;
    
    bot.sendMessage(msg.chat.id, welcomeText, { parse_mode: 'Markdown' });
});

// Получить QR код
bot.onText(/\/qr/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    const qrPath = path.join(__dirname, '123', 'qr.png');
    if (fs.existsSync(qrPath)) {
        bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath), {
            caption: '📱 QR код для подключения WhatsApp'
        });
    } else {
        bot.sendMessage(msg.chat.id, '❌ QR код не найден. Возможно, WhatsApp бот не запущен или уже подключен.');
    }
});

// Статус WhatsApp бота
bot.onText(/\/status/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    exec(`pm2 show ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка получения статуса: ${err.message}`);
            return;
        }
        
        const status = stdout.includes('online') ? '🟢 Онлайн' : '🔴 Оффлайн';
        bot.sendMessage(msg.chat.id, `📊 Статус WhatsApp бота: ${status}\n\n${stdout.slice(0, 1000)}`);
    });
});

// Логи WhatsApp бота
bot.onText(/\/logs/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    exec(`pm2 logs ${WHATSAPP_PM2_NAME} --lines 20 --nostream`, { maxBuffer: 1024 * 1024 }, (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка получения логов: ${err.message}`);
            return;
        }
        
        const logs = stdout || 'Нет логов';
        bot.sendMessage(msg.chat.id, `📋 Последние логи WhatsApp бота:\n\n\`\`\`${logs.slice(-3000)}\`\`\``, { parse_mode: 'Markdown' });
    });
});

// Перезапустить WhatsApp бота
bot.onText(/\/restart/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    bot.sendMessage(msg.chat.id, '🔄 Перезапускаю WhatsApp бота...');
    
    exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка перезапуска: ${err.message}`);
            return;
        }
        bot.sendMessage(msg.chat.id, '✅ WhatsApp бот перезапущен!');
    });
});

// Остановить WhatsApp бота
bot.onText(/\/stop/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    bot.sendMessage(msg.chat.id, '⏹️ Останавливаю WhatsApp бота...');
    
    exec(`pm2 stop ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка остановки: ${err.message}`);
            return;
        }
        bot.sendMessage(msg.chat.id, '✅ WhatsApp бот остановлен!');
    });
});

// Запустить WhatsApp бота
bot.onText(/\/start_wa/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    bot.sendMessage(msg.chat.id, '🚀 Запускаю WhatsApp бота...');
    
    exec(`pm2 start ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка запуска: ${err.message}`);
            return;
        }
        bot.sendMessage(msg.chat.id, '✅ WhatsApp бот запущен!');
    });
});

// Сбросить сессию WhatsApp
bot.onText(/\/reset/, (msg) => {
    if (!onlyOwner(msg)) return;
    
    bot.sendMessage(msg.chat.id, '🗑️ Сбрасываю сессию WhatsApp...');
    
    const sessionPath = path.join(__dirname, '123', 'LynxSession');
    if (fs.existsSync(sessionPath)) {
        try {
            fs.rmSync(sessionPath, { recursive: true, force: true });
            bot.sendMessage(msg.chat.id, '✅ Сессия сброшена! Перезапустите WhatsApp бота для генерации нового QR кода.');
        } catch (error) {
            bot.sendMessage(msg.chat.id, `❌ Ошибка сброса сессии: ${error.message}`);
        }
    } else {
        bot.sendMessage(msg.chat.id, 'ℹ️ Папка сессии не найдена.');
    }
});

// Обработка ошибок
bot.on('error', (error) => {
    console.error('❌ Ошибка Telegram бота:', error);
});

bot.on('polling_error', (error) => {
    console.error('❌ Ошибка polling:', error);
});

console.log('✅ Telegram бот готов к работе!');
