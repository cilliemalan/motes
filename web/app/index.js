const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const api = require('./api');
const zk = require('./integration/zookeeper');
const secrets = require('./integration/secrets');
const logger = require('winston');

// some vars
const port = process.env.PORT || 3000;
const wwwroot = path.resolve("./public");

/**
 * The main entrypoint function.
 */
async function main() {

    logger.info('starting...');

    // change cwd to the application root
    process.chdir(path.join(__dirname, '..'));

    logger.verbose(`running in ${process.cwd()}`);

    // initialize secrets
    await secrets.initializeAsync();

    // the express app
    const app = express();

    // static files
    logger.verbose(`static files in ${wwwroot}`);
    app.use(express.static(wwwroot));

    // some parsers
    app.use(bodyParser.urlencoded({ extended: true }));
    app.use(bodyParser.json());

    // our api
    app.use('/api', api);

    // start!
    logger.verbose(`start listen on port ${port}`);

    // listen (promisified)
    await new Promise((resolve, reject) => {
        app.addListener('error', reject);

        app.listen(port, () => {
            app.removeListener('error', reject);
            resolve();
        });
    });


    logger.info(`Listening on port ${port}`);
    let zkpath = await zk.registerAsync(process.env.HOSTNAME);
    logger.verbose(`registered with zk under ${zkpath} as ${process.env.HOSTNAME}`);
    logger.verbose(`There are currently ${await zk.getNumberOfActiveServersAsync()} registered servers`);
}

//start!
main();

//provide some data for whomever might need
module.exports = {
    url: `http://localhost:${port}/`
};