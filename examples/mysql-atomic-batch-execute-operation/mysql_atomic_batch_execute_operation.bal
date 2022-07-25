import ballerina/log;
import ballerinax/mysql;
import ballerina/sql;

public function main() returns error? {
    // Runs the prerequisite setup for the example.
    check initialize();

    // Initializes the MySQL client. The `mysqlClient` can be reused to access the database throughout the application execution.
    mysql:Client mysqlClient = check new (user = "root",
            password = "Test@123", database = "CUSTOMER");

    // The transaction block can be used to roll back if any error occurred.
    transaction {
        _ = check mysqlClient->execute(`INSERT INTO Customers (firstName, 
                     lastName, registrationID, creditLimit, country) VALUES 
                     ('Linda', 'Jones', 4, 10000.75, 'USA')`);
        log:printInfo("First query executed successfully.");

        // Insert Customer record which violates the unique
        sql:ExecutionResult|sql:Error result = mysqlClient->execute(
                `INSERT INTO Customers (firstName, lastName, registrationID,
                 creditLimit, country) VALUES ('Peter', 'Stuart', 4, 5000.75,
                 'USA')`);

        if result is sql:Error {
            log:printError(result.message());
            log:printInfo("Second query failed. Rollback transaction.");
            rollback;
        } else {
            error? err = commit;
            if err is error {
                log:printError("Error occurred while committing", err);
            }
        }
    }

    // Closes the MySQL client.
    check mysqlClient.close();

    // Performs the cleanup after the example.
    check cleanup();
}

// Initializes the database as a prerequisite to the example.
function initialize() returns sql:Error? {
    mysql:Client mysqlClient = check new (user = "root", password = "Test@123");

    // Creates a database.
    _ = check mysqlClient->execute(`CREATE DATABASE CUSTOMER`);

    // Creates a table in the database.
    _ = check mysqlClient->execute(`CREATE TABLE CUSTOMER.Customers
            (customerId INTEGER NOT NULL AUTO_INCREMENT,
            firstName VARCHAR(300), lastName  VARCHAR(300), registrationID
            INTEGER UNIQUE, creditLimit DOUBLE, country  VARCHAR(300),
            PRIMARY KEY (customerId))`);

    // Adds records to the newly-created table.
    _ = check mysqlClient->execute(`INSERT INTO CUSTOMER.Customers
            (firstName, lastName, registrationID,creditLimit,country) VALUES
             ('Peter', 'Stuart', 1, 5000.75, 'USA')`);

    check mysqlClient.close();
}

// Cleans up the database after running the example.
function cleanup() returns sql:Error? {
    mysql:Client mysqlClient = check new (user = "root", password = "Test@123");

    // Cleans the database.
    _ = check mysqlClient->execute(`DROP DATABASE CUSTOMER`);

    // Closes the MySQL client.
    check mysqlClient.close();
}
