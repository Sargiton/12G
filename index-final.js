import { makeWASocket, DisconnectReason, useMultiFileAuthState } from '@whiskeysockets/baileys';
import pino from 'pino';
import qrcode from 'qrcode';
import fs from 'fs';
import path from 'path';

console.log('🚀 Запуск WhatsApp бота...');

async function startBot() {
  try {
    // Создаем состояние аутентификации
    const { state, saveCreds } = await useMultiFileAuthState('LynxSession');
    
    console.log('🔗 Создание соединения...');
    
    const conn = makeWASocket({
      version: [2, 2323, 4],
      auth: state,
      logger: pino({ level: 'silent' }),
      printQRInTerminal: true
    });
    
    console.log('⏳ Ожидание QR кода...');
    
    conn.ev.on('connection.update', async (update) => {
      const { connection, lastDisconnect, qr } = update;
      
      if (qr) {
        console.log('📱 QR код получен!');
        
        try {
          // Сохраняем QR код в файл
          await qrcode.toFile('qr.png', qr);
          console.log('✅ QR код сохранен в qr.png');
          
          // Также выводим QR код в терминал
          console.log('📱 QR код в терминале:');
          console.log(qr);
        } catch (error) {
          console.error('❌ Ошибка сохранения QR кода:', error);
        }
      }
      
      if (connection === 'close') {
        const shouldReconnect = (lastDisconnect?.error)?.output?.statusCode !== DisconnectReason.loggedOut;
        console.log('🔌 Соединение закрыто из-за ', lastDisconnect?.error, ', переподключение ', shouldReconnect);
        if (!shouldReconnect) {
          process.exit(1);
        }
      } else if (connection === 'open') {
        console.log('✅ Соединение установлено!');
      }
    });
    
    conn.ev.on('creds.update', saveCreds);
    
    // Обработка сообщений
    conn.ev.on('messages.upsert', async (m) => {
      const msg = m.messages[0];
      if (!msg.key.fromMe && msg.message) {
        console.log('📨 Получено сообщение:', msg.message);
      }
    });
    
  } catch (error) {
    console.error('❌ Ошибка запуска бота:', error);
    process.exit(1);
  }
}

startBot();
