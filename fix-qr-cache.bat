@echo off
echo 🔧 Исправление проблемы с QR кэшем...

echo 📋 Остановка всех процессов...
pm2 stop all 2>nul
pm2 delete all 2>nul

echo 🧹 Очистка QR кэша...
node clear-qr-cache.js

echo 🗑️ Очистка временных файлов...
rmdir /s /q tmp 2>nul
mkdir tmp

echo 🗑️ Удаление QR файлов...
del qr.png 2>nul
del qr.jpg 2>nul
del *.png 2>nul

echo 🧹 Очистка кэша npm...
npm cache clean --force

echo 🔄 Перезапуск бота...
pm2 start ecosystem-simple.config.cjs

echo ✅ Готово! Теперь QR код будет генерироваться заново.
echo 📋 Проверьте логи: pm2 logs
pause
