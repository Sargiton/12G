#!/bin/bash

echo "🔧 СОЗДАНИЕ КОНФИГУРАЦИОННОГО ФАЙЛА PM2"

# Переходим в правильную директорию
echo "📁 Переходим в /root/12G..."
cd /root/12G

# Проверяем существующие конфигурационные файлы
echo "🔍 Ищем существующие конфигурационные файлы..."
ls -la *.cjs 2>/dev/null || echo "Файлы .cjs не найдены"
ls -la *.js 2>/dev/null | grep -i ecosystem || echo "Файлы ecosystem не найдены"

# Создаем ecosystem-old.config.cjs
echo "📝 Создаем ecosystem-old.config.cjs..."
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

echo "✅ ecosystem-old.config.cjs создан!"

# Проверяем что файл создался
if [ -f "123/ecosystem-old.config.cjs" ]; then
    echo "✅ Файл успешно создан"
    echo "📋 Содержимое файла:"
    cat 123/ecosystem-old.config.cjs
else
    echo "❌ Ошибка создания файла"
    exit 1
fi

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

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
echo "✅ Конфигурация создана и бот запущен!"
echo "🎯 Теперь попробуйте команду 'меню'"
