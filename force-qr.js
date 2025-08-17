import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } from '@whiskeysockets/baileys';
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
import fs from 'fs';

console.log('🔄 Принудительная генерация QR кода...');

// Удаляем старую сессию
if (fs.existsSync('./LynxSession')) {
    fs.rmSync('./LynxSession', { recursive: true, force: true });
}

async function forceQR() {
    const { state, saveCreds } = await useMultiFileAuthState('./LynxSession');
    const { version } = await fetchLatestBaileysVersion();
    
    const conn = makeWASocket({
        version,
        auth: { creds: state.creds, keys: state.keys },
        printQRInTerminal: true,
        logger: { level: 'silent' }
    });

    conn.ev.on('connection.update', async (update) => {
        const { qr } = update;
        if (qr) {
            console.log('📱 QR код получен!');
            qrcode.generate(qr, { small: true });
            await QRCode.toFile('qr.png', qr);
            console.log('✅ QR код сохранен в qr.png');
        }
    });

    conn.ev.on('creds.update', saveCreds);
}

forceQR();
