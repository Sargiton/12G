import os from 'os';
import { performance } from 'perf_hooks';
import NodeCache from 'node-cache';

class PerformanceMonitor {
  constructor() {
    this.metrics = {
      startTime: Date.now(),
      messageCount: 0,
      errorCount: 0,
      avgResponseTime: 0,
      memoryUsage: [],
      cpuUsage: [],
      activeConnections: 0,
      cacheHits: 0,
      cacheMisses: 0,
      queueStats: {}
    };
    
    this.healthChecks = new Map();
    this.alerts = [];
    this.metricsCache = new NodeCache({ stdTTL: 300 }); // 5 минут
    
    this.startMonitoring();
  }

  // Запуск мониторинга
  startMonitoring() {
    // Мониторинг памяти каждые 30 секунд
    setInterval(() => {
      this.recordMemoryUsage();
    }, 30000);

    // Мониторинг CPU каждую минуту
    setInterval(() => {
      this.recordCpuUsage();
    }, 60000);

    // Очистка старых метрик каждые 5 минут
    setInterval(() => {
      this.cleanupOldMetrics();
    }, 300000);

    // Проверка здоровья системы каждые 2 минуты
    setInterval(() => {
      this.runHealthChecks();
    }, 120000);

    console.log('📊 Performance monitoring started');
  }

  // Запись использования памяти
  recordMemoryUsage() {
    const memUsage = process.memoryUsage();
    const systemMem = os.freemem() / os.totalmem() * 100;
    
    this.metrics.memoryUsage.push({
      timestamp: Date.now(),
      rss: memUsage.rss,
      heapUsed: memUsage.heapUsed,
      heapTotal: memUsage.heapTotal,
      external: memUsage.external,
      systemFree: systemMem
    });

    // Ограничиваем количество записей
    if (this.metrics.memoryUsage.length > 100) {
      this.metrics.memoryUsage.shift();
    }

    // Проверяем критическое использование памяти
    if (systemMem < 10) {
      this.addAlert('CRITICAL', 'Low system memory', { freeMemory: systemMem });
    } else if (systemMem < 20) {
      this.addAlert('WARNING', 'Low system memory', { freeMemory: systemMem });
    }
  }

  // Запись использования CPU
  recordCpuUsage() {
    const cpuUsage = process.cpuUsage();
    const loadAvg = os.loadavg();
    
    this.metrics.cpuUsage.push({
      timestamp: Date.now(),
      user: cpuUsage.user,
      system: cpuUsage.system,
      loadAverage: loadAvg
    });

    if (this.metrics.cpuUsage.length > 60) {
      this.metrics.cpuUsage.shift();
    }

    // Проверяем высокую нагрузку CPU
    if (loadAvg[0] > os.cpus().length * 0.8) {
      this.addAlert('WARNING', 'High CPU load', { loadAverage: loadAvg[0] });
    }
  }

  // Очистка старых метрик
  cleanupOldMetrics() {
    const now = Date.now();
    const fiveMinutesAgo = now - 300000;

    this.metrics.memoryUsage = this.metrics.memoryUsage.filter(
      record => record.timestamp > fiveMinutesAgo
    );

    this.metrics.cpuUsage = this.metrics.cpuUsage.filter(
      record => record.timestamp > fiveMinutesAgo
    );

    // Очищаем старые алерты
    this.alerts = this.alerts.filter(
      alert => alert.timestamp > now - 3600000 // 1 час
    );
  }

  // Добавление health check
  addHealthCheck(name, checkFunction, interval = 60000) {
    this.healthChecks.set(name, {
      function: checkFunction,
      interval,
      lastCheck: 0,
      status: 'unknown',
      lastError: null
    });
  }

  // Выполнение health checks
  async runHealthChecks() {
    const now = Date.now();
    
    for (const [name, check] of this.healthChecks) {
      if (now - check.lastCheck >= check.interval) {
        try {
          const result = await check.function();
          check.status = result ? 'healthy' : 'unhealthy';
          check.lastError = null;
          check.lastCheck = now;
          
          if (!result) {
            this.addAlert('WARNING', `Health check failed: ${name}`);
          }
        } catch (error) {
          check.status = 'error';
          check.lastError = error.message;
          check.lastCheck = now;
          this.addAlert('ERROR', `Health check error: ${name}`, { error: error.message });
        }
      }
    }
  }

  // Добавление алерта
  addAlert(level, message, data = {}) {
    const alert = {
      level,
      message,
      data,
      timestamp: Date.now()
    };
    
    this.alerts.push(alert);
    console.log(`🚨 [${level}] ${message}`, data);
    
    // Ограничиваем количество алертов
    if (this.alerts.length > 100) {
      this.alerts.shift();
    }
  }

