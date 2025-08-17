#!/bin/bash

echo "🚀 ЗАПУСК РАБОЧЕГО БОТА"
echo "======================"

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
mkdir -p LynxSession

# Отключаем проблемные плагины
echo "🚫 Отключаем проблемные плагины..."
problematic_plugins=(
    "dl-facebook.js"
    "dl-playstore.js" 
    "info.js"
    "prueba-filterGB.js"
    "prueba-wattpad.js"
    "prueba_apk.js"
    "search-playstore.js"
)

for plugin in "${problematic_plugins[@]}"; do
    if [ -f "plugins/$plugin" ]; then
        mv "plugins/$plugin" "plugins/$plugin.disabled"
        echo "✅ Отключен: $plugin"
    fi
done

# Очищаем node_modules и переустанавливаем
echo "📦 Переустанавливаем зависимости..."
rm -rf node_modules package-lock.json
npm install

# Создаем конфигурацию PM2
echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-working.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-working',
      script: 'final-working-bot.js',
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
      name: 'telegram-working',
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
pm2 start ecosystem-working.config.cjs

sleep 10

echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-working --lines 10

echo ""
echo "🔍 Проверяем логи Telegram бота..."
pm2 logs telegram-working --lines 5

echo ""
echo "✅ РАБОЧИЙ БОТ ЗАПУЩЕН!"
echo "📱 WhatsApp: whatsapp-working"
echo "📲 Telegram: telegram-working"
echo ""
echo "🎯 Команды управления:"
echo "• pm2 logs whatsapp-working - логи WhatsApp"
echo "• pm2 logs telegram-working - логи Telegram"
echo "• pm2 restart all - перезапуск всех ботов"
echo "• pm2 stop all - остановка всех ботов"
echo ""
echo "🔐 QR код должен появиться в логах WhatsApp бота"
