const express = require('express');

const app = express();
const PORT = 3000;

//connect to DynamoDB fortunie-cookie-table


app.get("/", (req, res) => {
    res.send("Hello World from Express app!");
});

app.get("/fortune-cookie", (req, res) => {
    //access db and get random item from table
    //send phrase as string to client along with status code 200
});
app.post("/fortune-cookie", (req, res) => {
    //insert item into table
    //send phrase as string to client along with status code 200
});

app.listen(PORT, (error) => {
    if (!error)
        console.log("Server listening on port " + PORT)
    else
        console.log("Error occurred, server can't start", error);
}
);