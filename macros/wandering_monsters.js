// roll to check for wandering monster
let result = new Roll(`1d20`).roll().total;

// create the message
if(result !== '') {
  let chatData = {
    content: result,
    whisper: game.users.entities.filter(u => u.isGM).map(u => u._id)
  };
  ChatMessage.create(chatData, {});
}

// display which monster is selected based on named table
if (result >= 17) {
  const table = game.tables.entities.find(t => t.name === 
  "Wandering Monsters");
  table.draw();
}
