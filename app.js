const express = require('express');

const app = express();
const PORT = 3000;

//connect to DynamoDB fortunie-cookie-table


//set view engine to EJS so we can serve partials to client
app.set("view engine", "ejs");

app.get("/", (req, res) => {
    res.render("index");
});

app.get("/fortune-cookie", (req, res) => {
    //access db and get random item from table
    //send phrase as string to client along with status code 200
    res.send({ "phrase": 'This is a test phrase' });
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