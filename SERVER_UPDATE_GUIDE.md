# 🚀 Инструкция по обновлению бота на сервере

## 📋 Что нужно сделать на сервере

### 1. Подключение к серверу
```bash
ssh ваш_пользователь@ваш_сервер
cd /путь/к/боту
```

### 2. Остановка текущих процессов
```bash
# Остановить все процессы Node.js
pm2 stop all
# или
pm2 stop whatsapp-bot
pm2 stop telegram-bot
```

### 3. Резервное копирование (рекомендуется)
```bash
# Создать резервную копию
cp -r /путь/к/боту /путь/к/боту_backup_$(date +%Y%m%d_%H%M%S)
```

### 4. Обновление с GitHub
```bash
# Перейти в папку бота
cd /путь/к/боту

# Сохранить текущие изменения (если есть)
git stash

# Получить последние обновления
git pull origin master

# Если есть конфликты, решить их
git status
```

### 5. Установка новых зависимостей
```bash
# Установить новые пакеты
npm install

# Проверить, что все установилось
npm list --depth=0
```

### 6. Настройка Redis (опционально, но рекомендуется)
```bash
# Установить Redis (Ubuntu/Debian)
sudo apt update
sudo apt install redis-server

# Запустить Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Проверить статус
redis-cli ping
# Должен ответить: PONG
```

### 7. Включение Redis в боте
```bash
# Отредактировать файлы, убрав временные отключения
nano lib/cache.js
nano lib/queue.js

# Удалить эти строки:
# console.log('⚠️ Redis temporarily disabled for local development');
# this.redisClient = null;
# return;
```

### 8. Запуск ботов через PM2
```bash
# Запустить WhatsApp бота
pm2 start ecosystem.config.js --only whatsapp-bot

# Запустить Telegram бота
pm2 start ecosystem.config.js --only telegram-bot

# Проверить статус
pm2 list
pm2 logs
```

### 9. Проверка работы
```bash
# Проверить логи
pm2 logs whatsapp-bot --lines 50
pm2 logs telegram-bot --lines 50

# Проверить статус
pm2 show whatsapp-bot
pm2 show telegram-bot
```

## 🔧 Альтернативный способ запуска (без PM2)

### Если PM2 не установлен:
```bash
# Установить PM2
npm install -g pm2

# Или запустить напрямую
node index.js &
node telegram-bot.cjs &
```

## 📱 Тестирование новых команд

После запуска протестируйте в Telegram:

1. **`/help_me`** - помощник по решению проблем
2. **`/quick_check`** - быстрая диагностика
3. **`/smart_qr`** - умный QR-код
4. **`/fix_bot`** - автоматическое исправление
5. **`/auto_update`** - автоматическое обновление

## 🚨 Возможные проблемы и решения

### Проблема: Redis не подключается
```bash
# Решение: временно отключить Redis
# В файлах lib/cache.js и lib/queue.js оставить временные отключения
```

### Проблема: Конфликты Git
```bash
# Решение: принудительное обновление
git fetch origin
git reset --hard origin/master
```

### Проблема: Не хватает памяти
```bash
# Решение: увеличить лимиты в ecosystem.config.js
# max_memory_restart: '2G'
```

### Проблема: Модули не найдены
```bash
# Решение: переустановить зависимости
rm -rf node_modules package-lock.json
npm install
```

## 📊 Мониторинг после обновления

### Проверить производительность:
```bash
# В Telegram отправьте:
/quick_check
```

### Проверить логи:
```bash
pm2 logs --lines 100
```

### Проверить использование ресурсов:
```bash
pm2 monit
```

## 🔄 Автоматические обновления

### Настроить cron для автоматических обновлений:
```bash
# Открыть crontab
crontab -e

# Добавить строку (обновление каждый день в 3:00)
0 3 * * * cd /путь/к/боту && git pull origin master && npm install && pm2 restart all
```

## ✅ Чек-лист завершения

- [ ] Боты запущены и работают
- [ ] Новые команды в Telegram отвечают
- [ ] Логи не содержат критических ошибок
- [ ] Производительность улучшилась
- [ ] Redis работает (если включен)
- [ ] Автоматические обновления настроены

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи: `pm2 logs`
2. Проверьте статус: `pm2 list`
3. Перезапустите: `pm2 restart all`
4. Используйте команду `/fix_bot` в Telegram

---

# 🖥️ СПЕЦИАЛЬНАЯ ИНСТРУКЦИЯ ДЛЯ СЕРВЕРА С 1 ГБ RAM

## ⚠️ Важно! Для серверов с ограниченной памятью

### 1. Проверка памяти перед запуском
```bash
# Проверить доступную память
free -h

# Если свободно меньше 200MB, очистить систему
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### 2. Запуск с оптимизацией для низкой RAM
```bash
# Сделать скрипт исполняемым
chmod +x start-low-ram.sh

# Запустить оптимизированный скрипт
./start-low-ram.sh
```

### 3. Мониторинг памяти
```bash
# Запустить мониторинг памяти
chmod +x monitor-memory.sh
./monitor-memory.sh
```

### 4. Настройка swap (если нет)
```bash
# Создать swap файл 1GB
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Добавить в автозапуск
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 5. Оптимизация системы
```bash
# Отключить ненужные сервисы
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# Очистить логи
sudo journalctl --vacuum-time=3d
```

### 6. Автоматическая очистка памяти
```bash
# Добавить в crontab
crontab -e

# Добавить строки:
# Каждые 30 минут очищать кэш
*/30 * * * * sync && echo 3 > /proc/sys/vm/drop_caches
# Каждые 2 часа перезапускать боты
0 */2 * * * pm2 restart all
```

## 🚨 Критические настройки для 1 ГБ RAM

### Ограничения памяти:
- **WhatsApp бот**: максимум 512MB
- **Telegram бот**: максимум 256MB
- **Общий лимит**: 768MB (оставляем 256MB для системы)

### Автоматические действия:
- Перезапуск при использовании >90% памяти
- Очистка кэша каждые 30 минут
- Перезапуск ботов каждые 2 часа

### Мониторинг:
- Проверка памяти каждые 5 минут
- Автоматические уведомления при критическом использовании
- Логирование всех перезапусков

---

**Удачного обновления! 🚀**
