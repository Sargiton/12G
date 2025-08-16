import Redis from 'redis';
import { promisify } from 'util';
import NodeCache from 'node-cache';

class CacheManager {
  constructor() {
    this.redisClient = null;
    this.nodeCache = new NodeCache({ 
      stdTTL: 300, // 5 минут по умолчанию
      checkperiod: 60, // проверка каждую минуту
      maxKeys: 1000 // максимум 1000 ключей в памяти
    });
    
    this.initRedis();
  }

  async initRedis() {
    try {
      // Временно отключаем Redis для работы без него
      console.log('⚠️ Redis temporarily disabled for local development');
      this.redisClient = null;
      return;
      
      this.redisClient = Redis.createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379',
        retry_strategy: (options) => {
          if (options.error && options.error.code === 'ECONNREFUSED') {
            console.log('Redis server refused connection');
            return new Error('Redis server refused connection');
          }
          if (options.total_retry_time > 1000 * 60 * 60) {
            return new Error('Retry time exhausted');
          }
          if (options.attempt > 10) {
            return undefined;
          }
          return Math.min(options.attempt * 100, 3000);
        }
      });

      this.redisClient.on('error', (err) => {
        console.log('Redis Client Error:', err);
      });

      this.redisClient.on('connect', () => {
        console.log('✅ Redis connected successfully');
      });

      await this.redisClient.connect();
    } catch (error) {
      console.log('⚠️ Redis not available, using NodeCache only:', error.message);
      this.redisClient = null;
    }
  }

  // Универсальный метод получения данных
  async get(key, useRedis = true) {
    try {
      // Сначала проверяем NodeCache
      const nodeCacheValue = this.nodeCache.get(key);
      if (nodeCacheValue !== undefined) {
        return nodeCacheValue;
      }

      // Если Redis доступен, проверяем его
      if (useRedis && this.redisClient) {
        const redisValue = await this.redisClient.get(key);
        if (redisValue) {
          const parsed = JSON.parse(redisValue);
          // Кэшируем в NodeCache для быстрого доступа
          this.nodeCache.set(key, parsed, 60); // 1 минута в NodeCache
          return parsed;
        }
      }
      
      return null;
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  }

  // Универсальный метод сохранения данных
  async set(key, value, ttl = 300, useRedis = true) {
    try {
      // Сохраняем в NodeCache
      this.nodeCache.set(key, value, ttl);

      // Если Redis доступен, сохраняем и туда
      if (useRedis && this.redisClient) {
        await this.redisClient.setEx(key, ttl, JSON.stringify(value));
      }
      
      return true;
    } catch (error) {
      console.error('Cache set error:', error);
      return false;
    }
  }

  // Удаление данных
  async del(key, useRedis = true) {
    try {
      this.nodeCache.del(key);
      
      if (useRedis && this.redisClient) {
        await this.redisClient.del(key);
      }
      
      return true;
    } catch (error) {
      console.error('Cache del error:', error);
      return false;
    }
  }

  // Очистка всего кэша
  async flush() {
    try {
      this.nodeCache.flushAll();
      
      if (this.redisClient) {
        await this.redisClient.flushAll();
      }
      
      return true;
    } catch (error) {
      console.error('Cache flush error:', error);
      return false;
    }
  }

  // Получение статистики кэша
  async getStats() {
    const nodeCacheStats = this.nodeCache.getStats();
    const totalRequests = nodeCacheStats.hits + nodeCacheStats.misses;
    const hitRate = totalRequests > 0 ? (nodeCacheStats.hits / totalRequests * 100).toFixed(1) : 0;
    
    let redisStats = {
      connected: false,
      keys: 'N/A',
      memory: 'N/A'
    };
    
    if (this.redisClient) {
      try {
        redisStats.connected = true;
        const keys = await this.redisClient.dbSize();
        redisStats.keys = keys;
        
        // Попытка получить информацию о памяти Redis
        try {
          const info = await this.redisClient.info('memory');
          const usedMemoryMatch = info.match(/used_memory_human:(\S+)/);
          redisStats.memory = usedMemoryMatch ? usedMemoryMatch[1] : 'N/A';
        } catch (e) {
          redisStats.memory = 'N/A';
        }
      } catch (error) {
        redisStats.connected = false;
      }
    }
    
    return {
      redis: redisStats,
      nodeCache: {
        keys: nodeCacheStats.keys,
        memory: (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(1),
        hitRate: hitRate
      },
      total: {
        requests: totalRequests,
        hits: nodeCacheStats.hits,
        misses: nodeCacheStats.misses,
        hitRate: hitRate
      }
    };
  }

  // Специальные методы для пользователей
  async getUser(userId) {
    return await this.get(`user:${userId}`, true);
  }

  async setUser(userId, userData) {
    return await this.set(`user:${userId}`, userData, 600, true); // 10 минут
  }

  // Специальные методы для чатов
  async getChat(chatId) {
    return await this.get(`chat:${chatId}`, true);
  }

  async setChat(chatId, chatData) {
    return await this.set(`chat:${chatId}`, chatData, 600, true); // 10 минут
  }

  // Специальные методы для настроек
  async getSettings(key) {
    return await this.get(`settings:${key}`, true);
  }

  async setSettings(key, settingsData) {
    return await this.set(`settings:${key}`, settingsData, 1800, true); // 30 минут
  }

  // Специальные методы для API кэша
  async getApiCache(url) {
    return await this.get(`api:${Buffer.from(url).toString('base64')}`, true);
  }

  async setApiCache(url, data, ttl = 300) {
    return await this.set(`api:${Buffer.from(url).toString('base64')}`, data, ttl, true);
  }

  // Методы для медиа кэша
  async getMediaCache(mediaId) {
    return await this.get(`media:${mediaId}`, false); // только NodeCache для медиа
  }

  async setMediaCache(mediaId, mediaData, ttl = 120) {
    return await this.set(`media:${mediaId}`, mediaData, ttl, false); // только NodeCache
  }

  // Закрытие соединений
  async close() {
    if (this.redisClient) {
      await this.redisClient.quit();
    }
  }
}

// Создаем глобальный экземпляр кэш-менеджера
const cacheManager = new CacheManager();

export default cacheManager;
