# 🚀 Руководство по обновлению сервера

## 📋 Быстрое обновление

### 1. Остановите все процессы
```bash
pm2 stop all
pm2 delete all
```

### 2. Обновите код
```bash
git pull origin master
npm install
```

### 3. Исправьте ошибки Redis и импортов
```bash
# Очистите кэш Node.js
rm -rf node_modules/.cache
npm cache clean --force

# Переустановите зависимости
rm -rf node_modules package-lock.json
npm install
```

### 4. Запустите с простой конфигурацией
```bash
pm2 start ecosystem-simple.config.cjs
```

### 5. Проверьте статус
```bash
pm2 list
pm2 logs
```

## 🔧 Исправление ошибок

### ❌ Ошибка: SyntaxError в index-simple.js
**Проблема:** `exists` не экспортируется из `fs/promises`

**Решение:** ✅ Исправлено в коде - убран импорт `exists`

### ❌ Ошибка: Redis connection refused
**Проблема:** Бот пытается подключиться к Redis

**Решение:** ✅ Исправлено - Redis отключен, используется только NodeCache

### ❌ Ошибка: Telegram 409 Conflict
**Проблема:** Несколько экземпляров бота запущены

**Решение:** 
```bash
# Остановите все процессы
pm2 stop all
pm2 delete all

# Запустите заново
pm2 start ecosystem-simple.config.cjs
```

## 📊 Мониторинг

### Проверка логов
```bash
pm2 logs whatsapp-bot
pm2 logs telegram-bot
```

### Проверка статуса
```bash
pm2 list
pm2 monit
```

### Перезапуск при ошибках
```bash
pm2 restart whatsapp-bot
pm2 restart telegram-bot
```

## 🎯 Команды Telegram бота

После исправления ошибок команды должны работать:

- `/performance` - статистика производительности
- `/smart_qr` - умный QR-код
- `/fix_bot` - исправление бота
- `/status` - статус системы

## ⚠️ Важные замечания

1. **Redis не нужен** - бот работает без Redis
2. **Память ограничена** - 400MB для WhatsApp, 200MB для Telegram
3. **Автоматический перезапуск** - PM2 перезапустит бота при ошибках
4. **Логи сохраняются** - проверяйте логи при проблемах

## 🆘 Если проблемы остаются

1. Проверьте логи: `pm2 logs`
2. Перезапустите: `pm2 restart all`
3. Очистите кэш: `npm cache clean --force`
4. Переустановите: `rm -rf node_modules && npm install`
