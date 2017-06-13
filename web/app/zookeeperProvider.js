
const zookeeper = require('node-zookeeper-client-async');

// connect to zookeeper
const client = zookeeper.createAsyncClient('zookeeper:2181');
let clientPromise;

/**
 * Connects the client on first call and resolves the client once connected
 */
function getClientAsync() {
    if (!clientPromise) {
        clientPromise = client.connectAsync().then(() => client);
    }

    return clientPromise;
}

/**
 * Regisers this application as a server on zookeeper. Resolves
 * the path of the registration.
 * @param {string} name the name of this server
 */
async function registerAsync(name) {
    await getClientAsync();

    await client.mkdirpAsync('/web');
    
    return await client.createAsync(
        '/web/instance-',
        Buffer.from(JSON.stringify({ name })),
        null,
        zookeeper.CreateMode.EPHEMERAL_SEQUENTIAL);
}

/**
 * Removes a registration of a specific server.
 * @param {*} path The path of the regustratuib as returned by registerAsync
 */
async function unRegisterAsync(path) {
    await getClientAsync();
    await client.removeAsync(path);
}

/**
 * Returns the number of registered servers on zk.
 */
async function getNumberOfActiveServersAsync() {
    await getClientAsync();
    var children = await client.getChildrenAsync('/web');
    return children.length;
}

module.exports = {
    getClientAsync,
    registerAsync,
    unRegisterAsync,
    getNumberOfActiveServersAsync
};