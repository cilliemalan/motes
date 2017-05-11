const graphite = require('graphite');
const bluebird = require('bluebird');
const client = graphite.createClient('plaintext://graphite:2003/');
const writeAsync = bluebird.promisify(client.write);
const onFinished = require('on-finished');
const onHeaders = require('on-headers');

const trackedMetrics = {

};

const setMetrics = {

};

// register that an event happened, or that it happened multiple times
function track(metricName, amt = 1) {
    if (!(metricName in trackedMetrics)) {
        trackedMetrics[metricName] = 0;
    }

    trackedMetrics[metricName] += amt;
}

// register a metric set at a constant value
function set(metricName, value) {
    setMetrics[metricName] = value;
}

setInterval(() => {

    const data = Object.assign({}, trackedMetrics, setMetrics);

    client.write(data, e => {
        if (e) {
            console.error(e);
        }
    });

    Object.keys(trackedMetrics).forEach(k => trackedMetrics[k] = 0);
}, 10000);


function trackExpress(req, res, next) {
    let requestTime = process.hrtime();
    let responseTime;

    onHeaders(res, () => responseTime = process.hrtime());

    onFinished(res, () => {
        if (!responseTime) responseTime = process.hrtime();
        var ms = (responseTime[0] - requestTime[0]) * 1e3 +
            (responseTime[1] - requestTime[1]) * 1e-6;

        track(`web.requests.status.${res.statusCode}`);
        client.write({ 'web.requests.duration': ms }, e => {
            if (e) {
                console.error(e);
            }
        });
    });

    next();
}

module.exports = {
    writeAsync,
    track,
    set,
    trackExpress
};