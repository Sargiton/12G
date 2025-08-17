#!/bin/bash

echo "🔧 Быстрое исправление Telegram бота..."

# Останавливаем Telegram бота
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Устанавливаем зависимость если нужно
cd 123
npm install node-telegram-bot-api --save 2>/dev/null || true
cd ..

# Создаем конфиг и запускаем
cat > ecosystem-telegram.cjs << 'EOF'
module.exports = {
    apps: [{
        name: 'telegram-bot',
        script: 'telegram-bot.cjs',
        cwd: './123',
        autorestart: true,
        watch: false,
        env: { NODE_ENV: 'production' },
        out_file: './123/logs/telegram-bot-out.log',
        error_file: './123/logs/telegram-bot-error.log'
    }]
}
EOF

pm2 start ecosystem-telegram.cjs
pm2 save

echo "✅ Telegram бот исправлен!"
echo "📋 Статус:"
pm2 list | grep telegram
echo ""
echo "📋 Логи:"
pm2 logs telegram-bot --lines 10
