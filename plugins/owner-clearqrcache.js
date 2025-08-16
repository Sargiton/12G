import cacheManager from '../lib/cache.js';
import fs from 'fs';
import path from 'path';

const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    // Проверяем права доступа
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    let clearedCount = 0;

    // 1. Очистка кэша в памяти
    const qrKeys = cacheManager.nodeCache.keys().filter(key => key.startsWith('qr_'));
    for (const key of qrKeys) {
      cacheManager.nodeCache.del(key);
      clearedCount++;
    }

    // 2. Очистка файлов QR кодов
    const tmpDir = './tmp';
    if (fs.existsSync(tmpDir)) {
      const files = fs.readdirSync(tmpDir);
      files.forEach(file => {
        if (file.includes('qr') || file.includes('QR') || file.endsWith('.png') || file.endsWith('.jpg')) {
          try {
            fs.unlinkSync(path.join(tmpDir, file));
            clearedCount++;
          } catch (err) {
            console.log(`❌ Ошибка удаления ${file}:`, err.message);
          }
        }
      });
    }

    // 3. Очистка QR файлов в корне
    const rootFiles = fs.readdirSync('.');
    rootFiles.forEach(file => {
      if (file.includes('qr') || file.includes('QR') || file === 'qr.png' || file === 'qr.jpg') {
        try {
          fs.unlinkSync(file);
          clearedCount++;
        } catch (err) {
          console.log(`❌ Ошибка удаления QR файла ${file}:`, err.message);
        }
      }
    });

    // 4. Очистка общего кэша
    await cacheManager.clear();

    m.reply(`✅ Кэш QR кодов полностью очищен!\n\n🗑️ Удалено элементов: ${clearedCount}\n🧹 Общий кэш очищен\n🧹 Файлы QR кодов удалены\n\nТеперь при следующем запросе QR кода будет сгенерирован новый.`);

    console.log(`🧹 QR cache completely cleared by owner: ${clearedCount} items removed`);

  } catch (error) {
    console.error('❌ Clear QR cache error:', error);
    m.reply('❌ Ошибка при очистке кэша QR кодов');
  }
};

handler.help = ['clearqrcache'];
handler.tags = ['owner'];
handler.command = /^(clearqrcache|очиститьqr|qrclear)$/i;
handler.owner = true;

export default handler;
