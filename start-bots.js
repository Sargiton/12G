import { spawn } from 'child_process';
import path from 'path';

console.log('🚀 Запуск ботов...');

// Запускаем WhatsApp бота
const whatsappBot = spawn('node', ['index.js'], {
  stdio: 'inherit',
  cwd: process.cwd()
});

// Ждем немного и запускаем Telegram бота
setTimeout(() => {
  const telegramBot = spawn('node', ['telegram-bot.cjs'], {
    stdio: 'inherit',
    cwd: process.cwd()
  });

  telegramBot.on('error', (error) => {
    console.error('❌ Ошибка Telegram бота:', error);
  });

  telegramBot.on('exit', (code) => {
    console.log(`📱 Telegram бот завершился с кодом: ${code}`);
  });

}, 3000);

whatsappBot.on('error', (error) => {
  console.error('❌ Ошибка WhatsApp бота:', error);
});

whatsappBot.on('exit', (code) => {
  console.log(`📱 WhatsApp бот завершился с кодом: ${code}`);
});

// Обработка завершения процесса
process.on('SIGINT', () => {
  console.log('\n🛑 Остановка ботов...');
  whatsappBot.kill();
  process.exit(0);
});
