var db = require('./connect-to-db');

//remove previous, if any, tables called fortune-cookie-table
params = {
    TableName: db.TABLE_NAME
}
db.deleteTable(params, (err, data) => {
    if (err && err.code === 'ResourceNotFoundException') {
        console.log("Error: Table not found");
    } else if (err && err.code === 'ResourceInUseException') {
        console.log("Error: Table in use");
    } else {
        console.log("Success in deleting table", data);
    }
});