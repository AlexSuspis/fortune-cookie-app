var phrases = require('./seed-data');
var db = require('./connect-to-db');
var { v4: uuidv4 } = require('uuid');

// delete all items in table
var clearTable = async () => {

}

//add all items to table
var populateTable = async () => {
    await phrases.forEach((phrase, index) => {
        var params = {
            TableName: db.TABLE_NAME,
            Item: {
                "ID": { N: String(index) },
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