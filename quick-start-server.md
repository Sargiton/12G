# 🚀 Быстрый запуск сервера

## 📋 Подготовка

### 1. Подключение к серверу
```bash
ssh root@ваш_сервер_ip
```

### 2. Переход в корневую директорию
```bash
cd /root
```

## 🚀 Автоматическая настройка

### Запуск полной настройки
```bash
chmod +x server-setup.sh
./server-setup.sh
```

**Этот скрипт автоматически выполнит:**
- ✅ Обновление системы
- ✅ Установку Node.js 18
- ✅ Установку PM2
- ✅ Настройку SWAP (2GB)
- ✅ Оптимизацию памяти
- ✅ Клонирование проекта с GitHub
- ✅ Установку зависимостей
- ✅ Запуск ботов
- ✅ Настройку автозапуска

## 📊 Проверка работы

### Проверка памяти
```bash
free -h
```

### Проверка процессов
```bash
pm2 list
```

### Просмотр логов
```bash
pm2 logs
```

## 📱 Тестирование в Telegram

### Отправьте команды в Telegram бота:
```
.serverstatus
.clearqrcache
```

## 🔧 Полезные команды

### Перезапуск ботов
```bash
pm2 restart all
```

### Мониторинг системы
```bash
htop
```

### Просмотр логов мониторинга памяти
```bash
tail -f /var/log/memory-monitor.log
```

### Ручной перезапуск
```bash
/root/restart-bots.sh
```

## 🚨 Решение проблем

### Если боты не запускаются:
```bash
cd /root/12G
pm2 stop all
pm2 delete all
pm2 start ecosystem-simple.config.cjs
```

### Если проблемы с памятью:
```bash
# Проверка SWAP
swapon --show

# Перезапуск мониторинга
pkill -f monitor-memory
nohup /root/monitor-memory.sh > /var/log/memory-monitor.log 2>&1 &
```

### Если проблемы с зависимостями:
```bash
cd /root/12G
rm -rf node_modules package-lock.json
npm install
pm2 restart all
```

## 📞 Поддержка

### Логи для диагностики:
```bash
pm2 logs --lines 50
tail -f /var/log/memory-monitor.log
free -h
htop
```

### Статус всех сервисов:
```bash
systemctl status pm2-root
pm2 list
```

---

**💡 Совет:** Если что-то пошло не так, просто запустите `./server-setup.sh` заново - скрипт безопасен для повторного выполнения!
