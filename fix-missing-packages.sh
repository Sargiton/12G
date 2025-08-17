#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ ОТСУТСТВУЮЩИХ ПАКЕТОВ"
echo "=================================="

# Переходим в директорию
cd /root/12G

echo "📁 Текущая директория: $(pwd)"

# Переименовываем проблемные плагины
echo "🚫 Отключаем проблемные плагины..."

# Плагины с отсутствующими пакетами
problematic_plugins=(
    "dl-facebook.js"
    "dl-playstore.js" 
    "info.js"
    "prueba-filterGB.js"
    "prueba-wattpad.js"
    "prueba_apk.js"
    "search-playstore.js"
)

for plugin in "${problematic_plugins[@]}"; do
    if [ -f "plugins/$plugin" ]; then
        mv "plugins/$plugin" "plugins/$plugin.disabled"
        echo "✅ Отключен: $plugin"
    fi
done

# Устанавливаем недостающие пакеты
echo "📦 Устанавливаем недостающие пакеты..."
npm install --save \
    ruhend-scraper \
    google-play-scraper \
    node-os-utils \
    @vitalets/google-translate-api \
    aptoide-scraper

echo "✅ Все исправлено!"
echo "🎯 Теперь можно запускать бота"
