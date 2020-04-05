// setting variables
let msgContent = 'Wandering Monster roll was: ';
let result = '';

// roll to check for wandering monster
result = new Roll(`1d20`).roll().total;

// create the message
if(result !== '') {
  let chatData = {
    content: msgContent + result,
    whisper: game.users.entities.filter(u => u.isGM).map(u => u._id)
  };
  ChatMessage.create(chatData, {});
}

if (result >= 17) {
  const table = game.tables.entities.find(t => t.name === 
  "Wandering Monsters");
  table.draw();
}