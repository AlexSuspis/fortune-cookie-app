var db = require('./connect-to-db');


var tableParams = {
    KeySchema: [
        {
            AttributeName: 'ID',
            KeyType: 'HASH'
        }
    ],
    AttributeDefinitions: [
        {
            AttributeName: 'ID',
            AttributeType: 'N'
        }
    ],
    ProvisionedThroughput: {
        ReadCapacityUnits: 1,
        WriteCapacityUnits: 1
    },
    TableName: db.TABLE_NAME,
    StreamSpecification: {
        StreamEnabled: false
    }
}

db.createTable(tableParams, function (err, data) {
    if (err) {
        console.log("Error when creating database:\n\n", err);
    } else {
        console.log("Success in creating database!:\n\n", data);
    }
});

