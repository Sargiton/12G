#!/bin/bash

echo "🚀 НАСТРОЙКА СЕРВЕРА С НУЛЯ"
echo "================================"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Обновление системы
log "Обновляю систему..."
apt update && apt upgrade -y

# 2. Установка необходимых пакетов
log "Устанавливаю необходимые пакеты..."
apt install -y curl wget git nano htop bc

# 3. Установка Node.js 18
log "Устанавливаю Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 4. Установка PM2
log "Устанавливаю PM2..."
npm install -g pm2

# 5. Настройка SWAP (для 1GB RAM)
log "Настраиваю SWAP..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "SWAP создан и активирован"
else
    warn "SWAP файл уже существует"
fi

# 6. Настройка оптимизации памяти
log "Настраиваю оптимизацию памяти..."
cat > /etc/sysctl.conf << 'EOF'
# Memory optimization settings
vm.swappiness=10
vm.vfs_cache_pressure=50

# Network optimization
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216

# File system optimization
fs.file-max=65536
EOF

# Применяем настройки
sysctl -p

# 7. Настройка лимитов
log "Настраиваю лимиты системы..."
cat > /etc/security/limits.conf << 'EOF'
* soft memlock unlimited
* hard memlock unlimited
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

# 8. Создание рабочей директории
log "Создаю рабочую директорию..."
cd /root
if [ ! -d "12G" ]; then
    git clone https://github.com/Sargiton/12G.git
    cd 12G
else
    cd 12G
    git pull origin master
fi

# 9. Установка зависимостей
log "Устанавливаю зависимости..."
npm install

# 10. Создание .env файла
log "Создаю .env файл..."
cat > .env << 'EOF'
NODE_OPTIONS="--max-old-space-size=512"
EOF

# 11. Создание скрипта мониторинга памяти
log "Создаю скрипт мониторинга памяти..."
cat > /root/monitor-memory.sh << 'EOF'
#!/bin/bash
while true; do
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
    echo "$(date): Memory usage: ${MEMORY}%"
    
    if (( $(echo "$MEMORY > 90" | bc -l) )); then
        echo "High memory usage detected! Restarting PM2..."
        pm2 restart all
    fi
    
    sleep 300
done
EOF

chmod +x /root/monitor-memory.sh

# 12. Создание скрипта перезапуска
log "Создаю скрипт перезапуска..."
cat > /root/restart-bots.sh << 'EOF'
#!/bin/bash
echo "Restarting bots..."
pm2 stop all
pm2 delete all
sleep 5
pm2 start ecosystem-simple.config.cjs
pm2 save
echo "Bots restarted!"
EOF

chmod +x /root/restart-bots.sh

# 13. Запуск ботов
log "Запускаю боты..."
pm2 start ecosystem-simple.config.cjs

# 14. Настройка автозапуска PM2
log "Настраиваю автозапуск PM2..."
pm2 startup
pm2 save

# 15. Запуск мониторинга памяти
log "Запускаю мониторинг памяти..."
nohup /root/monitor-memory.sh > /var/log/memory-monitor.log 2>&1 &

# 16. Финальная проверка
log "Выполняю финальную проверку..."
sleep 5

echo ""
echo "✅ НАСТРОЙКА ЗАВЕРШЕНА!"
echo "================================"
echo "📊 Статус памяти:"
free -h

echo ""
echo "🤖 Статус ботов:"
pm2 list

echo ""
echo "📋 Полезные команды:"
echo "pm2 logs - просмотр логов"
echo "pm2 restart all - перезапуск ботов"
echo "htop - мониторинг системы"
echo "free -h - статус памяти"
echo "tail -f /var/log/memory-monitor.log - мониторинг памяти"

echo ""
echo "📱 В Telegram отправьте:"
echo ".serverstatus - статус сервера"
echo ".clearqrcache - очистка QR кэша"
