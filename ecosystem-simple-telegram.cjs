module.exports = {
    apps: [
        {
            name: 'simple-telegram',
            script: 'simple-telegram.js',
            cwd: './123',
            autorestart: true,
            watch: false,
            env: {
                NODE_ENV: 'production'
            }
        }
    ]
}
