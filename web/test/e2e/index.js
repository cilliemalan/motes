const assert = require('chai').assert;
const webdriver = require('selenium-webdriver');
const By = webdriver.By;
const until = webdriver.until;

//this will start the server
process.env.PORT = process.env.ALT_PORT || 4000;
require('../../app');

//get our ip address
const os = require('os');
const ifaces = os.networkInterfaces();
const url = `http://${ifaces['eth0'][0].address}:${process.env.PORT}`;


describe('End to End tests', function () {
    this.timeout(60000);
    let driver;

    before(async function () {
        driver = await new webdriver.Builder()
            .usingServer('http://selenium-hub:4444/wd/hub')
            .withCapabilities(webdriver.Capabilities.chrome())
            .build();
    });

    after(async function () {
        await driver.quit();
    });

    describe('The site', function () {

        beforeEach(function () {
            // load the page
            driver.get(url);
        });

        it('loads', async function () {

            // check the page title
            const pageTitle = await driver.getTitle();
            assert.equal(pageTitle, 'Continuous Delivery Example');
        });

        it('has the expected header', async function () {

            // check that there is a header
            let h1 = await driver.findElement(By.css('h1'));

            // check the header text
            let headerText = await h1.getText();
            assert.equal(headerText, "Continuous Delivery Example");
        });

        it('can run the redis test', async function () {
            let redisButton = await driver.findElement(By.id("redistestbutton"));
            await redisButton.click();

            // // wait up to three seconds for the result to show
            await driver.wait(until.elementTextIs(
                driver.findElement(By.id("redistestcontainer")), '👍'),
                3000);
        });

        it('can run the zookeeper test', async function () {
            let zookeeperButton = await driver.findElement(By.id("zookeepertestbutton"));
            await zookeeperButton.click();

            // // wait up to three seconds for the result to show
            await driver.wait(until.elementTextIs(
                driver.findElement(By.id("zookeepertestcontainer")), '👍'),
                3000);
        });

        it('can run the mongo test', async function () {
            let mongoButton = await driver.findElement(By.id("mongotestbutton"));
            await mongoButton.click();

            // // wait up to three seconds for the result to show
            await driver.wait(until.elementTextIs(
                driver.findElement(By.id("mongotestcontainer")), '👍'),
                3000);
        });

        it('can run the influx test', async function () {
            let influxButton = await driver.findElement(By.id("influxtestbutton"));
            await influxButton.click();

            // // wait up to three seconds for the result to show
            await driver.wait(until.elementTextMatches(
                driver.findElement(By.id("influxtestcontainer")), /^👍 that was click #\d+ out of all clicks/),
                3000);
        });

    });
});
