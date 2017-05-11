const ghost = require('ghostjs').default;
const assert = require('chai').assert;

//this will start the server
const url = require('../index').url;

describe('The site', () => {

    beforeEach(async () => {

        // open the page
        await ghost.open(url);

    });

    it('loads', async () => {

        // check the title
        let pageTitle = await ghost.pageTitle();
        assert.equal(pageTitle, 'Continuous Deliver Example');

        // check that there is a header
        let h1 = await ghost.findElement("h1");
        assert.isOk(h1);

        // check the header text
        let headerText = await h1.text();
        assert.isOk(headerText);
        assert.equal(headerText, "Continuous Deliver Example");
    });
});
