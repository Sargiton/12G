@echo off
echo 🔧 ИСПРАВЛЕНИЕ ПРОБЛЕМ СЕРВЕРА
echo ================================

REM 1. Остановка всех процессов
echo 🛑 Останавливаю все процессы...
pm2 stop all
pm2 delete all
taskkill /f /im node.exe 2>nul
taskkill /f /im pm2.exe 2>nul

REM 2. Очистка кэша и временных файлов
echo 🧹 Очищаю кэш и временные файлы...
if exist node_modules\.cache rmdir /s /q node_modules\.cache
if exist tmp rmdir /s /q tmp
if exist storage\data\cache rmdir /s /q storage\data\cache
npm cache clean --force

REM 3. Удаление устаревших зависимостей
echo 🗑️ Удаляю устаревшие зависимости...
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json

REM 4. Обновление кода
echo 📥 Обновляю код с GitHub...
git pull origin master

REM 5. Переустановка зависимостей
echo 📦 Переустанавливаю зависимости...
npm install

REM 6. Исправление уязвимостей
echo 🔒 Исправляю уязвимости...
npm audit fix --force
npm update

REM 7. Запуск с простой конфигурацией
echo 🚀 Запускаю боты...
pm2 start ecosystem-simple.config.cjs

REM 8. Проверка статуса
echo 📊 Проверяю статус...
timeout /t 5 /nobreak >nul
pm2 list

echo ✅ Исправление завершено!
echo 📋 Проверьте логи: pm2 logs
pause
