import fs from 'fs';
import path from 'path';

console.log('🧹 Очистка кэша QR кодов...');

// Очистка временных файлов
const tmpDir = './tmp';
if (fs.existsSync(tmpDir)) {
    const files = fs.readdirSync(tmpDir);
    files.forEach(file => {
        if (file.includes('qr') || file.includes('QR') || file.endsWith('.png') || file.endsWith('.jpg')) {
            try {
                fs.unlinkSync(path.join(tmpDir, file));
                console.log(`🗑️ Удален: ${file}`);
            } catch (err) {
                console.log(`❌ Ошибка удаления ${file}:`, err.message);
            }
        }
    });
}

// Очистка кэша в storage
const storageDir = './storage/data';
if (fs.existsSync(storageDir)) {
    const files = fs.readdirSync(storageDir);
    files.forEach(file => {
        if (file.includes('cache') || file.includes('qr')) {
            try {
                fs.unlinkSync(path.join(storageDir, file));
                console.log(`🗑️ Удален кэш: ${file}`);
            } catch (err) {
                console.log(`❌ Ошибка удаления кэша ${file}:`, err.message);
            }
        }
    });
}

// Очистка QR файлов в корне
const rootFiles = fs.readdirSync('.');
rootFiles.forEach(file => {
    if (file.includes('qr') || file.includes('QR') || file === 'qr.png' || file === 'qr.jpg') {
        try {
            fs.unlinkSync(file);
            console.log(`🗑️ Удален QR файл: ${file}`);
        } catch (err) {
            console.log(`❌ Ошибка удаления QR файла ${file}:`, err.message);
        }
    }
});

console.log('✅ Кэш QR кодов очищен!');
console.log('🔄 Теперь при следующем запросе QR кода будет сгенерирован новый.');
