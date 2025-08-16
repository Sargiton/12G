module.exports = {
  apps: [
    {
      name: 'whatsapp-bot',
      script: 'index.js',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=1024 --expose-gc --optimize-for-size',
        UV_THREADPOOL_SIZE: 4,
        REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379'
      },
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000,
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 8000,
      autorestart: true,
      watch: false,
      ignore_watch: [
        'node_modules',
        'logs',
        'tmp',
        '*.log',
        'database',
        'storage'
      ],
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      source_map_support: false,
      node_args: [
        '--max-old-space-size=1024',
        '--expose-gc',
        '--optimize-for-size',
        '--gc-interval=100',
        '--max-semi-space-size=64'
      ]
    },
    {
      name: 'telegram-bot',
      script: 'telegram-bot.cjs',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=512 --expose-gc',
        UV_THREADPOOL_SIZE: 2,
        REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379'
      },
      max_memory_restart: '512M',
      min_uptime: '10s',
      max_restarts: 5,
      restart_delay: 3000,
      kill_timeout: 3000,
      wait_ready: true,
      listen_timeout: 5000,
      autorestart: true,
      watch: false,
      ignore_watch: [
        'node_modules',
        'logs',
        'tmp',
        '*.log',
        'database',
        'storage'
      ],
      error_file: './logs/telegram-err.log',
      out_file: './logs/telegram-out.log',
      log_file: './logs/telegram-combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      source_map_support: false,
      node_args: [
        '--max-old-space-size=512',
        '--expose-gc',
        '--optimize-for-size',
        '--gc-interval=100',
        '--max-semi-space-size=32'
      ]
    },
    {
      name: 'monitor',
      script: 'lib/monitor.js',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        NODE_OPTIONS: '--max-old-space-size=256',
        REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379'
      },
      max_memory_restart: '256M',
      min_uptime: '10s',
      max_restarts: 3,
      restart_delay: 2000,
      kill_timeout: 2000,
      wait_ready: true,
      listen_timeout: 3000,
      autorestart: true,
      watch: false,
      ignore_watch: [
        'node_modules',
        'logs',
        'tmp',
        '*.log'
      ],
      error_file: './logs/monitor-err.log',
      out_file: './logs/monitor-out.log',
      log_file: './logs/monitor-combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      source_map_support: false,
      node_args: [
        '--max-old-space-size=256',
        '--expose-gc',
        '--optimize-for-size'
      ]
    }
  ],

  deploy: {
    production: {
      user: 'root',
      host: 'localhost',
      ref: 'origin/main',
      repo: 'git@github.com:your-repo/your-bot.git',
      path: '/var/www/bot',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    }
  },

  // Глобальные настройки
  max_memory_restart: '2G',
  min_uptime: '10s',
  max_restarts: 10,
  restart_delay: 4000,
  kill_timeout: 5000,
  wait_ready: true,
  listen_timeout: 8000,
  autorestart: true,
  watch: false,
  ignore_watch: [
    'node_modules',
    'logs',
    'tmp',
    '*.log',
    'database',
    'storage'
  ],
  error_file: './logs/err.log',
  out_file: './logs/out.log',
  log_file: './logs/combined.log',
  time: true,
  log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
  merge_logs: true,
  source_map_support: false
};
