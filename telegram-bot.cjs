const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const OWNER_IDS = [1424509648, 393422971, 2134847831]; // Массив разрешённых Telegram user ID
const TELEGRAM_TOKEN = '7882415806:AAGKIWslOZtVsK-EIHyHdIrM0jNS73BAnkM';
const WHATSAPP_PM2_NAME = 'whatsapp-bot';

const bot = new TelegramBot(TELEGRAM_TOKEN, { polling: true });

// Импорт модулей оптимизации (если доступны)
let cacheManager, messageQueue, performanceMonitor, mediaProcessor, pluginManager;

try {
  cacheManager = require('./lib/cache.js');
  messageQueue = require('./lib/queue.js');
  performanceMonitor = require('./lib/monitor.js');
  mediaProcessor = require('./lib/mediaProcessor.js');
  pluginManager = require('./lib/pluginManager.js');
} catch (error) {
  console.log('Модули оптимизации не найдены, некоторые команды будут недоступны');
}

function onlyOwner(msg) {
  if (!OWNER_IDS.includes(msg.from.id)) {
    bot.sendMessage(msg.chat.id, 'Нет доступа.');
    return false;
  }
  return true;
}

// Получить QR-код
bot.onText(/\/get_qr/, (msg) => {
  if (!onlyOwner(msg)) return;
  const qrPath = path.join(__dirname, 'qr.png');
  if (fs.existsSync(qrPath)) {
    bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath));
  } else {
    bot.sendMessage(msg.chat.id, 'Файл qr.png не найден.');
  }
});

// Сбросить сессию
bot.onText(/\/reset_session/, (msg) => {
  if (!onlyOwner(msg)) return;
  const sessionPath = path.join(__dirname, 'LynxSession');
  if (fs.existsSync(sessionPath)) {
    fs.rmSync(sessionPath, { recursive: true, force: true });
    bot.sendMessage(msg.chat.id, 'Папка LynxSession удалена. Перезапусти WhatsApp-бота для генерации нового QR-кода.');
  } else {
    bot.sendMessage(msg.chat.id, 'Папка LynxSession не найдена.');
  }
});

// Перезапустить WhatsApp-бота
bot.onText(/\/restart_whatsapp/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при перезапуске: ' + stderr);
    bot.sendMessage(msg.chat.id, 'WhatsApp-бот перезапущен.');
  });
});

// Запустить WhatsApp-бота
bot.onText(/\/start_whatsapp/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec(`pm2 start ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при запуске: ' + stderr);
    bot.sendMessage(msg.chat.id, 'WhatsApp-бот запущен.');
  });
});

// Остановить WhatsApp-бота
bot.onText(/\/stop_whatsapp/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec(`pm2 stop ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при остановке: ' + stderr);
    bot.sendMessage(msg.chat.id, 'WhatsApp-бот остановлен.');
  });
});

