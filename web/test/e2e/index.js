const assert = require('chai').assert;
const webdriver = require('selenium-webdriver');
const By = webdriver.By;

//this will start the server
process.env.PORT = process.env.ALT_PORT || 4000;
require('../../app');

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
            driver.get(`http://local-dev-alt:${process.env.PORT}`);
        });

        it('loads', async function () {

            // check the page title
            const pageTitle = await driver.getTitle();
            assert.equal(pageTitle, 'Continuous Delivery Example');

            // check that there is a header
            let h1 = await driver.findElement(By.css('h1'));

            // check the header text
            let headerText = await h1.getText();
            assert.equal(headerText, "Continuous Delivery Example");
        });

    });
});
