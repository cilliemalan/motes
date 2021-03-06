
// this is our api
const express = require('express');
const router = express.Router();

const integration = require('./integration');

const config = require('../package.json');
const zk = require('./integration/zookeeper');
module.exports = router;

const wrap = fn => (...args) => fn(...args).catch(args[2]);

//const delayAsync = howlong => new Promise((resolve) => setTimeout(() => resolve(), howlong));

router.getAsync = (url, handler) => router.get(url, wrap(handler));
router.postAsync = (url, handler) => router.post(url, wrap(handler));

// api status url
router.get('/', wrap(async (req, res) => {
    res.json({
        status: 'up',
        version: config.version,
        hostname: process.env.HOSTNAME,
        instances: await zk.getNumberOfActiveServersAsync()
    });
}));

// test zookeeper url
router.postAsync('/zookeeper', async (req, res) => {
    try {
        const instances = await zk.getNumberOfActiveServersAsync();
        res.json({ success: true, instances });
    } catch (e) {
        console.error(e);
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test mongo url
router.postAsync('/mongo', async (req, res) => {
    try {

        // connect
        const db = await integration.mongoConnectAsync();
        const col = db.collection('testitems');

        // the item to insert
        const dbitem = {
            id: new Date().getTime(),
            name: 'John',
            surname: 'Doe',
            updated: false
        };

        // insert it
        await col.insertOne(dbitem);

        // find it again
        const found = await col.findOne({ id: dbitem.id });

        // and delete it
        await col.deleteOne({ id: found.id });

        // close the connection
        await db.close();
        res.json({ success: true });
    } catch (e) {
        console.error(e);
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test redis url
router.postAsync('/redis', async (req, res) => {
    try {
        let redisClient = integration.createRedisClient();

        const crypto = require("crypto");
        let key = crypto.randomBytes(8).toString("hex");
        let value = crypto.randomBytes(8).toString("hex");
        await redisClient.setAsync(key, value);
        var gotten = await redisClient.getAsync(key);
        redisClient.delAsync(key);
        res.json({ success: value == gotten });
    } catch (e) {
        console.error(e);
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test influxdb url
router.postAsync('/influx', async (req, res) => {
    try {
        let influx = await integration.createInfluxDbConnection();
        await influx.writePoints([{
            measurement: 'button_clicks',
            tags: { nodeVersion: process.version, host: require('os').hostname() },
            fields: { count: 1 }
        }]);

        const clickQueryResult = await influx.query(`
            select COUNT("count") from button_clicks
        `);

        res.json({ success: true, total: clickQueryResult[0].count });
    } catch (e) {
        console.error(e);
        res.status(500).json({ success: false, error: e.toString() });
    }
});