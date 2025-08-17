#!/bin/bash

echo "🔧 ОБНОВЛЕНИЕ NODE.JS ДО ВЕРСИИ 20"
echo "==================================="

cd /root/12G

echo "📋 Текущая версия Node.js: $(node --version)"
echo "📋 Текущая версия NPM: $(npm --version)"

echo ""
echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "📥 Обновляем Node.js..."

# Добавляем репозиторий NodeSource
echo "🔧 Добавляем репозиторий NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Устанавливаем Node.js 20
echo "📦 Устанавливаем Node.js 20..."
sudo apt-get update
sudo apt-get install -y nodejs

echo ""
echo "📋 Проверяем новую версию..."
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

echo ""
echo "🧹 Очищаем кэш NPM..."
npm cache clean --force

echo ""
echo "📦 Переустанавливаем зависимости..."
rm -rf node_modules package-lock.json
npm install

echo ""
echo "🔍 Проверяем совместимость..."
node -e "
console.log('✅ Node.js версия:', process.version);
console.log('✅ Поддержка ES модулей:', typeof import !== 'undefined');
"

echo ""
echo "🚀 Запускаем боты..."
pm2 start ecosystem-final.config.cjs

echo ""
echo "📋 Статус ботов:"
pm2 list

echo ""
echo "✅ ОБНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "========================"
echo "📱 Теперь попробуйте команду /qr в Telegram боте"
