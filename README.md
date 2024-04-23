# CMTS (Cognitios Multi-Tenant SQLite3) Library

CMTS is a library designed for creating isolated databases for each user in a multi-tenancy environment. Each isolated database is encrypted with a unique key, adhering to the Zero Trust security concept.

## Introduction

CMTS (Cognitios Multi-Tenant SQLite3) Library is a powerful tool for developers working on multi-tenant applications where data isolation and security are paramount. It allows developers to create and manage isolated SQLite3 databases for each user seamlessly.

## Features

- **Multi-Tenancy Support**: CMTS enables developers to create separate databases for each user, ensuring data isolation and privacy.
- **Database Encryption**: Each isolated database is encrypted with a unique key, providing an extra layer of security.
- **Zero Trust Architecture**: Following the Zero Trust security model, CMTS ensures that access to each database is strictly controlled and authenticated.
- **Ease of Integration**: CMTS is designed to be easily integrated into existing applications with minimal changes to the codebase.

## Usage

Using CMTS in your application is straightforward:

1. **Initialization**: Initialize CMTS library in your application with the necessary configurations.
   
   ```lua
   local cmts = require("cmts")
   cmts.init()
   ```

2. **Create Isolated Database**: Create a new isolated database for each user.

   ```lua
   local userDb = cmts.createDatabase(userId)
   ```

3. **Access Database**: Use the created database for user-specific operations.

   ```lua
   userDb:execute("CREATE TABLE IF NOT EXISTS UserData (id INTEGER PRIMARY KEY, name TEXT)")
   ```

4. **Secure Operations**: Perform secure database operations ensuring data privacy and integrity.

   ```lua
   userDb:execute("INSERT INTO UserData (name) VALUES (?)", "John Doe")
   ```

5. **Cleanup**: Properly release resources when done.

   ```lua
   userDb:close()
   ```

## Security Considerations

CMTS employs industry-standard encryption techniques to secure user data. However, developers should adhere to best practices for handling sensitive information and regularly update CMTS to benefit from the latest security enhancements.

## Conclusion

CMTS (Cognitios Multi-Tenant SQLite3) Library is an indispensable tool for developers building multi-tenant applications. With its robust features and adherence to security best practices, CMTS simplifies the process of managing isolated databases while ensuring data privacy and security for each user.