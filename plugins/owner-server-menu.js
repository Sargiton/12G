const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    const menu = `🤖 **МЕНЮ УПРАВЛЕНИЯ СЕРВЕРОМ**

📋 **Основные команды:**
🛑 \`.stopserver\` - Остановить сервер
🚀 \`.startserver\` - Запустить сервер
🔄 \`.restartserver\` - Перезапустить сервер

🧹 **Очистка и исправление:**
🧹 \`.clearqrcache\` - Очистить QR кэш
🔧 \`.fixserver\` - Исправить проблемы сервера
📦 \`.updatepackages\` - Обновить пакеты

📊 **Мониторинг:**
📊 \`.serverstatus\` - Статус сервера
📋 \`.serverlogs\` - Логи сервера

🆘 **Экстренные действия:**
🛑 \`.emergencystop\` - Экстренная остановка
🚀 \`.emergencyrestart\` - Экстренный перезапуск

💡 **Русские команды:**
🛑 \`.остановитьсервер\`
🚀 \`.запуститьсервер\`
🔄 \`.перезапуститьсервер\`
🧹 \`.очиститьqr\`
📊 \`.статуссервера\`
📋 \`.логисервера\`
🔧 \`.исправитьсервер\`
📦 \`.обновитьпакеты\`

⚠️ **Внимание:** Все команды выполняются на сервере!
🔒 **Безопасность:** Только владелец может использовать эти команды.`;

    m.reply(menu);

  } catch (error) {
    console.error('❌ Server menu error:', error);
    m.reply('❌ Ошибка отображения меню');
  }
};

handler.help = ['servermenu', 'серверменю'];
handler.tags = ['owner', 'server'];
handler.command = /^(servermenu|серверменю|управлениесервером)$/i;
handler.owner = true;

export default handler;
