#!/bin/bash

# Один скрипт для полной установки
echo "🚀 УСТАНОВКА В ОДНУ КОМАНДУ"
echo "=========================="

# Обновляем систему
apt update -y && apt upgrade -y

# Устанавливаем пакеты
apt install -y curl wget git nano htop screen unzip

# Устанавливаем Node.js если не установлен
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

# Устанавливаем PM2 если не установлен
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Останавливаем все процессы
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3

# Переходим в папку и клонируем проект
cd /root
rm -rf 12G
git clone https://github.com/Sargiton/12G.git
cd 12G

# Очищаем и устанавливаем
rm -rf node_modules package-lock.json LynxSession/* BackupSession/* qr.png tmp/*
cp package-clean.json package.json
npm install --force
npm install baileys@latest --save --force

# Создаем папки
mkdir -p LynxSession BackupSession tmp logs

# Обновляем импорты
find . -name "*.js" -type f -exec sed -i 's/@whiskeysockets\/baileys/baileys/g' {} \;

# Проверяем синтаксис
node -c index.js && node -c telegram-bot.cjs

# Создаем конфигурацию PM2
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

# Запускаем боты
pm2 start ecosystem-final.config.cjs

# Настраиваем автозапуск
pm2 startup
pm2 save

# Показываем результат
sleep 5
echo ""
echo "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
echo "======================"
pm2 list
echo ""
echo "📱 Отправьте /qr в Telegram бота"
echo "📋 Команды: pm2 list, pm2 logs, pm2 restart all"