// Статус WhatsApp-бота
bot.onText(/\/status/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec(`pm2 show ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при получении статуса: ' + stderr);
    bot.sendMessage(msg.chat.id, 'Статус WhatsApp-бота:\n' + stdout);
  });
});

// Логи WhatsApp-бота
bot.onText(/\/logs/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec(`pm2 logs ${WHATSAPP_PM2_NAME} --lines 30 --nostream`, { maxBuffer: 1024 * 1024 }, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при получении логов: ' + stderr);
    bot.sendMessage(msg.chat.id, 'Последние логи WhatsApp-бота:\n' + stdout.slice(-4000));
  });
});

// Обновить код (git pull)
bot.onText(/\/update_code/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec('git pull', (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка git pull: ' + stderr);
    bot.sendMessage(msg.chat.id, 'Результат git pull:\n' + stdout);
  });
});

// Установить зависимости (npm install)
bot.onText(/\/npm_install/, (msg) => {
  if (!onlyOwner(msg)) return;
  exec('npm install', (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка npm install: ' + stderr);
    bot.sendMessage(msg.chat.id, 'Результат npm install:\n' + stdout);
  });
});

// Полный сброс: удалить сессию, перезапустить WhatsApp-бота, прислать QR
bot.onText(/\/full_reset/, async (msg) => {
  if (!onlyOwner(msg)) return;
  const sessionPath = path.join(__dirname, 'LynxSession');
  if (fs.existsSync(sessionPath)) {
    fs.rmSync(sessionPath, { recursive: true, force: true });
    bot.sendMessage(msg.chat.id, 'Папка LynxSession удалена. Перезапускаю WhatsApp-бота...');
  } else {
    bot.sendMessage(msg.chat.id, 'Папка LynxSession не найдена. Перезапускаю WhatsApp-бота...');
  }
  exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
    if (err) return bot.sendMessage(msg.chat.id, 'Ошибка при перезапуске WhatsApp-бота: ' + stderr);
    setTimeout(() => {
      const qrPath = path.join(__dirname, 'qr.png');
      if (fs.existsSync(qrPath)) {
        bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath));
      } else {
        bot.sendMessage(msg.chat.id, 'Файл qr.png не найден. Сначала сгенерируйте QR-код.');
      }
    }, 5000);
  });
});

// Мониторинг памяти
bot.onText(/\/memory/, (msg) => {
  if (!onlyOwner(msg)) return;
  
  const memUsage = process.memoryUsage();
  const rssMB = (memUsage.rss / 1024 / 1024).toFixed(1);
  const heapUsedMB = (memUsage.heapUsed / 1024 / 1024).toFixed(1);
  const heapTotalMB = (memUsage.heapTotal / 1024 / 1024).toFixed(1);
  
  exec('free -m', (err, stdout, stderr) => {
    let systemInfo = '';
    if (!err) {
      const lines = stdout.split('\n');
      const memLine = lines[1].split(/\s+/);
      const totalMB = memLine[1];
      const usedMB = memLine[2];
      const freeMB = memLine[3];
      systemInfo = `\n💻 Системная память:\n   Всего: ${totalMB}MB\n   Использовано: ${usedMB}MB\n   Свободно: ${freeMB}MB`;
    }
    
    const message = `📊 Использование памяти:\n\n🤖 Процесс:\n   RSS: ${rssMB}MB\n   Heap Used: ${heapUsedMB}MB\n   Heap Total: ${heapTotalMB}MB${systemInfo}`;
    bot.sendMessage(msg.chat.id, message);
  });
});

// Очистка памяти
bot.onText(/\/clean_memory/, (msg) => {
  if (!onlyOwner(msg)) return;
  
  exec('pm2 restart whatsapp-bot', (err, stdout, stderr) => {
    if (err) {
      bot.sendMessage(msg.chat.id, '❌ Ошибка при очистке памяти: ' + stderr);
    } else {
      bot.sendMessage(msg.chat.id, '✅ Память очищена. WhatsApp бот перезапущен.');
    }
  });
});

// Статистика системы
bot.onText(/\/system_stats/, (msg) => {
  if (!onlyOwner(msg)) return;
  
  exec('top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk \'{print 100 - $1}\'', (err, cpuOutput) => {
    exec('df -h / | tail -1 | awk \'{print $5}\'', (err2, diskOutput) => {
      const cpuUsage = cpuOutput.trim() || 'N/A';
      const diskUsage = diskOutput.trim() || 'N/A';
      
      const message = `🖥️ Статистика системы:\n\n💻 CPU: ${cpuUsage}%\n💾 Диск: ${diskUsage} использовано\n\n📊 PM2 процессы:`;
      
      exec('pm2 list', (err3, pm2Output) => {
        const fullMessage = message + '\n' + (pm2Output || 'Ошибка получения статуса PM2');
        bot.sendMessage(msg.chat.id, fullMessage);
      });
    });
  });
});

// Новые команды для мониторинга производительности

// Мониторинг кэша
bot.onText(/\/cache_stats/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!cacheManager) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль кэша не доступен');
  }
  
  try {
    const stats = await cacheManager.getStats();
    const message = `📊 Статистика кэша:\n\n` +
      `🔴 Redis:\n` +
      `   Статус: ${stats.redis.connected ? '✅ Подключен' : '❌ Отключен'}\n` +
      `   Ключей: ${stats.redis.keys || 'N/A'}\n` +
      `   Память: ${stats.redis.memory || 'N/A'}\n\n` +
      `🔵 NodeCache:\n` +
      `   Ключей: ${stats.nodeCache.keys}\n` +
      `   Память: ${stats.nodeCache.memory}MB\n` +
      `   Hit Rate: ${stats.nodeCache.hitRate}%\n\n` +
      `📈 Общая статистика:\n` +
      `   Всего запросов: ${stats.total.requests}\n` +
      `   Попаданий: ${stats.total.hits}\n` +
      `   Промахов: ${stats.total.misses}\n` +
      `   Hit Rate: ${stats.total.hitRate}%`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения статистики кэша: ${error.message}`);
  }
});

