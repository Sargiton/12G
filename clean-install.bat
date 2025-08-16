@echo off
echo 🧹 Полная очистка и переустановка пакетов...

echo 📋 Остановка всех процессов...
pm2 stop all 2>nul
pm2 delete all 2>nul

echo 🗑️ Удаление старых файлов...
rmdir /s /q node_modules 2>nul
del package-lock.json 2>nul
del yarn.lock 2>nul

echo 🧹 Очистка кэша...
npm cache clean --force
npm cache verify

echo 📦 Установка зависимостей...
npm install --no-optional --production=false

echo 🔧 Исправление уязвимостей...
npm audit fix --force

echo ✅ Проверка результата...
npm audit
npm outdated

echo.
echo 🎉 Установка завершена!
echo 📋 Для запуска: pm2 start ecosystem-simple.config.cjs
pause
