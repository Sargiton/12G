import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('🔍 ТЕСТ СРЕДЫ ВЫПОЛНЕНИЯ');
console.log('========================');

// Информация о системе
console.log('\n📊 Система:');
console.log('Node.js версия:', process.version);
console.log('Платформа:', process.platform);
console.log('Архитектура:', process.arch);
console.log('Текущая директория:', process.cwd());

// Проверяем package.json
console.log('\n📄 package.json:');
try {
    const packagePath = join(process.cwd(), 'package.json');
    if (fs.existsSync(packagePath)) {
        const packageData = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
        console.log('✅ package.json найден');
        console.log('Версия проекта:', packageData.version);
        
        // Проверяем baileys
        if (packageData.dependencies && packageData.dependencies['@whiskeysockets/baileys']) {
            console.log('✅ @whiskeysockets/baileys в dependencies:', packageData.dependencies['@whiskeysockets/baileys']);
        } else {
            console.log('❌ @whiskeysockets/baileys НЕ найден в dependencies');
        }
    } else {
        console.log('❌ package.json не найден');
    }
} catch (error) {
    console.log('❌ Ошибка чтения package.json:', error.message);
}

// Проверяем node_modules
console.log('\n📦 node_modules:');
const nodeModulesPath = join(process.cwd(), 'node_modules');
if (fs.existsSync(nodeModulesPath)) {
    console.log('✅ node_modules найден');
    
    // Проверяем @whiskeysockets/baileys
    const baileysPath = join(nodeModulesPath, '@whiskeysockets', 'baileys');
    if (fs.existsSync(baileysPath)) {
        console.log('✅ @whiskeysockets/baileys установлен');
        try {
            const baileysPackage = JSON.parse(fs.readFileSync(join(baileysPath, 'package.json'), 'utf8'));
            console.log('Версия @whiskeysockets/baileys:', baileysPackage.version);
        } catch (error) {
            console.log('❌ Ошибка чтения версии @whiskeysockets/baileys');
        }
    } else {
        console.log('❌ @whiskeysockets/baileys НЕ установлен');
    }
    
    // Проверяем baileys
    const baileysOldPath = join(nodeModulesPath, 'baileys');
    if (fs.existsSync(baileysOldPath)) {
        console.log('✅ baileys установлен');
        try {
            const baileysOldPackage = JSON.parse(fs.readFileSync(join(baileysOldPath, 'package.json'), 'utf8'));
            console.log('Версия baileys:', baileysOldPackage.version);
        } catch (error) {
            console.log('❌ Ошибка чтения версии baileys');
        }
    } else {
        console.log('❌ baileys НЕ установлен');
    }
} else {
    console.log('❌ node_modules не найден');
}

// Тестируем импорт baileys
console.log('\n🧪 Тест импорта baileys:');
try {
    console.log('Пытаемся импортировать @whiskeysockets/baileys...');
    const { default: makeWASocket } = await import('@whiskeysockets/baileys');
    console.log('✅ @whiskeysockets/baileys импортирован успешно');
    console.log('Тип makeWASocket:', typeof makeWASocket);
} catch (error) {
    console.log('❌ Ошибка импорта @whiskeysockets/baileys:', error.message);
}

try {
    console.log('Пытаемся импортировать baileys...');
    const { default: makeWASocketOld } = await import('baileys');
    console.log('✅ baileys импортирован успешно');
    console.log('Тип makeWASocket:', typeof makeWASocketOld);
} catch (error) {
    console.log('❌ Ошибка импорта baileys:', error.message);
}

// Проверяем переменные окружения
console.log('\n🌍 Переменные окружения:');
console.log('NODE_ENV:', process.env.NODE_ENV || 'не установлена');
console.log('NODE_OPTIONS:', process.env.NODE_OPTIONS || 'не установлена');

console.log('\n✅ ТЕСТ ЗАВЕРШЕН');
