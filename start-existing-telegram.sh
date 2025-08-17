#!/bin/bash

echo "🚀 ЗАПУСК СУЩЕСТВУЮЩЕГО TELEGRAM БОТА"

# Останавливаем старые Telegram боты
echo "🛑 Останавливаем старые Telegram боты..."
pm2 stop telegram-bot 2>/dev/null || true
pm2 delete telegram-bot 2>/dev/null || true

# Проверяем существующий файл
echo "🔍 Проверяем существующий telegram-bot.cjs..."
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo "❌ Файл 123/telegram-bot.cjs не найден!"
    exit 1
fi

# Исправляем имя WhatsApp бота в файле
echo "🔧 Исправляем имя WhatsApp бота в telegram-bot.cjs..."
sed -i "s/WHATSAPP_PM2_NAME = 'whatsapp-bot'/WHATSAPP_PM2_NAME = 'whatsapp-old'/g" 123/telegram-bot.cjs

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Создаем конфиг PM2 для существующего бота
echo "⚙️ Создаем конфиг PM2..."
cat > ecosystem-telegram-existing.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'telegram-bot',
            script: 'telegram-bot.cjs',
            cwd: './123',
            autorestart: true,
            watch: false,
            time: true,
            node_args: '',
            env: {
                NODE_ENV: 'production'
            }
        }
    ]
}
EOF

# Запускаем существующий Telegram бот
echo "🤖 Запускаем существующий Telegram бот..."
pm2 start ecosystem-telegram-existing.cjs

# Сохраняем PM2
echo "💾 Сохраняем PM2 конфигурацию..."
pm2 save

echo "⏳ Ждем запуска..."
sleep 3

echo "✅ Статус всех ботов:"
pm2 list

echo ""
echo "📋 Логи Telegram бота:"
pm2 logs telegram-bot --lines 10

echo ""
echo "🎯 Готово! Существующий Telegram бот запущен!"
echo "Теперь у вас работают оба бота:"
echo "• WhatsApp бот: whatsapp-old"
echo "• Telegram бот: telegram-bot (существующий файл)"
