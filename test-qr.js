import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys';
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
import fs from 'fs';
import path from 'path';

console.log('🚀 Тестирование QR кода...');

// Создаем папку для сессии
const sessionDir = './LynxSession';
if (!fs.existsSync(sessionDir)) {
    fs.mkdirSync(sessionDir, { recursive: true });
}

async function testQR() {
    try {
        // Получаем состояние аутентификации
        const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
        
        // Получаем версию Baileys
        const { version } = await fetchLatestBaileysVersion();
        
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

testQR();
