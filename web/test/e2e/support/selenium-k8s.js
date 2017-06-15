const request = require('request-promise');
const logger = require('winston');
const fs = require('fs');
const tcpp = require('tcp-ping');

const token = fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/token').toString();
const auth = { Authorization: `Bearer ${token}` };
const agentOptions = { ca: fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt') };

const seleniumDeployment = {
    apiVersion: 'apps/v1beta1',
    kind: 'Deployment',
    metadata: {
        name: 'dev-selenium'
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    app: 'selenium',
                    set: 'testing'
                }
            },
            spec: {
                containers: [{
                    name: 'dev-selenium',
                    imagePullPolicy: 'IfNotPresent',
                    image: 'selenium/standalone-chrome',
                    ports: [{
                        name: 'selenium',
                        containerPort: '4444'
                    }]
                }]
            }
        }
    }
};

const seleniumService = {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
        name: 'dev-selenium',
        labels: {
            app: 'selenium',
            set: 'testing'
        }
    },
    spec: {
        clusterIP: 'None',
        ports: [{
            name: 'selenium',
            port: 4444
        }],
        selector: {
            app: 'selenium',
            set: 'testing'
        }
    }
};

/**
 * Returns a promise that resolves after a while
 * @param {number} howlong number of miliseconds to delay
 */
function delay(howlong) {
    return new Promise((resolve) => setTimeout(resolve, howlong));
}

/**
 * checks that the given host is listening on a given address
 * @param {string} address 
 * @param {number} port 
 */
function probe(address, port) {
    return new Promise((resolve, reject) => {
        tcpp.probe(address, port, (e, d) => {
            if (e) reject(e);
            else resolve(d);
        });
    });
}

/**
 * Make a Kubernetes API call
 * @param {*} method the http method to make the call with
 * @param {*} path the path for the API call (e.g. /api/v1/namespaces/{namespace}/pods/{name})
 * @param {*} body the body of the call if POST, PUT, or PATCH
 */
async function k8s(method, path, body = null, contentType = null) {
    try {
        logger.info(`k8s ${method} to ${path}`);
        logger.silly(`k8s ${method} to ${path}\n request: ${JSON.stringify(body, null, '  ')}`);
        const response = await request({
            method: method,
            uri: `https://kubernetes${path}`,
            json: true,
            headers: Object.assign({}, auth, contentType && { 'Content-Type': contentType }),
            body: body,
            agentOptions
        });

        return response;
    } catch (e) {
        if (e.statusCode == 404) return null;
        else throw e;
    }
}

/**
 * Make a Kubernetes API GET request.
 * @param {*} path the path for the API call (e.g. /api/v1/namespaces/{namespace}/pods/{name})
 */
function k8sGet(path) {
    return k8s('GET', path);
}

/**
 * Make a Kubernetes API POST request.
 * @param {*} path the path for the API call (e.g. /api/v1/namespaces/{namespace}/pods/{name})
 */
function k8sPost(path, body) {
    return k8s('POST', path, body);
}

/**
 * Make a Kubernetes API PATCH request with content type application/strategic-merge-patch+json
 * @param {*} path the path for the API call (e.g. /api/v1/namespaces/{namespace}/pods/{name})
 */
function k8sPatch(path, body) {
    return k8s('PATCH', path, body, 'application/strategic-merge-patch+json');
}


/**
 * Get the selenium deployment
 */
function getSeleniumDeployment() {
    return k8sGet('/apis/apps/v1beta1/namespaces/default/deployments/dev-selenium');
}

/**
 * Get the selenium service
 */
async function getSeleniumService() {
    return k8sGet('/api/v1/namespaces/default/services/dev-selenium');
}

/**
 * Create the selenium deployment
 */
async function createSeleniumDeployment() {
    const result = await k8sPost('/apis/apps/v1beta1/namespaces/default/deployments', seleniumDeployment);

    logger.info('created selenium deployment');
    return result;
}

/**
 * Scales the selenium deployment to a specific number
 * @param {number} scale the number of servers to scale to
 */
async function scaleSeleniumDeployment(scale) {
    const result = k8sPatch('/apis/apps/v1beta1/namespaces/default/deployments/dev-selenium', {
        spec: {
            replicas: scale
        }
    });

    logger.info(`scaled selenium deployment to ${scale}`);
    return result;
}

/**
 * Create the selenium service
 */
async function createSeleniumService() {
    const result = k8sPost('/api/v1/namespaces/default/services', seleniumService);

    logger.info('created selenium service');
    return result;
}

/**
 * Create or scale the selenium deployment
 */
async function manageSeleniumDeployment() {
    let deployment = await getSeleniumDeployment();
    if (!deployment) {
        await createSeleniumDeployment();
    } else {
        if (deployment.spec.replicas == 0) {
            deployment = scaleSeleniumDeployment(1);
        }
    }
}

/**
 * Makes sure a selenium service is created
 */
async function manageSeleniumService() {
    let service = await getSeleniumService();
    if (!service) {
        await createSeleniumService();
    }
}

/**
 * Makes sure a selenium deployment, pod, and service are created
 */
async function startSeleniumAsync() {
    await Promise.all([
        manageSeleniumDeployment(),
        manageSeleniumService()]);

    logger.info('selenium deployment and service created');

    // wait for 10 minutes max
    let cutoff = new Date();
    const waitMinutes = 10;
    cutoff.setMinutes(cutoff.getMinutes() + waitMinutes);
    let ready = false;
    let available = false;

    while (new Date() < cutoff) {
        const deployment = await getSeleniumDeployment();
        if (deployment && deployment.status && deployment.status.readyReplicas > 0) {
            logger.info('selenium server ready');
            ready = true;
            break;
        }
        logger.info('waiting for selenium to become ready...');
        await delay(1000);
    }

    if (!ready) throw `Waited ${waitMinutes} minutes and selenium never became ready`;

    while (new Date() < cutoff) {
        available = await probe('dev-selenium', 4444);
        if (available) {
            logger.info('selenium server accepting connections');
            break;
        }

        logger.info('waiting for selenium to accept connections...');
        await delay(1000);
    }

    if (!available) throw `Waited ${waitMinutes} minutes and selenium never accepted connections`;

    return `http://dev-selenium:4444/wd/hub`;
}

/**
 * Scales down the selenium deployment
 */
async function stopSeleniumAsync() {
    await scaleSeleniumDeployment(0);

    // wait for 2 minutes max
    let cutoff = new Date();
    const waitMinutes = 2;
    cutoff.setMinutes(cutoff.getMinutes() + waitMinutes);
    let stopped = false;

    while (new Date() < cutoff) {
        const deployment = await getSeleniumDeployment();
        if (deployment && deployment.status && !deployment.status.readyReplicas) {
            logger.info('selenium deployment scaled down to 0');
            stopped = true;
            break;
        }
        logger.info('waiting for selenium deployment to scale down...');
        await delay(1000);
    }

    if (!stopped) throw `Waited ${waitMinutes} minutes and selenium deployment never scaled down`;
}

module.exports = {
    startSeleniumAsync,
    stopSeleniumAsync
};