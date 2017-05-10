'use strict';


function makeApiCall(path, method, body, loaderContainer) {
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
    return fetch(`api/${path}`, requestOptions)
        .then(response => {
            if (!response.ok) throw response.statusText;

            if (loader) loaderContainer.innerHTML = "";

            return response.json();
        }).catch(() => {

            if (loader) {
                var errorMessage = document.createElement('span');
                var retryButton = document.createElement('a');
                retryButton.innerText = 'retry';
                retryButton.href = 'javascript:void(0)';
                retryButton.addEventListener('click', () => makeApiCall(path, method, body, loaderContainer));
                errorMessage.append('An error occurred. ');
                errorMessage.append(retryButton);
                errorMessage.className = 'error';
                loaderContainer.replaceChild(errorMessage, loader);
            }
        });
}

makeApiCall('', 'GET', null, document.getElementById("loadingbar")).then(r => {
    document.getElementById('info').style.display = 'block';
    document.getElementById('servername').innerText = r.hostname;
    document.getElementById('version').innerText = r.version;

    document.getElementById('controls').style.display = 'block';
});

const redistestcontainer = document.getElementById('redistestcontainer');
const redistestbutton = document.getElementById('redistestbutton');
const zookeepertestcontainer = document.getElementById('zookeepertestcontainer');
const zookeepertestbutton = document.getElementById('zookeepertestbutton');
const mongotestcontainer = document.getElementById('mongotestcontainer');
const mongotestbutton = document.getElementById('mongotestbutton');
const graphitetestcontainer = document.getElementById('graphitetestcontainer');
const graphitetestbutton = document.getElementById('graphitetestbutton');


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

graphitetestbutton.addEventListener('click', () => {
    makeApiCall('graphite', 'POST', null, graphitetestcontainer).then(r => {
        graphitetestcontainer.innerText = r.success ? '👍' : '😭';
    });
});
