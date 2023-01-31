const express = require('express');

const app = express();
const PORT = 3000;

app.get("/home", (req, res) => {
    res.send("Hello World from Express app!");
})

app.listen(PORT, (error) => {
    if (!error)
        console.log("Server listening on port " + PORT)
    else
        console.log("Error occurred, server can't start", error);
}
);