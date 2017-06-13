const assert = require('chai').assert;

const MongoClient = require('mongodb').MongoClient;


describe("Integration", function () {

    describe('Mongo', function () {
        it('should be accessible', async function () {

            let db = await MongoClient.connect('mongodb://mongo:27017/test');
            assert.isOk(db);

        });
    });
});