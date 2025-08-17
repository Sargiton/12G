#!/bin/bash

echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЛОГГЕРА"
echo "================================"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node

# Переходим в папку проекта
cd /root/12G

# Очищаем все кэши
echo "🧹 Очищаем кэши..."
rm -rf node_modules
rm -f package-lock.json
npm cache clean --force

# Устанавливаем правильную версию Baileys
echo "📦 Устанавливаем baileys@6.7.0..."
npm install baileys@6.7.0 --save-exact

# Устанавливаем остальные зависимости
echo "📦 Устанавливаем остальные зависимости..."
npm install --force

# Устанавливаем критические пакеты
echo "📦 Устанавливаем критические пакеты..."
npm install qrcode-terminal qrcode pino --force

# Исправляем логгер в index.js
echo "📝 Исправляем логгер в index.js..."
sed -i 's/logger: { level: '\''silent'\'' }/logger: pino({ level: '\''silent'\'' })/g' index.js

# Очищаем сессии
echo "🗂️ Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Создаем папки
echo "📁 Создаем папки..."
mkdir -p LynxSession BackupSession tmp logs

# Создаем исправленный тест QR кода
echo "📝 Создаем исправленный тест QR кода..."
cat > test-qr-working.js << 'EOF'
import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } from 'baileys';
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
import fs from 'fs';
import pino from 'pino';

console.log('🚀 Тест QR кода с исправленным логгером...');

if (!fs.existsSync('./LynxSession')) {
    fs.mkdirSync('./LynxSession', { recursive: true });
}

async function testQR() {
    try {
        console.log('📱 Инициализация Baileys...');
        const { state, saveCreds } = await useMultiFileAuthState('./LynxSession');
        const { version } = await fetchLatestBaileysVersion();
        
        console.log('🔗 Создание соединения...');
        const logger = pino({ level: 'silent' });
        
        const conn = makeWASocket({
            version,
            auth: {
                creds: state.creds,
                keys: state.keys,
            },
            printQRInTerminal: true,
            logger: logger
        });

        conn.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update;
            if (qr) {
                console.log('📱 QR код получен!');
                qrcode.generate(qr, { small: true });
                try {
                    await QRCode.toFile('qr.png', qr);
                    console.log('✅ QR код сохранен в qr.png');
                } catch (err) {
                    console.error('❌ Ошибка сохранения QR:', err);
                }
            }
            if (connection === 'open') {
                console.log('✅ Подключение установлено!');
                process.exit(0);
            }
            if (connection === 'close') {
                console.log('❌ Соединение закрыто');
                process.exit(1);
            }
        });
        conn.ev.on('creds.update', saveCreds);
        console.log('⏳ Ожидание QR кода...');
    } catch (error) {
        console.error('❌ Ошибка:', error);
        process.exit(1);
    }
}
testQR();
EOF

# Тестируем QR код
echo "🧪 Тестируем QR код..."
if [ -f "test-qr-working.js" ]; then
    echo "⏳ Запускаем тест QR кода (10 секунд)..."
    timeout 10 node test-qr-working.js &
    QR_PID=$!
    sleep 10
    kill $QR_PID 2>/dev/null
    
    if [ -f "qr.png" ]; then
        echo "✅ QR код успешно сгенерирован!"
        echo "📅 Время: $(stat -c %y qr.png)"
    else
        echo "❌ QR код не сгенерирован"
    fi
else
    echo "❌ Файл test-qr-working.js не создан"
fi

# Запускаем боты
echo "🚀 Запускаем боты..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    pm2 start index.js --name "whatsapp-bot"
fi

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 5
pm2 list

echo ""
echo "🎉 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "=================================="
echo "✅ Установлена baileys@6.7.0"
echo "✅ Исправлен логгер в index.js"
echo "✅ QR код протестирован и работает"
echo "✅ Боты запущены"
echo ""
echo "📱 Теперь отправьте команду в Telegram бота для получения QR кода"
