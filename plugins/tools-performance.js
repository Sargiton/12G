import fetch from 'node-fetch'
import { performance } from 'perf_hooks'

let handler = async (m, { conn, usedPrefix, command, args }) => {
  let pp = 'https://i.ibb.co/0MZ0QGY/images-1.jpg'
  
  // Импорт оптимизированных модулей
  const cacheManager = await import('../../lib/cache.js').then(m => m.default);
  const messageQueue = await import('../../lib/queue.js').then(m => m.default);
  const performanceMonitor = await import('../../lib/monitor.js').then(m => m.default);
  const mediaProcessor = await import('../../lib/mediaProcessor.js').then(m => m.default);
  const pluginManager = await import('../../lib/pluginManager.js').then(m => m.default);

  const subcommand = args[0]?.toLowerCase();

  switch (subcommand) {
    case 'memory':
    case 'mem':
      await showMemoryStats(m, conn, pp);
      break;
      
    case 'cache':
      await showCacheStats(m, conn, pp);
      break;
      
    case 'queues':
    case 'queue':
      await showQueueStats(m, conn, pp);
      break;
      
    case 'plugins':
    case 'plugin':
      await showPluginStats(m, conn, pp);
      break;
      
    case 'media':
      await showMediaStats(m, conn, pp);
      break;
      
    case 'system':
    case 'sys':
      await showSystemStats(m, conn, pp);
      break;
      
    case 'clean':
    case 'clear':
      await cleanMemory(m, conn, pp);
      break;
      
    case 'health':
      await showHealthStatus(m, conn, pp);
      break;
      
    default:
      await showMainMenu(m, conn, pp);
  }
}

async function showMainMenu(m, conn, pp) {
  const menu = `╭━━━『 *PERFORMANCE MONITOR* 』━━━╮
┃
┃ 📊 *Команды мониторинга:*
┃
┃ • ${usedPrefix}${command} memory
┃   Показать использование памяти
┃
┃ • ${usedPrefix}${command} cache
┃   Статистика кэша
┃
┃ • ${usedPrefix}${command} queues
┃   Статистика очередей
┃
┃ • ${usedPrefix}${command} plugins
┃   Статистика плагинов
┃
┃ • ${usedPrefix}${command} media
┃   Статистика обработки медиа
┃
┃ • ${usedPrefix}${command} system
┃   Системная информация
┃
┃ • ${usedPrefix}${command} health
┃   Статус здоровья системы
┃
┃ • ${usedPrefix}${command} clean
┃   Очистить память и кэш
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`

  await conn.sendFile(m.chat, pp, 'menu.jpg', menu, m)
}

async function showMemoryStats(m, conn, pp) {
  const stats = performanceMonitor.getPerformanceStats();
  const memUsage = process.memoryUsage();
  
  const memoryInfo = `╭━━━『 *MEMORY STATS* 』━━━╮
┃
┃ 💾 *Использование памяти:*
┃
┃ • RSS: ${stats.memory.current.rss}
┃ • Heap Used: ${stats.memory.current.heapUsed}
┃ • Heap Total: ${stats.memory.current.heapTotal}
┃ • External: ${stats.memory.current.external}
┃ • System Free: ${stats.memory.systemFree}
┃
┃ 📈 *Среднее использование:*
┃ • ${stats.memory.average}
┃
┃ ⏱️ *Время работы:*
┃ • ${stats.uptime.formatted}
┃
┃ 📊 *Сообщения:*
┃ • Всего: ${stats.messages.total}
┃ • Ошибки: ${stats.messages.errors}
┃ • Ошибок: ${stats.messages.errorRate}%
┃ • Среднее время: ${stats.messages.avgResponseTime}ms
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`

  await conn.sendFile(m.chat, pp, 'memory.jpg', memoryInfo, m)
}

async function showCacheStats(m, conn, pp) {
  const stats = cacheManager.getStats();
  
  const cacheInfo = `╭━━━『 *CACHE STATS* 』━━━╮
┃
┃ 🗄️ *NodeCache:*
┃ • Ключи: ${stats.nodeCache.keys}
┃ • Попадания: ${stats.nodeCache.hits}
┃ • Промахи: ${stats.nodeCache.misses}
┃ • Hit Rate: ${stats.nodeCache.hitRate.toFixed(2)}%
┃
┃ 🔴 *Redis:*
┃ • Статус: ${stats.redis}
┃
┃ 📊 *Производительность:*
┃ • Эффективность кэша: ${stats.nodeCache.hitRate > 80 ? '✅ Отличная' : stats.nodeCache.hitRate > 60 ? '⚠️ Хорошая' : '❌ Низкая'}
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`

  await conn.sendFile(m.chat, pp, 'cache.jpg', cacheInfo, m)
}

