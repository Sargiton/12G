#!/bin/bash

echo "🔍 ДИАГНОСТИКА И ИСПРАВЛЕНИЕ БОТА"

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Проверяем текущую директорию
echo "📁 Текущая директория: $(pwd)"

# Проверяем содержимое папки 123
echo "📋 Проверяем содержимое папки 123..."
ls -la 123/ 2>/dev/null || echo "Папка 123 не найдена"

# Проверяем handler.js
echo "🔍 Проверяем handler.js..."
if [ -f "123/handler.js" ]; then
    echo "✅ handler.js найден"
    grep -n "isOwner" 123/handler.js | head -5
else
    echo "❌ handler.js не найден"
fi

# Создаем папки если их нет
echo "📁 Создаем необходимые папки..."
mkdir -p 123/tmp
mkdir -p 123/logs
chmod 755 123/tmp
chmod 755 123/logs

# Очищаем временные файлы
echo "🧹 Очищаем временные файлы..."
rm -f 123/tmp/*.jpg
rm -f 123/tmp/*.png
rm -f 123/tmp/*.mp4
rm -f 123/tmp/*.webp

# Проверяем и исправляем handler.js
echo "🔧 Проверяем и исправляем handler.js..."
if [ -f "123/handler.js" ]; then
    # Ищем проблемную строку
    if grep -q "if (isOwner && m.sender)" 123/handler.js; then
        echo "🔍 Найдена проблемная строка, исправляем..."
        sed -i 's/if (isOwner && m.sender)/\/\/ if (isOwner && m.sender)/g' 123/handler.js
        sed -i 's/this.reply(m.chat, `⚠️ \*System Notice:\*\/\/ this.reply(m.chat, `⚠️ \*System Notice:\*/g' 123/handler.js
        echo "✅ handler.js исправлен"
    else
        echo "✅ handler.js уже исправлен"
    fi
fi

# Проверяем и исправляем main-menu18.js
echo "🔧 Проверяем и исправляем main-menu18.js..."
if [ -f "123/plugins/main-menu18.js" ]; then
    if grep -q "conn.sendFile" 123/plugins/main-menu18.js; then
        echo "🔍 Найдена проблема с изображением, исправляем..."
        # Заменяем sendFile на reply
        sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu18.js
        # Убираем строку с img
        sed -i '/let img =/d' 123/plugins/main-menu18.js
        # Убираем fkontak
        sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu18.js
        echo "✅ main-menu18.js исправлен"
    else
        echo "✅ main-menu18.js уже исправлен"
    fi
fi

# Проверяем и исправляем main-menu1.js
echo "🔧 Проверяем и исправляем main-menu1.js..."
if [ -f "123/plugins/main-menu1.js" ]; then
    if grep -q "conn.sendFile" 123/plugins/main-menu1.js; then
        echo "🔍 Найдена проблема с изображением, исправляем..."
        # Заменяем sendFile на reply
        sed -i 's/await conn.sendFile(m.chat, img, .*)/await m.reply(texto)/g' 123/plugins/main-menu1.js
        # Убираем строку с img
        sed -i '/let img =/d' 123/plugins/main-menu1.js
        # Убираем fkontak
        sed -i '/const fkontak = {/,/}/d' 123/plugins/main-menu1.js
        echo "✅ main-menu1.js исправлен"
    else
        echo "✅ main-menu1.js уже исправлен"
    fi
fi

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
pm2 logs whatsapp-old --lines 10

echo ""
echo "✅ Диагностика и исправления завершены!"
echo "🎯 Теперь попробуйте команду 'меню'"
