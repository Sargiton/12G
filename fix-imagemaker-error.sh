#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    ИСПРАВЛЕНИЕ ОШИБКИ IMAGEMAKER ${NC}"
echo -e "${BLUE}================================${NC}"

# Проверяем, что мы в правильной директории
if [ ! -d "123" ]; then
    echo -e "${RED}❌ Папка 123 не найдена!${NC}"
    echo -e "${YELLOW}Убедитесь, что вы находитесь в корне проекта 12G${NC}"
    exit 1
fi

cd 123

echo -e "${YELLOW}🔧 Исправляем ошибку imagemaker.js...${NC}"

# Удаляем проблемный пакет
echo -e "${YELLOW}🗑️ Удаляем проблемный пакет imagemaker.js...${NC}"
npm uninstall imagemaker.js

# Очищаем npm кэш
echo -e "${YELLOW}🧹 Очищаем npm кэш...${NC}"
npm cache clean --force

# Удаляем node_modules и package-lock.json
echo -e "${YELLOW}🗑️ Удаляем node_modules и package-lock.json...${NC}"
rm -rf node_modules package-lock.json

# Устанавливаем зависимости без imagemaker.js
echo -e "${YELLOW}📦 Устанавливаем зависимости без imagemaker.js...${NC}"
npm install --production --ignore-scripts

# Если все еще есть ошибки, устанавливаем без проблемных пакетов
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️ Есть проблемы с установкой, пробуем альтернативный способ...${NC}"
    
    # Создаем временный package.json без проблемных пакетов
    echo -e "${YELLOW}🔧 Создаем временный package.json...${NC}"
    cp package.json package.json.backup
    
    # Удаляем проблемные пакеты из package.json
    sed -i '/imagemaker.js/d' package.json
    
    # Устанавливаем заново
    npm install --production --ignore-scripts
    
    # Восстанавливаем оригинальный package.json
    mv package.json.backup package.json
fi

echo -e "${GREEN}✅ Исправление завершено!${NC}"
echo -e "${YELLOW}📋 Теперь можно запускать бота:${NC}"
echo -e "  ${GREEN}pm2 restart whatsapp-old${NC}"

cd ..

echo -e "${BLUE}================================${NC}"
