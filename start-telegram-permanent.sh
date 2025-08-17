#!/bin/bash

echo "🔄 ПОСТОЯННЫЙ ЗАПУСК TELEGRAM БОТА"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pkill -f "telegram-bot.cjs" 2>/dev/null || true

# Проверяем файл
echo "🔍 Проверяем файл telegram-bot.cjs..."
if [ ! -f "123/telegram-bot.cjs" ]; then
    echo "❌ Файл 123/telegram-bot.cjs не найден!"
    exit 1
fi

# Исправляем имя WhatsApp бота
echo "🔧 Исправляем имя WhatsApp бота..."
sed -i "s/WHATSAPP_PM2_NAME = 'whatsapp-bot'/WHATSAPP_PM2_NAME = 'whatsapp-old'/g" 123/telegram-bot.cjs

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
cd 123
npm install node-telegram-bot-api --save
cd ..

# Создаем папку для логов
echo "📁 Создаем папку для логов..."
mkdir -p logs

# Запускаем WhatsApp бота через PM2
echo "🤖 Запускаем WhatsApp бота..."
pm2 start ecosystem-old.config.cjs

# Ждем
sleep 3

# Создаем скрипт для постоянного запуска Telegram бота
echo "📝 Создаем скрипт постоянного запуска..."
cat > start-telegram-loop.sh << 'EOF'
#!/bin/bash

echo "🔄 Запуск Telegram бота в цикле..."

while true; do
    echo "$(date): Запускаем Telegram бота..."
    
    cd /root/12G/123
    node telegram-bot.cjs >> ../logs/telegram-loop.log 2>&1
    
    echo "$(date): Telegram бот остановился, перезапускаем через 5 секунд..."
    sleep 5
done
EOF

chmod +x start-telegram-loop.sh

# Запускаем Telegram бота в постоянном цикле
echo "📱 Запускаем Telegram бота в постоянном цикле..."
nohup ./start-telegram-loop.sh > logs/telegram-permanent.log 2>&1 &
TELEGRAM_PID=$!

echo "✅ Telegram бот запущен с PID: $TELEGRAM_PID"

# Сохраняем PID в файл
echo $TELEGRAM_PID > logs/telegram-permanent.pid

echo "⏳ Ждем запуска..."
sleep 10

echo "✅ Статус:"
echo "• WhatsApp бот: PM2 (whatsapp-old)"
echo "• Telegram бот: Постоянный цикл (PID: $TELEGRAM_PID)"

echo ""
echo "📋 Логи WhatsApp бота:"
pm2 logs whatsapp-old --lines 3

echo ""
echo "📋 Логи Telegram бота:"
tail -10 logs/telegram-loop.log

echo ""
echo "🎯 Готово! Оба бота запущены!"
echo "• WhatsApp бот: whatsapp-old (PM2)"
echo "• Telegram бот: Постоянный цикл (PID: $TELEGRAM_PID)"
echo ""
echo "🔍 Для проверки Telegram бота отправьте /status в Telegram"
echo "📋 Для просмотра логов: tail -f logs/telegram-loop.log"
echo "🛑 Для остановки: kill $TELEGRAM_PID"
echo ""
echo "💡 Telegram бот будет автоматически перезапускаться при остановке!"
