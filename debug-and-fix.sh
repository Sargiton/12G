#!/bin/bash

echo "🔍 ДИАГНОСТИКА И ИСПРАВЛЕНИЕ"

# Переходим в правильную директорию
cd /root/12G

echo "📁 Текущая директория: $(pwd)"

# Проверяем где находится index.js
echo "🔍 Ищем index.js..."
find . -name "index.js" -type f 2>/dev/null

echo ""
echo "📋 Содержимое папки 123:"
ls -la 123/

echo ""
echo "📋 Содержимое корневой папки:"
ls -la | grep -E "(index\.js|ecosystem)"

# Останавливаем все процессы
echo ""
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Создаем конфигурацию в корневой папке
echo ""
echo "📝 Создаем конфигурацию в корневой папке..."
cat > ecosystem-old.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-old',
      script: './123/index.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: { NODE_ENV: 'production' },
      out_file: './123/logs/out.log',
      error_file: './123/logs/error.log',
      log_file: './123/logs/combined.log',
      time: true
    }
  ]
};
EOF

# Создаем папки
echo "📁 Создаем папки..."
mkdir -p 123/tmp
mkdir -p 123/logs

# Исправляем handler.js
echo "🔧 Исправляем handler.js..."
if [ -f "123/handler.js" ]; then
    sed -i '/if (isOwner && m.sender)/d' 123/handler.js
    sed -i '/this.reply(m.chat, `⚠️ \*System Notice:\*/d' 123/handler.js
    echo "✅ handler.js исправлен"
fi

# Исправляем меню файлы
echo "🔧 Исправляем меню файлы..."
if [ -f "123/plugins/main-menu18.js" ]; then
    sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu18.js
    sed -i '/let img =/d' 123/plugins/main-menu18.js
    sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu18.js
    echo "✅ main-menu18.js исправлен"
fi

if [ -f "123/plugins/main-menu1.js" ]; then
    sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu1.js
    sed -i '/let img =/d' 123/plugins/main-menu1.js
    sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu1.js
    echo "✅ main-menu1.js исправлен"
fi

# Запускаем бота из корневой папки
echo "🤖 Запускаем бота..."
pm2 start ecosystem-old.config.cjs

sleep 3

echo "📊 Статус:"
pm2 list

echo ""
echo "🔍 Проверяем логи..."
pm2 logs whatsapp-old --lines 5

echo ""
echo "✅ Все исправлено! Попробуйте команду 'меню'"
