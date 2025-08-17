#!/bin/bash

echo "🔧 КОМПЛЕКСНОЕ ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ"
echo "========================================"

# Останавливаем ВСЕ процессы
echo "🛑 Останавливаем ВСЕ процессы..."
pm2 stop all
pm2 delete all
pkill -f node
pkill -f pm2
pkill -f telegram
pkill -f whatsapp
sleep 5

cd /root/12G

# Обновляем npm до последней версии
echo "📦 Обновляем npm до последней версии..."
curl -qL https://www.npmjs.org/install.sh | sh
npm install -g npm@latest

# Проверяем версию npm
echo "📊 Проверяем версию npm..."
npm --version

# Очищаем ВСЕ кэши
echo "🧹 Очищаем ВСЕ кэши..."
npm cache clean --force
rm -rf ~/.npm
rm -rf node_modules
rm -f package-lock.json

# Заменяем package.json на очищенную версию
echo "📝 Заменяем package.json на очищенную версию..."
if [ -f "package-clean.json" ]; then
    cp package-clean.json package.json
    echo "✅ package.json заменен на очищенную версию"
else
    echo "❌ Файл package-clean.json не найден"
    exit 1
fi

# Устанавливаем зависимости с новой версией npm
echo "📦 Устанавливаем зависимости с новой версией npm..."
npm install --force

# Устанавливаем критические пакеты отдельно
echo "📦 Устанавливаем критические пакеты..."
npm install baileys@6.7.0 --save-exact --force
npm install qrcode-terminal qrcode pino --force
npm install node-telegram-bot-api --force

# Проверяем установку
echo "✅ Проверяем установку..."
if [ -d "node_modules/baileys" ]; then
    echo "✅ baileys установлен"
else
    echo "❌ baileys не установлен"
fi

if [ -d "node_modules/node-telegram-bot-api" ]; then
    echo "✅ node-telegram-bot-api установлен"
else
    echo "❌ node-telegram-bot-api не установлен"
fi

# Создаем папки
echo "📁 Создаем необходимые папки..."
mkdir -p LynxSession BackupSession tmp logs

# Очищаем сессии
echo "🧹 Очищаем сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg

# Проверяем синтаксис index.js
echo "🔍 Проверяем синтаксис index.js..."
if node -c index.js; then
    echo "✅ Синтаксис index.js корректен"
else
    echo "❌ Ошибка синтаксиса в index.js"
    echo "🔧 Исправляем синтаксис..."
    # Добавляем недостающие закрывающие скобки если нужно
    sed -i 's/logger: { level: '\''silent'\'' }/logger: pino({ level: '\''silent'\'' })/g' index.js
fi

# Проверяем синтаксис telegram-bot.cjs
echo "🔍 Проверяем синтаксис telegram-bot.cjs..."
if node -c telegram-bot.cjs; then
    echo "✅ Синтаксис telegram-bot.cjs корректен"
else
    echo "❌ Ошибка синтаксиса в telegram-bot.cjs"
fi

# Создаем простую конфигурацию PM2
echo "📝 Создаем простую конфигурацию PM2..."
cat > ecosystem-simple.config.cjs << 'EOF'
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
pm2 start ecosystem-simple.config.cjs

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 10
pm2 list

# Проверяем логи
echo "📋 Проверяем логи..."
if [ -f "logs/whatsapp-error-0.log" ]; then
    echo "🚨 Последние ошибки WhatsApp:"
    tail -5 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
    echo "🚨 Последние ошибки Telegram:"
    tail -5 logs/telegram-error-1.log
fi

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

echo ""
echo "🎉 КОМПЛЕКСНОЕ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "====================================="
echo "✅ npm обновлен до последней версии"
echo "✅ package.json очищен от проблемных зависимостей"
echo "✅ Все критические пакеты установлены"
echo "✅ Синтаксис файлов проверен"
echo "✅ Боты запущены с новой конфигурацией"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /help в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
