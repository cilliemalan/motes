const bluebird = require('bluebird');
const assert = require('chai').assert;

const redis = require("redis");
const zookeeper = require('node-zookeeper-client');
const kafka = require('kafka-node');
const MongoClient = require('mongodb').MongoClient;


bluebird.promisifyAll(redis.RedisClient.prototype);

describe("Ecosystem", function () {

    let redisClient;
    let zookeeperClient;
    let kafkaProducer;
    let kafkaConsumer;

    before(function () {
        redisClient = redis.createClient({ host: 'redis' });
        zookeeperClient = zookeeper.createClient('zookeeper:2181');
        kafkaProducer = new kafka.Producer(new kafka.Client('zookeeper:2181', 'test-producer'));
        kafkaConsumer = new kafka.Consumer(new kafka.Client('zookeeper:2181', 'test-consumer'), [{ topic: 'test-topic' }]);

        bluebird.promisifyAll(zookeeperClient);

        console.log('before');
    });

    after(function () {
        zookeeperClient.close();
        kafkaProducer.close();
        kafkaConsumer.close();

        console.log('after');
    });

    describe("Redis", function () {
        it("should be accessible", async function () {

            await redisClient.setAsync("test:hello", "world");
            var v = await redisClient.getAsync("test:hello");
            redisClient.delAsync("test:hello");
            var v2 = await redisClient.getAsync("test:hello");

            assert.equal(v, "world");
            assert.isNotOk(v2);
        });
    });

    describe("Zookeeper", function () {
        it("should be accessible", function (done) {

            zookeeperClient.on('connected', () => {
                zookeeperClient.exists('/', (e, s) => {
                    assert.isNotOk(e);
                    assert.isOk(s);
                    done();
                })
            });
            zookeeperClient.connect();
        });
    });

    describe("Kafka", function () {
        it("should be accessible", function (done) {

            var isdone = false;

            function run() {
                kafkaProducer.createTopics(['test-topic'], (e, d) => {
                    assert.isNotOk(e);

                    kafkaConsumer.on('message', (message) => {
                        assert.isOk(message);
                        assert.equal(message.value, 'test-message');

                        if (!isdone) { done(); isdone = true; }
                    });

                    kafkaProducer.send([{ topic: 'test-topic', messages: ['test-message'] }], (e, d) => {
                        assert.isNotOk(e);
                    });

                });
            }

            if (kafkaProducer.ready) run();
            else kafkaProducer.on('ready', run);
        });
    });

    describe('Mongo', function () {
        it('should be accessible', function (done) {

            const url = 'mongodb://mongo:27017/test';
            MongoClient.connect(url, (e, db) => {
                assert.isNotOk(e);
                db.close(done);
            });
        });
    });
});