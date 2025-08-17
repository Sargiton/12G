#!/bin/bash

echo "🚀 ПОЛНАЯ УСТАНОВКА НА СЕРВЕРЕ"
echo "=============================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для логирования
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Проверяем, что мы root
if [ "$EUID" -ne 0 ]; then
    log_error "Этот скрипт должен быть запущен от имени root"
    exit 1
fi

# Шаг 1: Обновление системы
log_info "Обновление системы..."
apt update -y
apt upgrade -y
log_success "Система обновлена"

# Шаг 2: Установка необходимых пакетов
log_info "Установка необходимых пакетов..."
apt install -y curl wget git nano htop screen unzip
log_success "Пакеты установлены"

# Шаг 3: Проверка и установка Node.js
log_info "Проверка Node.js..."
if ! command -v node &> /dev/null; then
    log_warning "Node.js не найден, устанавливаем..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    log_success "Node.js установлен"
else
    log_success "Node.js уже установлен"
fi

# Проверяем версии
log_info "Версии Node.js и npm:"
node --version
npm --version

# Шаг 4: Установка PM2
log_info "Установка PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    log_success "PM2 установлен"
else
    log_success "PM2 уже установлен"
fi

# Шаг 5: Остановка всех процессов
log_info "Остановка всех процессов..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pkill -f node 2>/dev/null
sleep 3
log_success "Все процессы остановлены"

# Шаг 6: Переход в папку проекта
log_info "Переход в папку проекта..."
cd /root

# Удаляем старую папку если существует
if [ -d "12G" ]; then
    log_warning "Удаляем старую папку проекта..."
    rm -rf 12G
fi

# Клонируем проект
log_info "Клонирование проекта с Git..."
git clone https://github.com/Sargiton/12G.git
cd 12G
log_success "Проект склонирован"

