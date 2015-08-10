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
queries.sh -s database1 -q -f source.sql -o result.csv
```

### Installation

1. Clone this git repository

2. Edit db-sample.conf and rename it to db.conf when you're done
This is the master list of aliases mapped to your host x database details.
It is basically a file like your .pgpass file, following the format: `alias:hostname:port:database:user`. 
All fields are mandatory.
Example: `database1:my.postgres.db.com:5432:my_database1:user1`

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

## psql-pgpass-conf.R

An R function that lets the user easily connect to a Postgres database using the same alias file described above.
It creates a connection to the database corresponding to the alias specified using the password contained in .pgpass.

## Usage

This creates a connection to database1 using the default locations for .pgpass and db.conf
```R
source(psql-pgpass-conf.R)
createPostgresConnection("database1")
```
This creates the PostgreSQL Driver `drv` and Connection `con` in your Global Environment (as a side-effect).

Alternatively you can specify the locations of .pgpass and db.conf directly in your script
```R
source(psql-pgpass-conf.R)
createPostgresConnection("database1", pgPassFile = "~/.pgpass", dbConfFile = "~/confs/db.conf")
```

Don't forget to close the connection and free up the resources used by the driver at the end of your script
```R
dbDisconnect(con)
dbUnloadDriver(drv)
```

## Installation

1. Clone this repository

2. Set up your db.conf (see Installation section for queries.sh above)

3. Edit psql-pgpass-conf.R and specify the location of your .pgpass and db.conf files (line 10)
```R
createPostgresConnection <- function(dbAlias, pgPassFile = "LOCATION_OF_YOUR_PGPASS", dbConfFile = "LOCATION_OF_YOUR_DB_CONF", silent = FALSE) {
```

## Dependencies
+ RPostgreSQL package
+ stringr package
