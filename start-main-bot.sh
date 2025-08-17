#!/bin/bash

echo "🚀 ЗАПУСК ОСНОВНОГО БОТА"
echo "================================"

# Переходим в директорию
cd /root/12G

echo "📁 Текущая директория: $(pwd)"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Создаем папки
echo "📁 Создаем папки..."
mkdir -p tmp
mkdir -p logs

# Проверяем зависимости
echo "📦 Проверяем зависимости..."
if [ ! -d "node_modules" ]; then
    echo "📦 Устанавливаем зависимости..."
    npm install
fi

# Создаем конфигурацию PM2 для основного бота
echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-main.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-main',
      script: 'index.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: { NODE_ENV: 'production' },
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_file: './logs/combined.log',
      time: true
    },
    {
      name: 'telegram-main',
      script: 'telegram-bot.cjs',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: { NODE_ENV: 'production' },
      out_file: './logs/telegram-out.log',
      error_file: './logs/telegram-error.log',
      log_file: './logs/telegram-combined.log',
      time: true
    }
  ]
};
EOF

# Запускаем ботов
echo "🤖 Запускаем ботов..."
pm2 start ecosystem-main.config.cjs

sleep 5

echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-main --lines 3

echo ""
echo "🔍 Проверяем логи Telegram бота..."
pm2 logs telegram-main --lines 3

echo ""
echo "✅ Основной бот запущен!"
echo "📱 WhatsApp: whatsapp-main"
echo "📲 Telegram: telegram-main"
echo ""
echo "🎯 Команды управления:"
echo "• pm2 logs whatsapp-main - логи WhatsApp"
echo "• pm2 logs telegram-main - логи Telegram"
echo "• pm2 restart all - перезапуск всех ботов"
echo "• pm2 stop all - остановка всех ботов"
