#!/bin/bash

echo "🔍 ДИАГНОСТИКА ТОЧНОЙ ОШИБКИ В HANDLER.JS"
echo "=========================================="

cd /root/12G

echo "🛑 Останавливаем боты..."
pm2 stop all

echo ""
echo "🔍 Проверяем строки вокруг 506..."

# Показываем строки вокруг 506
echo "📋 Строки 500-510:"
sed -n '500,510p' handler.js

echo ""
echo "📋 Строки 490-500:"
sed -n '490,500p' handler.js

echo ""
echo "🔍 Ищем незакрытые блоки..."

# Ищем незакрытые скобки и блоки
echo "📋 Проверяем баланс скобок:"
grep -n "{" handler.js | tail -10
grep -n "}" handler.js | tail -10

echo ""
echo "🔍 Проверяем функцию перед строкой 506..."

# Находим последнюю функцию перед строкой 506
echo "📋 Последняя функция перед 506:"
grep -n "function\|export" handler.js | grep -B5 -A5 "506"

echo ""
echo "🔧 Создаем минимальную версию handler.js..."

# Создаем минимальную версию для тестирования
cat > handler-minimal.js << 'EOF'
import { generateWAMessageFromContent } from "@whiskeysockets/baileys" 
import { smsg } from './lib/simple.js'
import { format } from 'util'
import { fileURLToPath } from 'url'
import path, { join } from 'path'
import { unwatchFile, watchFile } from 'fs'
import chalk from 'chalk'   
import fetch from 'node-fetch' 
import ws from 'ws'
import './plugins/_content.js'

const { proto } = (await import('@whiskeysockets/baileys')).default
const isNumber = x => typeof x === 'number' && !isNaN(x)
const delay = ms => isNumber(ms) && new Promise(resolve => setTimeout(function () {
clearTimeout(this)
resolve()
}, ms))

export async function handler(chatUpdate) {
  console.log('Handler function called');
  return;
}

export async function participantsUpdate({ id, participants, action }) {
  console.log('Participants update called');
  return;
}

export async function groupsUpdate(groupsUpdate) {
  console.log('Groups update called');
  return;
}

export async function callUpdate(callUpdate) {
  console.log('Call update called');
  return;
}

export async function deleteUpdate(message) {
  console.log('Delete update called');
  return;
}
EOF

echo ""
echo "🔍 Проверяем минимальную версию..."
if node -c handler-minimal.js; then
    echo "✅ Минимальная версия работает"
else
    echo "❌ Минимальная версия тоже не работает"
fi

echo ""
echo "🔍 Проверяем импорты..."
node -e "
try {
  import('./lib/simple.js').then(() => console.log('✅ simple.js - OK')).catch(e => console.log('❌ simple.js:', e.message));
} catch (e) {
  console.log('❌ Ошибка импорта simple.js:', e.message);
}
"

echo ""
echo "✅ ДИАГНОСТИКА ЗАВЕРШЕНА"
