#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ НА ОФИЦИАЛЬНЫЙ BAILEYS"
echo "====================================="

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔧 ПЕРЕХОДИМ НА ОФИЦИАЛЬНЫЙ BAILEYS..."

# Удаляем старую версию и устанавливаем официальную
echo "📦 Устанавливаем официальный Baileys..."
npm uninstall @whiskeysockets/baileys
npm install baileys@latest --save

echo ""
echo "🔧 ИСПРАВЛЯЕМ ВСЕ ИМПОРТЫ..."

# Исправляем импорты в index.js
sed -i 's/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''@whiskeysockets\/baileys'\''/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''baileys'\''/g' index.js

# Исправляем импорты в handler.js
sed -i 's/import { generateWAMessageFromContent } from "@whiskeysockets\/baileys"/import { generateWAMessageFromContent } from "baileys"/g' handler.js

# Исправляем импорты в lib/simple.js
sed -i 's/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''@whiskeysockets\/baileys'\''/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''baileys'\''/g' lib/simple.js

# Исправляем импорты в плагинах
echo "🔧 Исправляем импорты в плагинах..."
find plugins/ -name "*.js" -type f -exec sed -i 's/from '\''@whiskeysockets\/baileys'\''/from '\''baileys'\''/g' {} \;
find plugins/ -name "*.js" -type f -exec sed -i 's/from "baileys"/from "baileys"/g' {} \;

echo ""
echo "🔧 ОБНОВЛЯЕМ QR ГЕНЕРАТОР..."

# Обновляем QR генератор
cat > qr-generator.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

console.log('🧪 ГЕНЕРАТОР QR КОДА (ОФИЦИАЛЬНЫЙ BAILEYS)')
console.log('==========================================')

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
npm list baileys

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
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
echo "📱 Теперь попробуйте:"
echo "1. Отправьте /qr в Telegram бота"
echo "2. Или запустите: node qr-generator.js"
echo ""
echo "🔧 Если все еще есть ошибки, попробуйте:"
echo "   pm2 restart all"
echo "   pm2 logs whatsapp-bot --lines 50"
