const assert = require('chai').assert;
const zk = require('../zookeeperProvider');

describe("Integration", function () {

    describe("Zookeeper Provider", function () {

        it("should be able to get a client", async function () {

            const client = await zk.getClientAsync();
            assert.isOk(client);
            assert.isObject(client);

        });

        it("should be able to register", async function () {

            const path = await zk.registerAsync();
            
            assert.isOk(path);
            assert.isString(path);

            await zk.unRegisterAsync(path);

        });

        it("should be able to affect number of registrations", async function () {

            const numberBefore = await zk.getNumberOfActiveServersAsync();
            const path = await zk.registerAsync();
            const numberAfter = await zk.getNumberOfActiveServersAsync();

            // could fail if really unlucky
            assert.isTrue(numberAfter > numberBefore);

            await zk.unRegisterAsync(path);

        });

        it("should be able to de-register", async function () {

            const numberBefore = await zk.getNumberOfActiveServersAsync();
            const path = await zk.registerAsync();
            const numberAfter = await zk.getNumberOfActiveServersAsync();
            await zk.unRegisterAsync(path);
            const numberAtEnd = await zk.getNumberOfActiveServersAsync();

            assert.isTrue(numberAfter > numberBefore);
            assert.isTrue(numberAtEnd < numberAfter);
        });
    });

});