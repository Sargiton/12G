import NodeCache from 'node-cache';

class MessageQueue {
  constructor() {
    this.queues = new Map();
    this.redisClient = null;
    this.redisEnabled = false; // Полностью отключаем Redis
    
    // Кэш для быстрого доступа
    this.cache = new NodeCache({
      stdTTL: 300,
      checkperiod: 60,
      maxKeys: 500
    });
    
    console.log('✅ Message queue initialized (in-memory only)');
  }

  async initRedis() {
    // Redis полностью отключен
    console.log('⚠️ Redis disabled for queues - using in-memory fallback');
    this.redisClient = null;
    this.redisEnabled = false;
  }

  async addToQueue(queueName, message, priority = 0) {
    try {
      if (!this.queues.has(queueName)) {
        this.queues.set(queueName, []);
      }
      
      const queue = this.queues.get(queueName);
      const queueItem = {
        id: Date.now() + Math.random(),
        message,
        priority,
        timestamp: Date.now()
      };
      
      // Добавляем в начало очереди если высокий приоритет
      if (priority > 0) {
        queue.unshift(queueItem);
      } else {
        queue.push(queueItem);
      }
      
      // Ограничиваем размер очереди
      if (queue.length > 1000) {
        queue.splice(0, queue.length - 1000);
      }
      
      console.log(`✅ Message added to queue: ${queueName} (${queue.length} items)`);
      return queueItem.id;
    } catch (error) {
      console.log('❌ Queue add error:', error.message);
      return null;
    }
  }

  async getFromQueue(queueName) {
    try {
      if (!this.queues.has(queueName)) {
        return null;
      }
      
      const queue = this.queues.get(queueName);
      if (queue.length === 0) {
        return null;
      }
      
      const item = queue.shift();
      console.log(`📤 Message processed from queue: ${queueName} (${queue.length} remaining)`);
      return item;
    } catch (error) {
      console.log('❌ Queue get error:', error.message);
      return null;
    }
  }

  async getQueueStats(queueName) {
    try {
      if (!this.queues.has(queueName)) {
        return { length: 0, oldest: null, newest: null };
      }
      
      const queue = this.queues.get(queueName);
      return {
        length: queue.length,
        oldest: queue.length > 0 ? queue[0].timestamp : null,
        newest: queue.length > 0 ? queue[queue.length - 1].timestamp : null
      };
    } catch (error) {
      console.log('❌ Queue stats error:', error.message);
      return { length: 0, oldest: null, newest: null };
    }
  }

  async getAllStats() {
    try {
      const stats = {};
      for (const [queueName, queue] of this.queues) {
        stats[queueName] = await this.getQueueStats(queueName);
      }
      return stats;
    } catch (error) {
      console.log('❌ All queue stats error:', error.message);
      return {};
    }
  }

  async clearQueue(queueName) {
    try {
      if (this.queues.has(queueName)) {
        this.queues.set(queueName, []);
        console.log(`🗑️ Queue cleared: ${queueName}`);
      }
      return true;
    } catch (error) {
      console.log('❌ Queue clear error:', error.message);
      return false;
    }
  }

  async clearAllQueues() {
    try {
      this.queues.clear();
      console.log('🗑️ All queues cleared');
      return true;
    } catch (error) {
      console.log('❌ Clear all queues error:', error.message);
      return false;
    }
  }

  // Специальные методы для WhatsApp
  async addWhatsAppMessage(message, priority = 0) {
    return await this.addToQueue('whatsapp', message, priority);
  }

  async getWhatsAppMessage() {
    return await this.getFromQueue('whatsapp');
  }

  // Специальные методы для Telegram
  async addTelegramMessage(message, priority = 0) {
    return await this.addToQueue('telegram', message, priority);
  }

  async getTelegramMessage() {
    return await this.getFromQueue('telegram');
  }

  // Специальные методы для медиа
  async addMediaTask(task, priority = 1) {
    return await this.addToQueue('media', task, priority);
  }

  async getMediaTask() {
    return await this.getFromQueue('media');
  }
}

const messageQueue = new MessageQueue();
export default messageQueue;
