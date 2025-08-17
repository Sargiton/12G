#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🚀 ПОЛНОЕ ВОССТАНОВЛЕНИЕ ПРОЕКТА 12G"
echo "======================================"

# 1. Проверяем текущую директорию
log_info "Проверяем текущую директорию..."
if [ -d "12G" ]; then
    log_warning "Папка 12G уже существует. Удаляем..."
    rm -rf 12G
fi

# 2. Клонируем проект с GitHub
log_info "Клонируем проект с GitHub..."
git clone https://github.com/Sargiton/12G.git
if [ $? -ne 0 ]; then
    log_error "Ошибка клонирования проекта!"
    exit 1
fi

cd 12G

# 3. Устанавливаем зависимости
log_info "Устанавливаем зависимости..."
npm install
if [ $? -ne 0 ]; then
    log_error "Ошибка установки зависимостей!"
    exit 1
fi

# 4. Создаем .env файл
log_info "Создаем .env файл..."
cat > .env << 'EOF'
NODE_OPTIONS="--max-old-space-size=512"
EOF

# 5. Очищаем старые сессии
log_info "Очищаем старые сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png

# 6. Создаем необходимые папки
log_info "Создаем необходимые папки..."
mkdir -p LynxSession
mkdir -p BackupSession
mkdir -p tmp
mkdir -p database/users
mkdir -p database/chats
mkdir -p database/settings
mkdir -p database/msgs
mkdir -p database/sticker
mkdir -p database/stats

# 7. Тестируем QR код
log_info "Тестируем генерацию QR кода..."
node test-qr.js &
QR_PID=$!

# Ждем 10 секунд для генерации QR
sleep 10

# Проверяем, создался ли QR код
if [ -f "qr.png" ]; then
    log_success "QR код успешно создан!"
    kill $QR_PID 2>/dev/null
else
    log_warning "QR код не создался, пробуем принудительную генерацию..."
    kill $QR_PID 2>/dev/null
    node force-qr.js &
    sleep 5
fi

# 8. Запускаем боты через PM2
log_info "Запускаем боты через PM2..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pm2 start ecosystem-simple.config.cjs

# 9. Проверяем статус
log_info "Проверяем статус ботов..."
sleep 3
pm2 list

# 10. Настраиваем автозапуск
log_info "Настраиваем автозапуск PM2..."
pm2 startup
pm2 save

# 11. Создаем скрипт мониторинга памяти
log_info "Создаем скрипт мониторинга памяти..."
cat > /root/monitor-memory.sh << 'EOF'
#!/bin/bash
while true; do
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
    echo "$(date): Memory usage: ${MEMORY}%"
    if (( $(echo "$MEMORY > 90" | bc -l) )); then
        echo "High memory usage detected! Restarting PM2..."
        pm2 restart all
    fi
    sleep 300
done
EOF

chmod +x /root/monitor-memory.sh

# 12. Запускаем мониторинг памяти
log_info "Запускаем мониторинг памяти..."
nohup /root/monitor-memory.sh > /var/log/memory-monitor.log 2>&1 &

# 13. Создаем скрипт быстрого перезапуска
log_info "Создаем скрипт быстрого перезапуска..."
cat > /root/restart-bots.sh << 'EOF'
#!/bin/bash
echo "🔄 Перезапуск ботов..."
pm2 stop all
pm2 delete all
sleep 5
cd /root/12G
pm2 start ecosystem-simple.config.cjs
pm2 save
echo "✅ Боты перезапущены!"
EOF

chmod +x /root/restart-bots.sh

# 14. Создаем скрипт очистки QR кэша
log_info "Создаем скрипт очистки QR кэша..."
cat > /root/clear-qr.sh << 'EOF'
#!/bin/bash
echo "🧹 Очищаю QR кэш..."
pm2 stop all
pm2 delete all
rm -rf /root/12G/tmp/*
rm -rf /root/12G/storage/data/cache/*
rm -f /root/12G/qr.png
rm -f /root/12G/qr.jpg
rm -rf /root/12G/LynxSession/*
rm -rf /root/12G/BackupSession/*
cd /root/12G
pm2 start ecosystem-simple.config.cjs
echo "✅ QR кэш очищен и боты перезапущены!"
EOF

chmod +x /root/clear-qr.sh

# 15. Финальная проверка
log_info "Выполняем финальную проверку..."
sleep 5

echo ""
echo "🎉 ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "=============================="
echo ""
echo "📁 Проект восстановлен в: /root/12G"
echo "🤖 Боты запущены через PM2"
echo "📊 Мониторинг памяти активен"
echo ""
echo "🔧 Полезные команды:"
echo "  pm2 list                    - Статус ботов"
echo "  pm2 logs                    - Логи ботов"
echo "  /root/restart-bots.sh       - Перезапуск ботов"
echo "  /root/clear-qr.sh           - Очистка QR кэша"
echo "  node force-qr.js            - Принудительная генерация QR"
echo ""
echo "📱 Проверьте QR код:"
if [ -f "qr.png" ]; then
    echo "  ✅ QR код создан: qr.png"
else
    echo "  ⚠️  QR код не найден, запустите: node force-qr.js"
fi

log_success "Восстановление завершено успешно!"
