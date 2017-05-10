const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const api = require('./api');

console.log('starting...');

// change cwd to where this script is
process.chdir(__dirname);

// some vars
const port = process.env.PORT || 3000;
const wwwroot = path.resolve("./public");

console.log(`running in ${process.cwd()}`);

// the express app
const app = express();

// static files
console.log(`static files in ${wwwroot}`);
app.use(express.static(wwwroot));

// some parsers
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// our api
app.use('/api', api);

// start!
console.log(`start listen on port ${port}`);
app.listen(port, () => console.log(`Listening on port ${port}`));