// Очистка кэша
bot.onText(/\/clear_cache/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!cacheManager) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль кэша не доступен');
  }
  
  try {
    await cacheManager.flush();
    bot.sendMessage(msg.chat.id, '✅ Кэш очищен');
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка очистки кэша: ${error.message}`);
  }
});

// Мониторинг очередей
bot.onText(/\/queue_stats/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!messageQueue) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль очередей не доступен');
  }
  
  try {
    const stats = await messageQueue.getStats();
    const message = `📊 Статистика очередей:\n\n` +
      `🚨 Высокий приоритет:\n` +
      `   Ожидает: ${stats.highPriority.waiting}\n` +
      `   Активные: ${stats.highPriority.active}\n` +
      `   Завершено: ${stats.highPriority.completed}\n` +
      `   Ошибки: ${stats.highPriority.failed}\n\n` +
      `📨 Обычные сообщения:\n` +
      `   Ожидает: ${stats.normal.waiting}\n` +
      `   Активные: ${stats.normal.active}\n` +
      `   Завершено: ${stats.normal.completed}\n` +
      `   Ошибки: ${stats.normal.failed}\n\n` +
      `🎬 Медиа обработка:\n` +
      `   Ожидает: ${stats.media.waiting}\n` +
      `   Активные: ${stats.media.active}\n` +
      `   Завершено: ${stats.media.completed}\n` +
      `   Ошибки: ${stats.media.failed}\n\n` +
      `🌐 API запросы:\n` +
      `   Ожидает: ${stats.api.waiting}\n` +
      `   Активные: ${stats.api.active}\n` +
      `   Завершено: ${stats.api.completed}\n` +
      `   Ошибки: ${stats.api.failed}`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения статистики очередей: ${error.message}`);
  }
});

// Очистка очередей
bot.onText(/\/clear_queues/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!messageQueue) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль очередей не доступен');
  }
  
  try {
    await messageQueue.clearAll();
    bot.sendMessage(msg.chat.id, '✅ Все очереди очищены');
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка очистки очередей: ${error.message}`);
  }
});

// Мониторинг плагинов
bot.onText(/\/plugin_stats/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!pluginManager) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль плагинов не доступен');
  }
  
  try {
    const stats = await pluginManager.getPluginStats();
    const message = `📊 Статистика плагинов:\n\n` +
      `📁 Всего плагинов: ${stats.total}\n` +
      `⚡ Загружено: ${stats.loaded}\n` +
      `💤 Не загружено: ${stats.unloaded}\n` +
      `❌ Ошибки: ${stats.errors}\n\n` +
      `📈 Топ плагинов по использованию:\n` +
      `${stats.topUsed.slice(0, 5).map((plugin, i) => 
        `${i + 1}. ${plugin.name}: ${plugin.usage} использований`
      ).join('\n')}\n\n` +
      `🕒 Последние ошибки:\n` +
      `${stats.recentErrors.slice(0, 3).map(error => 
        `• ${error.plugin}: ${error.error}`
      ).join('\n')}`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения статистики плагинов: ${error.message}`);
  }
});

// Мониторинг медиа обработки
bot.onText(/\/media_stats/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!mediaProcessor) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль медиа обработки не доступен');
  }
  
  try {
    const stats = await mediaProcessor.getStats();
    const message = `📊 Статистика медиа обработки:\n\n` +
      `🖼️ Изображения:\n` +
      `   Обработано: ${stats.images.processed}\n` +
      `   Ошибки: ${stats.images.errors}\n` +
      `   Среднее время: ${stats.images.avgTime}ms\n\n` +
      `🎥 Видео:\n` +
      `   Обработано: ${stats.videos.processed}\n` +
      `   Ошибки: ${stats.videos.errors}\n` +
      `   Среднее время: ${stats.videos.avgTime}ms\n\n` +
      `🎵 Аудио:\n` +
      `   Обработано: ${stats.audio.processed}\n` +
      `   Ошибки: ${stats.audio.errors}\n` +
      `   Среднее время: ${stats.audio.avgTime}ms\n\n` +
      `💾 Кэш медиа:\n` +
      `   Файлов в кэше: ${stats.cache.files}\n` +
      `   Размер кэша: ${stats.cache.size}MB\n` +
      `   Временных файлов: ${stats.cache.tempFiles}`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения статистики медиа: ${error.message}`);
  }
});

// Очистка медиа кэша
bot.onText(/\/clear_media_cache/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!mediaProcessor) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль медиа обработки не доступен');
  }
  
  try {
    await mediaProcessor.cleanupMediaCache();
    await mediaProcessor.cleanupTempFiles();
    bot.sendMessage(msg.chat.id, '✅ Медиа кэш очищен');
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка очистки медиа кэша: ${error.message}`);
  }
});

