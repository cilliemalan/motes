const express = require('express');
const app = express();
const path = require('path');

console.log('starting...');

// change cwd to where this script is
process.chdir(__dirname);

console.log(`running in ${process.cwd()}`);

const port = process.env.PORT || 3000;
const wwwroot = path.resolve("./public");

console.log(`static files in ${wwwroot}`);
app.use(express.static(wwwroot));

console.log(`start listen on port ${port}`);
app.listen(port, () => console.log(`Listening on port ${port}`));
