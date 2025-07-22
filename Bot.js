const mineflayer = require('mineflayer');

const bot = mineflayer.createBot({
  host: 'tên-server.aternos.me', // đổi thành IP server của bạn
  port: 25565, // để mặc định, hoặc sửa nếu server có port riêng
  username: 'BotAFK' // Tên của bot (nếu là tài khoản cracked)
});

bot.on('chat', (username, message) => {
  if (username === bot.username) return;
  if (message === 'ping') {
    bot.chat('pong!');
  }
});
