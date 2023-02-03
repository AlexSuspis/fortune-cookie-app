var phrases = require('./seed-data');
var db = require('./connect-to-db');
var { v4: uuidv4 } = require('uuid');

// delete all items in table
var clearTable = async () => {

}

//add all items to table
var populateTable = async () => {
    await phrases.forEach(phrase => {
        var params = {
            TableName: "fortune-cookie-table",
            Item: {
                "ID": { S: uuidv4() },
                "PHRASE": { S: phrase }
            }
        }
        console.log(params)

        db.putItem(params, (err, data) => {
            if (err) console.log("Error during .putItem():", err)
            else if (data) console.log("Success putItem():", data)
        });
    });
}

populateTable()