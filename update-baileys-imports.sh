#!/bin/bash

echo "🔄 Обновление импортов baileys..."
echo "=================================="

# Функция для замены в файле
replace_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "📝 Обновляем $file"
        
        # Заменяем импорты
        sed -i 's/@whiskeysockets\/baileys/baileys/g' "$file"
        
        # Заменяем типы в комментариях
        sed -i 's/import.*@whiskeysockets\/baileys.*/import.*baileys.*/g' "$file"
        sed -i 's/from.*@whiskeysockets\/baileys.*/from.*baileys.*/g' "$file"
        
        echo "✅ $file обновлен"
    fi
}

# Обновляем основные файлы
replace_in_file "index.js"
replace_in_file "handler.js"
replace_in_file "lib/simple.js"
replace_in_file "lib/store.js"
replace_in_file "lib/print.js"

# Обновляем плагины
for file in plugins/*.js; do
    if [ -f "$file" ]; then
        replace_in_file "$file"
    fi
done

# Обновляем package.json
if [ -f "package.json" ]; then
    echo "📝 Обновляем package.json"
    sed -i 's/"@whiskeysockets\/baileys": ".*"/"baileys": "latest"/g' package.json
    echo "✅ package.json обновлен"
fi

echo ""
echo "🎉 Все импорты baileys обновлены!"
echo "Теперь используйте: npm install"
