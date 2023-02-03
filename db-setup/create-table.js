var db = require('./connect-to-db');


var tableParams = {
    AttributeDefinitions: [
        {
            AttributeName: 'COOKIE_ID',
            AttributeType: 'N'
        },
        {
            AttributeName: 'COOKIE_SENTENCE',
            AttributeType: 'S'
        }
    ],
    KeySchema: [
        {
            AttributeName: 'COOKIE_ID',
            KeyType: 'HASH'
        },
        {
            AttributeName: 'COOKIE_SENTENCE',
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

