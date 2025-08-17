#!/bin/bash

echo "🤖 ОБНОВЛЕНИЕ TELEGRAM БОТА НА УПРОЩЕННУЮ ВЕРСИЮ"
echo "================================================"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all
pm2 delete all
pkill -f node

# Переходим в папку проекта
cd /root/12G

# Создаем резервную копию старого бота
echo "💾 Создаем резервную копию старого бота..."
if [ -f "telegram-bot.cjs" ]; then
    cp telegram-bot.cjs telegram-bot-backup.cjs
    echo "✅ Резервная копия создана: telegram-bot-backup.cjs"
fi

# Заменяем на упрощенную версию
echo "🔄 Заменяем на упрощенную версию..."
if [ -f "telegram-bot-simple.cjs" ]; then
    cp telegram-bot-simple.cjs telegram-bot.cjs
    echo "✅ Telegram бот обновлен на упрощенную версию"
else
    echo "❌ Файл telegram-bot-simple.cjs не найден"
    exit 1
fi

# Обновляем ecosystem файл для использования упрощенной версии
echo "📝 Обновляем конфигурацию PM2..."
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

echo "✅ Конфигурация PM2 обновлена"

# Создаем папки для логов
echo "📁 Создаем папки для логов..."
mkdir -p logs

# Запускаем боты
echo "🚀 Запускаем боты..."
pm2 start ecosystem-simple.config.cjs

# Проверяем статус
echo "📊 Проверяем статус..."
sleep 5
pm2 list

# Настраиваем автозапуск
echo "⚙️ Настраиваем автозапуск..."
pm2 startup
pm2 save

echo ""
echo "🎉 TELEGRAM БОТ ОБНОВЛЕН!"
echo "========================"
echo "✅ Старый бот сохранен в telegram-bot-backup.cjs"
echo "✅ Установлена упрощенная версия с 6 командами:"
echo "   📱 /qr - Получить QR код"
echo "   📊 /status - Статус ботов"
echo "   🔄 /restart - Перезапустить WhatsApp"
echo "   🧹 /clear - Очистить сессию"
echo "   📋 /logs - Последние логи"
echo "   ❓ /help - Справка"
echo ""
echo "🤖 Telegram бот готов к работе!"
echo "📱 Отправьте /help в Telegram для получения справки"
