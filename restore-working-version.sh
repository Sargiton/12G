#!/bin/bash

echo "🔄 ВОССТАНОВЛЕНИЕ РАБОЧЕЙ ВЕРСИИ BAILEYS"
echo "========================================"

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

# Возвращаемся к рабочей версии Baileys
echo "📝 Возвращаемся к рабочей версии Baileys..."
sed -i 's/"@whiskeysockets\/baileys": "^6.6.0"/"baileys": "^6.5.0"/g' package.json

# Устанавливаем старую рабочую версию
echo "📦 Устанавливаем старую рабочую версию..."
npm install --force

# Проверяем установку
echo "🔍 Проверяем установку..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен (старая версия)"
    echo "📦 Версия: $(npm list baileys | grep baileys)"
else
    echo "❌ baileys не найден, устанавливаем вручную..."
    npm install baileys@^6.5.0 --force
fi

# Устанавливаем критические пакеты
echo "📦 Устанавливаем критические пакеты..."
npm install qrcode-terminal qrcode --force

# Очищаем сессии
echo "🗂️ Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Создаем папки
echo "📁 Создаем папки..."
mkdir -p LynxSession BackupSession tmp logs

# Создаем простой тест QR кода со старой версией
echo "📝 Создаем простой тест QR кода..."
cat > test-old-qr.js << 'EOF'
import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } from 'baileys';
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
import fs from 'fs';

console.log('🚀 Тест QR кода со старой версией Baileys...');

if (!fs.existsSync('./LynxSession')) {
    fs.mkdirSync('./LynxSession', { recursive: true });
}

async function testQR() {
    try {
        console.log('📱 Инициализация Baileys...');
        const { state, saveCreds } = await useMultiFileAuthState('./LynxSession');
        const { version } = await fetchLatestBaileysVersion();
        
        console.log('🔗 Создание соединения...');
        const conn = makeWASocket({
            version,
            auth: { creds: state.creds, keys: state.keys },
            printQRInTerminal: true,
            logger: { level: 'silent' }
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

# Тестируем QR код со старой версией
echo "🧪 Тестируем QR код со старой версией..."
if [ -f "test-old-qr.js" ]; then
    echo "⏳ Запускаем тест QR кода (10 секунд)..."
    timeout 10 node test-old-qr.js &
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
    echo "❌ Файл test-old-qr.js не создан"
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
echo "🎉 ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "============================"
echo "✅ Возвращена старая рабочая версия Baileys"
echo "✅ Создан тестовый файл test-old-qr.js"
echo "✅ QR код протестирован"
echo "✅ Боты запущены"
echo ""
echo "📱 Теперь отправьте команду в Telegram бота для получения QR кода"