// Мониторинг производительности
bot.onText(/\/performance/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!performanceMonitor) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль мониторинга не доступен');
  }
  
  try {
    const stats = await performanceMonitor.getPerformanceStats();
    const systemInfo = await performanceMonitor.getSystemInfo();
    
    const message = `📊 Производительность бота:\n\n` +
      `⚡ Обработка сообщений:\n` +
      `   Среднее время: ${stats.messageProcessing.avgTime}ms\n` +
      `   Максимальное время: ${stats.messageProcessing.maxTime}ms\n` +
      `   Всего сообщений: ${stats.messageProcessing.total}\n\n` +
      `💾 Память:\n` +
      `   Использовано: ${stats.memory.used}MB\n` +
      `   Всего: ${stats.memory.total}MB\n` +
      `   Процент: ${stats.memory.percentage}%\n\n` +
      `🖥️ CPU:\n` +
      `   Использование: ${stats.cpu.usage}%\n` +
      `   Нагрузка: ${stats.cpu.load}\n\n` +
      `❌ Ошибки:\n` +
      `   Всего: ${stats.errors.total}\n` +
      `   За последний час: ${stats.errors.lastHour}\n\n` +
      `🔍 Кэш:\n` +
      `   Hit Rate: ${stats.cache.hitRate}%\n` +
      `   Запросов: ${stats.cache.requests}\n` +
      `   Попаданий: ${stats.cache.hits}\n\n` +
      `📈 Очереди:\n` +
      `   Всего задач: ${stats.queues.totalJobs}\n` +
      `   Активных: ${stats.queues.activeJobs}\n` +
      `   Ожидающих: ${stats.queues.waitingJobs}`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения статистики производительности: ${error.message}`);
  }
});

// Проверка здоровья системы
bot.onText(/\/health_check/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  if (!performanceMonitor) {
    return bot.sendMessage(msg.chat.id, '❌ Модуль мониторинга не доступен');
  }
  
  try {
    const health = await performanceMonitor.runHealthChecks();
    let message = `🏥 Проверка здоровья системы:\n\n`;
    
    health.forEach(check => {
      const status = check.status ? '✅' : '❌';
      message += `${status} ${check.name}: ${check.message}\n`;
    });
    
    const allHealthy = health.every(check => check.status);
    message += `\n${allHealthy ? '🎉 Все системы работают нормально!' : '⚠️ Обнаружены проблемы!'}`;
    
    bot.sendMessage(msg.chat.id, message);
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка проверки здоровья: ${error.message}`);
  }
});

