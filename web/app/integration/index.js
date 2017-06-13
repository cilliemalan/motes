const bluebird = require('bluebird');
const redis = require("redis");
const Influx = require('influx');
const mongodb = require('mongodb');
const secrets = require('./secrets');
const logger = require('winston');

bluebird.promisifyAll(redis.RedisClient.prototype);
const MongoClient = mongodb.MongoClient;



/**
 * Creates a redis client connected to the local k8s redis
 */
function createRedisClient() {
    return redis.createClient({ host: 'redis', password: secrets.get('redis', 'password') });
}

/**
 * Connects to mongo and returns a client
 */
async function mongoConnectAsync(database = 'app') {
    await secrets.initializeAsync();
    const username = secrets.get("mongo", "user");
    const password = secrets.get("mongo", "password");
    const url = `mongodb://${encodeURIComponent(username)}:${encodeURIComponent(password)}@mongo:27017/${database}`;
    const db = await MongoClient.connect(url);

    return db;
}

/**
 * Connects to influxdb and returns the connection.
 * @param {string} database the database to connect to. Default is "influx".
 */
async function createInfluxDbConnection(database = 'influx') {
    await secrets.initializeAsync();
    const username = secrets.get("influxdb", "username");
    const password = secrets.get("influxdb", "password");
    const conn = new Influx.InfluxDB({
        database: database,
        host: 'influxdb',
        port: 80,
        username: username,
        password: password
    });

    return conn;
}

module.exports = {
    createRedisClient,
    mongoConnectAsync,
    createInfluxDbConnection
};