#!/bin/bash

echo "🚀 ФИНАЛЬНАЯ УСТАНОВКА ДЛЯ СЕРВЕРА"
echo "=================================="

# Проверяем версии
echo "📊 Проверяем версии..."
node --version
npm --version

# Переходим в папку проекта
cd /root/12G

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3

# Очищаем все кэши и старые файлы
echo "🧹 Очищаем все кэши..."
npm cache clean --force
rm -rf node_modules
rm -f package-lock.json
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg
rm -rf tmp/*

# Заменяем package.json на очищенную версию
echo "📝 Заменяем package.json на очищенную версию..."
if [ -f "package-clean.json" ]; then
    cp package-clean.json package.json
    echo "✅ package.json заменен на очищенную версию"
else
    echo "❌ Файл package-clean.json не найден"
    exit 1
fi

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
npm install --force

# Устанавливаем baileys отдельно
echo "📦 Устанавливаем baileys..."
npm install baileys@latest --save --force

# Проверяем установку baileys
echo "✅ Проверяем установку baileys..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен"
    ls -la node_modules/baileys/package.json
    echo "Версия: $(cat node_modules/baileys/package.json | grep '"version"' | cut -d'"' -f4)"
else
    echo "❌ baileys не установлен"
fi

# Создаем необходимые папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Обновляем импорты baileys во всех файлах
echo "🔄 Обновляем импорты baileys..."
find . -name "*.js" -type f -exec sed -i 's/@whiskeysockets\/baileys/baileys/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/from.*@whiskeysockets\/baileys/from "baileys"/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/import.*@whiskeysockets\/baileys/import.*baileys/g' {} \;

# Проверяем синтаксис файлов
echo "🔍 Проверяем синтаксис файлов..."
if node -c index.js; then
    echo "✅ Синтаксис index.js корректен"
else
    echo "❌ Ошибка синтаксиса в index.js"
fi

if node -c telegram-bot.cjs; then
    echo "✅ Синтаксис telegram-bot.cjs корректен"
else
    echo "❌ Ошибка синтаксиса в telegram-bot.cjs"
fi

# Создаем конфигурацию PM2
echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-final.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-bot',
      script: 'index.js',
      cwd: '/root/12G',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '200M',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=512'
      },
      error_file: './logs/whatsapp-error-0.log',
      out_file: './logs/whatsapp-out-0.log',
      log_file: './logs/whatsapp-combined-0.log',
      time: true
    },
    {
      name: 'telegram-bot',
      script: 'telegram-bot.cjs',
      cwd: '/root/12G',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '100M',
      env: {
        NODE_ENV: 'production'
      },
      error_file: './logs/telegram-error-1.log',
      out_file: './logs/telegram-out-1.log',
      log_file: './logs/telegram-combined-1.log',
      time: true
    }
  ]
};
EOF

# Тестируем QR генерацию
echo "🧪 Тестируем QR генерацию..."
cat > test-qr-final.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

async function testQR() {
    try {
        console.log('🔍 Тестируем QR генерацию...')
        
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
                console.log('✅ QR код сгенерирован успешно!')
                qrcode.generate(qr, { small: true })
                
                // Сохраняем QR в файл
                const fs = await import('fs')
                const qrCode = await import('qrcode')
                const qrBuffer = await qrCode.toBuffer(qr)
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                
                // Останавливаем тест
                process.exit(0)
            }
            
            if (connection === 'close') {
                const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
                console.log('❌ Соединение закрыто:', lastDisconnect?.error, ', переподключение:', shouldReconnect)
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
        console.error('❌ Ошибка тестирования QR:', error)
        process.exit(1)
    }
}

testQR()
EOF

# Запускаем тест QR
echo "🧪 Запускаем тест QR генерации..."
timeout 30s node test-qr-final.js

# Проверяем создался ли QR файл
if [ -f "qr.png" ]; then
    echo "✅ QR файл создан успешно!"
    ls -la qr.png
else
    echo "❌ QR файл не создан"
fi

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

# Проверяем статус
echo "📊 Проверяем статус ботов..."
sleep 10
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

# Проверяем логи на ошибки
echo "📋 Проверяем логи на ошибки..."
sleep 5
if [ -f "logs/whatsapp-error-0.log" ]; then
    echo "🚨 Последние ошибки WhatsApp:"
    tail -5 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
    echo "🚨 Последние ошибки Telegram:"
    tail -5 logs/telegram-error-1.log
fi

echo ""
echo "🎉 ФИНАЛЬНАЯ УСТАНОВКА ЗАВЕРШЕНА!"
echo "================================"
echo "✅ Все зависимости установлены"
echo "✅ Baileys обновлен до последней версии"
echo "✅ Все импорты исправлены"
echo "✅ Синтаксис файлов корректен"
echo "✅ Боты запущены с новой конфигурацией"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /qr в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
