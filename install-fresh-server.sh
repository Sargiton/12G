#!/bin/bash

echo "🚀 ПОЛНАЯ УСТАНОВКА БОТА НА ПУСТОЙ СЕРВЕР DEBIAN 12"
echo "=================================================="

# Обновляем систему
echo "📦 Обновляем систему..."
apt update && apt upgrade -y

# Устанавливаем необходимые пакеты
echo "🔧 Устанавливаем необходимые пакеты..."
apt install -y curl wget git nano htop screen

# Устанавливаем Node.js 18
echo "📥 Устанавливаем Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Проверяем версии
echo "✅ Проверяем версии:"
node --version
npm --version

# Устанавливаем PM2 глобально
echo "📦 Устанавливаем PM2..."
npm install -g pm2

# Создаем директорию для бота
echo "📁 Создаем директорию для бота..."
mkdir -p /root/12G
cd /root/12G

# Клонируем репозиторий
echo "📥 Клонируем репозиторий..."
git clone https://github.com/Sargiton/12G.git .
git pull

# Создаем необходимые папки
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

# Устанавливаем зависимости
echo "📦 Устанавливаем зависимости..."
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

# Ждем немного
sleep 10

# Показываем статус
echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-working --lines 10

echo ""
echo "🔍 Проверяем логи Telegram бота..."
pm2 logs telegram-working --lines 5

echo ""
echo "✅ ПОЛНАЯ УСТАНОВКА ЗАВЕРШЕНА!"
echo "📱 WhatsApp: whatsapp-working"
echo "📲 Telegram: telegram-working"
echo ""
echo "🎯 Команды управления:"
echo "• pm2 logs whatsapp-working - логи WhatsApp"
echo "• pm2 logs telegram-working - логи Telegram"
echo "• pm2 restart all - перезапуск всех ботов"
echo "• pm2 stop all - остановка всех ботов"
echo "• pm2 save - сохранить конфигурацию"
echo "• pm2 startup - автозапуск при перезагрузке"
echo ""
echo "🔐 QR код должен появиться в логах WhatsApp бота"
echo "📋 Для просмотра логов: pm2 logs whatsapp-working --lines 50"
