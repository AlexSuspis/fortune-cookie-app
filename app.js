const { DocDB } = require('aws-sdk');
const express = require('express');

const app = express();
const PORT = 3000;

//connect to DynamoDB fortune-cookie-table
var db = require('./db-setup/connect-to-db');

//set view engine to EJS so we can serve partials to client
app.set("view engine", "ejs");


app.get("/", (req, res) => {
    res.render("index");
});

app.get("/fortune-cookie", async (req, res) => {
    //get total number of records in database n
    params = {
        TableName: db.TABLE_NAME,
        Select: "COUNT"
    }
    const response = await db.scan(params).promise();
    const count = response.Count

    //pick random index between 0 and n-1
    var random_index = Math.floor(Math.random() * count)
    console.log(random_index)

    //get that record by index
    params = {
        TableName: db.TABLE_NAME,
        Key: { "ID": { N: String(random_index) } }
    }
    //query database and return result to user
    await db.getItem(params).promise()
        .then(response => response.Item.PHRASE.S)
        .then(phrase => res.send({ "phrase": phrase }))
        .catch(err => res.error("error occurred:", err))
});
app.post("/fortune-cookie", async (req, res) => {
    var phrase = req.query.phrase;

    //get total number of records in database n
    // params = {
    //     TableName: db.TABLE_NAME,
    //     Select: "COUNT"
    // }
    // const response = await db.scan(params).promise();
    // const index = response.Count
    // //insert item into table with key/index equal to total count of items on table
    // var params = {
    //     TableName: db.TABLE_NAME,
    //     Item: {
    //         "ID": { N: String(index) },
    //         "PHRASE": { S: phrase }
    //     }
    // }
    // console.log(params)

    // db.putItem(params, (err, data) => {
    //     if (err) console.log("Error while adding item to database.", err)
    //     else if (data) console.log("Success, item added to database.", data)
    // });
    //send phrase as string to client along with status code 200
    res.send({ "result": "phrase received :)" });
});

app.listen(PORT, (error) => {
    if (!error)
        console.log("Server listening on port " + PORT)
    else
        console.log("Error occurred, server can't start", error);
}
);