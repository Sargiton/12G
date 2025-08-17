#!/bin/bash

echo "🎛️ УПРАВЛЕНИЕ TELEGRAM БОТОМ"

# Проверяем PID файл
if [ -f "logs/telegram-permanent.pid" ]; then
    TELEGRAM_PID=$(cat logs/telegram-permanent.pid)
    echo "📋 Найден PID Telegram бота: $TELEGRAM_PID"
else
    echo "❌ PID файл не найден"
    TELEGRAM_PID=""
fi

echo ""
echo "Выберите действие:"
echo "1. Статус ботов"
echo "2. Показать логи Telegram бота"
echo "3. Остановить Telegram бота"
echo "4. Перезапустить Telegram бота"
echo "5. Показать все процессы"

read -p "Введите номер (1-5): " choice

case $choice in
    1)
        echo "📊 Статус ботов:"
        echo "• WhatsApp бот:"
        pm2 list | grep whatsapp-old || echo "  Не запущен"
        echo "• Telegram бот:"
        if [ ! -z "$TELEGRAM_PID" ] && ps -p $TELEGRAM_PID > /dev/null; then
            echo "  Запущен (PID: $TELEGRAM_PID)"
        else
            echo "  Не запущен"
        fi
        ;;
    2)
        echo "📋 Логи Telegram бота:"
        if [ -f "logs/telegram-loop.log" ]; then
            tail -20 logs/telegram-loop.log
        else
            echo "Файл логов не найден"
        fi
        ;;
    3)
        echo "🛑 Останавливаем Telegram бота..."
        if [ ! -z "$TELEGRAM_PID" ]; then
            kill $TELEGRAM_PID 2>/dev/null || true
            pkill -f "telegram-bot.cjs" 2>/dev/null || true
            rm -f logs/telegram-permanent.pid
            echo "✅ Telegram бот остановлен"
        else
            echo "Telegram бот не запущен"
        fi
        ;;
    4)
        echo "🔄 Перезапускаем Telegram бота..."
        # Останавливаем старый
        if [ ! -z "$TELEGRAM_PID" ]; then
            kill $TELEGRAM_PID 2>/dev/null || true
        fi
        pkill -f "telegram-bot.cjs" 2>/dev/null || true
        
        # Запускаем новый
        nohup ./start-telegram-loop.sh > logs/telegram-permanent.log 2>&1 &
        NEW_PID=$!
        echo $NEW_PID > logs/telegram-permanent.pid
        echo "✅ Telegram бот перезапущен (PID: $NEW_PID)"
        ;;
    5)
        echo "📋 Все процессы:"
        ps aux | grep -E "(telegram|node)" | grep -v grep
        ;;
    *)
        echo "❌ Неверный выбор"
        ;;
esac
