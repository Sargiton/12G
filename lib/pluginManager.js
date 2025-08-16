import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { performance } from 'perf_hooks';
import cacheManager from './cache.js';
import performanceMonitor from './monitor.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class PluginManager {
  constructor() {
    this.pluginsDir = path.join(__dirname, '../plugins');
    this.loadedPlugins = new Map();
    this.pluginCache = new Map();
    this.pluginStats = new Map();
    this.categories = {
      owner: [],
      admin: [],
      group: [],
      fun: [],
      tools: [],
      download: [],
      ai: [],
      media: [],
      info: [],
      other: []
    };
    
    this.startMonitoring();
  }

  // Запуск мониторинга плагинов
  startMonitoring() {
    // Обновление статистики каждые 5 минут
    setInterval(() => {
      this.updatePluginStats();
    }, 5 * 60 * 1000);

    // Очистка неиспользуемых плагинов каждые 30 минут
    setInterval(() => {
      this.cleanupUnusedPlugins();
    }, 30 * 60 * 1000);
  }

  // Сканирование и категоризация плагинов
  async scanPlugins() {
    try {
      const files = await fs.readdir(this.pluginsDir);
      const pluginFiles = files.filter(file => file.endsWith('.js') && !file.startsWith('_'));

      for (const file of pluginFiles) {
        const pluginPath = path.join(this.pluginsDir, file);
        const pluginInfo = await this.analyzePlugin(pluginPath);
        
        if (pluginInfo) {
          this.categorizePlugin(file, pluginInfo);
          this.pluginStats.set(file, {
            loadCount: 0,
            lastUsed: 0,
            avgLoadTime: 0,
            errorCount: 0,
            size: pluginInfo.size
          });
        }
      }

      console.log(`📦 Scanned ${pluginFiles.length} plugins, categorized into ${Object.keys(this.categories).length} categories`);
      return this.categories;
    } catch (error) {
      console.error('❌ Plugin scanning error:', error);
      return {};
    }
  }

  // Анализ плагина
  async analyzePlugin(pluginPath) {
    try {
      const stats = await fs.stat(pluginPath);
      const content = await fs.readFile(pluginPath, 'utf8');
      
      // Извлекаем информацию о плагине
      const info = {
        size: stats.size,
        modified: stats.mtime,
        hasCommand: /command\s*[:=]/.test(content),
        hasHelp: /help\s*[:=]/.test(content),
        hasTags: /tags\s*[:=]/.test(content),
        hasOwner: /owner\s*[:=]/.test(content),
        hasAdmin: /admin\s*[:=]/.test(content),
        hasGroup: /group\s*[:=]/.test(content),
        dependencies: this.extractDependencies(content)
      };

      return info;
    } catch (error) {
      console.error(`❌ Plugin analysis error for ${pluginPath}:`, error);
      return null;
    }
  }

  // Извлечение зависимостей плагина
  extractDependencies(content) {
    const dependencies = [];
    const requireRegex = /(?:import|require)\s*\(?['"`]([^'"`]+)['"`]\)?/g;
    let match;

    while ((match = requireRegex.exec(content)) !== null) {
      dependencies.push(match[1]);
    }

    return dependencies;
  }

  // Категоризация плагина
  categorizePlugin(filename, info) {
    const name = filename.toLowerCase();
    
    if (info.hasOwner || name.includes('owner') || name.includes('propietario')) {
      this.categories.owner.push(filename);
    } else if (info.hasAdmin || name.includes('admin')) {
      this.categories.admin.push(filename);
    } else if (info.hasGroup || name.includes('group') || name.includes('grupo')) {
      this.categories.group.push(filename);
    } else if (name.includes('fun') || name.includes('game')) {
      this.categories.fun.push(filename);
    } else if (name.includes('dl-') || name.includes('download')) {
      this.categories.download.push(filename);
    } else if (name.includes('ai-') || name.includes('chatgpt') || name.includes('gemini')) {
      this.categories.ai.push(filename);
    } else if (name.includes('img-') || name.includes('audio-') || name.includes('video-')) {
      this.categories.media.push(filename);
    } else if (name.includes('info-') || name.includes('ping')) {
      this.categories.info.push(filename);
    } else if (name.includes('tools-') || name.includes('convert')) {
      this.categories.tools.push(filename);
    } else {
      this.categories.other.push(filename);
    }
  }

  // Lazy loading плагина
  async loadPlugin(pluginName, forceReload = false) {
    const startTime = performance.now();
    
    try {
      // Проверяем кэш
      if (!forceReload && this.pluginCache.has(pluginName)) {
        const cached = this.pluginCache.get(pluginName);
        this.updatePluginStats(pluginName, performance.now() - startTime);
        return cached;
      }

      // Проверяем, загружен ли уже плагин
      if (!forceReload && this.loadedPlugins.has(pluginName)) {
        this.updatePluginStats(pluginName, performance.now() - startTime);
        return this.loadedPlugins.get(pluginName);
      }

      const pluginPath = path.join(this.pluginsDir, pluginName);
      
      if (!await fs.pathExists(pluginPath)) {
        throw new Error(`Plugin not found: ${pluginName}`);
      }

      // Загружаем плагин
      const pluginModule = await import(pluginPath);
      const plugin = pluginModule.default || pluginModule;

      // Кэшируем плагин
      this.loadedPlugins.set(pluginName, plugin);
      this.pluginCache.set(pluginName, plugin);

      const loadTime = performance.now() - startTime;
      this.updatePluginStats(pluginName, loadTime);

      console.log(`📦 Plugin loaded: ${pluginName} (${loadTime.toFixed(2)}ms)`);
      return plugin;

    } catch (error) {
      console.error(`❌ Plugin loading error for ${pluginName}:`, error);
      this.recordPluginError(pluginName, error);
      throw error;
    }
  }

  // Загрузка плагинов по категории
  async loadCategory(category, forceReload = false) {
    const plugins = this.categories[category] || [];
    const results = [];

    for (const plugin of plugins) {
      try {
        const loadedPlugin = await this.loadPlugin(plugin, forceReload);
        results.push({ name: plugin, success: true, plugin: loadedPlugin });
      } catch (error) {
        results.push({ name: plugin, success: false, error: error.message });
      }
    }

    return results;
  }

  // Загрузка всех плагинов (не рекомендуется для больших проектов)
  async loadAllPlugins(forceReload = false) {
    const allPlugins = Object.values(this.categories).flat();
    const results = [];

    console.log(`🔄 Loading ${allPlugins.length} plugins...`);

    for (const plugin of allPlugins) {
      try {
        const loadedPlugin = await this.loadPlugin(plugin, forceReload);
        results.push({ name: plugin, success: true, plugin: loadedPlugin });
      } catch (error) {
        results.push({ name: plugin, success: false, error: error.message });
      }
    }

    const successCount = results.filter(r => r.success).length;
    console.log(`✅ Loaded ${successCount}/${allPlugins.length} plugins successfully`);

    return results;
  }

  // Поиск плагина по команде
  async findPluginByCommand(command) {
    const allPlugins = Object.values(this.categories).flat();
    
    for (const pluginName of allPlugins) {
      try {
        const plugin = await this.loadPlugin(pluginName);
        
        if (plugin && plugin.command && plugin.command === command) {
          return { name: pluginName, plugin };
        }
      } catch (error) {
        // Пропускаем плагины с ошибками
        continue;
      }
    }

    return null;
  }

  // Поиск плагинов по тегу
  async findPluginsByTag(tag) {
    const allPlugins = Object.values(this.categories).flat();
    const results = [];

    for (const pluginName of allPlugins) {
      try {
        const plugin = await this.loadPlugin(pluginName);
        
        if (plugin && plugin.tags && plugin.tags.includes(tag)) {
          results.push({ name: pluginName, plugin });
        }
      } catch (error) {
        // Пропускаем плагины с ошибками
        continue;
      }
    }

    return results;
  }

  // Обновление статистики плагина
  updatePluginStats(pluginName, loadTime) {
    const stats = this.pluginStats.get(pluginName) || {
      loadCount: 0,
      lastUsed: 0,
      avgLoadTime: 0,
      errorCount: 0,
      size: 0
    };

    stats.loadCount++;
    stats.lastUsed = Date.now();
    
    // Обновляем среднее время загрузки
    const total = stats.avgLoadTime * (stats.loadCount - 1) + loadTime;
    stats.avgLoadTime = total / stats.loadCount;

    this.pluginStats.set(pluginName, stats);
  }

  // Запись ошибки плагина
  recordPluginError(pluginName, error) {
    const stats = this.pluginStats.get(pluginName) || {
      loadCount: 0,
      lastUsed: 0,
      avgLoadTime: 0,
      errorCount: 0,
      size: 0
    };

    stats.errorCount++;
    this.pluginStats.set(pluginName, stats);
  }

  // Очистка неиспользуемых плагинов
  cleanupUnusedPlugins() {
    const now = Date.now();
    const maxAge = 60 * 60 * 1000; // 1 час

    for (const [pluginName, plugin] of this.loadedPlugins) {
      const stats = this.pluginStats.get(pluginName);
      
      if (stats && (now - stats.lastUsed) > maxAge) {
        this.loadedPlugins.delete(pluginName);
        console.log(`🗑️ Unloaded unused plugin: ${pluginName}`);
      }
    }
  }

  // Получение статистики плагинов
  getPluginStats() {
    const stats = {
      total: 0,
      loaded: this.loadedPlugins.size,
      unloaded: 0,
      errors: 0,
      categories: {},
      topUsed: [],
      recentErrors: [],
      totalSize: 0
    };

    // Статистика по категориям
    for (const [category, plugins] of Object.entries(this.categories)) {
      stats.categories[category] = {
        count: plugins.length,
        loaded: plugins.filter(p => this.loadedPlugins.has(p)).length
      };
      stats.total += plugins.length;
    }

    stats.unloaded = stats.total - stats.loaded;

    // Топ используемых плагинов
    const sortedByUsage = Array.from(this.pluginStats.entries())
      .sort((a, b) => b[1].loadCount - a[1].loadCount)
      .slice(0, 5);

    stats.topUsed = sortedByUsage.map(([name, stat]) => ({
      name,
      usage: stat.loadCount
    }));

    // Последние ошибки плагинов
    const pluginsWithErrors = Array.from(this.pluginStats.entries())
      .filter(([name, stat]) => stat.errorCount > 0)
      .sort((a, b) => b[1].lastUsed - a[1].lastUsed)
      .slice(0, 3);

    stats.recentErrors = pluginsWithErrors.map(([name, stat]) => ({
      plugin: name,
      error: `Ошибок: ${stat.errorCount}`
    }));

    // Общий размер
    stats.totalSize = Array.from(this.pluginStats.values())
      .reduce((sum, stat) => sum + stat.size, 0);

    return stats;
  }

  // Получение информации о плагине
  getPluginInfo(pluginName) {
    const plugin = this.loadedPlugins.get(pluginName);
    const stats = this.pluginStats.get(pluginName);

    if (!plugin || !stats) {
      return null;
    }

    return {
      name: pluginName,
      command: plugin.command,
      help: plugin.help,
      tags: plugin.tags,
      owner: plugin.owner,
      admin: plugin.admin,
      group: plugin.group,
      stats: {
        loadCount: stats.loadCount,
        lastUsed: stats.lastUsed,
        avgLoadTime: stats.avgLoadTime.toFixed(2),
        errorCount: stats.errorCount,
        size: stats.size
      }
    };
  }

  // Перезагрузка плагина
  async reloadPlugin(pluginName) {
    try {
      // Удаляем из кэша
      this.loadedPlugins.delete(pluginName);
      this.pluginCache.delete(pluginName);

      // Загружаем заново
      const plugin = await this.loadPlugin(pluginName, true);
      
      console.log(`🔄 Plugin reloaded: ${pluginName}`);
      return plugin;
    } catch (error) {
      console.error(`❌ Plugin reload error for ${pluginName}:`, error);
      throw error;
    }
  }

  // Получение списка всех плагинов
  getAllPlugins() {
    return {
      categories: this.categories,
      loaded: Array.from(this.loadedPlugins.keys()),
      stats: this.getPluginStats()
    };
  }
}

// Создаем глобальный экземпляр менеджера плагинов
const pluginManager = new PluginManager();

export default pluginManager;
