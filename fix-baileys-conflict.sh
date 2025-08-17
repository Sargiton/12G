#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ КОНФЛИКТА BAILEYS"
echo "=================================="

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔧 УДАЛЯЕМ КОНФЛИКТУЮЩИЕ ПАКЕТЫ..."

# Удаляем все версии baileys
npm uninstall baileys @whiskeysockets/baileys

echo ""
echo "🔧 УСТАНАВЛИВАЕМ РАБОЧУЮ ВЕРСИЮ..."

# Устанавливаем только одну версию - ту, что работает локально
npm install @whiskeysockets/baileys@6.7.0 --save-exact

echo ""
echo "🔧 ИСПРАВЛЯЕМ ВСЕ ИМПОРТЫ..."

# Исправляем все импорты на @whiskeysockets/baileys
find . -name "*.js" -type f -exec sed -i 's/from '\''baileys'\''/from '\''@whiskeysockets\/baileys'\''/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/from "baileys"/from "@whiskeysockets\/baileys"/g' {} \;

echo ""
echo "🔧 УСТАНАВЛИВАЕМ ОТСУТСТВУЮЩИЕ ПАКЕТЫ..."

# Устанавливаем все отсутствующие пакеты
npm install aptoide-scraper ruhend-scraper node-os-utils @vitalets/google-translate-api --save

echo ""
echo "🔧 ИСПРАВЛЯЕМ CHEERIO ИМПОРТЫ..."

# Исправляем все импорты cheerio
find . -name "*.js" -type f -exec sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' {} \;

echo ""
echo "🔧 СОЗДАЕМ РАБОЧИЙ QR ГЕНЕРАТОР..."

# Создаем рабочий QR генератор
cat > working-qr.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '@whiskeysockets/baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

console.log('🧪 РАБОЧИЙ ГЕНЕРАТОР QR КОДА')
console.log('============================')

async function generateQR() {
    try {
        console.log('🔍 Инициализация...')
        
        const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
        
        console.log('🔗 Создание соединения...')
        const sock = makeWASocket({
            auth: state,
            printQRInTerminal: true,
            logger: pino({ level: 'silent' }),
            browser: ['Lynx Bot', 'Chrome', '1.0.0']
        })
        
        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update
            
            console.log('📡 Обновление соединения:', connection)
            
            if (qr) {
                console.log('✅ QR код получен!')
                qrcode.generate(qr, { small: true })
                
                // Сохраняем QR в файл
                const fs = await import('fs')
                const qrCode = await import('qrcode')
                const qrBuffer = await qrCode.toBuffer(qr)
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                
                // Останавливаем процесс
                process.exit(0)
            }
            
            if (connection === 'open') {
                console.log('✅ Подключение установлено!')
                process.exit(0)
            }
            
            if (connection === 'close') {
                const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
                console.log('❌ Соединение закрыто:', lastDisconnect?.error)
                console.log('🔄 Переподключение:', shouldReconnect)
                if (!shouldReconnect) {
                    process.exit(1)
                }
            }
        })
        
        // Ждем 30 секунд
        setTimeout(() => {
            console.log('⏰ Время ожидания истекло')
            process.exit(1)
        }, 30000)
        
    } catch (error) {
        console.error('❌ Ошибка:', error)
        process.exit(1)
    }
}

generateQR()
EOF

echo ""
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -f qr.png

echo ""
echo "🔍 Проверяем синтаксис..."
node -c index.js
node -c handler.js

echo ""
echo "📋 Проверяем версию Baileys..."
npm list @whiskeysockets/baileys

echo ""
echo "🔍 Проверяем, что конфликт устранен..."
echo "📋 Проверяем package.json..."
grep -A 5 -B 5 "baileys" package.json

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
echo "📋 Проверяем логи..."
pm2 logs whatsapp-bot --lines 15

echo ""
echo "✅ ИСПРАВЛЕНИЕ КОНФЛИКТА ЗАВЕРШЕНО!"
echo "==================================="
echo "📱 Теперь попробуйте:"
echo "1. Отправьте /qr в Telegram бота"
echo "2. Или запустите: node working-qr.js"
echo ""
echo "🔧 Если все еще есть ошибки, попробуйте:"
echo "   pm2 restart all"
echo "   pm2 logs whatsapp-bot --lines 50"
