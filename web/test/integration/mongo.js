const assert = require('chai').assert;


describe("Integration", function () {

    describe('Mongo', function () {

        let db;

        beforeEach(async function () {
            db = await require('../../app/integration').mongoConnectAsync();
        });

        afterEach(async function () {
            await db.close();
        });

        it('should be accessible', async function () {

            assert.isOk(db);
        });

        it('should be able to create and delete documents', async function () {

            // the item to insert
            const dbitem = {
                id: new Date().getTime(),
                name: 'John',
                surname: 'Doe',
                updated: false
            };

            // get the collection
            const col = db.collection('testitems');

            // insert it
            const inserted = await col.insertOne(dbitem);

            // find it again
            const found = await col.findOne({ id: dbitem.id });

            // and delete it
            const deleted = await col.deleteOne({ id: found.id });

            assert.isOk(col);
            assert.isOk(inserted);
            assert.equal(inserted.insertedCount, 1);
            assert.isOk(found);
            assert.equal(found.id, dbitem.id);
            assert.equal(found.name, dbitem.name);
            assert.equal(found.surname, dbitem.surname);
            assert.equal(found.updated, dbitem.updated);
            assert.isOk(deleted);
            assert.equal(deleted.deletedCount, 1);
        });
    });
});