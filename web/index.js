const express = require('express');
const app = express();

const port = process.env.PORT || 3000;
const wwwroot = "public";

app.use(express.static(wwwroot));

app.listen(port, () => console.log(`Listening on port ${port}`));

