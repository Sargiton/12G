# 🚀 Руководство по обновлению сервера

## 🚨 КРИТИЧЕСКИЕ ОШИБКИ - НЕМЕДЛЕННОЕ ИСПРАВЛЕНИЕ

### ❌ Проблемы, которые вызывают зависание:

1. **SyntaxError в WhatsApp** - ошибка парсинга модулей
2. **Telegram 409 Conflict** - несколько экземпляров бота
3. **Redis ошибки** - бот пытается подключиться к Redis
4. **Старый QR код** - кэш не обновляется

### 🔧 НЕМЕДЛЕННЫЕ ДЕЙСТВИЯ:

```bash
# 1. ОСТАНОВИТЬ ВСЕ ПРОЦЕССЫ
pm2 stop all
pm2 delete all
pkill -f node
pkill -f pm2

# 2. ОЧИСТИТЬ КЭШ И ПЕРЕМЕННЫЕ
rm -rf node_modules/.cache
rm -rf tmp/*
rm -rf storage/data/cache/*
npm cache clean --force

# 3. ПЕРЕУСТАНОВИТЬ ЗАВИСИМОСТИ
rm -rf node_modules package-lock.json
npm install

# 4. ОБНОВИТЬ КОД
git pull origin master

# 5. ЗАПУСТИТЬ С ПРОСТОЙ КОНФИГУРАЦИЕЙ
pm2 start ecosystem-simple.config.cjs
```

### 📋 Быстрое обновление

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
**Проблема:** Бот пытается подключиться к Redis, которого нет

**Решение:** ✅ Исправлено - Redis полностью отключен

### ❌ Ошибка: Telegram 409 Conflict
**Проблема:** Несколько экземпляров бота запущены

**Решение:** 
```bash
# Остановить все процессы
pm2 stop all
pm2 delete all
pkill -f node

# Запустить только один экземпляр
pm2 start ecosystem-simple.config.cjs
```

### ❌ Ошибка: Старый QR код
**Проблема:** Бот отправляет старый QR код вместо нового

**Решение:**
```bash
# 1. Используйте команду очистки QR кэша
.clearqrcache

# 2. Если команда не работает:
pm2 stop all
pm2 delete all

# 3. Очистите кэш
node clear-qr-cache.js

# 4. Очистите временные файлы
rm -rf tmp/*
rm -rf storage/data/cache/*

# 5. Перезапустите
pm2 start ecosystem-simple.config.cjs
```

**Быстрое решение:**
```bash
# Windows
fix-qr-cache.bat

# Linux/Mac
./fix-qr-cache.sh
```

**Причины проблемы:**
- QR код кэшируется в памяти
- Файлы QR кодов не удаляются
- Кэш не очищается при перезапуске
**Проблема:** Кэш QR кодов не обновляется

**Решение:** 
```bash
# Использовать команду очистки кэша
.clearqrcache
# или
.очиститьqr
```

## 🆕 Новые команды

### 🧹 Очистка кэша QR кодов
```
.clearqrcache - Очистить кэш QR кодов (только владелец)
.очиститьqr - Альтернативная команда
.qrclear - Короткая команда
```

### 🤖 Управление сервером через Telegram
```
.servermenu - Меню управления сервером
.stopserver - Остановить сервер
.startserver - Запустить сервер
.restartserver - Перезапустить сервер
.serverstatus - Статус сервера
.serverlogs - Логи сервера
.fixserver - Исправить проблемы сервера
.updatepackages - Обновить пакеты
```

### 🚨 Экстренные команды
```
.emergencystop - Экстренная остановка сервера
.emergencyrestart - Экстренный перезапуск
.killall - Принудительное завершение всех процессов
.systeminfo - Информация о системе
```

### 🇷🇺 Русские команды
```
.серверменю - Меню управления сервером
.остановитьсервер - Остановить сервер
.запуститьсервер - Запустить сервер
.перезапуститьсервер - Перезапустить сервер
.статуссервера - Статус сервера
.логисервера - Логи сервера
.исправитьсервер - Исправить проблемы сервера
.обновитьпакеты - Обновить пакеты
.экстреннаяостановка - Экстренная остановка
.экстренныйперезапуск - Экстренный перезапуск
.убитьвсе - Принудительное завершение
.инфосистемы - Информация о системе
```

## 📊 Мониторинг

### Проверка состояния системы
```bash
# Статус процессов
pm2 list

# Логи в реальном времени
pm2 logs

# Статистика использования ресурсов
pm2 monit
```

### Проверка кэша
```bash
# В боте
.cachestats - Статистика кэша
.queuestats - Статистика очередей
```

## 🔄 Автоматическое обновление

### Скрипт для автоматического обновления
```bash
#!/bin/bash
echo "🔄 Обновление бота..."

# Остановка процессов
pm2 stop all
pm2 delete all

# Обновление кода
git pull origin master

# Переустановка зависимостей
rm -rf node_modules package-lock.json
npm install

# Очистка кэша
rm -rf node_modules/.cache
npm cache clean --force

# Запуск
pm2 start ecosystem-simple.config.cjs

echo "✅ Обновление завершено!"
```

## 🚨 Экстренные действия

### Если бот полностью завис:
```bash
# Принудительная остановка
sudo pkill -f node
sudo pkill -f pm2

# Очистка всех процессов
sudo systemctl restart pm2-root

# Перезапуск
pm2 start ecosystem-simple.config.cjs
```

### Если не работает WhatsApp:
```bash
# Очистка сессии
rm -rf LynxSession/*
rm -rf BackupSession/*

# Перезапуск
pm2 restart all
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `pm2 logs`
2. Очистите кэш: `.clearqrcache`
3. Перезапустите: `pm2 restart all`
4. Если не помогает - полная переустановка по инструкции выше
