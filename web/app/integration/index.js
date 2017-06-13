const bluebird = require('bluebird');

const secrets = require('./secrets');

const redis = require("redis");
bluebird.promisifyAll(redis.RedisClient.prototype);

const MongoClient = require('mongodb').MongoClient;

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
    const username = secrets.get("mongo", "user");
    const password = secrets.get("mongo", "password");
    const url = `mongodb://${encodeURIComponent(username)}:${encodeURIComponent(password)}@mongo:27017/${database}`;

    const db = await MongoClient.connect(url);

    return db;
}

module.exports = {
    createRedisClient,
    mongoConnectAsync
};