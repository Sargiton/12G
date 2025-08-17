#!/bin/bash

echo "🚀 БЫСТРОЕ ИСПРАВЛЕНИЕ ВСЕГО"

# Останавливаем все
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true
sleep 2

# Исправляем имя в telegram-bot.cjs
echo "🔧 Исправляем имя в telegram-bot.cjs..."
sed -i "s/WHATSAPP_PM2_NAME = 'whatsapp-bot'/WHATSAPP_PM2_NAME = 'whatsapp-old'/g" 123/telegram-bot.cjs

# Проверяем зависимости
echo "📦 Проверяем зависимости..."
cd 123
npm install node-telegram-bot-api --save 2>/dev/null || true
cd ..

# Создаем конфиги
echo "⚙️ Создаем конфиги..."

cat > ecosystem-old.config.cjs << 'EOF'
module.exports = {
    apps: [{
        name: 'whatsapp-old',
        script: 'index.js',
        cwd: './123',
        autorestart: true,
        watch: false,
        env: { NODE_ENV: 'production' }
    }]
}
EOF

cat > ecosystem-telegram.cjs << 'EOF'
module.exports = {
    apps: [{
        name: 'telegram-bot',
        script: 'telegram-bot.cjs',
        cwd: './123',
        autorestart: true,
        watch: false,
        env: { NODE_ENV: 'production' }
    }]
}
EOF

# Запускаем ботов
echo "🚀 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

echo "🤖 Запускаем Telegram бота..."
pm2 start ecosystem-telegram.cjs

pm2 save

echo "⏳ Ждем запуска..."
sleep 5

echo "✅ Статус:"
pm2 list

echo ""
echo "📋 Логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "🎯 Готово! Теперь Telegram бот должен работать!"
