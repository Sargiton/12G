#!/bin/bash

echo "🚀 ПОЛНОЕ ВОССТАНОВЛЕНИЕ С НУЛЯ"
echo "================================"

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 1. Останавливаем все процессы
log_info "Останавливаем все процессы..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null

# 2. Удаляем старую папку если есть
if [ -d "/root/12G" ]; then
    log_info "Удаляем старую папку 12G..."
    rm -rf /root/12G
fi

# 3. Клонируем проект заново
log_info "Клонируем проект с GitHub..."
cd /root
git clone https://github.com/Sargiton/12G.git
if [ $? -ne 0 ]; then
    log_error "Ошибка клонирования проекта!"
    exit 1
fi

cd /root/12G

# 4. Устанавливаем зависимости
log_info "Устанавливаем зависимости..."
npm install --force
if [ $? -ne 0 ]; then
    log_warning "Первый npm install не удался, пробуем с очисткой..."
    rm -rf node_modules package-lock.json
    npm cache clean --force
    npm install --force
fi

# 5. Проверяем критичные пакеты
log_info "Проверяем критичные пакеты..."

# Проверяем @whiskeysockets/baileys
if [ ! -d "node_modules/@whiskeysockets" ]; then
    log_warning "@whiskeysockets/baileys не найден, устанавливаем..."
    npm install @whiskeysockets/baileys --force
fi

# Проверяем qrcode-terminal
if [ ! -d "node_modules/qrcode-terminal" ]; then
    log_warning "qrcode-terminal не найден, устанавливаем..."
    npm install qrcode-terminal --force
fi

# Проверяем qrcode
if [ ! -d "node_modules/qrcode" ]; then
    log_warning "qrcode не найден, устанавливаем..."
    npm install qrcode --force
fi

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

# 7. Создаем .env файл
log_info "Создаем .env файл..."
echo 'NODE_OPTIONS="--max-old-space-size=512"' > .env

# 8. Тестируем QR код
log_info "Тестируем генерацию QR кода..."
if [ -f "simple-qr.js" ]; then
    timeout 30 node simple-qr.js &
    QR_PID=$!
    
    # Ждем 15 секунд
    sleep 15
    
    # Проверяем результат
    if [ -f "qr.png" ]; then
        log_success "QR код успешно создан!"
        kill $QR_PID 2>/dev/null
    else
        log_warning "QR код не создался за 15 секунд"
        kill $QR_PID 2>/dev/null
    fi
else
    log_warning "Файл simple-qr.js не найден"
fi

# 9. Запускаем боты
log_info "Запускаем боты..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    log_warning "ecosystem-simple.config.cjs не найден, запускаем основной бот..."
    pm2 start index.js --name "whatsapp-bot"
fi

# 10. Проверяем статус
log_info "Проверяем статус..."
sleep 5
pm2 list

# 11. Настраиваем автозапуск
log_info "Настраиваем автозапуск..."
pm2 startup
pm2 save

# 12. Создаем полезные скрипты
log_info "Создаем полезные скрипты..."

# Скрипт перезапуска
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

# Скрипт очистки QR
cat > /root/clear-qr.sh << 'EOF'
#!/bin/bash
echo "🧹 Очищаю QR кэш..."
pm2 stop all
pm2 delete all
rm -rf /root/12G/tmp/*
rm -f /root/12G/qr.png
rm -rf /root/12G/LynxSession/*
rm -rf /root/12G/BackupSession/*
cd /root/12G
pm2 start ecosystem-simple.config.cjs
echo "✅ QR кэш очищен и боты перезапущены!"
EOF
chmod +x /root/clear-qr.sh

echo ""
echo "🎉 ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "=============================="
echo ""
echo "📁 Проект восстановлен в: /root/12G"
echo "🤖 Боты запущены через PM2"
echo ""
echo "📱 Проверьте QR код:"
if [ -f "qr.png" ]; then
    echo "  ✅ QR код создан: qr.png"
else
    echo "  ⚠️  QR код не найден"
    echo "  🔧 Попробуйте: node simple-qr.js"
fi

echo ""
echo "🔧 Полезные команды:"
echo "  pm2 list                    - Статус ботов"
echo "  pm2 logs                    - Логи ботов"
echo "  node simple-qr.js           - Генерация QR кода"
echo "  /root/restart-bots.sh       - Перезапуск ботов"
echo "  /root/clear-qr.sh           - Очистка QR кэша"

log_success "Восстановление с нуля завершено!"
