const mysql = require('mysql');
const dotenv = require('dotenv');
let instance = null;
dotenv.config();
const connectionParams = {
    user: process.env.MYSQL_ROOT_USERNAME,
    password: process.env.MYSQL_ROOT_PASSWORD,
    host: process.env.MYSQL_HOST,
    port: process.env.MYSQL_PORT,
    database: process.env.MYSQL_DATABASE
};
let connection = mysql.createConnection(connectionParams);

connection.connect((err) => {
    if (err) {
        console.log(err.message);
        console.log("Retry..");
        connection.destroy();
        connection = mysql.createConnection(connectionParams);
        setTimeout(() => connection.connect((err) => {
            if (err) {
                connection.destroy();
                console.log(err.message);
                console.log("Connection failed");
            }
            console.log('db ' + connection.state);
        }), 10000);
    }
    console.log('db ' + connection.state);
});


class DbService {
    static getDbServiceInstance() {
        return instance ? instance : new DbService();
    }

    async search(last_name) {
        try {
            const response = await new Promise((resolve, reject) => {
                const query = "SELECT date, last_name, full_info FROM records WHERE last_name = ? ORDER BY date DESC;";

                connection.query(query, [last_name], (err, results) => {
                    if (err) reject(new Error(err.message));
                    resolve(results);
                })
            });

            return response;
        } catch (error) {
            console.log(error);
        }
    }

    async count() {
        try {
            const response = await new Promise((resolve, reject) => {
                const query = "SELECT COUNT(*) FROM records;";

                connection.query(query, [], (err, results) => {
                    if (err) reject(new Error(err.message));
                    resolve(results);
                })
            });

            return response;
        } catch (error) {
            console.log(error);
        }
    }
}

module.exports = DbService;