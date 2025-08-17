#!/bin/bash

echo "🚀 БЫСТРОЕ ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ"

# Переходим в правильную директорию
cd /root/12G

# Останавливаем все процессы
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Создаем правильный конфигурационный файл
echo "📝 Создаем правильный конфигурационный файл..."
cat > 123/ecosystem-old.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-old',
      script: 'index.js',
      cwd: './123',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: { NODE_ENV: 'production' },
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_file: './logs/combined.log',
      time: true
    }
  ]
};
EOF

# Создаем папки
mkdir -p 123/tmp
mkdir -p 123/logs

# Исправляем handler.js
echo "🔧 Исправляем handler.js..."
sed -i '/if (isOwner && m.sender)/d' 123/handler.js
sed -i '/this.reply(m.chat, `⚠️ \*System Notice:\*/d' 123/handler.js

# Исправляем меню файлы
echo "🔧 Исправляем меню файлы..."
if [ -f "123/plugins/main-menu18.js" ]; then
    sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu18.js
    sed -i '/let img =/d' 123/plugins/main-menu18.js
    sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu18.js
fi

if [ -f "123/plugins/main-menu1.js" ]; then
    sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu1.js
    sed -i '/let img =/d' 123/plugins/main-menu1.js
    sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu1.js
fi

# Запускаем бота
echo "🤖 Запускаем бота..."
cd 123
pm2 start ecosystem-old.config.cjs

sleep 3

echo "📊 Статус:"
pm2 list

echo ""
echo "✅ Все исправлено! Попробуйте команду 'меню'"
