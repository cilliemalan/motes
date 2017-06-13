const assert = require('chai').assert;
const integration = require('../../app/integration');


describe("Integration", function () {

    describe("InfluxDb", function () {

        let influx;

        beforeEach(async function () {
            influx = await integration.createInfluxDbConnection();
        });

        afterEach(function () {
        });

        it("should be able to write a point", async function () {

            await influx.writePoints([{
                measurement: 'test_runs',
                tags: { nodeVersion: process.version },
                fields: { count: 1 }
            }]);
        });

        it("should be able to query the data", async function () {
            const result = await influx.query(`
                select COUNT("count") from test_runs
            `);

            const firstResult = result[0];

            assert.isOk(result);
            assert.isOk(firstResult);
            assert.isTrue(firstResult.count >= 1);
        });
    });

});