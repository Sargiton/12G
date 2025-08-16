import Queue from 'bull';
import Redis from 'redis';

class MessageQueue {
  constructor() {
    this.queues = {};
    this.redisClient = null;
    this.initRedis();
    this.initQueues();
  }

  async initRedis() {
    try {
      // Временно отключаем Redis для работы без него
      console.log('⚠️ Redis temporarily disabled for local development');
      this.redisClient = null;
      return;
      
      this.redisClient = Redis.createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379'
      });
      await this.redisClient.connect();
    } catch (error) {
      console.log('⚠️ Redis not available for queues, using in-memory fallback');
    }
  }

  initQueues() {
    // Очередь для высокоприоритетных сообщений (команды владельца, админов)
    this.queues.high = new Queue('high-priority', {
      redis: process.env.REDIS_URL || 'redis://localhost:6379',
      defaultJobOptions: {
        removeOnComplete: 100,
        removeOnFail: 50,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000
        }
      }
    });

    // Очередь для обычных сообщений
    this.queues.normal = new Queue('normal-priority', {
      redis: process.env.REDIS_URL || 'redis://localhost:6379',
      defaultJobOptions: {
        removeOnComplete: 50,
        removeOnFail: 25,
        attempts: 2,
        backoff: {
          type: 'exponential',
          delay: 5000
        }
      }
    });

    // Очередь для медиа-обработки
    this.queues.media = new Queue('media-processing', {
      redis: process.env.REDIS_URL || 'redis://localhost:6379',
      defaultJobOptions: {
        removeOnComplete: 20,
        removeOnFail: 10,
        attempts: 1,
        timeout: 300000 // 5 минут
      }
    });

    // Очередь для API запросов
    this.queues.api = new Queue('api-requests', {
      redis: process.env.REDIS_URL || 'redis://localhost:6379',
      defaultJobOptions: {
        removeOnComplete: 100,
        removeOnFail: 50,
        attempts: 2,
        timeout: 60000 // 1 минута
      }
    });

    // Настройка обработчиков
    this.setupProcessors();
  }

  setupProcessors() {
    // Обработчик высокоприоритетных сообщений
    this.queues.high.process(async (job) => {
      try {
        const { message, handler } = job.data;
        console.log(`🔄 Processing high priority message: ${message.key.id}`);
        
        // Выполняем обработку
        const result = await handler(message);
        
        console.log(`✅ High priority message processed: ${message.key.id}`);
        return result;
      } catch (error) {
        console.error(`❌ High priority message error:`, error);
        throw error;
      }
    });

    // Обработчик обычных сообщений
    this.queues.normal.process(async (job) => {
      try {
        const { message, handler } = job.data;
        console.log(`🔄 Processing normal message: ${message.key.id}`);
        
        const result = await handler(message);
        
        console.log(`✅ Normal message processed: ${message.key.id}`);
        return result;
      } catch (error) {
        console.error(`❌ Normal message error:`, error);
        throw error;
      }
    });

    // Обработчик медиа
    this.queues.media.process(async (job) => {
      try {
        const { mediaData, processor } = job.data;
        console.log(`🔄 Processing media: ${mediaData.id}`);
        
        const result = await processor(mediaData);
        
        console.log(`✅ Media processed: ${mediaData.id}`);
        return result;
      } catch (error) {
        console.error(`❌ Media processing error:`, error);
        throw error;
      }
    });

    // Обработчик API запросов
    this.queues.api.process(async (job) => {
      try {
        const { apiData, requester } = job.data;
        console.log(`🔄 Processing API request: ${apiData.url}`);
        
        const result = await requester(apiData);
        
        console.log(`✅ API request processed: ${apiData.url}`);
        return result;
      } catch (error) {
        console.error(`❌ API request error:`, error);
        throw error;
      }
    });

    // Обработка ошибок
    this.queues.high.on('failed', (job, err) => {
      console.error(`High priority job failed:`, job.id, err.message);
    });

    this.queues.normal.on('failed', (job, err) => {
      console.error(`Normal job failed:`, job.id, err.message);
    });

    this.queues.media.on('failed', (job, err) => {
      console.error(`Media job failed:`, job.id, err.message);
    });

    this.queues.api.on('failed', (job, err) => {
      console.error(`API job failed:`, job.id, err.message);
    });
  }

  // Добавление сообщения в очередь
  async addMessage(message, handler, priority = 'normal') {
    try {
      const queue = priority === 'high' ? this.queues.high : this.queues.normal;
      
      const job = await queue.add({
        message,
        handler
      }, {
        priority: priority === 'high' ? 1 : 5,
        delay: priority === 'high' ? 0 : 1000 // задержка 1 секунда для обычных сообщений
      });

      console.log(`📥 Message added to ${priority} queue: ${message.key.id}`);
      return job;
    } catch (error) {
      console.error(`❌ Failed to add message to queue:`, error);
      throw error;
    }
  }

  // Добавление медиа в очередь обработки
  async addMedia(mediaData, processor) {
    try {
      const job = await this.queues.media.add({
        mediaData,
        processor
      });

      console.log(`📥 Media added to processing queue: ${mediaData.id}`);
      return job;
    } catch (error) {
      console.error(`❌ Failed to add media to queue:`, error);
      throw error;
    }
  }

  // Добавление API запроса в очередь
  async addApiRequest(apiData, requester) {
    try {
      const job = await this.queues.api.add({
        apiData,
        requester
      });

      console.log(`📥 API request added to queue: ${apiData.url}`);
      return job;
    } catch (error) {
      console.error(`❌ Failed to add API request to queue:`, error);
      throw error;
    }
  }

  // Получение статистики очередей
  async getStats() {
    try {
      const stats = {};
      
      for (const [name, queue] of Object.entries(this.queues)) {
        const waiting = await queue.getWaiting();
        const active = await queue.getActive();
        const completed = await queue.getCompleted();
        const failed = await queue.getFailed();
        
        stats[name] = {
          waiting: waiting.length,
          active: active.length,
          completed: completed.length,
          failed: failed.length,
          total: waiting.length + active.length + completed.length + failed.length
        };
      }
      
      return {
        highPriority: stats.high || { waiting: 0, active: 0, completed: 0, failed: 0 },
        normal: stats.normal || { waiting: 0, active: 0, completed: 0, failed: 0 },
        media: stats.media || { waiting: 0, active: 0, completed: 0, failed: 0 },
        api: stats.api || { waiting: 0, active: 0, completed: 0, failed: 0 }
      };
    } catch (error) {
      console.error(`❌ Failed to get queue stats:`, error);
      return {
        highPriority: { waiting: 0, active: 0, completed: 0, failed: 0 },
        normal: { waiting: 0, active: 0, completed: 0, failed: 0 },
        media: { waiting: 0, active: 0, completed: 0, failed: 0 },
        api: { waiting: 0, active: 0, completed: 0, failed: 0 }
      };
    }
  }

  // Очистка всех очередей
  async clearAll() {
    try {
      for (const queue of Object.values(this.queues)) {
        await queue.empty();
      }
      console.log(`🧹 All queues cleared`);
    } catch (error) {
      console.error(`❌ Failed to clear queues:`, error);
    }
  }

  // Пауза всех очередей
  async pauseAll() {
    try {
      for (const queue of Object.values(this.queues)) {
        await queue.pause();
      }
      console.log(`⏸️ All queues paused`);
    } catch (error) {
      console.error(`❌ Failed to pause queues:`, error);
    }
  }

  // Возобновление всех очередей
  async resumeAll() {
    try {
      for (const queue of Object.values(this.queues)) {
        await queue.resume();
      }
      console.log(`▶️ All queues resumed`);
    } catch (error) {
      console.error(`❌ Failed to resume queues:`, error);
    }
  }

  // Закрытие всех очередей
  async close() {
    try {
      for (const queue of Object.values(this.queues)) {
        await queue.close();
      }
      if (this.redisClient) {
        await this.redisClient.quit();
      }
      console.log(`🔒 All queues closed`);
    } catch (error) {
      console.error(`❌ Failed to close queues:`, error);
    }
  }
}

// Создаем глобальный экземпляр очереди
const messageQueue = new MessageQueue();

export default messageQueue;
