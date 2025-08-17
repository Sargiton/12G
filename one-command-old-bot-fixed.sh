#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ОДНА КОМАНДА - СТАРЫЙ БОТ (ИСПРАВЛЕННЫЙ) ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем, что мы в домашней директории
cd ~

# Останавливаем все существующие процессы PM2
echo -e "${YELLOW}🛑 Останавливаем все боты...${NC}"
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Удаляем старую папку если есть
echo -e "${YELLOW}🧹 Очищаем старые файлы...${NC}"
rm -rf 12G 2>/dev/null || true

# Скачиваем репозиторий
echo -e "${YELLOW}📥 Скачиваем репозиторий...${NC}"
git clone https://github.com/Sargiton/12G.git
cd 12G

# Проверяем, что папка 123 существует
if [ ! -d "123" ]; then
    echo -e "${RED}❌ Папка 123 не найдена!${NC}"
    exit 1
fi

# Создаем папку для логов
echo -e "${YELLOW}📁 Создаем папки для логов...${NC}"
mkdir -p 123/logs

# Переходим в папку 123 и устанавливаем зависимости
echo -e "${YELLOW}📦 Устанавливаем зависимости для старого бота...${NC}"
cd 123

# Проверяем Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js не установлен!${NC}"
    echo -e "${YELLOW}Установите Node.js: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs${NC}"
    exit 1
fi

# Проверяем npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm не установлен!${NC}"
    exit 1
fi

# Удаляем проблемный пакет imagemaker.js из package.json
echo -e "${YELLOW}🔧 Исправляем package.json (удаляем imagemaker.js)...${NC}"
sed -i '/imagemaker.js/d' package.json

# Устанавливаем зависимости с игнорированием скриптов сборки
echo -e "${YELLOW}⚙️ Устанавливаем пакеты (игнорируем скрипты сборки)...${NC}"
npm install --production --ignore-scripts

# Если установка не удалась, пробуем без проблемных пакетов
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️ Есть проблемы с установкой, пробуем альтернативный способ...${NC}"
    
    # Очищаем npm кэш
    npm cache clean --force
    
    # Удаляем node_modules и package-lock.json
    rm -rf node_modules package-lock.json
    
    # Устанавливаем только основные пакеты
    echo -e "${YELLOW}📦 Устанавливаем основные пакеты...${NC}"
    npm install @whiskeysockets/baileys@6.5.0 pino qrcode-terminal qrcode chalk --ignore-scripts
fi

# Возвращаемся в корень
cd ..

# Создаем PM2 конфиг для старого бота
echo -e "${YELLOW}⚙️ Создаем конфигурацию PM2...${NC}"
cat > ecosystem-old.config.cjs << 'EOF'
module.exports = {
    apps: [
        {
            name: 'whatsapp-old',
            script: 'index.js',
            cwd: './123',
            autorestart: true,
            watch: false,
            time: true,
            node_args: '',
            env: {
                NODE_ENV: 'production',
                PORT: '3300'
            },
            out_file: './123/logs/whatsapp-old-out.log',
            error_file: './123/logs/whatsapp-old-error.log',
            log_date_format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
        }
    ]
}
EOF

# Запускаем старого бота
echo -e "${YELLOW}🚀 Запускаем старого бота...${NC}"
pm2 start ecosystem-old.config.cjs

# Сохраняем PM2
echo -e "${YELLOW}💾 Сохраняем PM2 конфигурацию...${NC}"
pm2 save

# Ждем немного для запуска
echo -e "${YELLOW}⏳ Ждем запуска...${NC}"
sleep 10

# Показываем статус
echo -e "${GREEN}✅ Статус ботов:${NC}"
pm2 list

echo ""
echo -e "${GREEN}📋 Проверяем логи старого бота:${NC}"
pm2 logs whatsapp-old --lines 15

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ СТАРЫЙ БОТ ЗАПУЩЕН!${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}📱 Команды для управления:${NC}"
echo -e "  Логи: ${GREEN}pm2 logs whatsapp-old --lines 50${NC}"
echo -e "  Перезапуск: ${GREEN}pm2 restart whatsapp-old${NC}"
echo -e "  Остановка: ${GREEN}pm2 stop whatsapp-old${NC}"
echo -e "  Удаление: ${GREEN}pm2 delete whatsapp-old${NC}"
echo ""
echo -e "${YELLOW}📁 Папка бота: ${GREEN}~/12G/123${NC}"
echo -e "${YELLOW}📁 Логи: ${GREEN}~/12G/123/logs/${NC}"
echo ""
echo -e "${BLUE}================================${NC}"
