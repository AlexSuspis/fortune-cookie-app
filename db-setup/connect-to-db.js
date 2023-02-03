var AWS = require('aws-sdk');

// checks '~/.aws/credentials' file in local system for AWS tokens 
var credentials = new AWS.SharedIniFileCredentials({ profile: 'default' });
AWS.config.credentials = credentials;
AWS.config.update({ region: 'us-west-2' })

var db = new AWS.DynamoDB();

module.exports = db;
