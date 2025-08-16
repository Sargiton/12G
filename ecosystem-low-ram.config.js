module.exports = {
  apps: [
    {
      name: 'whatsapp-bot',
      script: 'index.js',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '512M', // Ограничиваем до 512MB
      node_args: '--max-old-space-size=512 --optimize-for-size --gc-interval=100',
      env: {
        NODE_ENV: 'production',
        REDIS_URL: 'redis://localhost:6379'
      },
      env_production: {
        NODE_ENV: 'production'
      },
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'tmp', '*.log'],
      max_restarts: 10,
      min_uptime: '10s',
      error_file: './logs/whatsapp-error.log',
      out_file: './logs/whatsapp-out.log',
      log_file: './logs/whatsapp-combined.log',
      time: true,
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 10000
    },
    {
      name: 'telegram-bot',
      script: 'telegram-bot.cjs',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '256M', // Ограничиваем до 256MB
      node_args: '--max-old-space-size=256 --optimize-for-size',
      env: {
        NODE_ENV: 'production'
      },
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'tmp', '*.log'],
      max_restarts: 10,
      min_uptime: '10s',
      error_file: './logs/telegram-error.log',
      out_file: './logs/telegram-out.log',
      log_file: './logs/telegram-combined.log',
      time: true,
      kill_timeout: 3000,
      wait_ready: true,
      listen_timeout: 5000
    }
  ]
};
