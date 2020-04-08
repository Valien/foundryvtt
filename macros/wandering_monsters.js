// setting variables
let msgContent = 'Wandering Monster roll was: ';
let result = '';

// roll to check for wandering monster
result = new Roll(`1d20`).roll().total;

// create the message
if(result !== '') {
  let chatData = {
    sound = CONFIG.sounds.dice,
    content: msgContent + result,
    whisper: game.users.entities.filter(u => u.isGM).map(u => u._id)
  };
  ChatMessage.create(chatData, {});
}

// This requires you to have an existing Table built in Foundry VTT. Replace the table name below with your table name.
// In this example, a roll between 17-20 will generate a roll from the Table. Tweak as needed!
if (result >= 17) {
  const table = game.tables.entities.find(t => t.name === "Wandering Monsters");
  table.draw({}, {rollMode: "gmroll"});
}