import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys';
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
import fs from 'fs';

console.log('🚀 Простая генерация QR кода...');

// Создаем папку для сессии если её нет
if (!fs.existsSync('./LynxSession')) {
    fs.mkdirSync('./LynxSession', { recursive: true });
}

async function generateQR() {
    try {
        console.log('📱 Инициализация Baileys...');
        
        // Получаем состояние аутентификации
        const { state, saveCreds } = await useMultiFileAuthState('./LynxSession');
        
        // Получаем версию Baileys
        const { version } = await fetchLatestBaileysVersion();
        
        console.log('🔗 Создание соединения...');
        
        // Создаем соединение
        const conn = makeWASocket({
            version,
            auth: {
                creds: state.creds,
                keys: state.keys,
            },
            printQRInTerminal: true,
            logger: { level: 'silent' }
        });

        // Обработчик обновлений соединения
        conn.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update;
            
            if (qr) {
                console.log('📱 QR код получен!');
                
                // Показываем QR в терминале
                qrcode.generate(qr, { small: true });
                
                // Сохраняем QR в файл
                try {
                    await QRCode.toFile('qr.png', qr);
                    console.log('✅ QR код сохранен в qr.png');
                } catch (err) {
                    console.error('❌ Ошибка сохранения QR:', err);
                }
            }
            
            if (connection === 'open') {
                console.log('✅ Подключение установлено!');
                process.exit(0);
            }
            
            if (connection === 'close') {
                console.log('❌ Соединение закрыто');
                process.exit(1);
            }
        });

        // Обработчик обновления учетных данных
        conn.ev.on('creds.update', saveCreds);
        
        console.log('⏳ Ожидание QR кода...');
        
    } catch (error) {
        console.error('❌ Ошибка:', error);
        process.exit(1);
    }
}

generateQR();
