const bluebird = require('bluebird');

const secrets = require('./secrets');

const redis = require("redis");
bluebird.promisifyAll(redis.RedisClient.prototype);


/**
 * Creates a redis client connected to the local k8s redis
 */
function createRedisClient() {
    return redis.createClient({ host: 'redis', password: secrets.get('redis', 'password') });
}

module.exports = {
    createRedisClient
};