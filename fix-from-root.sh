#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ИЗ КОРНЕВОЙ ДИРЕКТОРИИ"

# Переходим в правильную директорию
echo "📁 Переходим в /root/12G..."
cd /root/12G

# Проверяем что мы в правильной папке
echo "📋 Проверяем содержимое..."
ls -la

# Останавливаем все процессы
echo "🛑 Останавливаем все процессы..."
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Проверяем файлы
echo "🔍 Проверяем файлы..."
if [ -f "123/handler.js" ]; then
    echo "✅ handler.js найден"
else
    echo "❌ handler.js не найден"
    exit 1
fi

if [ -f "123/ecosystem-old.config.cjs" ]; then
    echo "✅ ecosystem-old.config.cjs найден"
else
    echo "❌ ecosystem-old.config.cjs не найден"
    exit 1
fi

# Создаем папки
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

# Исправляем handler.js
echo "🔧 Исправляем handler.js..."
if grep -q "if (isOwner && m.sender)" 123/handler.js; then
    echo "🔍 Найдена проблемная строка, исправляем..."
    # Удаляем проблемные строки
    sed -i '/if (isOwner && m.sender)/d' 123/handler.js
    sed -i '/this.reply(m.chat, `⚠️ \*System Notice:\*/d' 123/handler.js
    echo "✅ handler.js исправлен"
else
    echo "✅ handler.js уже исправлен"
fi

# Исправляем main-menu18.js
echo "🔧 Исправляем main-menu18.js..."
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

# Исправляем main-menu1.js
echo "🔧 Исправляем main-menu1.js..."
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
pm2 logs whatsapp-old --lines 5

echo ""
echo "✅ Исправления завершены!"
echo "🎯 Теперь попробуйте команду 'меню'"
