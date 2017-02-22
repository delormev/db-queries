# Database queries

A bash script that lets you easily connect to and query databases using aliases. 

## queries.sh

The script lets you either query a database in interactive mode or run a query from a local file and export it to a CSV file on your local drive.
Databases are described through a list of aliases, see "Installation" paragraph below. 
Supports default input and output files for those days where you're too lazy to specify them.
Works with MySQL and postgres databases (including Redshift) for now. 
As this is just a wrapper around psql, the use of [.pgpass](http://www.postgresql.org/docs/current/static/libpq-pgpass.html) is supported when connecting to postgres databases.

## Examples

This connects to the databases with alias "database1" (interactive mode)
```
queries.sh -s database1
```

This runs the query contained in your default input file on database1 and outputs the results to STDOUT
```
queries.sh -s database1 -q
```

This runs the query contained in source.sql on database1 and outputs the results to result.cv
```
queries.sh -s database1 -q -f source.sql -o result.csv
```

## Installation

### Basic Installation

1. Clone this git repository

2. Edit db-sample.conf and rename it to db.conf when you're done.  
This is the master list of aliases mapped to your host x database details.  
It is basically a file like your .pgpass file, following the format: `alias:dbtype:hostname:port:database:user`. 
All fields are mandatory; `dbtype` can either be `psql` or `mysql`.  
Example: 
 ```
#alias:dbtype:hostname:port:database:user
database1:postgres:my.postgres.db.com:5432:my_database1:user1
database1:mysql:my.mysql.db.com:3306:my_database1:user1
```

3. Edit queries-sample.conf and rename it to queries.conf when you're done.  
This is to let the script know user defaults such as default input / output and the location of your db.info

4. Enjoy

### About Passwords

If you are not familiar with .pgpass files, no worries: you can read more about them [here](http://www.postgresql.org/docs/current/static/libpq-pgpass.html), or just use the script as it is (it will just prompt you for a password if needed.)
To match the native Postgres behaviour, the command supports a password file for MySQL as well. You can just add those to your normal .pgpass file and it'll pick it up! 
The password is used in the command line, which isn't super secure (as the MySQL startup message will remind you), but it won't be displayed in your terminal when you connect to a database that way. 

### Advanced Set-Up: tunneling through remote server

I've also built support for databases behind firewalls / on server where the database ports are not open. 
The only thing you'll need is SSH access without having to specify a password.

The way to use this feature is to modify your `db.conf` file to include the port you want to tunnel through and the username (if it's different to your local username).

Simply add `[port]` or `[port:username]` at the end of the line in your db.conf file. So the format becomes:
  ```
#alias:dbtype:hostname:port:database:user[port:username]
database1:mysql:my.mysql.db.com:3306:my_database1:user1[tunnel_port:ssh_username]
```

## Requirements
+ psql
+ mysql

## Future improvements
+ Add a layer of security to the password file (for example by checking the file permissions and making sure they are not too open)
+ Improved support for Redshift by UNLOADING to s3.