  // Запись метрики сообщения
  recordMessage(processingTime) {
    this.metrics.messageCount++;
    
    // Обновляем среднее время ответа
    const total = this.metrics.avgResponseTime * (this.metrics.messageCount - 1) + processingTime;
    this.metrics.avgResponseTime = total / this.metrics.messageCount;
  }

  // Запись ошибки
  recordError(error) {
    this.metrics.errorCount++;
    this.addAlert('ERROR', 'Message processing error', { error: error.message });
  }

  // Запись статистики кэша
  recordCacheHit() {
    this.metrics.cacheHits++;
  }

  recordCacheMiss() {
    this.metrics.cacheMisses++;
  }

  // Обновление статистики очередей
  updateQueueStats(stats) {
    this.metrics.queueStats = stats;
  }

  // Получение статистики производительности
  getPerformanceStats() {
    const uptime = Date.now() - this.metrics.startTime;
    const memoryUsage = process.memoryUsage();
    const systemMem = os.freemem() / os.totalmem() * 100;
    
    // Вычисляем среднее использование памяти за последние 5 минут
    const recentMemory = this.metrics.memoryUsage.slice(-10);
    const avgMemoryUsage = recentMemory.length > 0 
      ? recentMemory.reduce((sum, record) => sum + record.heapUsed, 0) / recentMemory.length
      : 0;

    // Вычисляем среднее использование CPU
    const recentCpu = this.metrics.cpuUsage.slice(-5);
    const avgCpuUsage = recentCpu.length > 0
      ? recentCpu.reduce((sum, record) => sum + record.loadAverage[0], 0) / recentCpu.length
      : 0;

    return {
      uptime: {
        total: uptime,
        formatted: this.formatUptime(uptime)
      },
      messages: {
        total: this.metrics.messageCount,
        errors: this.metrics.errorCount,
        errorRate: this.metrics.messageCount > 0 
          ? (this.metrics.errorCount / this.metrics.messageCount * 100).toFixed(2)
          : 0,
        avgResponseTime: this.metrics.avgResponseTime.toFixed(2)
      },
      memory: {
        current: {
          rss: this.formatBytes(memoryUsage.rss),
          heapUsed: this.formatBytes(memoryUsage.heapUsed),
          heapTotal: this.formatBytes(memoryUsage.heapTotal),
          external: this.formatBytes(memoryUsage.external)
        },
        average: this.formatBytes(avgMemoryUsage),
        systemFree: systemMem.toFixed(2) + '%'
      },
      cpu: {
        current: os.loadavg(),
        average: avgCpuUsage.toFixed(2)
      },
      cache: {
        hits: this.metrics.cacheHits,
        misses: this.metrics.cacheMisses,
        hitRate: (this.metrics.cacheHits + this.metrics.cacheMisses) > 0
          ? (this.metrics.cacheHits / (this.metrics.cacheHits + this.metrics.cacheMisses) * 100).toFixed(2)
          : 0
      },
      queues: this.metrics.queueStats,
      health: this.getHealthStatus(),
      alerts: this.alerts.slice(-10) // Последние 10 алертов
    };
  }

  // Получение статуса здоровья системы
  getHealthStatus() {
    const health = {
      overall: 'healthy',
      checks: {}
    };

    for (const [name, check] of this.healthChecks) {
      health.checks[name] = {
        status: check.status,
        lastCheck: check.lastCheck,
        lastError: check.lastError
      };
      
      if (check.status !== 'healthy') {
        health.overall = 'unhealthy';
      }
    }

    return health;
  }

  // Форматирование времени работы
  formatUptime(ms) {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days}d ${hours % 24}h ${minutes % 60}m`;
    if (hours > 0) return `${hours}h ${minutes % 60}m`;
    if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
    return `${seconds}s`;
  }

  // Форматирование байтов
  formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  // Получение детальной информации о системе
  getSystemInfo() {
    return {
      platform: os.platform(),
      arch: os.arch(),
      nodeVersion: process.version,
      cpus: os.cpus().length,
      totalMemory: this.formatBytes(os.totalmem()),
      freeMemory: this.formatBytes(os.freemem()),
      loadAverage: os.loadavg(),
      uptime: this.formatUptime(os.uptime() * 1000)
    };
  }

  // Экспорт метрик для внешних систем мониторинга
  exportMetrics() {
    return {
      timestamp: Date.now(),
      metrics: this.getPerformanceStats(),
      system: this.getSystemInfo()
    };
  }

  // Сброс метрик
  resetMetrics() {
    this.metrics = {
      startTime: Date.now(),
      messageCount: 0,
      errorCount: 0,
      avgResponseTime: 0,
      memoryUsage: [],
      cpuUsage: [],
      activeConnections: 0,
      cacheHits: 0,
      cacheMisses: 0,
      queueStats: {}
    };
    
    this.alerts = [];
    console.log('🔄 Performance metrics reset');
  }
}

// Создаем глобальный экземпляр монитора
const performanceMonitor = new PerformanceMonitor();

module.exports = performanceMonitor;
