import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const handler = async (m, { conn, usedPrefix, command }) => {
  try {
    if (!m.isOwner) {
      return m.reply('❌ Эта команда доступна только владельцу бота');
    }

    const action = command.toLowerCase();

    switch (action) {
      case 'emergencystop':
      case 'экстреннаяостановка':
        await m.reply('🚨 ЭКСТРЕННАЯ ОСТАНОВКА СЕРВЕРА!');
        try {
          // Принудительная остановка всех процессов
          await execAsync('pm2 stop all');
          await execAsync('pm2 delete all');
          await execAsync('pkill -f node');
          await execAsync('pkill -f pm2');
          
          m.reply('✅ Сервер экстренно остановлен!\n🛑 Все процессы Node.js завершены');
        } catch (error) {
          m.reply(`❌ Ошибка экстренной остановки: ${error.message}`);
        }
        break;

      case 'emergencyrestart':
      case 'экстренныйперезапуск':
        await m.reply('🚨 ЭКСТРЕННЫЙ ПЕРЕЗАПУСК СЕРВЕРА!');
        try {
          // Остановка
          await execAsync('pm2 stop all');
          await execAsync('pm2 delete all');
          await execAsync('pkill -f node');
          
          // Очистка
          await execAsync('rm -rf tmp/*');
          await execAsync('rm -rf storage/data/cache/*');
          await execAsync('npm cache clean --force');
          
          // Запуск
          await execAsync('pm2 start ecosystem-simple.config.cjs');
          
          m.reply('✅ Сервер экстренно перезапущен!\n🧹 Кэш очищен\n🚀 Процессы запущены');
        } catch (error) {
          m.reply(`❌ Ошибка экстренного перезапуска: ${error.message}`);
        }
        break;

      case 'killall':
      case 'убитьвсе':
        await m.reply('💀 ПРИНУДИТЕЛЬНОЕ ЗАВЕРШЕНИЕ ВСЕХ ПРОЦЕССОВ!');
        try {
          await execAsync('sudo pkill -9 -f node');
          await execAsync('sudo pkill -9 -f pm2');
          await execAsync('sudo systemctl restart pm2-root');
          
          m.reply('💀 Все процессы принудительно завершены!\n🔄 PM2 перезапущен');
        } catch (error) {
          m.reply(`❌ Ошибка принудительного завершения: ${error.message}`);
        }
        break;

      case 'systeminfo':
      case 'инфосистемы':
        await m.reply('📊 Получаю информацию о системе...');
        try {
          const [cpu, mem, disk, uptime] = await Promise.all([
            execAsync('top -bn1 | grep "Cpu(s)" | awk \'{print $2}\' | cut -d"%" -f1'),
            execAsync('free -m | awk \'NR==2{printf "%.2f%%", $3*100/$2}\''),
            execAsync('df -h | awk \'$NF=="/"{printf "%s", $5}\''),
            execAsync('uptime -p')
          ]);
          
          const info = `📊 **ИНФОРМАЦИЯ О СИСТЕМЕ**

🖥️ **CPU:** ${cpu.stdout.trim()}%
💾 **RAM:** ${mem.stdout.trim()}
💿 **Диск:** ${disk.stdout.trim()}
⏰ **Аптайм:** ${uptime.stdout.trim()}

🔄 **Статус процессов:**
\`\`\`
${(await execAsync('pm2 list')).stdout}
\`\`\``;
          
          m.reply(info);
        } catch (error) {
          m.reply(`❌ Ошибка получения информации: ${error.message}`);
        }
        break;

      default:
        m.reply(`🚨 **ЭКСТРЕННЫЕ КОМАНДЫ**

💀 \`.emergencystop\` - Экстренная остановка сервера
🚨 \`.emergencyrestart\` - Экстренный перезапуск
💀 \`.killall\` - Принудительное завершение всех процессов
📊 \`.systeminfo\` - Информация о системе

⚠️ **ВНИМАНИЕ:** Эти команды выполняют критические действия!
🔒 **Безопасность:** Используйте только в экстренных случаях!`);
    }

  } catch (error) {
    console.error('❌ Emergency control error:', error);
    m.reply('❌ Ошибка выполнения экстренной команды');
  }
};

handler.help = ['emergencystop', 'emergencyrestart', 'killall', 'systeminfo'];
handler.tags = ['owner', 'emergency'];
handler.command = /^(emergencystop|emergencyrestart|killall|systeminfo|экстреннаяостановка|экстренныйперезапуск|убитьвсе|инфосистемы)$/i;
handler.owner = true;

export default handler;
