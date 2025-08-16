#!/bin/bash

# Оптимизированный запуск WhatsApp бота
# Автор: DarkCore
# Версия: 2.0

echo "🚀 Запуск оптимизированного WhatsApp бота..."

# Проверка наличия Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js не найден. Установите Node.js 16+"
    exit 1
fi

# Проверка версии Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Требуется Node.js версии 16 или выше. Текущая версия: $(node -v)"
    exit 1
fi

# Создание директорий для логов
mkdir -p logs
mkdir -p tmp
mkdir -p storage/media-cache

# Очистка старых логов
find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true

# Настройка переменных окружения для оптимизации
export NODE_ENV=production
export NODE_OPTIONS="--max-old-space-size=1024 --expose-gc --optimize-for-size"
export UV_THREADPOOL_SIZE=4
export REDIS_URL=${REDIS_URL:-"redis://localhost:6379"}

# Проверка Redis (опционально)
if command -v redis-cli &> /dev/null; then
    if redis-cli ping &> /dev/null; then
        echo "✅ Redis подключен"
    else
        echo "⚠️ Redis недоступен, используется только NodeCache"
    fi
else
    echo "⚠️ Redis не установлен, используется только NodeCache"
fi

# Установка зависимостей если нужно
if [ ! -d "node_modules" ]; then
    echo "📦 Установка зависимостей..."
    npm install
fi

# Проверка PM2
if command -v pm2 &> /dev/null; then
    echo "🔄 Запуск через PM2..."
    
    # Остановка существующих процессов
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
    
    # Запуск с новой конфигурацией
    pm2 start ecosystem.config.js
    
    # Сохранение конфигурации PM2
    pm2 save
    
    echo "✅ Бот запущен через PM2"
    echo "📊 Мониторинг: pm2 monit"
    echo "📋 Логи: pm2 logs"
    echo "🛑 Остановка: pm2 stop all"
    
else
    echo "🔄 Запуск напрямую через Node.js..."
    
    # Запуск бота
    node --max-old-space-size=1024 --expose-gc --optimize-for-size index.js
fi

echo "🎉 Запуск завершен!" 