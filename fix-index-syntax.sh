#!/bin/bash

echo "🔧 ИСПРАВЛЕНИЕ СИНТАКСИСА INDEX.JS"
echo "==================================="

cd /root/12G

echo "🛑 Останавливаем ботов..."
pm2 stop all
pm2 delete all

echo "📝 Исправляем index.js..."
cat > index.js << 'EOF'
import { spawn } from 'child_process'
import { watchFile, unwatchFile } from 'fs'
import { fileURLToPath } from 'url'
import { dirname } from 'path'
import chalk from 'chalk'
import { createRequire } from 'module'
import { exec } from 'child_process'
import { promisify } from 'util'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const require = createRequire(__dirname)

const execAsync = promisify(exec)

function start(file) {
    const args = [file, ...process.argv.slice(2)]
    const p = spawn(process.argv[0], args, { stdio: ['inherit', 'inherit', 'inherit', 'ipc'] })
        .on('message', data => {
            console.log('[RECEIVED]', data)
            switch (data) {
                case 'reset':
                    p.kill()
                    import('./index.js')
                    break
                case 'uptime':
                    p.send(process.uptime())
                    break
            }
        })
        .on('exit', code => {
            console.error('Exited with code:', code)
            if (code === 0) return
            watchFile(args[0], () => {
                unwatchFile(args[0])
                start(file)
            })
        })
        .on('error', err => {
            console.error('FATAL', err)
            process.exit(1)
        })
}

// Проверяем наличие handler.js
if (!require('fs').existsSync('./handler.js')) {
    console.error('❌ Файл handler.js не найден!')
    process.exit(1)
}

console.log(chalk.cyan('🚀 Запуск бота с полным функционалом...'))
start('./handler.js')
EOF

echo "📝 Проверяем handler.js..."
if [ ! -f "handler.js" ]; then
    echo "❌ handler.js не найден, восстанавливаем..."
    if [ -f "123/handler.js" ]; then
        cp 123/handler.js handler.js
        echo "✅ handler.js восстановлен"
    else
        echo "❌ Резервная копия не найдена"
        exit 1
    fi
fi

echo "📝 Создаем конфигурацию PM2..."
cat > ecosystem-fixed.config.cjs << 'EOF'
module.exports = {
  apps: [
    {
      name: 'whatsapp-fixed',
      script: 'index.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: { NODE_ENV: 'production' },
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_file: './logs/combined.log',
      time: true
    },
    {
      name: 'telegram-working',
      script: 'telegram-bot.cjs',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: { NODE_ENV: 'production' },
      out_file: './logs/telegram-out.log',
      error_file: './logs/telegram-error.log',
      log_file: './logs/telegram-combined.log',
      time: true
    }
  ]
};
EOF

echo "🤖 Запускаем исправленного бота..."
pm2 start ecosystem-fixed.config.cjs

sleep 10

echo "📊 Статус процессов:"
pm2 list

echo ""
echo "🔍 Проверяем логи WhatsApp бота..."
pm2 logs whatsapp-fixed --lines 10

echo ""
echo "✅ СИНТАКСИС ИСПРАВЛЕН!"
echo "📱 WhatsApp бот: whatsapp-fixed"
echo "📲 Telegram бот: telegram-working"
