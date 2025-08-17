#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ СОХРАНЕНИЯ QR КОДА"
echo "=================================="

cd /root/12G

echo "🛑 Останавливаем ботов..."
pm2 stop all
pm2 delete all

echo "📝 Создаем бота с сохранением QR в файл..."
cat > final-working-bot.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'
import fs from 'fs'
import path from 'path'

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
            
            // Генерируем QR в терминале
            qrcode.generate(qr, { small: true })
            
            // Сохраняем QR в файл
            try {
                const qrBuffer = await import('qrcode').then(qr => qr.default.toBuffer(qr, { 
                    type: 'png',
                    width: 300,
                    margin: 2
                }))
                
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                
                // Также сохраняем в tmp папку
                fs.writeFileSync('tmp/qr.png', qrBuffer)
                console.log('✅ QR код сохранен в tmp/qr.png')
                
            } catch (error) {
                console.log('❌ Ошибка сохранения QR:', error.message)
            }
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

echo "📝 Обновляем Telegram бота для поиска QR в разных местах..."
cat > telegram-bot.cjs << 'EOF'
const TelegramBot = require('node-telegram-bot-api');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

// Замените на ваш токен
const token = 'YOUR_TELEGRAM_BOT_TOKEN';
const bot = new TelegramBot(token, { polling: true });

console.log('🤖 Telegram бот запущен');

// Функция для поиска QR файла
function findQRFile() {
    const possiblePaths = [
        'qr.png',
        'tmp/qr.png',
        './qr.png',
        './tmp/qr.png',
        '/root/12G/qr.png',
        '/root/12G/tmp/qr.png'
    ];
    
    for (const filePath of possiblePaths) {
        if (fs.existsSync(filePath)) {
            console.log(`✅ QR файл найден: ${filePath}`);
            return filePath;
        }
    }
    
    console.log('❌ QR файл не найден');
    return null;
}

// Функция для получения статуса WhatsApp бота
function getWhatsAppStatus() {
    return new Promise((resolve) => {
        exec('pm2 jlist', (error, stdout) => {
            if (error) {
                resolve('❌ Ошибка получения статуса');
                return;
            }
            
            try {
                const processes = JSON.parse(stdout);
                const whatsappProcess = processes.find(p => p.name === 'whatsapp-working');
                
                if (whatsappProcess) {
                    const status = whatsappProcess.pm2_env.status;
                    const uptime = Math.floor((Date.now() - whatsappProcess.pm2_env.pm_uptime) / 1000);
                    resolve(`📱 WhatsApp бот: ${status} (работает ${uptime} сек)`);
                } else {
                    resolve('❌ WhatsApp бот не найден');
                }
            } catch (e) {
                resolve('❌ Ошибка парсинга статуса');
            }
        });
    });
}

// Команда /qr
bot.onText(/\/qr/, async (msg) => {
    const chatId = msg.chat.id;
    console.log(`📱 Запрос QR кода от ${msg.from.username || msg.from.first_name}`);
    
    try {
        const qrFile = findQRFile();
        
        if (qrFile) {
            // Проверяем размер файла
            const stats = fs.statSync(qrFile);
            const fileSizeInMB = stats.size / (1024 * 1024);
            
            if (fileSizeInMB > 10) {
                await bot.sendMessage(chatId, '⚠️ QR файл слишком большой для отправки');
                return;
            }
            
            await bot.sendPhoto(chatId, qrFile, {
                caption: '🔐 QR код для подключения WhatsApp\n\nОтсканируйте этот код в WhatsApp'
            });
            console.log('✅ QR код отправлен');
        } else {
            await bot.sendMessage(chatId, '❌ QR код не найден\n\nПопробуйте позже или проверьте статус бота командой /status');
        }
    } catch (error) {
        console.error('❌ Ошибка отправки QR:', error.message);
        await bot.sendMessage(chatId, '❌ Ошибка отправки QR кода');
    }
});

// Команда /status
bot.onText(/\/status/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        const status = await getWhatsAppStatus();
        await bot.sendMessage(chatId, `📊 Статус ботов:\n\n${status}\n\n📲 Telegram бот: ✅ работает`);
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Ошибка получения статуса');
    }
});

// Команда /restart
bot.onText(/\/restart/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        exec('pm2 restart whatsapp-working', async (error) => {
            if (error) {
                await bot.sendMessage(chatId, '❌ Ошибка перезапуска WhatsApp бота');
            } else {
                await bot.sendMessage(chatId, '✅ WhatsApp бот перезапущен');
            }
        });
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Ошибка перезапуска');
    }
});

// Команда /clear
bot.onText(/\/clear/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        // Удаляем QR файлы
        const filesToDelete = ['qr.png', 'tmp/qr.png'];
        let deletedCount = 0;
        
        for (const file of filesToDelete) {
            if (fs.existsSync(file)) {
                fs.unlinkSync(file);
                deletedCount++;
            }
        }
        
        await bot.sendMessage(chatId, `🧹 Удалено ${deletedCount} QR файлов`);
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Ошибка очистки');
    }
});

// Команда /logs
bot.onText(/\/logs/, async (msg) => {
    const chatId = msg.chat.id;
    
    try {
        exec('pm2 logs whatsapp-working --lines 10 --nostream', async (error, stdout) => {
            if (error) {
                await bot.sendMessage(chatId, '❌ Ошибка получения логов');
            } else {
                const logs = stdout || 'Нет логов';
                await bot.sendMessage(chatId, `📋 Последние логи WhatsApp:\n\n\`\`\`\n${logs}\n\`\`\``, { parse_mode: 'Markdown' });
            }
        });
    } catch (error) {
        await bot.sendMessage(chatId, '❌ Ошибка получения логов');
    }
});

// Команда /help
bot.onText(/\/help/, async (msg) => {
    const chatId = msg.chat.id;
    
    const helpText = `🤖 Команды бота:

🔐 /qr - Получить QR код для подключения WhatsApp
📊 /status - Статус ботов
🔄 /restart - Перезапустить WhatsApp бота
🧹 /clear - Очистить QR файлы
📋 /logs - Последние логи WhatsApp бота
❓ /help - Показать эту справку

💡 Если QR код не появляется, попробуйте:
1. Команду /status для проверки
2. Команду /restart для перезапуска
3. Подождите 30 секунд и попробуйте /qr снова`;
    
    await bot.sendMessage(chatId, helpText);
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
echo "🔐 QR код теперь будет сохраняться в файл qr.png"
echo "📲 Telegram бот сможет найти и отправить QR код"
