import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs';
import path from 'path';

const execAsync = promisify(exec);

const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    const action = command.toLowerCase();

    switch (action) {
      case 'stopserver':
      case 'остановитьсервер':
        await m.reply('🛑 Останавливаю сервер...');
        try {
          await execAsync('pm2 stop all');
          await execAsync('pm2 delete all');
          m.reply('✅ Сервер остановлен!');
        } catch (error) {
          m.reply(`❌ Ошибка остановки сервера: ${error.message}`);
        }
        break;

      case 'startserver':
      case 'запуститьсервер':
        await m.reply('🚀 Запускаю сервер...');
        try {
          await execAsync('pm2 start ecosystem-simple.config.cjs');
          m.reply('✅ Сервер запущен!');
        } catch (error) {
          m.reply(`❌ Ошибка запуска сервера: ${error.message}`);
        }
        break;

      case 'restartserver':
      case 'перезапуститьсервер':
        await m.reply('🔄 Перезапускаю сервер...');
        try {
          await execAsync('pm2 stop all');
          await execAsync('pm2 delete all');
          await execAsync('pm2 start ecosystem-simple.config.cjs');
          m.reply('✅ Сервер перезапущен!');
        } catch (error) {
          m.reply(`❌ Ошибка перезапуска сервера: ${error.message}`);
        }
        break;

      case 'clearqrcache':
      case 'очиститьqr':
        await m.reply('🧹 Очищаю QR кэш...');
        try {
          // Очистка кэша в памяти
          const cacheManager = await import('../lib/cache.js');
          const qrKeys = cacheManager.default.nodeCache.keys().filter(key => key.startsWith('qr_'));
          qrKeys.forEach(key => cacheManager.default.nodeCache.del(key));

          // Очистка файлов
          const tmpDir = './tmp';
          if (fs.existsSync(tmpDir)) {
            const files = fs.readdirSync(tmpDir);
            files.forEach(file => {
              if (file.includes('qr') || file.includes('QR') || file.endsWith('.png') || file.endsWith('.jpg')) {
                try {
                  fs.unlinkSync(path.join(tmpDir, file));
                } catch (err) {
                  console.log(`Ошибка удаления ${file}:`, err.message);
                }
              }
            });
          }

          // Удаление QR файлов в корне
          const rootFiles = fs.readdirSync('.');
          rootFiles.forEach(file => {
            if (file.includes('qr') || file.includes('QR') || file === 'qr.png' || file === 'qr.jpg') {
              try {
                fs.unlinkSync(file);
              } catch (err) {
                console.log(`Ошибка удаления QR файла ${file}:`, err.message);
              }
            }
          });

          await cacheManager.default.clear();
          m.reply(`✅ QR кэш очищен!\n🗑️ Удалено QR кодов: ${qrKeys.length}\n🧹 Файлы QR кодов удалены`);
        } catch (error) {
          m.reply(`❌ Ошибка очистки QR кэша: ${error.message}`);
        }
        break;

      case 'serverstatus':
      case 'статуссервера':
        await m.reply('📊 Проверяю статус сервера...');
        try {
          const { stdout } = await execAsync('pm2 list');
          m.reply(`📋 Статус сервера:\n\`\`\`${stdout}\`\`\``);
        } catch (error) {
          m.reply(`❌ Ошибка получения статуса: ${error.message}`);
        }
        break;

      case 'serverlogs':
      case 'логисервера':
        await m.reply('📋 Получаю логи сервера...');
        try {
          const { stdout } = await execAsync('pm2 logs --lines 20 --nostream');
          const logs = stdout.length > 4000 ? stdout.substring(0, 4000) + '...' : stdout;
          m.reply(`📋 Последние логи:\n\`\`\`${logs}\`\`\``);
        } catch (error) {
          m.reply(`❌ Ошибка получения логов: ${error.message}`);
        }
        break;

      case 'fixserver':
      case 'исправитьсервер':
        await m.reply('🔧 Исправляю проблемы сервера...');
        try {
          // Остановка
          await execAsync('pm2 stop all');
          await execAsync('pm2 delete all');
          
          // Очистка кэша
          await execAsync('npm cache clean --force');
          await execAsync('rm -rf tmp/*');
          await execAsync('rm -rf storage/data/cache/*');
          
          // Запуск
          await execAsync('pm2 start ecosystem-simple.config.cjs');
          
          m.reply('✅ Сервер исправлен и перезапущен!');
        } catch (error) {
          m.reply(`❌ Ошибка исправления сервера: ${error.message}`);
        }
        break;

      case 'updatepackages':
      case 'обновитьпакеты':
        await m.reply('📦 Обновляю пакеты...');
        try {
          await execAsync('npm audit fix --force');
          await execAsync('npm update');
          m.reply('✅ Пакеты обновлены!');
        } catch (error) {
          m.reply(`❌ Ошибка обновления пакетов: ${error.message}`);
        }
        break;

      default:
        m.reply(`📋 Доступные команды управления сервером:

🛑 .stopserver - Остановить сервер
🚀 .startserver - Запустить сервер
🔄 .restartserver - Перезапустить сервер
🧹 .clearqrcache - Очистить QR кэш
📊 .serverstatus - Статус сервера
📋 .serverlogs - Логи сервера
🔧 .fixserver - Исправить проблемы
📦 .updatepackages - Обновить пакеты

💡 Используйте эти команды для управления сервером через Telegram!`);
    }

  } catch (error) {
    console.error('❌ Server control error:', error);
    m.reply('❌ Ошибка выполнения команды');
  }
};

handler.help = [
  'stopserver', 'startserver', 'restartserver', 'clearqrcache',
  'serverstatus', 'serverlogs', 'fixserver', 'updatepackages'
];
handler.tags = ['owner', 'server'];
handler.command = /^(stopserver|startserver|restartserver|clearqrcache|serverstatus|serverlogs|fixserver|updatepackages|остановитьсервер|запуститьсервер|перезапуститьсервер|очиститьqr|статуссервера|логисервера|исправитьсервер|обновитьпакеты)$/i;
handler.owner = true;

export default handler;
