'use strict';


function makeApiCall(path, method, body, loaderContainer) {
    return new Promise((resolve) => {

        let loader;
        if (loaderContainer) {
            loaderContainer.innerHTML = "";

            loader = document.createElement('div');
            loader.className = 'loadingring';
            loaderContainer.appendChild(loader);
        }

        // headers for the request
        const headers = new Headers();
        if (body) {
            headers.set('Content-Type', 'application/json');
        }

        if (typeof body != undefined && body !== null && typeof body != "string") {
            body = JSON.stringify(body);
        }

        const requestOptions = {
            method: method,
            headers: headers,
            body: body
        };

        // make the request
        fetch(`api/${path}`, requestOptions)
            .then(response => {
                if (!response.ok) throw response.statusText;

                if (loader) loaderContainer.innerHTML = "";

                resolve(response.json());
            }).catch(e => {

                if (loader) {
                    var errorMessage = document.createElement('span');
                    var retryButton = document.createElement('a');
                    retryButton.innerText = 'retry';
                    retryButton.href = 'javascript:void(0)';
                    retryButton.addEventListener('click', () => makeApiCall(path, method, body, loaderContainer).then(resolve));
                    errorMessage.append('An error occurred. ');
                    errorMessage.append(retryButton);
                    errorMessage.className = 'error';
                    loaderContainer.replaceChild(errorMessage, loader);
                } else {
                    throw e;
                }
            });
    });
}

function updateStatus(status) {
    document.getElementById('servername').innerText = status.hostname;
    document.getElementById('version').innerText = status.version;
    document.getElementById('instances').innerText = status.instances;
}

makeApiCall('', 'GET', null, document.getElementById("loadingbar")).then(status => {
    document.getElementById('info').style.display = 'block';
    document.getElementById('controls').style.display = 'block';

    updateStatus(status);
});

//periodically refresh status
var oldCall;
window.setInterval(() => {
    if (!oldCall) oldCall = makeApiCall('', 'GET');
    oldCall
        .then(r => {
            updateStatus(r);
            oldCall = null;
        })
        .catch(e => {
            console.error(e);
            oldCall = null;
        });
}, 2500);

const redistestcontainer = document.getElementById('redistestcontainer');
const redistestbutton = document.getElementById('redistestbutton');
const zookeepertestcontainer = document.getElementById('zookeepertestcontainer');
const zookeepertestbutton = document.getElementById('zookeepertestbutton');
const mongotestcontainer = document.getElementById('mongotestcontainer');
const mongotestbutton = document.getElementById('mongotestbutton');
const influxtestcontainer = document.getElementById('influxtestcontainer');
const influxtestbutton = document.getElementById('influxtestbutton');


redistestbutton.addEventListener('click', () => {
    makeApiCall('redis', 'POST', null, redistestcontainer).then(r => {
        redistestcontainer.innerText = r.success ? '👍' : '😭';
    });
});

zookeepertestbutton.addEventListener('click', () => {
    makeApiCall('zookeeper', 'POST', null, zookeepertestcontainer).then(r => {
        zookeepertestcontainer.innerText = r.success ? '👍' : '😭';
    });
});

mongotestbutton.addEventListener('click', () => {
    makeApiCall('mongo', 'POST', null, mongotestcontainer).then(r => {
        mongotestcontainer.innerText = r.success ? '👍' : '😭';
    });
});

influxtestbutton.addEventListener('click', () => {
    makeApiCall('influx', 'POST', null, influxtestcontainer).then(r => {
        let statusText = r.success ? '👍' : '😭';
        statusText += ` that was click #${r.total} out of all clicks`;
        influxtestcontainer.innerText = statusText;
    });
});
