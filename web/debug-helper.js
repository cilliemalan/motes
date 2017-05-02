(async function main() {

    const net = require("net");
    const spawn = require('child_process').spawn;
    const listenPort = 30858;
    const connectPort = 31858;
    const minikubeIp = '192.168.99.102';
    let backlog = [];
    let connected = false;
    let terminated = false;
    let serverConnection = null;
    let clientConnection = null;
    let retries = 0;

    function serverListen() {
        return new Promise((resolve, reject) => {

            console.log(`going to listen on ${listenPort}`);
            const server = net.createServer(socket => {

                if (serverConnection) {
                    console.log("ending dup connection");
                    socket.end();
                } else {
                    console.log(`debugger has connected`);
                    serverConnection = socket;

                    socket.on('data', data => {
                        if (terminated) socket.end();
                        else {
                            if (connected) clientConnection.write(data);
                            else backlog.push(data);
                        }
                    });
                }
            });

            // and wait for connection
            server.listen(listenPort, () => { console.log(`Listening on port ${listenPort}`); resolve(); });
            server.on('error', e => reject(e));
        });
    }

    function runProgram(cmd, args, chainstdio) {
        return new Promise((resolve, reject) => {
            let output = "";
            console.log(`starting ${cmd}`);
            const program = spawn(cmd, args, { stdio: chainstdio && "inherit" });
            if (!chainstdio) {
                program.stdout.on('data', data => { output += data; console.log(`[${cmd}]: ${data.toString()}`); });
                program.stderr.on('data', data => console.log(`[${cmd}]: ${data.toString()}`));
            }
            program.on('exit', (code) => {
                console.log(`${cmd} exited with code ${code}`);
                if (code) reject(code);
                else resolve(output.trim());
            });
            program.on('error', e => {
                console.error(`error running ${cmd}: ${e}`);
                reject(e);
            });
        });
    }

    function connectClient(ip, port) {
        return new Promise((resolve, reject) => {
            connected = false;
            if (clientConnection) {
                try { clientConnection.end(); } catch (_) { };
                clientConnection = null;
            }

            clientConnection = net.connect({ port: port, host: ip }, () => {
                console.log(`connected to ${ip}:${port}`);
                resolve();
                connected = true;

                //send backlog of packets
                if(backlog.length) {
                    console.log(`Sending backlog of ${backlog.length} packets`);
                    backlog.forEach(p => clientConnection.write(p));
                }
            });

            clientConnection.on('data', data => {
                if (!serverConnection) clientConnection.end();
                else {
                    serverConnection.write(data);
                }
            });

            clientConnection.on('error', e => {
                console.log(`connection error: ${e}`);
                setTimeout(() => {
                    if (++retries < 10) {
                        console.log(`retry #${retries}`);
                        connectClient();
                    } else {
                        terminated = true;
                        serverConnection && serverConnection.end();
                        reject();
                    }
                }, 1000);
            });


        });


    }

    //listen for debugger
    await serverListen();

    //copy files in
    console.log("preparing pod...")
    await runProgram('bash', ['copy-files-to-k8s.sh'], false);

    //get minikube ip address
    // console.log("finding minkube address...");
    // let minikubeIp = await runProgram('minikube', ['ip'], false);
    // console.log(`using minikube ip address ${minikubeIp}:${connectPort}`);

    //start client
    let runningProgram = runProgram('kubectl', ['exec', 'web', '--', 'node', '--debug=0.0.0.0:5858', '--debug-brk', '--nolazy', 'index.js'], true);
    let ondone = () => (clientConnection && clientConnection.end()) || (serverConnection && serverConnection.end());
    runningProgram.then(ondone, ondone);

    //connect to client
    await connectClient(minikubeIp, connectPort);

})();