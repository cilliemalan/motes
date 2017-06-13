const request = require('request-promise');
const logger = require('winston');
const fs = require('fs');

const token = fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/token').toString();
const auth = { Authorization: `Bearer ${token}` };
let allSecrets = {};
const agentOptions = { ca: fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt') };

/**
 * Loads secrets from the local k8s cluster if they have not yet been loaded
 * @param {boolean?} force if true will force reload secrets.
 */
async function initializeAsync(force) {
    if (Object.keys(allSecrets).length && !force) return;

    logger.silly('loading secrets...');

    const data = await request({
        uri: 'https://kubernetes/api/v1/namespaces/default/secrets',
        json: true,
        headers: auth,
        agentOptions
    });

    function base64decode(input) {
        return Buffer.from(input, 'base64').toString("ascii");
    }

    if (data && data.items) {
        data.items.filter(s => s.type == 'Opaque')
            .forEach(s => {
                let name = s.metadata.name;
                let data = {};
                Object.keys(s.data).forEach(k => data[k] = base64decode(s.data[k]));
                allSecrets[name] = data;
            });
    }

    logger.verbose(`loaded secrets for: ${Object.keys(allSecrets).join(", ")}`);
}

/**
 * Gets the value of a secret.
 * @param {string} name the name of the secret (e.g. redis).
 * @param {*} key the name of the key within the secret (e.g. password).
 */
function get(name, key) {
    return allSecrets && allSecrets[name] && allSecrets[name][key];
}

module.exports = {
    initializeAsync,
    get
};