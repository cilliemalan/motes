const bluebird = require('bluebird');
const assert = require('chai').assert;

const redis = require("redis");
const zookeeper = require('node-zookeeper-client');
const kafka = require('kafka-node');
const MongoClient = require('mongodb').MongoClient;


bluebird.promisifyAll(redis.RedisClient.prototype);

describe("Ecosystem", () => {

    let redisClient;
    let zookeeperClient;

    before(() => {
        redisClient = redis.createClient({ host: 'redis' });
        zookeeperClient = zookeeper.createClient('zookeeper:2181');

        bluebird.promisifyAll(zookeeperClient);
    });

    describe("Redis", () => {
        it("should be accessible", async () => {

            await redisClient.setAsync("test:hello", "world");
            var v = await redisClient.getAsync("test:hello");
            redisClient.delAsync("test:hello");
            var v2 = await redisClient.getAsync("test:hello");

            assert.equal(v, "world");
            assert.isNotOk(v2);
        });
    });

    describe("Zookeeper", () => {
        it("should be accessible", (cb) => {
            zookeeperClient.on('connected', () => {
                zookeeperClient.exists('/', (e,s) => {
                    assert.isOk(s);
                    cb(e);
                })
            });
            zookeeperClient.connect();
        });
    })
});