#!/bin/bash

echo "🔧 ПОЛНОЕ ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ"
echo "=================================="

# Переходим в папку проекта
cd /root/12G

# Останавливаем боты
echo "🛑 Останавливаем боты..."
pm2 stop all

# Обновляем код
echo "📥 Обновляем код..."
git pull origin master

# Исправляем импорт cheerio
echo "🔧 Исправляем импорт cheerio..."
sed -i 's/import cheerio from '\''cheerio'\''/import * as cheerio from '\''cheerio'\''/g' config.js

# Проверяем синтаксис
echo "🔍 Проверяем синтаксис..."
node -c config.js
node -c index.js

# Проверяем наличие тестового файла
echo "📋 Проверяем файлы..."
ls -la test-qr-simple.js

# Очищаем старые сессии
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -f qr.png

# Переустанавливаем зависимости
echo "📦 Переустанавливаем зависимости..."
npm install

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

# Ждем немного
sleep 5

# Показываем результат
echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
pm2 list

echo ""
echo "📋 Проверяем логи..."
pm2 logs whatsapp-bot --lines 10

echo ""
echo "🧪 Тестируем QR генерацию..."
if [ -f "test-qr-simple.js" ]; then
    echo "✅ Тестовый файл найден"
    echo "Запустите: node test-qr-simple.js"
else
    echo "❌ Тестовый файл не найден"
    echo "Создаем простой тест..."
    cat > test-qr-simple.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

console.log('🧪 ТЕСТ QR ГЕНЕРАЦИИ')

async function testQR() {
    try {
        const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
        
        const sock = makeWASocket({
            auth: state,
            printQRInTerminal: true,
            logger: pino({ level: 'silent' }),
            browser: ['Lynx Bot', 'Chrome', '1.0.0']
        })
        
        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update
            
            if (qr) {
                console.log('✅ QR код получен!')
                qrcode.generate(qr, { small: true })
                
                const fs = await import('fs')
                const qrCode = await import('qrcode')
                const qrBuffer = await qrCode.toBuffer(qr)
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                process.exit(0)
            }
            
            if (connection === 'open') {
                console.log('✅ Подключение установлено!')
                process.exit(0)
            }
        })
        
        setTimeout(() => {
            console.log('⏰ Время ожидания истекло')
            process.exit(1)
        }, 30000)
        
    } catch (error) {
        console.error('❌ Ошибка:', error)
        process.exit(1)
    }
}

testQR()
EOF
    echo "✅ Тестовый файл создан"
fi

echo ""
echo "📱 Теперь отправьте /qr в Telegram бота"
echo "Или запустите: node test-qr-simple.js"
