#!/bin/bash

echo "🔧 ПОЛНОЕ ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ"
echo "==================================="

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

# 2. Переходим в папку проекта
cd /root/12G

# 3. Полностью очищаем зависимости
log_info "Полностью очищаем зависимости..."
rm -rf node_modules
rm -f package-lock.json
npm cache clean --force

# 4. Обновляем package.json с правильными зависимостями
log_info "Обновляем package.json..."
if [ -f "package.json" ]; then
    # Заменяем старый baileys на новый
    sed -i 's/"baileys": "^6.6.0"/"@whiskeysockets\/baileys": "^6.6.0"/g' package.json
fi

# 5. Устанавливаем зависимости принудительно
log_info "Устанавливаем зависимости принудительно..."
npm install --force

# 6. Проверяем и устанавливаем критичные пакеты
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

# 7. Очищаем старые сессии
log_info "Очищаем старые сессии..."
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png

# 8. Создаем необходимые папки
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

# 9. Тестируем QR код
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

# 10. Запускаем боты
log_info "Запускаем боты..."
if [ -f "ecosystem-simple.config.cjs" ]; then
    pm2 start ecosystem-simple.config.cjs
else
    log_warning "ecosystem-simple.config.cjs не найден, запускаем основной бот..."
    pm2 start index.js --name "whatsapp-bot"
fi

# 11. Проверяем статус
log_info "Проверяем статус..."
sleep 5
pm2 list

# 12. Настраиваем автозапуск
log_info "Настраиваем автозапуск..."
pm2 startup
pm2 save

echo ""
echo "🎉 ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "=========================="
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
echo "  pm2 restart all             - Перезапуск ботов"

log_success "Исправление завершено!"