// Полная очистка и оптимизация
bot.onText(/\/optimize_all/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    let results = [];
    
    // Очистка кэша
    if (cacheManager) {
      try {
        await cacheManager.flush();
        results.push('✅ Кэш очищен');
      } catch (error) {
        results.push('❌ Ошибка очистки кэша');
      }
    }
    
    // Очистка очередей
    if (messageQueue) {
      try {
        await messageQueue.clearAll();
        results.push('✅ Очереди очищены');
      } catch (error) {
        results.push('❌ Ошибка очистки очередей');
      }
    }
    
    // Очистка медиа кэша
    if (mediaProcessor) {
      try {
        await mediaProcessor.cleanupMediaCache();
        await mediaProcessor.cleanupTempFiles();
        results.push('✅ Медиа кэш очищен');
      } catch (error) {
        results.push('❌ Ошибка очистки медиа кэша');
      }
    }
    
    // Принудительная сборка мусора
    if (global.gc) {
      global.gc();
      results.push('✅ Сборка мусора выполнена');
    }
    
    // Перезапуск WhatsApp бота
    exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
      if (err) {
        results.push('❌ Ошибка перезапуска WhatsApp бота');
      } else {
        results.push('✅ WhatsApp бот перезапущен');
      }
      
      const message = `🔧 Полная оптимизация завершена:\n\n${results.join('\n')}`;
      bot.sendMessage(msg.chat.id, message);
    });
    
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка оптимизации: ${error.message}`);
  }
});

// Детальная информация о системе
bot.onText(/\/system_info/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    const memUsage = process.memoryUsage();
    const uptime = process.uptime();
    const nodeVersion = process.version;
    const platform = process.platform;
    
    exec('cat /proc/loadavg', (err, loadOutput) => {
      exec('df -h / | tail -1', (err2, diskOutput) => {
        exec('free -m | grep Mem', (err3, memOutput) => {
          
          const load = loadOutput ? loadOutput.trim() : 'N/A';
          const disk = diskOutput ? diskOutput.trim() : 'N/A';
          const mem = memOutput ? memOutput.trim() : 'N/A';
          
          const message = `🖥️ Детальная информация о системе:\n\n` +
            `🤖 Процесс:\n` +
            `   Node.js: ${nodeVersion}\n` +
            `   Платформа: ${platform}\n` +
            `   Время работы: ${Math.floor(uptime / 3600)}ч ${Math.floor((uptime % 3600) / 60)}м\n` +
            `   RSS: ${(memUsage.rss / 1024 / 1024).toFixed(1)}MB\n` +
            `   Heap Used: ${(memUsage.heapUsed / 1024 / 1024).toFixed(1)}MB\n` +
            `   Heap Total: ${(memUsage.heapTotal / 1024 / 1024).toFixed(1)}MB\n\n` +
            `💻 Система:\n` +
            `   Нагрузка: ${load}\n` +
            `   Диск: ${disk}\n` +
            `   Память: ${mem}`;
          
          bot.sendMessage(msg.chat.id, message);
        });
      });
    });
    
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка получения информации о системе: ${error.message}`);
  }
});

// Автоматизированные команды для решения проблем

// Умная команда для получения рабочего QR-кода
bot.onText(/\/smart_qr/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    bot.sendMessage(msg.chat.id, '🔍 Проверяю статус WhatsApp бота...');
    
    // Проверяем статус бота
    exec(`pm2 show ${WHATSAPP_PM2_NAME}`, async (err, stdout, stderr) => {
      if (err) {
        bot.sendMessage(msg.chat.id, '❌ WhatsApp бот не запущен. Запускаю...');
        exec(`pm2 start ${WHATSAPP_PM2_NAME}`, (err2, stdout2, stderr2) => {
          if (err2) {
            bot.sendMessage(msg.chat.id, '❌ Ошибка запуска WhatsApp бота');
            return;
          }
          setTimeout(() => sendQRCode(msg.chat.id), 10000); // Ждем 10 секунд
        });
      } else {
        // Бот запущен, проверяем QR-код
        const qrPath = path.join(__dirname, 'qr.png');
        if (fs.existsSync(qrPath)) {
          const stats = fs.statSync(qrPath);
          const fileAge = Date.now() - stats.mtime.getTime();
          
          if (fileAge > 5 * 60 * 1000) { // QR старше 5 минут
            bot.sendMessage(msg.chat.id, '⚠️ QR-код устарел. Перезапускаю бота...');
            await resetAndRestart(msg.chat.id);
          } else {
            bot.sendMessage(msg.chat.id, '✅ QR-код актуален');
            bot.sendPhoto(msg.chat.id, fs.createReadStream(qrPath));
          }
        } else {
          bot.sendMessage(msg.chat.id, '📱 QR-код не найден. Перезапускаю бота...');
          await resetAndRestart(msg.chat.id);
        }
      }
    });
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка: ${error.message}`);
  }
});

// Автоматическое решение проблем с ботом
bot.onText(/\/fix_bot/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    bot.sendMessage(msg.chat.id, '🔧 Автоматическое исправление проблем...');
    
    const results = [];
    
    // 1. Очистка кэша
    if (cacheManager) {
      try {
        await cacheManager.flush();
        results.push('✅ Кэш очищен');
      } catch (error) {
        results.push('❌ Ошибка очистки кэша');
      }
    }
    
    // 2. Очистка очередей
    if (messageQueue) {
      try {
        await messageQueue.clearAll();
        results.push('✅ Очереди очищены');
      } catch (error) {
        results.push('❌ Ошибка очистки очередей');
      }
    }
    
    // 3. Очистка медиа кэша
    if (mediaProcessor) {
      try {
        await mediaProcessor.cleanupMediaCache();
        await mediaProcessor.cleanupTempFiles();
        results.push('✅ Медиа кэш очищен');
      } catch (error) {
        results.push('❌ Ошибка очистки медиа кэша');
      }
    }
    
    // 4. Сборка мусора
    if (global.gc) {
      global.gc();
      results.push('✅ Сборка мусора выполнена');
    }
    
    // 5. Перезапуск WhatsApp бота
    exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
      if (err) {
        results.push('❌ Ошибка перезапуска WhatsApp бота');
      } else {
        results.push('✅ WhatsApp бот перезапущен');
      }
      
      const message = `🔧 Автоматическое исправление завершено:\n\n${results.join('\n')}\n\n📱 Проверьте статус через 30 секунд командой /status`;
      bot.sendMessage(msg.chat.id, message);
    });
    
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка автоматического исправления: ${error.message}`);
  }
});

