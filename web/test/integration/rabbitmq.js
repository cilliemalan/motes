const assert = require('chai').assert;
const integration = require('../../app/integration');


describe("Integration", function () {

    let rabbitmq;
    let queue;

    before(function () {
        queue = `testqueue-${new Date().getTime().toString()}`;
    });

    beforeEach(async function () {
        rabbitmq = await integration.createRabbitmqConnectionAsync();
    });

    afterEach(async function () {
        await rabbitmq.close();
    });

    after(async function () {
        const c = await integration.createRabbitmqConnectionAsync();
        const ch = await c.createChannel();
        if (await ch.checkQueue(queue)) {
            await ch.deleteQueue(queue);
        }
    });

    describe("RabbitMQ", function () {
        it("should be accessible", async function () {
            assert.isOk(rabbitmq);

            // open and close a channel
            const channel = await rabbitmq.createChannel();
            assert.isOk(channel);
            await channel.close();
        });

        it("should be able to create a queue", async function () {
            const channel = await rabbitmq.createChannel();
            const qok = await channel.assertQueue(queue);
            const cok = await channel.checkQueue(queue);
            assert.isOk(qok);
            assert.equal(qok.queue, queue);
            assert.isOk(cok);
            assert.equal(cok.queue, queue);

            await channel.close();
        });

        it("sould be able to put a message on a queue", async function () {
            const channel = await rabbitmq.createChannel();
            await channel.assertQueue(queue);
            await channel.sendToQueue(queue, Buffer.from('hello world'));
            await channel.close();
        });

        it("sould be able to take a message off the queue", async function () {
            const channel = await rabbitmq.createChannel();
            await channel.assertQueue(queue);

            const message = await new Promise((resolve, reject) => {
                channel.consume(queue, msg => {
                    if (msg) {
                        channel.ack(msg);
                        resolve(msg.content);
                    }
                }).catch(reject);
            });

            assert.isOk(message);
            assert.equal(message.toString(), "hello world");
            await channel.close();
        });
    });

});