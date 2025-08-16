import NodeCache from 'node-cache';

class CacheManager {
  constructor() {
    this.nodeCache = new NodeCache({
      stdTTL: 3600, // 1 час по умолчанию
      checkperiod: 600, // проверка каждые 10 минут
      maxKeys: 1000
    });
    
    this.redisClient = null;
    this.redisEnabled = false; // Полностью отключаем Redis
    
    console.log('✅ Cache manager initialized (NodeCache only)');
  }

  async initRedis() {
    // Redis полностью отключен
    console.log('⚠️ Redis disabled - using NodeCache only');
    this.redisClient = null;
    this.redisEnabled = false;
  }

  async get(key) {
    try {
      // Сначала проверяем NodeCache
      const value = this.nodeCache.get(key);
      if (value !== undefined) {
        return value;
      }
      
      return null;
    } catch (error) {
      console.log('❌ Cache get error:', error.message);
      return null;
    }
  }

  async set(key, value, ttl = 3600) {
    try {
      this.nodeCache.set(key, value, ttl);
      return true;
    } catch (error) {
      console.log('❌ Cache set error:', error.message);
      return false;
    }
  }

  async delete(key) {
    try {
      this.nodeCache.del(key);
      return true;
    } catch (error) {
      console.log('❌ Cache delete error:', error.message);
      return false;
    }
  }

  async clear() {
    try {
      this.nodeCache.flushAll();
      return true;
    } catch (error) {
      console.log('❌ Cache clear error:', error.message);
      return false;
    }
  }

  async getStats() {
    try {
      return {
        nodeCache: {
          keys: this.nodeCache.keys().length,
          stats: this.nodeCache.getStats()
        },
        redis: {
          enabled: this.redisEnabled,
          connected: false
        }
      };
    } catch (error) {
      console.log('❌ Cache stats error:', error.message);
      return {
        nodeCache: { keys: 0, stats: {} },
        redis: { enabled: false, connected: false }
      };
    }
  }

  // Специальный метод для QR кодов
  async setQRCode(key, qrData, ttl = 300) { // 5 минут для QR
    try {
      const qrKey = `qr_${key}`;
      this.nodeCache.set(qrKey, qrData, ttl);
      console.log(`✅ QR code cached: ${qrKey}`);
      return true;
    } catch (error) {
      console.log('❌ QR cache error:', error.message);
      return false;
    }
  }

  async getQRCode(key) {
    try {
      const qrKey = `qr_${key}`;
      return this.nodeCache.get(qrKey);
    } catch (error) {
      console.log('❌ QR get error:', error.message);
      return null;
    }
  }

  async clearQRCode(key) {
    try {
      const qrKey = `qr_${key}`;
      this.nodeCache.del(qrKey);
      console.log(`🗑️ QR code cleared: ${qrKey}`);
      return true;
    } catch (error) {
      console.log('❌ QR clear error:', error.message);
      return false;
    }
  }
}

const cacheManager = new CacheManager();
export default cacheManager;
