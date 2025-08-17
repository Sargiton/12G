module.exports = {
	apps: [
		{
			name: 'whatsapp-old',
			script: 'index.js',
			cwd: './123',
			autorestart: true,
			watch: false,
			time: true,
			node_args: '',
			env: {
				NODE_ENV: 'production',
				PORT: '3300'
			},
			out_file: './123/logs/whatsapp-old-out.log',
			error_file: './123/logs/whatsapp-old-error.log',
			log_date_format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
		}
	]
}


