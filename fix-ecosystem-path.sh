#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ПУТИ В КОНФИГУРАЦИОННОМ ФАЙЛЕ"

# Переходим в правильную директорию
echo "📁 Переходим в /root/12G..."
cd /root/12G

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Проверяем где находится index.js
echo "🔍 Проверяем расположение index.js..."
if [ -f "123/index.js" ]; then
    echo "✅ index.js найден в 123/index.js"
    INDEX_PATH="index.js"
elif [ -f "index.js" ]; then
    echo "✅ index.js найден в корне"
    INDEX_PATH="../index.js"
else
    echo "❌ index.js не найден"
    exit 1
fi

# Создаем правильный конфигурационный файл
echo "📝 Создаем правильный ecosystem-old.config.cjs..."
cat > 123/ecosystem-old.config.cjs << EOF
module.exports = {
  apps: [
    {
      name: 'whatsapp-old',
      script: '${INDEX_PATH}',
      cwd: './123',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      },
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_file: './logs/combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ ecosystem-old.config.cjs исправлен!"

# Проверяем что файл создался
if [ -f "123/ecosystem-old.config.cjs" ]; then
    echo "✅ Файл успешно создан"
    echo "📋 Содержимое файла:"
    cat 123/ecosystem-old.config.cjs
else
    echo "❌ Ошибка создания файла"
    exit 1
fi

# Создаем папку для логов
echo "📁 Создаем папку для логов..."
mkdir -p 123/logs

# Запускаем бота
echo "🤖 Запускаем бота..."
cd 123
pm2 start ecosystem-old.config.cjs

echo "⏳ Ждем запуска..."
sleep 5

echo "📊 Статус бота:"
pm2 list

echo ""
echo "🔍 Проверяем логи..."
pm2 logs whatsapp-old --lines 5

echo ""
echo "✅ Путь исправлен и бот запущен!"
echo "🎯 Теперь попробуйте команду 'меню'"
