const bluebird = require('bluebird');
const assert = require('chai').assert;

const redis = require("redis");


bluebird.promisifyAll(redis.RedisClient.prototype);

describe("Integration", function () {

    let redisClient;

    before(function () {
        redisClient = redis.createClient({ host: 'redis' });
    });

    after(function () {
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

});