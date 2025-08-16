import sharp from 'sharp';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { performance } from 'perf_hooks';
import cacheManager from './cache.js';
import messageQueue from './queue.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class MediaProcessor {
  constructor() {
    this.tempDir = path.join(__dirname, '../tmp');
    this.cacheDir = path.join(__dirname, '../storage/media-cache');
    this.maxFileSize = 50 * 1024 * 1024; // 50MB
    this.supportedFormats = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'mp4', 'mp3', 'ogg', 'wav'];
    
    // Статистика обработки
    this.stats = {
      images: { processed: 0, errors: 0, totalTime: 0, avgTime: 0 },
      videos: { processed: 0, errors: 0, totalTime: 0, avgTime: 0 },
      audio: { processed: 0, errors: 0, totalTime: 0, avgTime: 0 }
    };
    
    this.ensureDirectories();
    this.startCleanup();
  }

  // Создание необходимых директорий
  async ensureDirectories() {
    await fs.ensureDir(this.tempDir);
    await fs.ensureDir(this.cacheDir);
  }

  // Запуск периодической очистки
  startCleanup() {
    // Очистка временных файлов каждые 30 минут
    setInterval(() => {
      this.cleanupTempFiles();
    }, 30 * 60 * 1000);

    // Очистка кэша медиа каждые 2 часа
    setInterval(() => {
      this.cleanupMediaCache();
    }, 2 * 60 * 60 * 1000);
  }

  // Обработка изображения
  async processImage(buffer, options = {}) {
    const startTime = performance.now();
    
    try {
      const {
        quality = 80,
        width,
        height,
        format = 'webp',
        blur = 0,
        sharpen = 0
      } = options;

      // Проверяем кэш
      const cacheKey = this.generateCacheKey(buffer, options);
      const cached = await cacheManager.getMediaCache(cacheKey);
      if (cached) {
        console.log(`📸 Image served from cache: ${cacheKey}`);
        return cached;
      }

      let sharpInstance = sharp(buffer);

      // Применяем преобразования
      if (width || height) {
        sharpInstance = sharpInstance.resize(width, height, {
          fit: 'inside',
          withoutEnlargement: true
        });
      }

      if (blur > 0) {
        sharpInstance = sharpInstance.blur(blur);
      }

      if (sharpen > 0) {
        sharpInstance = sharpInstance.sharpen(sharpen);
      }

      // Конвертируем в нужный формат
      let processedBuffer;
      switch (format.toLowerCase()) {
        case 'webp':
          processedBuffer = await sharpInstance.webp({ quality }).toBuffer();
          break;
        case 'jpeg':
        case 'jpg':
          processedBuffer = await sharpInstance.jpeg({ quality }).toBuffer();
          break;
        case 'png':
          processedBuffer = await sharpInstance.png({ quality }).toBuffer();
          break;
        default:
          processedBuffer = await sharpInstance.webp({ quality }).toBuffer();
      }

      const processingTime = performance.now() - startTime;
      console.log(`📸 Image processed in ${processingTime.toFixed(2)}ms`);

      // Обновляем статистику
      this.stats.images.processed++;
      this.stats.images.totalTime += processingTime;
      this.stats.images.avgTime = this.stats.images.totalTime / this.stats.images.processed;

      // Кэшируем результат
      await cacheManager.setMediaCache(cacheKey, processedBuffer, 1800); // 30 минут

      return processedBuffer;
    } catch (error) {
      console.error('❌ Image processing error:', error);
      this.stats.images.errors++;
      throw error;
    }
  }

  // Обработка видео (базовая оптимизация)
  async processVideo(buffer, options = {}) {
    const startTime = performance.now();
    
    try {
      const {
        quality = 'medium',
        format = 'mp4',
        maxDuration = 60 // максимальная длительность в секундах
      } = options;

      // Проверяем кэш
      const cacheKey = this.generateCacheKey(buffer, options);
      const cached = await cacheManager.getMediaCache(cacheKey);
      if (cached) {
        console.log(`🎥 Video served from cache: ${cacheKey}`);
        return cached;
      }

      // Сохраняем во временный файл
      const tempFile = path.join(this.tempDir, `video_${Date.now()}.${format}`);
      await fs.writeFile(tempFile, buffer);

      // Здесь можно добавить обработку видео с помощью ffmpeg
      // Пока возвращаем исходный буфер
      const processedBuffer = buffer;

      const processingTime = performance.now() - startTime;
      console.log(`🎥 Video processed in ${processingTime.toFixed(2)}ms`);

      // Кэшируем результат
      await cacheManager.setMediaCache(cacheKey, processedBuffer, 3600); // 1 час

      // Удаляем временный файл
      await fs.remove(tempFile);

      return processedBuffer;
    } catch (error) {
      console.error('❌ Video processing error:', error);
      throw error;
    }
  }

  // Обработка аудио
  async processAudio(buffer, options = {}) {
    const startTime = performance.now();
    
    try {
      const {
        quality = 128,
        format = 'mp3',
        normalize = true
      } = options;

      // Проверяем кэш
      const cacheKey = this.generateCacheKey(buffer, options);
      const cached = await cacheManager.getMediaCache(cacheKey);
      if (cached) {
        console.log(`🎵 Audio served from cache: ${cacheKey}`);
        return cached;
      }

      // Сохраняем во временный файл
      const tempFile = path.join(this.tempDir, `audio_${Date.now()}.${format}`);
      await fs.writeFile(tempFile, buffer);

      // Здесь можно добавить обработку аудио с помощью ffmpeg
      // Пока возвращаем исходный буфер
      const processedBuffer = buffer;

      const processingTime = performance.now() - startTime;
      console.log(`🎵 Audio processed in ${processingTime.toFixed(2)}ms`);

      // Кэшируем результат
      await cacheManager.setMediaCache(cacheKey, processedBuffer, 3600); // 1 час

      // Удаляем временный файл
      await fs.remove(tempFile);

      return processedBuffer;
    } catch (error) {
      console.error('❌ Audio processing error:', error);
      throw error;
    }
  }

  // Универсальная обработка медиа
  async processMedia(buffer, options = {}) {
    const startTime = performance.now();
    
    try {
      // Определяем тип медиа
      const mediaType = this.detectMediaType(buffer);
      
      if (!mediaType) {
        throw new Error('Unsupported media type');
      }

      // Проверяем размер файла
      if (buffer.length > this.maxFileSize) {
        throw new Error(`File too large: ${(buffer.length / 1024 / 1024).toFixed(2)}MB`);
      }

      let processedBuffer;
      switch (mediaType) {
        case 'image':
          processedBuffer = await this.processImage(buffer, options);
          break;
        case 'video':
          processedBuffer = await this.processVideo(buffer, options);
          break;
        case 'audio':
          processedBuffer = await this.processAudio(buffer, options);
          break;
        default:
          processedBuffer = buffer;
      }

      const processingTime = performance.now() - startTime;
      console.log(`📁 Media processed in ${processingTime.toFixed(2)}ms`);

      return {
        buffer: processedBuffer,
        type: mediaType,
        originalSize: buffer.length,
        processedSize: processedBuffer.length,
        compressionRatio: ((buffer.length - processedBuffer.length) / buffer.length * 100).toFixed(2),
        processingTime: processingTime.toFixed(2)
      };
    } catch (error) {
      console.error('❌ Media processing error:', error);
      throw error;
    }
  }

  // Асинхронная обработка медиа через очередь
  async processMediaAsync(buffer, options = {}) {
    return new Promise((resolve, reject) => {
      messageQueue.addMedia(
        { id: Date.now().toString(), buffer, options },
        async (mediaData) => {
          try {
            const result = await this.processMedia(mediaData.buffer, mediaData.options);
            resolve(result);
          } catch (error) {
            reject(error);
          }
        }
      );
    });
  }

  // Определение типа медиа
  detectMediaType(buffer) {
    // Проверяем сигнатуры файлов
    const signatures = {
      image: {
        jpg: [0xFF, 0xD8, 0xFF],
        png: [0x89, 0x50, 0x4E, 0x47],
        webp: [0x52, 0x49, 0x46, 0x46],
        gif: [0x47, 0x49, 0x46, 0x38]
      },
      video: {
        mp4: [0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70],
        avi: [0x52, 0x49, 0x46, 0x46]
      },
      audio: {
        mp3: [0x49, 0x44, 0x33],
        wav: [0x52, 0x49, 0x46, 0x46]
      }
    };

    for (const [type, formats] of Object.entries(signatures)) {
      for (const [format, signature] of Object.entries(formats)) {
        if (this.checkSignature(buffer, signature)) {
          return type;
        }
      }
    }

    return null;
  }

  // Проверка сигнатуры файла
  checkSignature(buffer, signature) {
    if (buffer.length < signature.length) return false;
    
    for (let i = 0; i < signature.length; i++) {
      if (buffer[i] !== signature[i]) return false;
    }
    
    return true;
  }

  // Генерация ключа кэша
  generateCacheKey(buffer, options) {
    const hash = require('crypto').createHash('md5');
    hash.update(buffer);
    hash.update(JSON.stringify(options));
    return hash.digest('hex');
  }

  // Очистка временных файлов
  async cleanupTempFiles() {
    try {
      const files = await fs.readdir(this.tempDir);
      const now = Date.now();
      const maxAge = 30 * 60 * 1000; // 30 минут

      for (const file of files) {
        const filePath = path.join(this.tempDir, file);
        const stats = await fs.stat(filePath);
        
        if (now - stats.mtime.getTime() > maxAge) {
          await fs.remove(filePath);
          console.log(`🗑️ Cleaned up temp file: ${file}`);
        }
      }
    } catch (error) {
      console.error('❌ Temp cleanup error:', error);
    }
  }

  // Очистка кэша медиа
  async cleanupMediaCache() {
    try {
      const files = await fs.readdir(this.cacheDir);
      const now = Date.now();
      const maxAge = 24 * 60 * 60 * 1000; // 24 часа

      for (const file of files) {
        const filePath = path.join(this.cacheDir, file);
        const stats = await fs.stat(filePath);
        
        if (now - stats.mtime.getTime() > maxAge) {
          await fs.remove(filePath);
          console.log(`🗑️ Cleaned up cache file: ${file}`);
        }
      }
    } catch (error) {
      console.error('❌ Cache cleanup error:', error);
    }
  }

  // Получение статистики обработки
  async getStats() {
    try {
      // Подсчет файлов в кэше
      let cacheFiles = 0;
      let cacheSize = 0;
      try {
        const cacheFilesList = await fs.readdir(this.cacheDir);
        cacheFiles = cacheFilesList.length;
        
        for (const file of cacheFilesList) {
          const filePath = path.join(this.cacheDir, file);
          const stats = await fs.stat(filePath);
          cacheSize += stats.size;
        }
      } catch (error) {
        // Кэш директория может не существовать
      }
      
      // Подсчет временных файлов
      let tempFiles = 0;
      try {
        const tempFilesList = await fs.readdir(this.tempDir);
        tempFiles = tempFilesList.length;
      } catch (error) {
        // Временная директория может не существовать
      }
      
      return {
        images: {
          processed: this.stats.images?.processed || 0,
          errors: this.stats.images?.errors || 0,
          avgTime: this.stats.images?.avgTime || 0
        },
        videos: {
          processed: this.stats.videos?.processed || 0,
          errors: this.stats.videos?.errors || 0,
          avgTime: this.stats.videos?.avgTime || 0
        },
        audio: {
          processed: this.stats.audio?.processed || 0,
          errors: this.stats.audio?.errors || 0,
          avgTime: this.stats.audio?.avgTime || 0
        },
        cache: {
          files: cacheFiles,
          size: (cacheSize / 1024 / 1024).toFixed(1),
          tempFiles: tempFiles
        }
      };
    } catch (error) {
      console.error('❌ Error getting media stats:', error);
      return {
        images: { processed: 0, errors: 0, avgTime: 0 },
        videos: { processed: 0, errors: 0, avgTime: 0 },
        audio: { processed: 0, errors: 0, avgTime: 0 },
        cache: { files: 0, size: '0.0', tempFiles: 0 }
      };
    }
  }

  // Оптимизация изображения для WhatsApp
  async optimizeForWhatsApp(buffer, type = 'image') {
    const options = {
      quality: 85,
      format: 'webp',
      width: 1024,
      height: 1024
    };

    if (type === 'image') {
      return await this.processImage(buffer, options);
    }

    return buffer;
  }

  // Создание превью изображения
  async createThumbnail(buffer, size = 200) {
    return await this.processImage(buffer, {
      width: size,
      height: size,
      quality: 70,
      format: 'webp'
    });
  }
}

// Создаем глобальный экземпляр процессора медиа
const mediaProcessor = new MediaProcessor();

module.exports = mediaProcessor;
