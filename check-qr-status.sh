#!/bin/bash

echo "🔍 ПРОВЕРКА СТАТУСА ПОСЛЕ ОЧИСТКИ QR КЭША"
echo "=========================================="

# Переходим в папку проекта
cd /root/12G

echo "📁 Проверяем папку проекта..."
if [ -d "/root/12G" ]; then
    echo "✅ Папка /root/12G существует"
    echo "📂 Содержимое папки:"
    ls -la | head -10
else
    echo "❌ Папка /root/12G не найдена!"
    exit 1
fi

echo ""
echo "📱 Проверяем QR файлы..."
if [ -f "qr.png" ]; then
    echo "✅ QR файл qr.png найден"
    echo "📅 Время создания: $(stat -c %y qr.png)"
    echo "📏 Размер: $(du -h qr.png | cut -f1)"
else
    echo "❌ QR файл qr.png не найден"
fi

echo ""
echo "🗂️ Проверяем сессии..."
if [ -d "LynxSession" ]; then
    echo "✅ Папка LynxSession существует"
    echo "📂 Содержимое:"
    ls -la LynxSession/ 2>/dev/null || echo "  (пустая папка)"
else
    echo "❌ Папка LynxSession не найдена"
fi

echo ""
echo "📦 Проверяем зависимости..."
if [ -d "node_modules" ]; then
    echo "✅ node_modules существует"
    if [ -d "node_modules/@whiskeysockets" ]; then
        echo "✅ @whiskeysockets/baileys установлен"
    else
        echo "❌ @whiskeysockets/baileys не найден"
    fi
else
    echo "❌ node_modules не найден"
fi

echo ""
echo "🤖 Проверяем статус PM2..."
pm2 list

echo ""
echo "📊 Проверяем логи..."
if [ -d "logs" ]; then
    echo "✅ Папка logs существует"
    echo "📂 Файлы логов:"
    ls -la logs/ 2>/dev/null || echo "  (пустая папка)"
    
    # Проверяем последние ошибки
    if [ -f "logs/whatsapp-error-0.log" ]; then
        echo ""
        echo "🚨 Последние ошибки WhatsApp бота:"
        tail -5 logs/whatsapp-error-0.log
    fi
    
    if [ -f "logs/telegram-error-1.log" ]; then
        echo ""
        echo "🚨 Последние ошибки Telegram бота:"
        tail -5 logs/telegram-error-1.log
    fi
else
    echo "❌ Папка logs не найдена"
fi

echo ""
echo "🧪 Тестируем генерацию QR кода..."
if [ -f "simple-qr.js" ]; then
    echo "✅ Файл simple-qr.js найден"
    echo "⏳ Запускаем тест QR кода (5 секунд)..."
    timeout 5 node simple-qr.js &
    QR_PID=$!
    sleep 5
    kill $QR_PID 2>/dev/null
    
    if [ -f "qr.png" ]; then
        echo "✅ QR код успешно сгенерирован!"
        echo "📅 Время: $(stat -c %y qr.png)"
    else
        echo "❌ QR код не сгенерирован"
    fi
else
    echo "❌ Файл simple-qr.js не найден"
fi

echo ""
echo "🎯 РЕЗУЛЬТАТ ПРОВЕРКИ:"
echo "===================="
if [ -f "qr.png" ] && pm2 list | grep -q "online"; then
    echo "✅ ВСЕ РАБОТАЕТ! QR код сгенерирован, боты запущены"
    echo "📱 Отправьте команду в Telegram бота для получения QR кода"
else
    echo "❌ ЕСТЬ ПРОБЛЕМЫ! Проверьте логи выше"
    echo "🔄 Попробуйте перезапустить: pm2 restart all"
fi

echo ""
echo "📋 ПОЛЕЗНЫЕ КОМАНДЫ:"
echo "=================="
echo "• pm2 logs - просмотр логов"
echo "• pm2 restart all - перезапуск всех ботов"
echo "• pm2 stop all && pm2 start ecosystem-simple.config.cjs - полный перезапуск"
echo "• node simple-qr.js - тест QR кода"