// Быстрая диагностика системы
bot.onText(/\/quick_check/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    bot.sendMessage(msg.chat.id, '🔍 Быстрая диагностика системы...');
    
    const checks = [];
    
    // Проверка статуса WhatsApp бота
    exec(`pm2 show ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
      if (err) {
        checks.push('❌ WhatsApp бот не запущен');
      } else {
        checks.push('✅ WhatsApp бот работает');
      }
      
      // Проверка памяти
      const memUsage = process.memoryUsage();
      const rssMB = (memUsage.rss / 1024 / 1024).toFixed(1);
      if (rssMB > 500) {
        checks.push(`⚠️ Высокое использование памяти: ${rssMB}MB`);
      } else {
        checks.push(`✅ Память в норме: ${rssMB}MB`);
      }
      
      // Проверка QR-кода
      const qrPath = path.join(__dirname, 'qr.png');
      if (fs.existsSync(qrPath)) {
        const stats = fs.statSync(qrPath);
        const fileAge = Date.now() - stats.mtime.getTime();
        if (fileAge > 5 * 60 * 1000) {
          checks.push('⚠️ QR-код устарел');
        } else {
          checks.push('✅ QR-код актуален');
        }
      } else {
        checks.push('❌ QR-код не найден');
      }
      
      // Проверка модулей оптимизации
      if (cacheManager) checks.push('✅ Модуль кэша доступен');
      if (messageQueue) checks.push('✅ Модуль очередей доступен');
      if (performanceMonitor) checks.push('✅ Модуль мониторинга доступен');
      
      const message = `🔍 Результаты диагностики:\n\n${checks.join('\n')}`;
      bot.sendMessage(msg.chat.id, message);
    });
    
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка диагностики: ${error.message}`);
  }
});

