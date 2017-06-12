const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const api = require('./api');
const zk = require('./zookeeperProvider');

console.log('starting...');

// change cwd to the application root
process.chdir(path.join(__dirname, '..'));

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
app.listen(port, async () => {
    console.log(`Listening on port ${port}`);
    let path = await zk.registerAsync(process.env.HOSTNAME);
    console.log(`registered with zk under ${path} as ${process.env.HOSTNAME}`);
    console.log(`There are currently ${await zk.getNumberOfActiveServersAsync()} registered servers`);
});

//provide some data for whomever might need
module.exports = {
    url: `http://localhost:${port}/`
};