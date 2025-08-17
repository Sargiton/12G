import { makeWASocket, DisconnectReason, useMultiFileAuthState } from 'baileys';
import pino from 'pino';
import qrcode from 'qrcode';

console.log('🚀 Простой тест QR кода...');

async function testQR() {
  try {
    console.log('📱 Инициализация Baileys...');
    
    // Создаем простое состояние аутентификации
    const { state, saveCreds } = await useMultiFileAuthState('test-session');
    
    console.log('🔗 Создание соединения...');
    
    const conn = makeWASocket({
      version: [2, 2323, 4],
      auth: state,
      printQRInTerminal: true,
      logger: pino({ level: 'silent' })
    });
    
    console.log('⏳ Ожидание QR кода...');
    
    conn.ev.on('connection.update', async (update) => {
      const { connection, lastDisconnect, qr } = update;
      
      if (qr) {
        console.log('📱 QR код получен!');
        console.log(qr);
        
        // Сохраняем QR код в файл
        await qrcode.toFile('test-qr.png', qr);
        console.log('✅ QR код сохранен в test-qr.png');
        
        // Останавливаем процесс
        process.exit(0);
      }
      
      if (connection === 'close') {
        const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut;
        console.log('🔌 Соединение закрыто из-за ', lastDisconnect?.error, ', переподключение ', shouldReconnect);
        if (!shouldReconnect) {
          process.exit(1);
        }
      } else if (connection === 'open') {
        console.log('✅ Соединение установлено!');
        process.exit(0);
      }
    });
    
    conn.ev.on('creds.update', saveCreds);
    
  } catch (error) {
    console.error('❌ Ошибка:', error);
    process.exit(1);
  }
}

testQR();
