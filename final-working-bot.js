import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

const logger = pino({ level: 'silent' })

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
    
    const sock = makeWASocket({
        printQRInTerminal: true,
        logger,
        auth: state,
        browser: ['DarkCore Bot', 'Chrome', '1.0.0']
    })

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update
        
        if (qr) {
            console.log('🔐 QR КОД ПОЛУЧЕН!')
            qrcode.generate(qr, { small: true })
        }
        
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
            console.log('❌ Соединение закрыто из-за ', lastDisconnect?.error, ', переподключение ', shouldReconnect)
            if (shouldReconnect) {
                setTimeout(connectToWhatsApp, 3000)
            }
        } else if (connection === 'open') {
            console.log('✅ Соединение установлено!')
        }
    })

    sock.ev.on('creds.update', saveCreds)
}

console.log('🚀 Запуск финального рабочего бота...')
connectToWhatsApp()
