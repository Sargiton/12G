@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🚀 ПОЛНОЕ ВОССТАНОВЛЕНИЕ ПРОЕКТА 12G
echo ======================================

REM 1. Проверяем текущую директорию
echo [INFO] Проверяем текущую директорию...
if exist "12G" (
    echo [WARNING] Папка 12G уже существует. Удаляем...
    rmdir /s /q 12G
)

REM 2. Клонируем проект с GitHub
echo [INFO] Клонируем проект с GitHub...
git clone https://github.com/Sargiton/12G.git
if errorlevel 1 (
    echo [ERROR] Ошибка клонирования проекта!
    pause
    exit /b 1
)

cd 12G

REM 3. Устанавливаем зависимости
echo [INFO] Устанавливаем зависимости...
call npm install
if errorlevel 1 (
    echo [ERROR] Ошибка установки зависимостей!
    pause
    exit /b 1
)

REM 4. Создаем .env файл
echo [INFO] Создаем .env файл...
echo NODE_OPTIONS="--max-old-space-size=512" > .env

REM 5. Очищаем старые сессии
echo [INFO] Очищаем старые сессии...
if exist "LynxSession" rmdir /s /q LynxSession
if exist "BackupSession" rmdir /s /q BackupSession
if exist "qr.png" del qr.png

REM 6. Создаем необходимые папки
echo [INFO] Создаем необходимые папки...
mkdir LynxSession
mkdir BackupSession
mkdir tmp
mkdir database\users
mkdir database\chats
mkdir database\settings
mkdir database\msgs
mkdir database\sticker
mkdir database\stats

REM 7. Тестируем QR код
echo [INFO] Тестируем генерацию QR кода...
start /b node test-qr.js
timeout /t 10 /nobreak >nul

REM Проверяем, создался ли QR код
if exist "qr.png" (
    echo [SUCCESS] QR код успешно создан!
) else (
    echo [WARNING] QR код не создался, пробуем принудительную генерацию...
    start /b node force-qr.js
    timeout /t 5 /nobreak >nul
)

REM 8. Запускаем боты через PM2
echo [INFO] Запускаем боты через PM2...
pm2 stop all 2>nul
pm2 delete all 2>nul
pm2 start ecosystem-simple.config.cjs

REM 9. Проверяем статус
echo [INFO] Проверяем статус ботов...
timeout /t 3 /nobreak >nul
pm2 list

REM 10. Настраиваем автозапуск
echo [INFO] Настраиваем автозапуск PM2...
pm2 startup
pm2 save

echo.
echo 🎉 ВОССТАНОВЛЕНИЕ ЗАВЕРШЕНО!
echo ==============================
echo.
echo 📁 Проект восстановлен в: %CD%
echo 🤖 Боты запущены через PM2
echo.
echo 🔧 Полезные команды:
echo   pm2 list                    - Статус ботов
echo   pm2 logs                    - Логи ботов
echo   node force-qr.js            - Принудительная генерация QR
echo.
echo 📱 Проверьте QR код:
if exist "qr.png" (
    echo   ✅ QR код создан: qr.png
) else (
    echo   ⚠️  QR код не найден, запустите: node force-qr.js
)

echo [SUCCESS] Восстановление завершено успешно!
pause
