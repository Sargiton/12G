import fs from 'fs';
import path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    // Проверяем права доступа
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    let clearedCount = 0;
    const clearedItems = [];

    // 1. Очистка QR файлов в корне
    const rootFiles = fs.readdirSync('.');
    rootFiles.forEach(file => {
      if (file.includes('qr') || file.includes('QR') || file === 'qr.png' || file === 'qr.jpg') {
        try {
          fs.unlinkSync(file);
          clearedCount++;
          clearedItems.push(`📄 ${file}`);
        } catch (err) {
          console.log(`❌ Ошибка удаления QR файла ${file}:`, err.message);
        }
      }
    });

    // 2. Очистка файлов QR кодов в tmp
    const tmpDir = './tmp';
    if (fs.existsSync(tmpDir)) {
      const files = fs.readdirSync(tmpDir);
      files.forEach(file => {
        if (file.includes('qr') || file.includes('QR') || file.endsWith('.png') || file.endsWith('.jpg')) {
          try {
            fs.unlinkSync(path.join(tmpDir, file));
            clearedCount++;
            clearedItems.push(`📁 tmp/${file}`);
          } catch (err) {
            console.log(`❌ Ошибка удаления ${file}:`, err.message);
          }
        }
      });
    }

    // 3. Очистка сессий WhatsApp
    const sessionDirs = ['./LynxSession', './BackupSession'];
    sessionDirs.forEach(dir => {
      if (fs.existsSync(dir)) {
        try {
          const files = fs.readdirSync(dir);
          files.forEach(file => {
            if (file !== 'creds.json') {
              try {
                fs.unlinkSync(path.join(dir, file));
                clearedCount++;
                clearedItems.push(`🗂️ ${dir}/${file}`);
              } catch (err) {
                console.log(`❌ Ошибка удаления ${file}:`, err.message);
              }
            }
          });
        } catch (err) {
          console.log(`❌ Ошибка очистки ${dir}:`, err.message);
        }
      }
    });

    // 4. Очистка кэша Node.js
    try {
      await execAsync('npm cache clean --force');
      clearedItems.push('🧹 npm cache');
    } catch (err) {
      console.log('❌ Ошибка очистки npm cache:', err.message);
    }

    // 5. Перезапуск WhatsApp бота для генерации нового QR
    try {
      await execAsync('pm2 restart whatsapp-bot');
      clearedItems.push('🔄 WhatsApp bot restarted');
    } catch (err) {
      console.log('❌ Ошибка перезапуска бота:', err.message);
    }

    // Формируем отчет
    const report = `✅ QR кэш полностью очищен!\n\n🗑️ Удалено элементов: ${clearedCount}\n\n📋 Выполненные действия:\n${clearedItems.map(item => `  • ${item}`).join('\n')}\n\n🔄 WhatsApp бот перезапущен\n📱 Новый QR код будет сгенерирован при следующем запросе`;

    m.reply(report);

    console.log(`🧹 QR cache completely cleared by owner: ${clearedCount} items removed`);

  } catch (error) {
    console.error('❌ Clear QR cache error:', error);
    m.reply('❌ Ошибка при очистке кэша QR кодов: ' + error.message);
  }
};

handler.help = ['clearqrcache'];
handler.tags = ['owner'];
handler.command = /^(clearqrcache|очиститьqr|qrclear)$/i;
handler.owner = true;

export default handler;
