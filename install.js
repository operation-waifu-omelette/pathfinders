const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface(process.stdin, process.stdout);
rl.setPrompt('Dota Path: ');
rl.prompt();

rl.on('line', (dotaPath) => {
  const gamePath = `${dotaPath}/game/dota_addons`;
  const contentPath = `${dotaPath}/content/dota_addons`;
  if (!fs.existsSync(gamePath)) {
    console.log(`${gamePath} not found`);
    rl.prompt();
    return;
  }
  if (!fs.existsSync(contentPath)) {
    console.log(`${contentPath} not found`);
    rl.prompt();
    return;
  }
  rl.close();

  (async () => {
    await fs.promises.rename('./game/dota_addons/pathfinder', gamePath + '/pathfinder');
    await fs.promises.rename('./content/dota_addons/pathfinder', contentPath + '/pathfinder');
    await fs.promises.symlink(gamePath + '/pathfinder', './game/dota_addons/pathfinder', 'junction');
    await fs.promises.symlink(contentPath + '/pathfinder', './content/dota_addons/pathfinder', 'junction');
  })().catch(err => {
    console.error(err);
    process.exit(1);
  });
});
