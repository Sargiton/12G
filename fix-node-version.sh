#!/bin/bash

echo "🔧 ПРОВЕРКА И ИСПРАВЛЕНИЕ ВЕРСИИ NODE.JS"
echo "========================================"

cd /root/12G

echo "📋 Текущие версии:"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

echo ""
echo "📋 Проверяем совместимость..."

# Проверяем, поддерживает ли текущая версия все функции
echo "🔍 Проверяем поддержку ES модулей..."
node -e "
console.log('✅ Node.js версия:', process.version);
console.log('✅ Поддержка ES модулей:', typeof import !== 'undefined');
console.log('✅ Поддержка top-level await:', (async () => { try { await Promise.resolve(); return true; } catch { return false; } })());
"

echo ""
echo "📋 Проверяем package.json..."
echo "🔍 Type модуля: $(grep '"type"' package.json)"

echo ""
echo "📋 Тестируем основные импорты..."

# Тестируем импорты по очереди
echo "🔍 Тест импорта baileys..."
node -e "
try {
  import('baileys').then(() => console.log('✅ baileys - OK')).catch(e => console.log('❌ baileys:', e.message));
} catch (e) {
  console.log('❌ Ошибка импорта baileys:', e.message);
}
"

echo "🔍 Тест импорта cheerio..."
node -e "
try {
  import('cheerio').then(() => console.log('✅ cheerio - OK')).catch(e => console.log('❌ cheerio:', e.message));
} catch (e) {
  console.log('❌ Ошибка импорта cheerio:', e.message);
}
"

echo ""
echo "📋 Проверяем проблемные файлы..."

# Проверяем файлы, которые могут вызывать проблемы
for file in lib/cache.js lib/queue.js lib/pluginManager.js lib/monitor.js; do
    if [ -f "$file" ]; then
        echo "🔍 Проверяем $file..."
        if node -c "$file" 2>&1 | grep -q "Unexpected token"; then
            echo "❌ Ошибка в $file"
            echo "Содержимое первых строк:"
            head -5 "$file"
        else
            echo "✅ $file - OK"
        fi
    fi
done

echo ""
echo "📋 РЕКОМЕНДАЦИИ:"

# Проверяем версию Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt "18" ]; then
    echo "⚠️  Рекомендуется обновить Node.js до версии 18+"
    echo "🔧 Команда для обновления:"
    echo "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "sudo apt-get install -y nodejs"
elif [ "$NODE_VERSION" -lt "20" ]; then
    echo "⚠️  Рекомендуется обновить Node.js до версии 20+"
    echo "🔧 Команда для обновления:"
    echo "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "sudo apt-get install -y nodejs"
else
    echo "✅ Версия Node.js подходящая"
fi

echo ""
echo "📋 Если проблема в версии, попробуйте:"
echo "1. Обновить Node.js до версии 20+"
echo "2. Переустановить зависимости: npm install"
echo "3. Очистить кэш: npm cache clean --force"

echo ""
echo "✅ ПРОВЕРКА ЗАВЕРШЕНА"
