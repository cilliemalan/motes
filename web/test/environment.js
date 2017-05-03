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
                zookeeperClient.exists('/', (e, s) => {
                    assert.isOk(s);
                    cb(e);
                })
            });
            zookeeperClient.connect();
        });
    });

    describe("Kafka", () => {
        it("should be accessible", (cb) => {
            const producer = new kafka.Producer(new kafka.Client('zookeeper:2181', 'test-producer'));
            const consumer = new kafka.Consumer(new kafka.Client('zookeeper:2181', 'test-consumer'), [{ topic: 'test-topic' }]);
            var done = false;

            producer.on('ready', () => {
                producer.createTopics(['test-topic'], (e, d) => {
                    if (e) cb(e);
                    else {

                        consumer.on('message', (message) => {
                            assert.isOk(message);
                            assert.equal(message.value, 'test-message');

                            if (!done) { cb(); done = true; }
                        });

                        producer.send([{ topic: 'test-topic', messages: ['test-message'] }], (e, d) => {
                            if (e) cb(e);
                        });
                    }
                })
            });
        });
    });
});