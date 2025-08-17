#!/bin/bash

echo "🔧 ПРИНУДИТЕЛЬНОЕ ИСПРАВЛЕНИЕ handler.js"

# Останавливаем бота
echo "🛑 Останавливаем бота..."
pm2 stop whatsapp-old 2>/dev/null || true

# Проверяем файл
echo "🔍 Проверяем handler.js..."
if [ ! -f "123/handler.js" ]; then
    echo "❌ Файл 123/handler.js не найден!"
    exit 1
fi

# Создаем резервную копию
echo "💾 Создаем резервную копию..."
cp 123/handler.js 123/handler.js.backup

# Исправляем проблемную строку принудительно
echo "🔧 Исправляем проблемную строку..."
sed -i '454s/.*/\/\/ Закомментировано для исправления ошибки isOwner/' 123/handler.js
sed -i '455s/.*/\/\/ if (isOwner && m.sender) {/' 123/handler.js
sed -i '456s/.*/\/\/   this.reply(m.chat, `⚠️ \*System Notice:\*\\n\\nA critical update is available for this WhatsApp bot. Due to recent changes in the WhatsApp API, it is strongly recommended to update the bot as soon as possible to avoid service interruptions or loss of functionality. Please update your bot installation to the latest version.\\n\\nFor update instructions, refer to the official documentation or contact your technical provider.`, m)/' 123/handler.js
sed -i '457s/.*/\/\/ }/' 123/handler.js

# Проверяем результат
echo "✅ Проверяем результат..."
if grep -q "// Закомментировано для исправления ошибки isOwner" 123/handler.js; then
    echo "✅ Исправление применено успешно!"
else
    echo "❌ Исправление не применено, пробуем другой способ..."
    
    # Альтернативный способ - удаляем проблемные строки
    echo "🔧 Удаляем проблемные строки..."
    sed -i '454,457d' 123/handler.js
    echo "✅ Проблемные строки удалены!"
fi

# Проверяем что ошибка исправлена
echo "🔍 Проверяем что ошибка исправлена..."
if grep -q "if (isOwner && m.sender)" 123/handler.js; then
    echo "❌ Проблемная строка все еще найдена!"
    # Удаляем все строки с isOwner
    sed -i '/if (isOwner && m.sender)/d' 123/handler.js
    sed -i '/this.reply(m.chat, `⚠️ \*System Notice:\*/d' 123/handler.js
    echo "✅ Все проблемные строки удалены!"
else
    echo "✅ Проблемная строка не найдена!"
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
echo "✅ Принудительное исправление завершено!"
echo "🎯 Теперь попробуйте команду 'меню'"
