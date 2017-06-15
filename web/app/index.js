const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const api = require('./api');
const zk = require('./integration/zookeeper');
const secrets = require('./integration/secrets');
const logger = require('winston');
const http = require('http');


class Application {

    constructor(options = {}) {
        this._port = options.port || process.env.PORT || 3000;
        this._wwwroot = options.wwwroot || path.resolve("./public");
        this._hostname = options.hostname || process.env.HOSTNAME;
        this._app = express();
    }

    async start() {
        try {
            if (this._started) {
                logger.warn('tried to start when already started');
                return;
            }

            const app = this._app;

            logger.info('starting...');
            logger.verbose(`Going to listen on ${this._port}`);
            logger.verbose(`Going to server files from ${this._wwwroot}`);

            // initialize secrets
            await secrets.initializeAsync();

            // static files
            app.use(express.static(this._wwwroot));

            // parsers
            app.use(bodyParser.urlencoded({ extended: true }));
            app.use(bodyParser.json());

            // the api
            app.use('/api', api);

            // start listening
            await this._listen();

            logger.info(`Listening`);
            logger.info(`Available on ${this.localUrl}`);
            logger.info(`Available on ${this.publicUrl}`);

            // register with zookeeper
            await this._register();

            this._started = true;

        } catch (e) {
            logger.error(e);
            throw e;
        }
    }

    async stop() {
        if (!this._started) {
            logger.warn('tried to stop while not running. Doing nothing.');
        } else {
            logger.info('stopping...');

            // stop listening
            this._http.close();
            delete this._http;
            this._started = false;

            // unregister
            await zk.unRegisterAsync(this._zkpath);
            logger.verbose('unregistered from zk');
            logger.info('stopped');

        }
    }

    _listen() {
        return new Promise((resolve, reject) => {
            const app = this._app;
            const port = this._port;

            // create the server object
            this._http = http.createServer(app);
            this._http.addListener('error', reject);

            // listen and resolve once listening
            this._http.listen(port, () => {
                this._http.removeListener('error', reject);
                resolve();
            });
        });
    }

    async _register() {
        this._zkpath = await zk.registerAsync(process.env.HOSTNAME);
        logger.verbose(`registered with zk under ${this._zkpath} as ${process.env.HOSTNAME}`);
        logger.verbose(`There are currently ${await zk.getNumberOfActiveServersAsync()} registered servers`);
    }

    get localUrl() {
        return `http://127.0.0.1:${this._port}`;
    }

    get publicUrl() {
        //get our ip address
        if (!this._ipaddress) {
            const os = require('os');
            const ifaces = os.networkInterfaces();
            this._ipaddress = ifaces['eth0'][0].address;
        }

        return `http://${this._ipaddress}:${this._port}`;
    }
}

module.exports.Application = Application;
