# Database Utilities

Bunch of useful scripts / functions I've come up up to make working with databases a bit easier.

## queries.sh

A bash scrip that lets you either query a database in interactive mode or run a query from a local file and export it to a CSV file on your local drive.
Databases are described through a list of aliases, see "Installation" paragraph below. 
Supports default input and output for those days where you're too lazy to specify input and output files.
Only support postgres databases / Redshift for now. Your passwords must be set up in .pgpass (see: http://www.postgresql.org/docs/current/static/libpq-pgpass.html)

### Examples

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
queries -s database1 -q -f source.sql -o result.csv
```

### Installation

1. Clone this git repository

2. Edit db-sample.conf and rename if db.conf when you're done
This is the master list of aliases mapped to your host x database details.
It is basically a file like your .pgpass file, following the format: `alias:hostname:port:database:user`. 
All fields are mandatory.

Example:
```
# alias:hostname:port:database:user
database1:my.postgres.db.com:5432:my_database1:user1
```
3. Edit queries-sample.conf and rename it to queries.conf when you're done
This is to let the script know user defaults such as default input / output and the location of your db.info

4. Enjoy

### Requirements
+ psql (recentish version)
+ an up-to-date .pgpass file

### Future improvements
+ Support for hosts/databases not present in .pgpass (automatically asks for password)
+ Support my MySQL
+ Imporved support for Redshift by UNLOADING to s3.

'k, bye.
