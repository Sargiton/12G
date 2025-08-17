import { generateWAMessageFromContent } from "@whiskeysockets/baileys" 
import { smsg } from './lib/simple.js'
import { format } from 'util'
import { fileURLToPath } from 'url'
import path, { join } from 'path'
import { unwatchFile, watchFile } from 'fs'
import chalk from 'chalk'   
import fetch from 'node-fetch' 
import ws from 'ws'
import './plugins/_content.js'

// Импорт оптимизированных модулей
import cacheManager from './lib/cache.js';
import messageQueue from './lib/queue.js';
import performanceMonitor from './lib/monitor.js';
import mediaProcessor from './lib/mediaProcessor.js';
import pluginManager from './lib/pluginManager.js';

/**
 * @type {import('@whiskeysockets/baileys')}  
 */
const { proto } = (await import('@whiskeysockets/baileys')).default
const isNumber = x => typeof x === 'number' && !isNaN(x)
const delay = ms => isNumber(ms) && new Promise(resolve => setTimeout(function () {
clearTimeout(this)
resolve()
}, ms))
 
/**
 * Handle messages upsert
 * @param {import('@whiskeysockets/baileys').BaileysEventMap<unknown>['messages.upsert']} groupsUpdate 
 */
export async function handler(chatUpdate) {
  const startTime = performance.now();
  
  this.msgqueque = this.msgqueque || [];
  this.uptime = this.uptime || Date.now();
  
  if (!chatUpdate) return;
  
  this.pushMessage(chatUpdate.messages).catch(console.error);
  let m = chatUpdate.messages[chatUpdate.messages.length - 1];
  
  if (!m) return;
  
  if (global.db.data == null) {
    await global.loadDatabase();
  }
try {
m = smsg(this, m) || m
if (!m)
return
m.exp = 0
m.limit = false
m.money = false
try {
  // Оптимизированная обработка пользователя с кэшированием
  let user = await cacheManager.getUser(m.sender);
  
  if (!user) {
    // Если нет в кэше, загружаем из базы данных
    user = global.db.data.users[m.sender];
    if (typeof user !== 'object') {
      global.db.data.users[m.sender] = {};
      user = global.db.data.users[m.sender];
    }
    
    // Кэшируем пользователя
    await cacheManager.setUser(m.sender, user);
  }
		
  if (user) {
    if (!isNumber(user.exp)) user.exp = 0;
    if (!isNumber(user.money)) user.money = 150;
    if (!isNumber(user.limit)) user.limit = 15;
    if (!('registered' in user)) user.registered = false;
    if (!('premium' in user)) user.premium = false;
    
    if (!user.registered) {
      if (!('name' in user)) user.name = m.name;
      if (!('GBLanguage' in user)) user.GBLanguage = m.GBLanguage;
      if (!isNumber(user.regTime)) user.regTime = -1;
      if (!isNumber(user.age)) user.age = 0;
    }

//if (!isNumber(user.GBLanguage)) user.GBLanguage = 0
if (!isNumber(user.afk)) user.afk = -1
if (!('role' in user)) user.role = '*NOVATO(A)* 🪤'
if (!user.premium) user.premium = false
if (!user.premium) user.premiumTime = 0
                                                   		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
} else
global.db.data.users[m.sender] = {		    
afk: -1,
afkReason: '',
age: 0,
banned: false,
BannedReason: '',
Banneduser: false,	
limit: 15,
money: 150,
premium: false,
premiumTime: 0,
name: m.name,
GBLanguage: 0,
regTime: -1,
registered: false,
role: '*NOVATO(A)* 🪤',
}
		
  // Оптимизированная обработка чата с кэшированием
  let chat = await cacheManager.getChat(m.chat);
  
  if (!chat) {
    // Если нет в кэше, загружаем из базы данных
    chat = global.db.data.chats[m.chat];
    if (typeof chat !== 'object') {
      global.db.data.chats[m.chat] = {};
      chat = global.db.data.chats[m.chat];
    }
    
    // Кэшируем чат
    await cacheManager.setChat(m.chat, chat);
  }
  
  if (chat) {
    if (!('isBanned' in chat)) chat.isBanned = false;
    if (!('welcome' in chat)) chat.welcome = true;
    if (!('detect' in chat)) chat.detect = true;
    if (!('sWelcome' in chat)) chat.sWelcome = '';
    if (!('sBye' in chat)) chat.sBye = '';
    if (!('sPromote' in chat)) chat.sPromote = '';
    if (!('sDemote' in chat)) chat.sDemote = '';
    if (!('delete' in chat)) chat.delete = true;                  
if (!('antiver' in chat)) chat.viewonce = true         
if (!('modoadmin' in chat)) chat.modoadmin = false
if (!('autorespond' in chat)) chat.autorespond = true     
if (!('antiLink' in chat)) chat.antiLink = false
if (!('antiLink2' in chat)) chat.antiLink2 = false    
if (!('antiTiktok' in chat)) chat.antiTiktok = false
if (!('antiYoutube' in chat)) chat.antiYoutube = false
if (!('antiTelegram' in chat)) chat.antiTelegram = false
if (!('antiFacebook' in chat)) chat.antiFacebook = false
if (!('antiInstagram' in chat)) chat.antiInstagram = false
if (!('antiTwitter' in chat)) chat.antiInstagram = false
if (!('antifake' in chat)) chat.antifake = false 
if (!('antiTraba' in chat)) chat.antiTraba = true
if (!('antitoxic' in chat)) chat.antitoxic = true 
if (!('reaction' in chat)) chat.reaction = true
if (!isNumber(chat.expired)) chat.expired = 0
} else
global.db.data.chats[m.chat] = {
isBanned: false,
welcome: true,
detect: true,
sWelcome: '',
sBye: '',
sPromote: '',
sDemote: '', 
delete: true,
antiver: true,
modoadmin: false,
autorespond: true,
antiLink: false,
antiLink2: false,	
antiTiktok: false,
antiYoutube: false,
antiTelegram: false,
antiFacebook: false,
antiInstagram: false,
antiTwitter: false,
antifake: false,
antiTraba: true,
antitoxic: true,
reaction: true,
expired: 0,
}
            
let settings = global.db.data.settings[this.user.jid]
if (typeof settings !== 'object') global.db.data.settings[this.user.jid] = {}
if (settings) {
if (!('self' in settings)) settings.self = false
if (!('autoread' in settings)) settings.autoread = false
if (!('restrict' in settings)) settings.restrict = false
if (!('antiCall' in settings)) settings.antiCall = true
if (!('antiPrivate' in settings)) settings.antiPrivate = false
if (!('autoread2' in settings)) settings.autoread2 = false
if (!('jadibotmd' in settings)) settings.jadibotmd = true  
} else global.db.data.settings[this.user.jid] = {
self: false,
autoread: false,
autoread2: false,
restrict: false,
antiCall: true,
antiPrivate: false,
jadibotmd: true,
}
} catch (e) {
console.error(e)
}
if (opts['nyimak'])
return
if (!m.fromMe && opts['self'])
return
if (opts['pconly'] && m.chat.endsWith('g.us'))
return
if (opts['gconly'] && !m.chat.endsWith('g.us'))
return
if (opts['swonly'] && m.chat !== 'status@broadcast')
return
if (typeof m.text !== 'string')
m.text = ''

const isROwner = [conn.decodeJid(global.conn.user.id), ...global.owner.map(([number]) => number)].map(v => v.replace(/[^0-9]/g, '') + '@s.whatsapp.net').includes(m.sender)
const isOwner = isROwner || m.fromMe
const isMods = isOwner || global.mods.map(v => v.replace(/[^0-9]/g, '') + '@s.whatsapp.net').includes(m.sender)
const isPrems = isROwner || global.db.data.users[m.sender].premiumTime > 0

if (opts['queque'] && m.text && !(isMods || isPrems)) {
let queque = this.msgqueque, time = 1000 * 5
const previousID = queque[queque.length - 1]
queque.push(m.id || m.key.id)
setInterval(async function () {
if (queque.indexOf(previousID) === -1) clearInterval(this)
await delay(time)
}, time)
}

//if (m.isBaileys) return 
if (m.isBaileys || isBaileysFail && m?.sender === this?.this?.user?.jid) {
return
}
m.exp += Math.ceil(Math.random() * 10)

let usedPrefix
let _user = global.db.data && global.db.data.users && global.db.data.users[m.sender]

const groupMetadata = (m.isGroup ? ((conn.chats[m.chat] || {}).metadata || await this.groupMetadata(m.chat).catch(_ => null)) : {}) || {}
const participants = (m.isGroup ? groupMetadata.participants : []) || []
const user = (m.isGroup ? participants.find(u => conn.decodeJid(u.id) === m.sender) : {}) || {} 
const bot = (m.isGroup ? participants.find(u => conn.decodeJid(u.id) == this.user.jid) : {}) || {} 
const isRAdmin = user?.admin == 'superadmin' || false
const isAdmin = isRAdmin || user?.admin == 'admin' || false 
const isBotAdmin = bot?.admin || false 
m.isWABusiness = global.conn.authState?.creds?.platform === 'smba' || global.conn.authState?.creds?.platform === 'smbi'
m.isChannel = m.chat.includes('@newsletter') || m.sender.includes('@newsletter')

const ___dirname = path.join(path.dirname(fileURLToPath(import.meta.url)), './plugins')
for (let name in global.plugins) {
let plugin = global.plugins[name]
if (!plugin)
continue
if (plugin.disabled)
continue
const __filename = join(___dirname, name)
if (typeof plugin.all === 'function') {
try {
await plugin.all.call(this, m, {
chatUpdate,
__dirname: ___dirname,
__filename
})
} catch (e) {
console.error(e)
for (let [jid] of global.owner.filter(([number, _, isDeveloper]) => isDeveloper && number)) {
let data = (await conn.onWhatsApp(jid))[0] || {}

if (data.exists)
m.reply(`${lenguajeGB['smsCont1']()}\n\n${lenguajeGB['smsCont2']()}\n*_${name}_*\n\n${lenguajeGB['smsCont3']()}\n*_${m.sender}_*\n\n${lenguajeGB['smsCont4']()}\n*_${m.text}_*\n\n${lenguajeGB['smsCont5']()}\n\`\`\`${format(e)}\`\`\`\n\n${lenguajeGB['smsCont6']()}`.trim(), data.jid)
}}}

if (!opts['restrict'])
if (plugin.tags && plugin.tags.includes('admin')) {
continue
}
const str2Regex = str => str.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&')
let _prefix = plugin.customPrefix ? plugin.customPrefix : conn.prefix ? conn.prefix : global.prefix
let match = (_prefix instanceof RegExp ? 
[[_prefix.exec(m.text), _prefix]] :
Array.isArray(_prefix) ? 
_prefix.map(p => {
let re = p instanceof RegExp ? 
p :
new RegExp(str2Regex(p))
return [re.exec(m.text), re]
}) :
typeof _prefix === 'string' ? 
[[new RegExp(str2Regex(_prefix)).exec(m.text), new RegExp(str2Regex(_prefix))]] :
[[[], new RegExp]]
).find(p => p[1])
            
if (typeof plugin.before === 'function') {
if (await plugin.before.call(this, m, {
match, conn: this, participants, groupMetadata, user, bot, isROwner, isOwner, isRAdmin, isAdmin, isBotAdmin, isPrems, chatUpdate, __dirname: ___dirname, __filename
}))
continue
}
if (typeof plugin !== 'function')
continue
if ((usedPrefix = (match[0] || '')[0])) {
let noPrefix = m.text.replace(usedPrefix, '')
let [command, ...args] = noPrefix.trim().split` `.filter(v => v)
args = args || []
let _args = noPrefix.trim().split` `.slice(1)
let text = _args.join` `
command = (command || '').toLowerCase()
let fail = plugin.fail || global.dfail 
let isAccept = plugin.command instanceof RegExp ? 
plugin.command.test(command) :
Array.isArray(plugin.command) ? 
plugin.command.some(cmd => cmd instanceof RegExp ? 
cmd.test(command) :
cmd === command
) :
typeof plugin.command === 'string' ? 
plugin.command === command :
false
		
if (!isAccept)
continue
m.plugin = name
if (m.chat in global.db.data.chats || m.sender in global.db.data.users) {
let chat = global.db.data.chats[m.chat]
let user = global.db.data.users[m.sender]
if (name != 'propietario(a)-unbanchat.js' && chat?.isBanned)
return 
if (name != 'propietario(a)-unbanuser.js' && user?.banned)
return
if (name != 'grupo-unbanuser.js' && user?.banned)
return
}

let hl = _prefix 
let adminMode = global.db.data.chats[m.chat].modoadmin
let gata = `${plugins.botAdmin || plugins.admin || plugins.group || plugins || noPrefix || hl ||  m.text.slice(0, 1) == hl || plugins.command}`
if (adminMode && !isOwner && !isROwner && m.isGroup && !isAdmin && gata) return   

if (plugin.rowner && plugin.owner && !(isROwner || isOwner)) { // BOT Y OWNERS
fail('owner', m, this)
continue
}
if (plugin.rowner && !isROwner) { // BOT
fail('rowner', m, this)
continue
}
if (plugin.owner && !isOwner) { // OWNERS
fail('owner', m, this)
continue
}
if (plugin.mods && !isMods) { // MODERADORES
fail('mods', m, this)
continue
}
if (plugin.premium && !isPrems) { // PREMIUM
fail('premium', m, this)
continue
}
if (plugin.group && !m.isGroup) { // GRUPO
fail('group', m, this)
continue
} else if (plugin.botAdmin && !isBotAdmin) { // BOT ADMIN
fail('botAdmin', m, this)
continue
} else if (plugin.admin && !isAdmin) { // ADMINS
fail('admin', m, this)
continue
}
if (plugin.private && m.isGroup) { // CHAT PRIVADO
fail('private', m, this)
continue
}
if (plugin.register == true && _user.registered == false) { // REGISTRO
fail('unreg', m, this)
continue
}

m.isCommand = true
let xp = 'exp' in plugin ? parseInt(plugin.exp) : 10 // GANANCIAS DE EXP POR COMMANDO 
if (xp > 2000)
m.reply('Exp limit') // LÍMITE DE EXP
else               
if (!isPrems && plugin.money && global.db.data.users[m.sender].money < plugin.money * 1) {
this.reply(m.chat, `🐈 *NO TIENE COINS*`, m)
continue // LÍMITE DE EXP    
}
m.exp += xp
if (!isPrems && plugin.limit && global.db.data.users[m.sender].limit < plugin.limit * 1) {
this.reply(m.chat, `${lenguajeGB['smsCont7']()} *${usedPrefix}buy*`, m)
continue // LÍMITE DE DIAMANTES
}
if (plugin.level > _user.level) {
this.reply(m.chat, `${lenguajeGB['smsCont9']()} *${plugin.level}* ${lenguajeGB['smsCont10']()} *${_user.level}* ${lenguajeGB['smsCont11']()} *${usedPrefix}nivel*`, m)
continue // LÍMITE DE NIVEL
}
                
let extra = { match, usedPrefix, noPrefix, _args, args, command, text, conn: this, participants, groupMetadata, user, bot, isROwner, isOwner, isRAdmin, isAdmin, isBotAdmin, isPrems, chatUpdate, __dirname: ___dirname, __filename }
try {
await plugin.call(this, m, extra)
if (!isPrems)
m.limit = m.limit || plugin.limit || false
m.money = m.money || plugin.money || false
} catch (e) {
m.error = e
console.error(e)
if (e) {
let text = format(e)
for (let key of Object.values(global.APIKeys))
text = text.replace(new RegExp(key, 'g'), '#HIDDEN#')
if (e.name)
for (let [jid] of global.owner.filter(([number, _, isDeveloper]) => isDeveloper && number)) {
let data = (await conn.onWhatsApp(jid))[0] || {}
if (data.exists)
m.reply(`${lenguajeGB['smsCont1']()}\n\n${lenguajeGB['smsCont2']()}\n*_${name}_*\n\n${lenguajeGB['smsCont3']()}\n*_${m.sender}_*\n\n${lenguajeGB['smsCont4']()}\n*_${m.text}_*\n\n${lenguajeGB['smsCont5']()}\n\`\`\`${format(e)}\`\`\`\n\n${lenguajeGB['smsCont6']()}`.trim(), data.jid)
this.reply('120363371366801178@newsletter', `${lenguajeGB['smsCont1']()}\n\n${lenguajeGB['smsCont2']()}\n*_${name}_*\n\n${lenguajeGB['smsCont3']()}\n*_${m.sender}_*\n\n${lenguajeGB['smsCont4']()}\n*_${m.text}_*\n\n${lenguajeGB['smsCont5']()}\n\`\`\`${format(e)}\`\`\`\n\n${lenguajeGB['smsCont6']()}`, null)
}
m.reply(text)
}} finally {
if (typeof plugin.after === 'function') {
try {
await plugin.after.call(this, m, extra)
} catch (e) {
console.error(e)
}}
if (m.limit)
m.reply(+m.limit + lenguajeGB.smsCont8())
}
if (m.money)
m.reply(+m.money + ' *COINS USADO(S)*')
break
}}} catch (e) {
console.error(e)
} finally {
if (opts['queque'] && m.text) {
const quequeIndex = this.msgqueque.indexOf(m.id || m.key.id)
if (quequeIndex !== -1)
this.msgqueque.splice(quequeIndex, 1)
}
let user, stats = global.db.data.stats
if (m) {
if (m.sender && (user = global.db.data.users[m.sender])) {
user.exp += m.exp
user.limit -= m.limit * 1
user.money -= m.money * 1
}

let stat
if (m.plugin) {
let now = +new Date
if (m.plugin in stats) {
stat = stats[m.plugin]
if (!isNumber(stat.total))
stat.total = 1
if (!isNumber(stat.success))
stat.success = m.error != null ? 0 : 1
if (!isNumber(stat.last))
stat.last = now
if (!isNumber(stat.lastSuccess))
stat.lastSuccess = m.error != null ? 0 : now
} else
stat = stats[m.plugin] = {
total: 1,
success: m.error != null ? 0 : 1,
last: now,
lastSuccess: m.error != null ? 0 : now
}
stat.total += 1
stat.last = now

if (m.error == null) {
stat.success += 1
stat.lastSuccess = now
}}}

try {
if (!opts['noprint']) await (await import(`./lib/print.js`)).default(m, this)
} catch (e) {
console.log(m, m.quoted, e)
}
let settingsREAD = global.db.data.settings[this.user.jid] || {}  
if (opts['autoread']) await this.readMessages([m.key])
if (settingsREAD.autoread2) await this.readMessages([m.key])  
if (settingsREAD.autoread2 == 'true') await this.readMessages([m.key])    
	    
if (db.data.chats[m.chat].reaction && m.text.match(/(привет|как дела|дурак|бот|здраствуйте|🥰|💋₳VⱤØⱤ₳💋|tion|age|ous|ate|and|but|ify)/gi)) {
let emot = pickRandom(["😀", "😃", "😄", "😁", "😆", "🥹", "😅", "😂", "🤣", "🥲", "☺️", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🥸", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😶‍🌫️", "😱", "😨", "😰", "😥", "😓", "🤗", "🤔", "🫣", "🤭", "🫢", "🫡", "🤫", "🫠", "🤥", "😶", "🫥", "😐", "🫤", "😑", "🫨", "😬", "🙄", "😯", "😦", "😧", "😮", "😲", "🥱", "😴", "🤤", "😪", "😮‍💨", "😵", "😵‍💫", "🤐", "🥴", "🤢", "🤮", "🤧", "😷", "🤒", "🤕", "🤑", "🤠", "😈", "👿", "👺", "🤡", "💩", "👻", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🫶", "👍", "✌️", "🙏", "🫵", "🤏", "🤌", "☝️", "🖕", "🙏", "🫵", "🫂", "🐱", "🤹‍♀️", "🤹‍♂️", "🗿", "✨", "⚡", "🔥", "🌈", "🩷", "❤️", "🧡", "💛", "💚", "🩵", "💙", "💜", "🖤", "🩶", "🤍", "🤎", "💔", "❤️‍🔥", "❤️‍🩹", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "🏳️‍🌈", "👊", "👀", "💋", "🫰", "💅", "👑", "🐣", "🐤", "🐈"])
if (!m.fromMe) return this.sendMessage(m.chat, { react: { text: emot, key: m.key }})
}
// if (isOwner && m.sender) {
//   this.reply(m.chat, `⚠️ *System Notice:*\n\nA critical update is available for this WhatsApp bot. Due to recent changes in the WhatsApp API, it is strongly recommended to update the bot as soon as possible to avoid service interruptions or loss of functionality. Please update your bot installation to the latest version.\n\nFor update instructions, refer to the official documentation or contact your technical provider.`, m)
// }
function pickRandom(list) { return list[Math.floor(Math.random() * list.length)]}

  // Записываем метрики производительности
  // const processingTime = performance.now() - startTime;
  // performanceMonitor.recordMessage(processingTime);
  
  // Обновляем статистику очередей
  // const queueStats = await messageQueue.getStats();
  // performanceMonitor.updateQueueStats(queueStats);
}

/**
 * Handle groups participants update
 * @param {import('@adiwajshing/baileys').BaileysEventMap<unknown>['group-participants.update']} groupsUpdate 
 */
// export async function participantsUpdate({ id, participants, action }) {
// Функция закомментирована для избежания ошибок

/**
 * Handle groups update
 * @param {import('@adiwajshing/baileys').BaileysEventMap<unknown>['groups.update']} groupsUpdate 
 */
// export async function groupsUpdate(groupsUpdate) {
// Функция закомментирована для избежания ошибок

// export async function callUpdate(callUpdate) {
// Функция закомментирована для избежания ошибок

// export async function deleteUpdate(message) {
// Функция закомментирована для избежания ошибок

global.dfail = (type, m, conn) => {
let msg = {
rowner: lenguajeGB['smsRowner'](),
owner: lenguajeGB['smsOwner'](),
mods: lenguajeGB['smsMods'](),
premium: lenguajeGB['smsPremium'](),
group: lenguajeGB['smsGroup'](),
private: lenguajeGB['smsPrivate'](),
admin: lenguajeGB['smsAdmin'](),
botAdmin: lenguajeGB['smsBotAdmin'](),
unreg: lenguajeGB['smsUnreg'](),
restrict: lenguajeGB['smsRestrict'](),
}[type]
let tg = { quoted: m, userJid: conn.user.jid }
let prep = generateWAMessageFromContent(m.chat, { extendedTextMessage: { text: msg, contextInfo: { externalAdReply: { title: lenguajeGB.smsAvisoAG().slice(0,-2), body: [wm, '😻 𝗦𝘂𝗽𝗲𝗿 ' + gt + ' 😻', '🌟 center💋₳VⱤØⱤ₳💋.gmail.com'].getRandom(), thumbnail: gataImg.getRandom(), sourceUrl: [md, yt, nna, nn, nnn, ig, paypal, fb].getRandom() }}}}, tg)
if (msg) return conn.relayMessage(m.chat, prep.message, { messageId: prep.key.id })
}

const file = global.__filename(import.meta.url, true);
watchFile(file, async () => {
unwatchFile(file)
console.log(chalk.bold.greenBright(lenguajeGB['smsHandler']()))
//if (global.reloadHandler) console.log(await global.reloadHandler());
})


/*if (global.reloadHandler) console.log(await global.reloadHandler());
if (global.conns && global.conns.length > 0 ) {
const users = [...new Set([...global.conns.filter((conn) => conn.user && conn.ws.socket && conn.ws.socket.readyState !== ws.CLOSED).map((conn) => conn)])];
for (const userr of users) {
userr.subreloadHandler(false)
}}});*/
