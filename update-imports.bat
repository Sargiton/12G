@echo off
echo 🔄 Обновление импортов baileys...

echo 📝 Обновление импортов в файлах...
powershell -Command "(Get-Content -Path '*.js' -Recurse -Encoding UTF8) -replace '@whiskeysockets/baileys', 'baileys' | Set-Content -Path '*.js' -Encoding UTF8"

echo 📝 Обновление импортов в lib/*.js...
powershell -Command "(Get-Content -Path 'lib/*.js' -Recurse -Encoding UTF8) -replace '@whiskeysockets/baileys', 'baileys' | Set-Content -Path 'lib/*.js' -Encoding UTF8"

echo 📝 Обновление импортов в plugins/*.js...
powershell -Command "(Get-Content -Path 'plugins/*.js' -Recurse -Encoding UTF8) -replace '@whiskeysockets/baileys', 'baileys' | Set-Content -Path 'plugins/*.js' -Encoding UTF8"

echo ✅ Импорты обновлены!
echo.
echo Теперь запустите: clean-install.bat
pause
