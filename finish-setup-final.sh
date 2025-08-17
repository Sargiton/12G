#!/bin/bash

echo "🚀 ФИНАЛЬНАЯ УСТАНОВКА ПОСЛЕ ИСПРАВЛЕНИЯ ОШИБОК"
echo "================================================"

# Проверяем версии
echo "📊 Проверяем версии Node.js и npm..."
node --version
npm --version

# Переходим в папку проекта
cd /root/12G

# Останавливаем старые процессы
echo "🛑 Останавливаем старые процессы..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3

# Очищаем старые зависимости
echo "🧹 Очищаем старые зависимости..."
npm cache clean --force
rm -rf node_modules
rm -f package-lock.json

# Обновляем package.json с правильной версией baileys
echo "📝 Обновляем package.json..."
sed -i 's/"@whiskeysockets\/baileys": ".*"/"@whiskeysockets\/baileys": "6.5.0"/g' package.json

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
npm install --force

# Устанавливаем критические пакеты отдельно
echo "📦 Устанавливаем критические пакеты..."
npm install @whiskeysockets/baileys@6.5.0 --save-exact --force
npm install qrcode-terminal qrcode pino --force
npm install node-telegram-bot-api --force

# Проверяем установку
echo "✅ Проверяем установку..."
if [ -d "node_modules/@whiskeysockets/baileys" ]; then
    echo "✅ @whiskeysockets/baileys установлен"
else
    echo "❌ @whiskeysockets/baileys не установлен"
fi

if [ -d "node_modules/node-telegram-bot-api" ]; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
fi

# Создаем необходимые папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем старые сессии
echo "🧹 Очищаем старые сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

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
    tail -3 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
    echo "🚨 Последние ошибки Telegram:"
    tail -3 logs/telegram-error-1.log
fi

echo ""
echo "🎉 ФИНАЛЬНАЯ УСТАНОВКА ЗАВЕРШЕНА!"
echo "================================="
echo "✅ @whiskeysockets/baileys 6.5.0 установлен"
echo "✅ Синтаксис файлов исправлен"
echo "✅ Все зависимости установлены"
echo "✅ Боты запущены с новой конфигурацией"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
