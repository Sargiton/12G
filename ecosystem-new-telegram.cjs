module.exports = {
    apps: [
        {
            name: 'new-telegram-bot',
            script: 'new-telegram-bot.js',
            autorestart: true,
            watch: false,
            time: true,
            node_args: '',
            env: {
                NODE_ENV: 'production'
            },
            out_file: './logs/new-telegram-bot-out.log',
            error_file: './logs/new-telegram-bot-error.log',
            log_date_format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
        }
    ]
}
