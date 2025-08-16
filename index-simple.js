import { spawn } from 'child_process';
import { createRequire } from 'module';
import { fileURLToPath, pathToFileURL } from 'url';
import { dirname } from 'path';
import { platform, arch, cpus, freemem, totalmem, uptime, type, release, hostname, userInfo, networkInterfaces } from 'os';
import { readFileSync, watchFile, unwatchFile } from 'fs';
import yargs from 'yargs';
import chalk from 'chalk';
import { tmpdir } from 'os';
import { join } from 'path';
import { readdir, unlink, exists, copyFile, rm, statSync, mkdir, readFile, writeFile } from 'fs/promises';
import { watch } from 'fs';
import NodeCache from 'node-cache'
import { gataJadiBot } from './plugins/jadibot-serbot.js';

const { PHONENUMBER_MCC, makeInMemoryStore, DisconnectReason, useMultiFileAuthState, MessageRetryMap, fetchLatestBaileysVersion, makeCacheableSignalKeyStore } = await import('@whiskeysockets/baileys')
const { CONNECTING } = ws
const { chain } = lodash
import cfonts from 'cfonts';
const { say } = cfonts
import qrcode from 'qrcode-terminal';
import QRCode from 'qrcode';
const PORT = process.env.PORT || process.env.SERVER_PORT || 3000
let stopped = 'close'

protoType()
serialize()

say('DarkCore\nVIP\nMD', {
 font: 'chrome',
 align: 'center',
 gradient: ['red', 'magenta']
})

say(`Project Author:\nnDarkcore (@)\n\nDeveloper:\nDarkCore (dark)`.trim(), {
 font: 'console',
 align: 'center',
 colors: ['candy']
})

console.log(chalk.cyan('🚀 Starting simple version without optimizations...'));

global.__filename = function filename(pathURL = import.meta.url, rmPrefix = platform !== 'win32') {
  return rmPrefix ? /file:\/\/\//.test(pathURL) ? fileURLToPath(pathURL) : pathURL : pathToFileURL(pathURL).toString();
}; global.__dirname = function dirname(pathURL) {
  return path.dirname(global.__filename(pathURL, true));
}; global.__require = function require(dir = import.meta.url) {
  return createRequire(dir);
};

global.API = (name, path = '/', query = {}, apikeyqueryname) => (name in global.APIs ? global.APIs[name] : name) + path + (query || apikeyqueryname ? '?' + new URLSearchParams(Object.entries({...query, ...(apikeyqueryname ? {[apikeyqueryname]: global.APIKeys[name in global.APIs ? global.APIs[name] : name]} : {})})) : '')
global.timestamp = { start: new Date }

const __dirname = global.__dirname(import.meta.url);

global.opts = new Object(yargs(process.argv.slice(2)).exitProcess(false).parse());
const prefixChars = (opts['prefix'] || '*/!.#$%+£¢€¥^°=¶∆×÷π√✓©®&@').replace(/[|\\{}()[\]^$+*?.\-]/g, '\\$&');
global.prefix = new RegExp(`^[${prefixChars}]`);

// Создание директорий базы данных
const databasePath = path.join(__dirname, 'database');
if (!fs.existsSync(databasePath)) {
fs.mkdirSync(databasePath)}

const usersPath = path.join(databasePath, 'users');
const chatsPath = path.join(databasePath, 'chats');
const settingsPath = path.join(databasePath, 'settings');
const msgsPath = path.join(databasePath, 'msgs');
const stickerPath = path.join(databasePath, 'sticker');
const statsPath = path.join(databasePath, 'stats');

if (!fs.existsSync(usersPath)) fs.mkdirSync(usersPath);
if (!fs.existsSync(chatsPath)) fs.mkdirSync(chatsPath);
if (!fs.existsSync(settingsPath)) fs.mkdirSync(settingsPath);
if (!fs.existsSync(msgsPath)) fs.mkdirSync(msgsPath);
if (!fs.existsSync(stickerPath)) fs.mkdirSync(stickerPath);
if (!fs.existsSync(statsPath)) fs.mkdirSync(statsPath);

function getFilePath(basePath, id) {
return path.join(basePath, `${id}.json`)}

global.db = {
data: {
users: {},
chats: {},
stats: {},
msgs: {},
sticker: {},
settings: {},
...(() => {
const files = readdirSync(databasePath)
const database = {}
for (const file of files) {
if (file.endsWith('.json')) {
const data = JSON.parse(readFileSync(join(databasePath, file)))
database[file.replace(/\.json/, '')] = data
}
}
return database
})()
},
async write(update = {}) {
database.data = { ...database.data, ...update }
database.write()
}
}

// Остальной код остается без изменений...
