const assert = require('chai').assert;
const integration = require('../../app/integration');


describe("Integration", function () {

    let redisClient;

    before(async function () {
        await require('../../app/integration/secrets').initializeAsync();
        redisClient = integration.createRedisClient();
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