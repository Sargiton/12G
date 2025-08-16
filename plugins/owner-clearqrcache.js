import cacheManager from '../lib/cache.js';

const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    // Проверяем права доступа
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    // Очищаем все QR коды из кэша
    const qrKeys = cacheManager.nodeCache.keys().filter(key => key.startsWith('qr_'));
    
    for (const key of qrKeys) {
      cacheManager.nodeCache.del(key);
    }

    // Очищаем общий кэш
    await cacheManager.clear();

    const clearedCount = qrKeys.length;
    
    m.reply(`✅ Кэш QR кодов очищен!\n\n🗑️ Удалено QR кодов: ${clearedCount}\n🧹 Общий кэш очищен\n\nТеперь при следующем запросе QR кода будет сгенерирован новый.`);

    console.log(`🧹 QR cache cleared by owner: ${clearedCount} QR codes removed`);

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
