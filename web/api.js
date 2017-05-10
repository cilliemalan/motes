
// this is our api
const express = require('express');
const router = express.Router();
const config = require('./package.json');
module.exports = router;

const wrap = fn => (...args) => fn(...args).catch(args[2]);

//const delayAsync = howlong => new Promise((resolve) => setTimeout(() => resolve(), howlong));

router.getAsync = (url, handler) => router.get(url, wrap(handler));
router.postAsync = (url, handler) => router.post(url, wrap(handler));

// api status url
router.get('/', (req, res) => {
    res.json({ status: 'up', version: config.version, hostname: process.env.HOSTNAME });
});

// test zookeeper url
router.postAsync('/zookeeper', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test mongo url
router.postAsync('/mongo', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test redis url
router.postAsync('/redis', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// send kafka message url
router.postAsync('/kafka', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// get kafka messages url
router.getAsync('/kafka', async (req, res) => {
    try {
        res.json({ success: true, message: ['hello world'] });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});

// test graphite url
router.postAsync('/graphite', async (req, res) => {
    try {
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ success: false, error: e.toString() });
    }
});