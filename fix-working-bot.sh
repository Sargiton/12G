#!/bin/bash

echo "🔧 ВОССТАНОВЛЕНИЕ РАБОЧЕГО БОТА"
echo "================================"

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔧 УСТАНАВЛИВАЕМ РАБОЧУЮ ВЕРСИЮ BAILEYS..."

# Устанавливаем рабочую версию из старого бота
npm uninstall baileys @whiskeysockets/baileys
npm install @whiskeysockets/baileys@6.5.0 --save-exact

echo ""
echo "🔧 ИСПРАВЛЯЕМ ВСЕ ИМПОРТЫ..."

# Исправляем все импорты на @whiskeysockets/baileys
find . -name "*.js" -type f -exec sed -i 's/from '\''baileys'\''/from '\''@whiskeysockets\/baileys'\''/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/from "baileys"/from "@whiskeysockets\/baileys"/g' {} \;

echo ""
echo "🔧 ИСПРАВЛЯЕМ ОСНОВНЫЕ ФАЙЛЫ..."

# Исправляем основные файлы
sed -i 's/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''baileys'\''/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''@whiskeysockets\/baileys'\''/g' index.js
sed -i 's/import { generateWAMessageFromContent } from "baileys"/import { generateWAMessageFromContent } from "@whiskeysockets\/baileys"/g' handler.js
sed -i 's/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''baileys'\''/import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '\''@whiskeysockets\/baileys'\''/g' lib/simple.js

echo ""
echo "🔧 ИСПРАВЛЯЕМ QR ГЕНЕРАЦИЮ..."

# Исправляем функцию connectionUpdate для правильной обработки QR
sed -i '/if (update.qr != 0 && update.qr != undefined || methodCodeQR) {/,/}/c\
if (update.qr != 0 && update.qr != undefined || methodCodeQR) {\
if (opcion == '\''1'\'' || methodCodeQR) {\
console.log(chalk.bold.yellow(lenguajeGB['\''smsCodigoQR'\'']()));\
// Генерируем QR код в терминале\
qrcode.generate(update.qr, { small: true });\
// Сохраняем QR код в файл\
QRCode.toFile('\''qr.png'\'', update.qr, function (err) {\
  if (err) {\
    console.error('\''Ошибка сохранения QR:'\'', err);\
  } else {\
    console.log('\''✅ QR код сохранен в qr.png'\'');\
  }\
});\
console.log('\''📱 Отсканируйте этот QR код через WhatsApp на телефоне!'\'');\
}\
}' index.js

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
import QRCode from 'qrcode'

console.log('🧪 РАБОЧИЙ ГЕНЕРАТОР QR КОДА')
console.log('============================')

async function generateQR() {
    try {
        console.log('🔍 Инициализация...')
        
        const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
        
        console.log('🔗 Создание соединения...')
        const sock = makeWASocket({
            auth: state,
            printQRInTerminal: false, // Отключаем устаревшую опцию
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
                QRCode.toFile('qr.png', qr, function (err) {
                    if (err) {
                        console.error('Ошибка сохранения QR:', err);
                    } else {
                        console.log('✅ QR код сохранен в qr.png');
                    }
                });
                
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
echo "🔍 Проверяем, что все импорты исправлены..."
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
echo "✅ ВОССТАНОВЛЕНИЕ РАБОЧЕГО БОТА ЗАВЕРШЕНО!"
echo "=========================================="
echo "📱 Теперь попробуйте:"
echo "1. Отправьте /qr в Telegram бота"
echo "2. Или запустите: node working-qr.js"
echo ""
echo "🔧 Если все еще есть ошибки, попробуйте:"
echo "   pm2 restart all"
echo "   pm2 logs whatsapp-bot --lines 50"