// Автоматическое обновление и перезапуск
bot.onText(/\/auto_update/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  try {
    bot.sendMessage(msg.chat.id, '🔄 Автоматическое обновление...');
    
    const results = [];
    
    // 1. Git pull
    exec('git pull', (err, stdout, stderr) => {
      if (err) {
        results.push('❌ Ошибка git pull');
      } else {
        results.push('✅ Код обновлен');
      }
      
      // 2. NPM install
      exec('npm install', (err2, stdout2, stderr2) => {
        if (err2) {
          results.push('❌ Ошибка npm install');
        } else {
          results.push('✅ Зависимости обновлены');
        }
        
        // 3. Перезапуск бота
        exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err3, stdout3, stderr3) => {
          if (err3) {
            results.push('❌ Ошибка перезапуска');
          } else {
            results.push('✅ Бот перезапущен');
          }
          
          const message = `🔄 Автоматическое обновление завершено:\n\n${results.join('\n')}\n\n📱 Проверьте статус через 30 секунд`;
          bot.sendMessage(msg.chat.id, message);
        });
      });
    });
    
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Ошибка автоматического обновления: ${error.message}`);
  }
});

// Помощник для решения проблем
bot.onText(/\/help_me/, async (msg) => {
  if (!onlyOwner(msg)) return;
  
  const helpMessage = `🤖 Помощник по решению проблем:\n\n` +
    `🔧 **Проблемы с QR-кодом:**\n` +
    `   /smart_qr - Получить рабочий QR-код\n` +
    `   /fix_bot - Автоматическое исправление\n\n` +
    `🔍 **Диагностика:**\n` +
    `   /quick_check - Быстрая проверка\n` +
    `   /performance - Детальная производительность\n` +
    `   /health_check - Проверка здоровья\n\n` +
    `🔄 **Обновления:**\n` +
    `   /auto_update - Автоматическое обновление\n` +
    `   /optimize_all - Полная оптимизация\n\n` +
    `📊 **Мониторинг:**\n` +
    `   /cache_stats - Статистика кэша\n` +
    `   /queue_stats - Статистика очередей\n` +
    `   /plugin_stats - Статистика плагинов\n\n` +
    `🚨 **Экстренные действия:**\n` +
    `   /restart_whatsapp - Перезапуск бота\n` +
    `   /full_reset - Полный сброс\n\n` +
    `💡 **Советы:**\n` +
    `• Используйте /smart_qr вместо /get_qr\n` +
    `• /fix_bot решает большинство проблем\n` +
    `• /quick_check для быстрой диагностики\n` +
    `• /auto_update для обновлений`;
  
  bot.sendMessage(msg.chat.id, helpMessage);
});

// Вспомогательные функции

async function resetAndRestart(chatId) {
  try {
    // Удаляем сессию
    const sessionPath = path.join(__dirname, 'LynxSession');
    if (fs.existsSync(sessionPath)) {
      fs.rmSync(sessionPath, { recursive: true, force: true });
    }
    
    // Перезапускаем бота
    exec(`pm2 restart ${WHATSAPP_PM2_NAME}`, (err, stdout, stderr) => {
      if (err) {
        bot.sendMessage(chatId, '❌ Ошибка перезапуска WhatsApp бота');
        return;
      }
      
      bot.sendMessage(chatId, '✅ WhatsApp бот перезапущен. Ожидаю QR-код...');
      
      // Ждем и отправляем QR-код
      setTimeout(() => sendQRCode(chatId), 15000); // 15 секунд
    });
  } catch (error) {
    bot.sendMessage(chatId, `❌ Ошибка: ${error.message}`);
  }
}

function sendQRCode(chatId) {
  const qrPath = path.join(__dirname, 'qr.png');
  if (fs.existsSync(qrPath)) {
    bot.sendMessage(chatId, '📱 Новый QR-код готов:');
    bot.sendPhoto(chatId, fs.createReadStream(qrPath));
  } else {
    bot.sendMessage(chatId, '❌ QR-код не найден. Попробуйте еще раз через минуту.');
  }
}

// Обновленная справка с новыми командами
bot.onText(/\/(start|help)/, (msg) => {
  if (!onlyOwner(msg)) return;
  bot.sendMessage(msg.chat.id, `Привет! Я бот для управления WhatsApp-ботом.\n\n🚀 **Умные команды:**\n/smart_qr — получить рабочий QR-код\n/fix_bot — автоматическое исправление проблем\n/quick_check — быстрая диагностика\n/auto_update — автоматическое обновление\n/help_me — помощник по решению проблем\n\n📋 **Основные команды:**\n/get_qr — получить QR-код\n/reset_session — сбросить сессию\n/restart_whatsapp — перезапустить WhatsApp-бота\n/start_whatsapp — запустить WhatsApp-бота\n/stop_whatsapp — остановить WhatsApp-бота\n/status — статус WhatsApp-бота\n/logs — последние логи WhatsApp-бота\n\n📊 **Мониторинг производительности:**\n/cache_stats — статистика кэша\n/clear_cache — очистить кэш\n/queue_stats — статистика очередей\n/clear_queues — очистить очереди\n/plugin_stats — статистика плагинов\n/media_stats — статистика медиа\n/clear_media_cache — очистить медиа кэш\n/performance — общая производительность\n/health_check — проверка здоровья\n/optimize_all — полная оптимизация\n/system_info — информация о системе\n\n🔧 **Управление:**\n/update_code — git pull\n/npm_install — npm install\n/full_reset — полный сброс\n/memory — использование памяти\n/clean_memory — очистка памяти\n/system_stats — статистика системы\n\n💡 **Рекомендации:**\n• Используйте /smart_qr вместо /get_qr\n• /fix_bot решает большинство проблем\n• /help_me для получения помощи\n\n/help — показать эту справку`);
}); 