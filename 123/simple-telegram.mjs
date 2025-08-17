import TelegramBot from 'node-telegram-bot-api';
import { exec } from 'child_process';
import fs from 'fs';

// Простая конфигурация
const TELEGRAM_TOKEN = '7882415806:AAGKIWslOZtVsK-EIHyHdIrM0jNS73BAnkM';
const OWNER_IDS = [1424509648, 393422971, 2134847831];

// Создаем бота
const bot = new TelegramBot(TELEGRAM_TOKEN, { polling: true });

console.log('🤖 Простой Telegram бот запущен!');

// Проверка доступа
function checkAccess(msg) {
    if (!OWNER_IDS.includes(msg.from.id)) {
        bot.sendMessage(msg.chat.id, '❌ Нет доступа');
        return false;
    }
    return true;
}

// Команда /start
bot.onText(/\/start/, (msg) => {
    if (!checkAccess(msg)) return;
    
    const text = `
🤖 *Простой Telegram Бот*

Команды:
• /test - Тест бота
• /status - Статус WhatsApp
• /qr - QR код
• /help - Помощь

Бот работает! ✅
    `;
    
    bot.sendMessage(msg.chat.id, text, { parse_mode: 'Markdown' });
});

// Тест бота
bot.onText(/\/test/, (msg) => {
    if (!checkAccess(msg)) return;
    bot.sendMessage(msg.chat.id, '✅ Бот работает! Тест пройден.');
});

// Статус WhatsApp
bot.onText(/\/status/, (msg) => {
    if (!checkAccess(msg)) return;
    
    exec('pm2 show whatsapp-old', (err, stdout, stderr) => {
        if (err) {
            bot.sendMessage(msg.chat.id, '❌ Ошибка получения статуса');
            return;
        }
        const status = stdout.includes('online') ? '🟢 Онлайн' : '🔴 Оффлайн';
        bot.sendMessage(msg.chat.id, `📊 WhatsApp бот: ${status}`);
    });
});

// QR код
bot.onText(/\/qr/, (msg) => {
    if (!checkAccess(msg)) return;
    
    const qrPath = './qr.png';
    
    if (fs.existsSync(qrPath)) {
        bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath), {
            caption: '📱 QR код'
        });
    } else {
        bot.sendMessage(msg.chat.id, '❌ QR код не найден');
    }
});

// Помощь
bot.onText(/\/help/, (msg) => {
    if (!checkAccess(msg)) return;
    bot.sendMessage(msg.chat.id, '🤖 Простой Telegram бот работает!');
});

// Обработка ошибок
bot.on('error', (error) => {
    console.error('❌ Ошибка:', error);
});

bot.on('polling_error', (error) => {
    console.error('❌ Polling ошибка:', error);
});

console.log('✅ Простой Telegram бот готов!');
