module.exports = {
  apps: [
    {
      name: 'whatsapp-bot',
      script: 'index.js',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '400M', // Ограничиваем до 400MB
      node_args: '--max-old-space-size=400 --optimize-for-size',
      env: {
        NODE_ENV: 'production'
      },
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'tmp', '*.log'],
      max_restarts: 5,
      min_uptime: '10s',
      error_file: './logs/whatsapp-error.log',
      out_file: './logs/whatsapp-out.log',
      time: true,
      kill_timeout: 3000
    },
    {
      name: 'telegram-bot',
      script: 'telegram-bot.cjs',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '200M', // Ограничиваем до 200MB
      node_args: '--max-old-space-size=200 --optimize-for-size',
      env: {
        NODE_ENV: 'production'
      },
      autorestart: true,
      watch: false,
      ignore_watch: ['node_modules', 'tmp', '*.log'],
      max_restarts: 5,
      min_uptime: '10s',
      error_file: './logs/telegram-error.log',
      out_file: './logs/telegram-out.log',
      time: true,
      kill_timeout: 2000
    }
  ]
};
