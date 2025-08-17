#!/bin/bash

echo "🚀 УСТАНОВКА БОТОВ НА СЕРВЕРЕ"
echo "============================"

# Шаг 1: Обновление системы
echo "📦 Обновление системы..."
apt update -y
apt upgrade -y

# Шаг 2: Установка пакетов
echo "📦 Установка пакетов..."
apt install -y curl wget git nano htop screen unzip

# Шаг 3: Установка Node.js
echo "📦 Установка Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

# Шаг 4: Установка PM2
echo "📦 Установка PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Шаг 5: Остановка процессов
echo "🛑 Остановка процессов..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3

# Шаг 6: Клонирование проекта
echo "📥 Клонирование проекта..."
cd /root
rm -rf 12G
git clone https://github.com/Sargiton/12G.git
cd 12G

# Шаг 7: Очистка и установка
echo "🧹 Очистка и установка..."
rm -rf node_modules package-lock.json LynxSession/* BackupSession/* qr.png tmp/*
cp package-clean.json package.json
npm install --force
npm install baileys@latest --save --force

# Шаг 8: Создание папок
echo "📁 Создание папок..."
mkdir -p LynxSession BackupSession tmp logs

# Шаг 9: Обновление импортов
echo "🔄 Обновление импортов..."
find . -name "*.js" -type f -exec sed -i 's/@whiskeysockets\/baileys/baileys/g' {} \;

# Шаг 10: Проверка синтаксиса
echo "🔍 Проверка синтаксиса..."
node -c index.js
node -c telegram-bot.cjs

# Шаг 11: Создание конфигурации PM2
echo "⚙️ Создание конфигурации PM2..."
cat > ecosystem-final.config.cjs << 'EOF'
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
      env: { NODE_ENV: 'production', NODE_OPTIONS: '--max-old-space-size=512' },
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
      env: { NODE_ENV: 'production' },
      error_file: './logs/telegram-error-1.log',
      out_file: './logs/telegram-out-1.log',
      log_file: './logs/telegram-combined-1.log',
      time: true
    }
  ]
};
EOF

# Шаг 12: Запуск ботов
echo "🚀 Запуск ботов..."
pm2 start ecosystem-final.config.cjs

# Шаг 13: Настройка автозапуска
echo "⚙️ Настройка автозапуска..."
pm2 startup
pm2 save

# Шаг 14: Результат
echo ""
echo "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
echo "======================"
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Отправьте /qr в Telegram бота"
echo "📋 Полезные команды:"
echo "  pm2 list          - статус ботов"
echo "  pm2 logs          - логи ботов"
echo "  pm2 monit         - мониторинг"
echo "  pm2 restart all   - перезапуск всех ботов"
echo "  pm2 stop all      - остановка всех ботов"
