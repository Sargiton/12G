# Оптимизированный запуск WhatsApp бота для Windows
# Автор: DarkCore
# Версия: 2.0

Write-Host "🚀 Запуск оптимизированного WhatsApp бота..." -ForegroundColor Cyan

# Проверка наличия Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js найден: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js не найден. Установите Node.js 16+" -ForegroundColor Red
    exit 1
}

# Проверка версии Node.js
$majorVersion = (node --version).Split('.')[0].TrimStart('v')
if ([int]$majorVersion -lt 16) {
    Write-Host "❌ Требуется Node.js версии 16 или выше. Текущая версия: $(node --version)" -ForegroundColor Red
    exit 1
}

# Создание директорий
$directories = @("logs", "tmp", "storage\media-cache")
foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "📁 Создана директория: $dir" -ForegroundColor Yellow
    }
}

# Очистка старых логов (старше 7 дней)
$cutoffDate = (Get-Date).AddDays(-7)
Get-ChildItem -Path "logs" -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoffDate } | Remove-Item -Force

# Настройка переменных окружения
$env:NODE_ENV = "production"
$env:NODE_OPTIONS = "--max-old-space-size=1024 --expose-gc --optimize-for-size"
$env:UV_THREADPOOL_SIZE = "4"
$env:REDIS_URL = if ($env:REDIS_URL) { $env:REDIS_URL } else { "redis://localhost:6379" }

# Проверка Redis (опционально)
try {
    $redisTest = redis-cli ping 2>$null
    if ($redisTest -eq "PONG") {
        Write-Host "✅ Redis подключен" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Redis недоступен, используется только NodeCache" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Redis не установлен, используется только NodeCache" -ForegroundColor Yellow
}

# Установка зависимостей если нужно
if (!(Test-Path "node_modules")) {
    Write-Host "📦 Установка зависимостей..." -ForegroundColor Yellow
    npm install
}

# Проверка PM2
try {
    $pm2Version = pm2 --version
    Write-Host "🔄 Запуск через PM2..." -ForegroundColor Cyan
    
    # Остановка существующих процессов
    pm2 stop all 2>$null
    pm2 delete all 2>$null
    
    # Запуск с новой конфигурацией
    pm2 start ecosystem.config.js
    
    # Сохранение конфигурации PM2
    pm2 save
    
    Write-Host "✅ Бот запущен через PM2" -ForegroundColor Green
    Write-Host "📊 Мониторинг: pm2 monit" -ForegroundColor Cyan
    Write-Host "📋 Логи: pm2 logs" -ForegroundColor Cyan
    Write-Host "🛑 Остановка: pm2 stop all" -ForegroundColor Cyan
    
} catch {
    Write-Host "🔄 Запуск напрямую через Node.js..." -ForegroundColor Cyan
    
    # Запуск бота
    node --max-old-space-size=1024 --expose-gc --optimize-for-size index.js
}

Write-Host "🎉 Запуск завершен!" -ForegroundColor Green 