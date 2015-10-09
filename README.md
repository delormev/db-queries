# Database queries

A bash script that lets you easily connect to and query databases using aliases. 

## queries.sh

The scrip that lets you either query a database in interactive mode or run a query from a local file and export it to a CSV file on your local drive.
Databases are described through a list of aliases, see "Installation" paragraph below. 
Supports default input and output for those days where you're too lazy to specify input and output files.
Works MySQL and postgres databases (including Redshift) for now. 
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

1. Clone this git repository

2. Edit db-sample.conf and rename it to db.conf when you're done.
This is the master list of aliases mapped to your host x database details.
It is basically a file like your .pgpass file, following the format: `alias:dbtype:hostname:port:database:user`. 
All fields are mandatory; `dbtype` can either be `postgres` or `mysql`.
Example: 
```database1:postgres:my.postgres.db.com:5432:my_database1:user1
database1:mysql:my.postgres.db.com:5432:my_database1:user1```

3. Edit queries-sample.conf and rename it to queries.conf when you're done.
This is to let the script know user defaults such as default input / output and the location of your db.info

4. Enjoy

## Requirements
+ psql
+ mysql

## Future improvements
+ A password file that lets you store your passwords locally (like .pgpass but database agnostic)
+ Improved support for Redshift by UNLOADING to s3.