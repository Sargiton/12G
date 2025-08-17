#!/bin/bash

echo "🤖 СОЗДАНИЕ ПОЛНОЦЕННОГО WHATSAPP БОТА"
echo "======================================"

cd /root/12G

echo "🛑 Останавливаем ботов..."
pm2 stop all
pm2 delete all

echo "📝 Создаем полноценный WhatsApp бот..."
cat > full-whatsapp-bot.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'
import fs from 'fs'
import path from 'path'

const logger = pino({ level: 'silent' })

// Список владельцев (замените на ваши номера)
const owners = ['79035599539@s.whatsapp.net']

// Функция для проверки владельца
function isOwner(sender) {
    return owners.includes(sender)
}

// Функция для сохранения QR кода
async function saveQRCode(qr) {
    try {
        const qrcode = await import('qrcode')
        const qrBuffer = await qrcode.default.toBuffer(qr, { 
            type: 'png',
            width: 300,
            margin: 2
        })
        
        fs.writeFileSync('qr.png', qrBuffer)
        fs.writeFileSync('tmp/qr.png', qrBuffer)
        console.log('✅ QR код сохранен в файл')
    } catch (error) {
        console.log('❌ Ошибка сохранения QR:', error.message)
    }
}

// Функция для обработки команд
function handleCommand(m, sock) {
    const command = m.message?.conversation || m.message?.extendedTextMessage?.text || ''
    const sender = m.key.remoteJid
    
    console.log(`📱 Команда от ${sender}: ${command}`)
    
    // Команды для владельца
    if (isOwner(sender)) {
        switch (command.toLowerCase()) {
            case '!ping':
                sock.sendMessage(sender, { text: '🏓 Pong!' })
                break
                
            case '!status':
                sock.sendMessage(sender, { text: '✅ Бот работает!' })
                break
                
            case '!info':
                const info = `🤖 Информация о боте:
📱 Статус: Работает
👤 Владелец: ${sender}
⏰ Время: ${new Date().toLocaleString('ru-RU')}`
                sock.sendMessage(sender, { text: info })
                break
                
            case '!qr':
                if (fs.existsSync('qr.png')) {
                    sock.sendMessage(sender, { 
                        image: fs.readFileSync('qr.png'),
                        caption: '🔐 QR код для подключения'
                    })
                } else {
                    sock.sendMessage(sender, { text: '❌ QR код не найден' })
                }
                break
                
            case '!restart':
                sock.sendMessage(sender, { text: '🔄 Перезапуск бота...' })
                setTimeout(() => {
                    process.exit(0)
                }, 1000)
                break
                
            case '!help':
                const help = `🤖 Команды бота:

👑 Команды владельца:
!ping - Проверка бота
!status - Статус бота
!info - Информация о боте
!qr - Получить QR код
!restart - Перезапуск бота
!help - Эта справка

💡 Обычные команды:
!menu - Главное меню
!time - Текущее время
!version - Версия бота`
                sock.sendMessage(sender, { text: help })
                break
        }
    }
    
    // Обычные команды для всех
    switch (command.toLowerCase()) {
        case '!menu':
            const menu = `🤖 Главное меню:

📋 Доступные команды:
!menu - Это меню
!time - Текущее время
!version - Версия бота
!help - Справка (только владелец)

💡 Для получения QR кода обратитесь к владельцу`
            sock.sendMessage(sender, { text: menu })
            break
            
        case '!time':
            const time = `⏰ Текущее время: ${new Date().toLocaleString('ru-RU')}`
            sock.sendMessage(sender, { text: time })
            break
            
        case '!version':
            sock.sendMessage(sender, { text: '📦 Версия бота: 1.5.0' })
            break
            
        case 'привет':
        case 'hello':
        case 'hi':
            sock.sendMessage(sender, { text: '👋 Привет! Я WhatsApp бот. Напишите !menu для списка команд.' })
            break
            
        case 'бот':
            sock.sendMessage(sender, { text: '🤖 Да, я здесь! Чем могу помочь?' })
            break
    }
}

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
    
    const sock = makeWASocket({
        logger,
        auth: state,
        browser: ['DarkCore Bot', 'Chrome', '1.0.0']
    })

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update
        
        if (qr) {
            console.log('🔐 QR КОД ПОЛУЧЕН!')
            qrcode.generate(qr, { small: true })
            await saveQRCode(qr)
        }
        
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
            console.log('❌ Соединение закрыто из-за ', lastDisconnect?.error, ', переподключение ', shouldReconnect)
            if (shouldReconnect) {
                setTimeout(connectToWhatsApp, 3000)
            }
        } else if (connection === 'open') {
            console.log('✅ Соединение установлено!')
            console.log('🤖 Бот готов к работе!')
            console.log('📋 Доступные команды: !menu, !ping, !status, !help')
        }
    })

    // Обработка сообщений
    sock.ev.on('messages.upsert', async (m) => {
        const msg = m.messages[0]
        
        if (!msg.key.fromMe && msg.message) {
            handleCommand(msg, sock)
        }
    })

    sock.ev.on('creds.update', saveCreds)
}

console.log('🚀 Запуск полноценного WhatsApp бота...')
connectToWhatsApp()
EOF

echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-full.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-full',
      script: 'full-whatsapp-bot.js',
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
pm2 start ecosystem-full.config.cjs

sleep 10

echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-full --lines 10

echo ""
echo "✅ ПОЛНОЦЕННЫЙ БОТ СОЗДАН!"
echo "📱 WhatsApp бот: whatsapp-full"
echo "📲 Telegram бот: telegram-working"
echo ""
echo "🎯 Команды WhatsApp бота:"
echo "• !menu - Главное меню"
echo "• !ping - Проверка бота"
echo "• !status - Статус бота"
echo "• !info - Информация о боте"
echo "• !qr - Получить QR код"
echo "• !help - Справка"
echo ""
echo "⚠️ ВАЖНО: Замените номер владельца в файле full-whatsapp-bot.js"
echo "📝 Найдите строку: const owners = ['79035599539@s.whatsapp.net']"
echo "🔧 И замените на ваш номер в формате: 79XXXXXXXXX@s.whatsapp.net"
