@echo off
echo 🔧 Исправление уязвимостей пакетов...

echo 📋 Проверка текущих уязвимостей...
npm audit

echo 🔄 Исправление безопасных уязвимостей...
npm audit fix

echo ⚠️ Принудительное исправление (может сломать код)...
npm audit fix --force

echo 📦 Обновление критических пакетов...
npm update axios
npm update @whiskeysockets/baileys
npm update uuid

echo 🧹 Очистка кэша...
npm cache clean --force

echo ✅ Проверка результата...
npm audit

echo.
echo Если остались уязвимости, нужно обновить package.json вручную
pause
