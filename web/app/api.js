
// this is our api
const express = require('express');
const router = express.Router();

const integration = require('./integration');
const MongoClient = require('mongodb').MongoClient;


const config = require('../package.json');
const zk = require('./zookeeperProvider');
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
        const url = 'mongodb://mongo:27017/test';
        await new Promise((resolve, reject) => {
            MongoClient.connect(url, (e, db) => {
                if (e) reject(e);
                if (!db) reject('no db!');
                db.close(e => {
                    if (e) reject(e);
                    else resolve();
                });
            });
        });

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

// test graphite url
router.postAsync('/graphite', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        console.error(e);
        res.status(500).json({ success: false, error: e.toString() });
    }
});