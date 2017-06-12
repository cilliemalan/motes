
const zookeeper = require('node-zookeeper-client');

// connect to zookeeper
const client = zookeeper.createClient('zookeeper:2181');
let clientPromise;

function getClientInternalAsync() {
    return new Promise((resolve, reject) => {
        client.once('connected', () => {
            resolve(client);
        });
        client.on('error', e => reject(e));
        client.connect();
    });
}

function getClientAsync() {
    if (!clientPromise) {
        clientPromise = getClientInternalAsync();
    }

    return clientPromise;
}

client.createAsync = function createAsync(path, data, acls, mode) {
    return new Promise((resolve, reject) => {
        client.create(path, data, acls, mode, (e, path) => {
            if (e) reject(e);
            else {
                resolve(path);
            }
        });
    });
};

client.removeAsync = function removeAsync(path, version) {
    if (typeof version != 'number') version = -1;
    return new Promise((resolve, reject) => {
        client.remove(path, version, (e) => {
            if (e) reject(e);
            else {
                resolve();
            }
        });
    });
};

client.getChildrenAsync = function getChildrenAsync(path, watcher) {
    return new Promise((resolve, reject) => {
        client.getChildren(path, watcher, (e, children, stats) => {
            if (e) reject(e);
            else {
                resolve({ children, stats });
            }
        });
    });
};

client.existsAsync = function existsAsync(path, watcher) {
    return new Promise((resolve, reject) => {
        client.exists(path, watcher, (e, stat) => {
            if (e) reject(e);
            else {
                resolve(stat);
            }
        });
    });
};

async function registerAsync(name) {
    await getClientAsync();
    if (!await client.existsAsync('/web')) {
        await client.createAsync('/web');
    }
    return await client.createAsync(
        '/web/instance-',
        Buffer.from(JSON.stringify({ name })),
        null,
        zookeeper.CreateMode.EPHEMERAL_SEQUENTIAL);
}

async function unRegisterAsync(path) {
    await getClientAsync();
    await client.removeAsync(path);
}

async function getNumberOfActiveServersAsync() {
    await getClientAsync();
    var children = await client.getChildrenAsync('/web');
    return children.children.length;
}

module.exports = {
    getClientAsync,
    registerAsync,
    unRegisterAsync,
    getNumberOfActiveServersAsync
};