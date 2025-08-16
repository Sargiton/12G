@echo off
echo 🛑 Остановка всех ботов...

echo 📋 Остановка PM2 процессов...
pm2 stop all
pm2 delete all

echo 🔪 Принудительная остановка Node.js процессов...
taskkill /f /im node.exe 2>nul
taskkill /f /im pm2.exe 2>nul

echo 🧹 Очистка временных файлов...
rmdir /s /q tmp 2>nul
del /q tmp\* 2>nul

echo ✅ Все боты остановлены!
echo.
echo Для запуска используйте: pm2 start ecosystem-simple.config.cjs
pause