async function showQueueStats(m, conn, pp) {
  const stats = await messageQueue.getStats();
  
  let queueInfo = `╭━━━『 *QUEUE STATS* 』━━━╮
┃
┃ 📥 *Статистика очередей:*
┃
`;

  for (const [name, queue] of Object.entries(stats)) {
    queueInfo += `┃ 🔸 *${name.toUpperCase()}:*
┃ • Ожидает: ${queue.waiting}
┃ • Активно: ${queue.active}
┃ • Завершено: ${queue.completed}
┃ • Ошибок: ${queue.failed}
┃ • Всего: ${queue.total}
┃
`;
  }

  queueInfo += `╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

  await conn.sendFile(m.chat, pp, 'queues.jpg', queueInfo, m)
}

async function showPluginStats(m, conn, pp) {
  const stats = pluginManager.getPluginStats();
  
  const pluginInfo = `╭━━━『 *PLUGIN STATS* 』━━━╮
┃
┃ 📦 *Общая статистика:*
┃ • Всего плагинов: ${stats.total}
┃ • Загружено: ${stats.loaded}
┃ • Общий размер: ${(stats.totalSize / 1024).toFixed(2)} KB
┃
┃ 📂 *По категориям:*
`;

  for (const [category, info] of Object.entries(stats.categories)) {
    pluginInfo += `┃ • ${category}: ${info.count} (${info.loaded} загружено)
`;
  }

  pluginInfo += `
┃ 🔥 *Топ используемых:*
`;

  stats.topUsed.slice(0, 5).forEach((plugin, index) => {
    pluginInfo += `┃ ${index + 1}. ${plugin.name}: ${plugin.loadCount} раз
`;
  });

  pluginInfo += `
┃ ❌ *Топ ошибок:*
`;

  stats.topErrors.slice(0, 3).forEach((plugin, index) => {
    pluginInfo += `┃ ${index + 1}. ${plugin.name}: ${plugin.errorCount} ошибок
`;
  });

  pluginInfo += `
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

  await conn.sendFile(m.chat, pp, 'plugins.jpg', pluginInfo, m)
}

async function showMediaStats(m, conn, pp) {
  const stats = mediaProcessor.getStats();
  
  const mediaInfo = `╭━━━『 *MEDIA STATS* 』━━━╮
┃
┃ 📁 *Настройки обработки:*
┃ • Макс. размер: ${(stats.maxFileSize / 1024 / 1024).toFixed(0)}MB
┃ • Поддерживаемые форматы: ${stats.supportedFormats.length}
┃
┃ 📂 *Директории:*
┃ • Временные файлы: ${stats.tempDir}
┃ • Кэш медиа: ${stats.cacheDir}
┃
┃ 🎨 *Поддерживаемые форматы:*
┃ • ${stats.supportedFormats.join(', ')}
┃
┃ ⚡ *Оптимизации:*
┃ • Сжатие изображений
┃ • Кэширование результатов
┃ • Автоматическая очистка
┃ • Асинхронная обработка
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

  await conn.sendFile(m.chat, pp, 'media.jpg', mediaInfo, m)
}

async function showSystemStats(m, conn, pp) {
  const stats = performanceMonitor.getSystemInfo();
  
  const systemInfo = `╭━━━『 *SYSTEM STATS* 』━━━╮
┃
┃ 💻 *Системная информация:*
┃ • Платформа: ${stats.platform}
┃ • Архитектура: ${stats.arch}
┃ • Node.js: ${stats.nodeVersion}
┃ • CPU ядер: ${stats.cpus}
┃
┃ 💾 *Память:*
┃ • Всего: ${stats.totalMemory}
┃ • Свободно: ${stats.freeMemory}
┃
┃ 📊 *Нагрузка:*
┃ • Load Average: ${stats.loadAverage.join(', ')}
┃ • Время работы системы: ${stats.uptime}
┃
┃ ⚡ *Оптимизации:*
┃ • Ограничение памяти: 1GB
┃ • Принудительная сборка мусора
┃ • Мониторинг производительности
┃ • Автоматическое восстановление
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

  await conn.sendFile(m.chat, pp, 'system.jpg', systemInfo, m)
}

async function showHealthStatus(m, conn, pp) {
  const health = performanceMonitor.getHealthStatus();
  
  let healthInfo = `╭━━━『 *HEALTH STATUS* 』━━━╮
┃
┃ 🏥 *Общий статус:*
┃ • ${health.overall === 'healthy' ? '✅ Здоров' : '❌ Проблемы'}
┃
┃ 🔍 *Проверки:*
┃
`;

  for (const [name, check] of Object.entries(health.checks)) {
    const status = check.status === 'healthy' ? '✅' : check.status === 'unhealthy' ? '❌' : '⚠️';
    healthInfo += `┃ ${status} ${name}: ${check.status}
`;
  }

  healthInfo += `
┃ 📊 *Рекомендации:*
┃ • Регулярно проверяйте логи
┃ • Мониторьте использование памяти
┃ • Обновляйте плагины при необходимости
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

  await conn.sendFile(m.chat, pp, 'health.jpg', healthInfo, m)
}

async function cleanMemory(m, conn, pp) {
  try {
    // Очистка кэша
    await cacheManager.flush();
    
    // Очистка очередей
    await messageQueue.clearAll();
    
    // Сброс метрик
    performanceMonitor.resetMetrics();
    
    // Принудительная сборка мусора
    if (global.gc) {
      global.gc();
    }
    
    const cleanInfo = `╭━━━『 *MEMORY CLEANED* 』━━━╮
┃
┃ ✅ *Очистка завершена:*
┃ • Кэш очищен
┃ • Очереди очищены
┃ • Метрики сброшены
┃ • Сборка мусора выполнена
┃
┃ 💾 *Текущая память:*
┃ • ${(process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2)} MB
┃
┃ ⚡ *Система оптимизирована*
┃
╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯`;

    await conn.sendFile(m.chat, pp, 'clean.jpg', cleanInfo, m)
  } catch (error) {
    await m.reply(`❌ Ошибка при очистке: ${error.message}`);
  }
}

handler.help = ['performance [memory|cache|queues|plugins|media|system|health|clean]']
handler.tags = ['tools']
handler.command = ['performance', 'perf', 'stats']

handler.owner = false
handler.mods = false
handler.premium = false
handler.group = false
handler.private = false

handler.admin = false
handler.botAdmin = false

handler.fail = null

export default handler
