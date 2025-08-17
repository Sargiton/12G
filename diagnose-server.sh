#!/bin/bash

echo "🔍 ДИАГНОСТИКА СЕРВЕРА"
echo "====================="

# Проверяем систему
echo "📊 Информация о системе:"
echo "ОС: $(uname -a)"
echo "Архитектура: $(uname -m)"
echo "Версия ядра: $(uname -r)"

# Проверяем Node.js
echo ""
echo "📦 Node.js:"
node --version
which node
echo "NODE_PATH: $NODE_PATH"

# Проверяем npm
echo ""
echo "📦 npm:"
npm --version
which npm
echo "npm config prefix: $(npm config get prefix)"

# Проверяем текущую директорию
echo ""
echo "📁 Текущая директория:"
pwd
ls -la

# Проверяем папку проекта
echo ""
echo "📁 Папка проекта:"
if [ -d "/root/12G" ]; then
    cd /root/12G
    echo "Переходим в /root/12G"
    pwd
    ls -la
else
    echo "❌ Папка /root/12G не найдена"
fi

# Проверяем package.json
echo ""
echo "📄 package.json:"
if [ -f "package.json" ]; then
    echo "✅ package.json найден"
    echo "Размер: $(ls -lh package.json | awk '{print $5}')"
    echo "Последние изменения: $(ls -la package.json | awk '{print $6, $7, $8}')"
    
    # Проверяем версию baileys в package.json
    if grep -q '"@whiskeysockets/baileys"' package.json; then
        echo "✅ @whiskeysockets/baileys найден в package.json"
        grep '"@whiskeysockets/baileys"' package.json
    else
        echo "❌ @whiskeysockets/baileys НЕ найден в package.json"
    fi
else
    echo "❌ package.json не найден"
fi

# Проверяем node_modules
echo ""
echo "📦 node_modules:"
if [ -d "node_modules" ]; then
    echo "✅ node_modules найден"
    echo "Размер: $(du -sh node_modules 2>/dev/null || echo 'неизвестно')"
    
    # Проверяем baileys
    if [ -d "node_modules/@whiskeysockets/baileys" ]; then
        echo "✅ @whiskeysockets/baileys установлен"
        ls -la node_modules/@whiskeysockets/baileys/package.json
        echo "Версия: $(cat node_modules/@whiskeysockets/baileys/package.json | grep '"version"' | cut -d'"' -f4)"
    else
        echo "❌ @whiskeysockets/baileys НЕ установлен"
    fi
    
    if [ -d "node_modules/baileys" ]; then
        echo "✅ baileys установлен"
        ls -la node_modules/baileys/package.json
        echo "Версия: $(cat node_modules/baileys/package.json | grep '"version"' | cut -d'"' -f4)"
    else
        echo "❌ baileys НЕ установлен"
    fi
else
    echo "❌ node_modules не найден"
fi

# Проверяем PM2
echo ""
echo "📦 PM2:"
if command -v pm2 &> /dev/null; then
    echo "✅ PM2 установлен"
    pm2 --version
    echo ""
    echo "📊 Статус PM2:"
    pm2 list
else
    echo "❌ PM2 не установлен"
fi

# Проверяем права доступа
echo ""
echo "🔐 Права доступа:"
ls -la | head -10

# Проверяем свободное место
echo ""
echo "💾 Дисковое пространство:"
df -h

# Проверяем память
echo ""
echo "🧠 Память:"
free -h

# Проверяем процессы
echo ""
echo "🔄 Активные процессы Node.js:"
ps aux | grep node | grep -v grep

echo ""
echo "🔍 ДИАГНОСТИКА ЗАВЕРШЕНА"
echo "======================="