# Шаг 7: Очистка и подготовка
log_info "Очистка проекта..."
rm -rf node_modules
rm -f package-lock.json
rm -rf LynxSession/*
rm -rf BackupSession/*
rm -f qr.png qr.jpg
rm -rf tmp/*
log_success "Проект очищен"

# Шаг 8: Замена package.json
log_info "Замена package.json на очищенную версию..."
if [ -f "package-clean.json" ]; then
    cp package-clean.json package.json
    log_success "package.json заменен"
else
    log_error "Файл package-clean.json не найден"
    exit 1
fi

# Шаг 9: Установка зависимостей
log_info "Установка зависимостей..."
npm install --force
if [ $? -eq 0 ]; then
    log_success "Зависимости установлены"
else
    log_error "Ошибка установки зависимостей"
    exit 1
fi

# Шаг 10: Установка baileys
log_info "Установка baileys..."
npm install baileys@latest --save --force
if [ $? -eq 0 ]; then
    log_success "Baileys установлен"
else
    log_error "Ошибка установки baileys"
    exit 1
fi

# Шаг 11: Проверка установки baileys
log_info "Проверка установки baileys..."
if [ -d "node_modules/baileys" ]; then
    log_success "Baileys установлен"
    ls -la node_modules/baileys/package.json
    echo "Версия: $(cat node_modules/baileys/package.json | grep '"version"' | cut -d'"' -f4)"
else
    log_error "Baileys не установлен"
    exit 1
fi

# Шаг 12: Создание необходимых папок
log_info "Создание необходимых папок..."
mkdir -p LynxSession BackupSession tmp logs
log_success "Папки созданы"

# Шаг 13: Обновление импортов baileys
log_info "Обновление импортов baileys..."
find . -name "*.js" -type f -exec sed -i 's/@whiskeysockets\/baileys/baileys/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/from.*@whiskeysockets\/baileys/from "baileys"/g' {} \;
find . -name "*.js" -type f -exec sed -i 's/import.*@whiskeysockets\/baileys/import.*baileys/g' {} \;
log_success "Импорты обновлены"

# Шаг 14: Проверка синтаксиса файлов
log_info "Проверка синтаксиса файлов..."
if node -c index.js; then
    log_success "Синтаксис index.js корректен"
else
    log_error "Ошибка синтаксиса в index.js"
    exit 1
fi

if node -c telegram-bot.cjs; then
    log_success "Синтаксис telegram-bot.cjs корректен"
else
    log_error "Ошибка синтаксиса в telegram-bot.cjs"
    exit 1
fi

# Шаг 15: Создание конфигурации PM2
log_info "Создание конфигурации PM2..."
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
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=512'
      },
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
      env: {
        NODE_ENV: 'production'
      },
      error_file: './logs/telegram-error-1.log',
      out_file: './logs/telegram-out-1.log',
      log_file: './logs/telegram-combined-1.log',
      time: true
    }
  ]
};
EOF
log_success "Конфигурация PM2 создана"

# Шаг 16: Тестирование QR генерации
log_info "Тестирование QR генерации..."
cat > test-qr-final.js << 'EOF'
import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

async function testQR() {
    try {
        console.log('🔍 Тестируем QR генерацию...')
        
        const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
        
        const sock = makeWASocket({
            auth: state,
            printQRInTerminal: true,
            logger: pino({ level: 'silent' }),
            browser: ['Lynx Bot', 'Chrome', '1.0.0']
        })
        
        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update
            
            if (qr) {
                console.log('✅ QR код сгенерирован успешно!')
                qrcode.generate(qr, { small: true })
                
                // Сохраняем QR в файл
                const fs = await import('fs')
                const qrCode = await import('qrcode')
                const qrBuffer = await qrCode.toBuffer(qr)
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                
                // Останавливаем тест
                process.exit(0)
            }
            
            if (connection === 'close') {
                const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
                console.log('❌ Соединение закрыто:', lastDisconnect?.error, ', переподключение:', shouldReconnect)
                if (!shouldReconnect) {
                    process.exit(1)
                }
            }
        })
        
        // Ждем 30 секунд
        setTimeout(() => {
            console.log('⏰ Время ожидания истекло')
            process.exit(1)
        }, 30000)
        
    } catch (error) {
        console.error('❌ Ошибка тестирования QR:', error)
        process.exit(1)
    }
}

testQR()
EOF

# Запускаем тест QR
log_info "Запуск теста QR генерации..."
timeout 30s node test-qr-final.js

# Проверяем создался ли QR файл
if [ -f "qr.png" ]; then
    log_success "QR файл создан успешно!"
    ls -la qr.png
else
    log_warning "QR файл не создан, но это может быть нормально"
fi

# Шаг 17: Запуск ботов
log_info "Запуск ботов..."
pm2 start ecosystem-final.config.cjs
if [ $? -eq 0 ]; then
    log_success "Боты запущены"
else
    log_error "Ошибка запуска ботов"
    exit 1
fi

# Шаг 18: Проверка статуса
log_info "Проверка статуса ботов..."
sleep 10
pm2 list

# Шаг 19: Настройка автозапуска
log_info "Настройка автозапуска..."
pm2 startup
pm2 save
log_success "Автозапуск настроен"

# Шаг 20: Проверка логов на ошибки
log_info "Проверка логов на ошибки..."
sleep 5
if [ -f "logs/whatsapp-error-0.log" ]; then
    log_info "Последние ошибки WhatsApp:"
    tail -5 logs/whatsapp-error-0.log
fi

if [ -f "logs/telegram-error-1.log" ]; then
    log_info "Последние ошибки Telegram:"
    tail -5 logs/telegram-error-1.log
fi

# Шаг 21: Финальная проверка
log_info "Финальная проверка..."
echo ""
echo "🎉 УСТАНОВКА ЗАВЕРШЕНА!"
echo "======================"
echo "✅ Все зависимости установлены"
echo "✅ Baileys обновлен до последней версии"
echo "✅ Все импорты исправлены"
echo "✅ Синтаксис файлов корректен"
echo "✅ Боты запущены с новой конфигурацией"
echo ""
echo "📊 Статус ботов:"
pm2 list
echo ""
echo "📱 Теперь отправьте /qr в Telegram бота"
echo "🔍 Если есть проблемы, проверьте логи: pm2 logs"
echo ""
echo "📋 Полезные команды:"
echo "  pm2 list          - статус ботов"
echo "  pm2 logs          - логи ботов"
echo "  pm2 monit         - мониторинг"
echo "  pm2 restart all   - перезапуск всех ботов"
echo "  pm2 stop all      - остановка всех ботов"
