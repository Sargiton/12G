import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys'
import pino from 'pino'
import qrcode from 'qrcode-terminal'

console.log('🧪 ТЕСТ QR ГЕНЕРАЦИИ')
console.log('===================')

async function testQR() {
    try {
        console.log('🔍 Инициализация...')
        
        const { state, saveCreds } = await useMultiFileAuthState('LynxSession')
        
        console.log('🔗 Создание соединения...')
        const sock = makeWASocket({
            auth: state,
            printQRInTerminal: true,
            logger: pino({ level: 'silent' }),
            browser: ['Lynx Bot', 'Chrome', '1.0.0']
        })
        
        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update
            
            console.log('📡 Обновление соединения:', connection)
            
            if (qr) {
                console.log('✅ QR код получен!')
                qrcode.generate(qr, { small: true })
                
                // Сохраняем QR в файл
                const fs = await import('fs')
                const qrCode = await import('qrcode')
                const qrBuffer = await qrCode.toBuffer(qr)
                fs.writeFileSync('qr.png', qrBuffer)
                console.log('✅ QR код сохранен в qr.png')
                
                // Останавливаем тест
                process.exit(0)
            }
            
            if (connection === 'open') {
                console.log('✅ Подключение установлено!')
                process.exit(0)
            }
            
            if (connection === 'close') {
                const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut
                console.log('❌ Соединение закрыто:', lastDisconnect?.error)
                console.log('🔄 Переподключение:', shouldReconnect)
                if (!shouldReconnect) {
                    process.exit(1)
                }
            }
        })
        
        // Ждем 30 секунд
        setTimeout(() => {
            console.log('⏰ Время ожидания истекло')
            process.exit(1)
        }, 30000)
        
    } catch (error) {
        console.error('❌ Ошибка:', error)
        process.exit(1)
    }
}

testQR()
