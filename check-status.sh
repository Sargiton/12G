#!/bin/bash

echo "🔍 ПРОВЕРКА СТАТУСА БОТА"

echo "📊 Статус PM2 процессов:"
pm2 list

echo ""
echo "📁 Проверка файлов:"
echo "handler.js:"
if [ -f "123/handler.js" ]; then
    echo "✅ Найден"
    grep -n "isOwner" 123/handler.js | head -3
else
    echo "❌ Не найден"
fi

echo ""
echo "main-menu18.js:"
if [ -f "123/plugins/main-menu18.js" ]; then
    echo "✅ Найден"
    grep -n "sendFile\|reply" 123/plugins/main-menu18.js | head -3
else
    echo "❌ Не найден"
fi

echo ""
echo "main-menu1.js:"
if [ -f "123/plugins/main-menu1.js" ]; then
    echo "✅ Найден"
    grep -n "sendFile\|reply" 123/plugins/main-menu1.js | head -3
else
    echo "❌ Не найден"
fi

echo ""
echo "📁 Проверка папок:"
echo "tmp:"
if [ -d "123/tmp" ]; then
    echo "✅ Найдена"
    ls -la 123/tmp/ | head -5
else
    echo "❌ Не найдена"
fi

echo ""
echo "🔍 Последние логи ошибок:"
pm2 logs whatsapp-old --err --lines 5 2>/dev/null || echo "Логи недоступны"

echo ""
echo "🎯 Рекомендации:"
echo "1. Если есть ошибки - запустите: curl -s https://raw.githubusercontent.com/Sargiton/12G/master/diagnose-and-fix.sh | bash"
echo "2. Если бот не запущен - запустите: pm2 start 123/ecosystem-old.config.cjs"
echo "3. Для полной перезагрузки: pm2 restart whatsapp-old"
