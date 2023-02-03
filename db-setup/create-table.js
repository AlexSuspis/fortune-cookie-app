var db = require('./connect-to-db');


var tableParams = {
    AttributeDefinitions: [
        {
            AttributeName: 'ID',
            AttributeType: 'N'
        },
        {
            AttributeName: 'PHRASE',
            AttributeType: 'S'
        }
    ],
    KeySchema: [
        {
            AttributeName: 'ID',
            KeyType: 'HASH'
        },
        {
            AttributeName: 'PHRASE',
            KeyType: 'RANGE'
        }
    ],
    ProvisionedThroughput: {
        ReadCapacityUnits: 1,
        WriteCapacityUnits: 1
    },
    TableName: 'fortune-cookie-table',
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

