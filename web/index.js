const logger = require('winston');
const Application = require('./app').Application;

//start the application
const application = new Application();
application.start();

// graceful shutdown
async function shutdown() {
    logger.info('received shutdown signal');
    await application.stop();

    logger.info('server stopped.');
    process.exit();
}

process.once('SIGINT', shutdown);
process.once('SIGUSR2', shutdown);