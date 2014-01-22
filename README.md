# Database Utilities

Bunch of useful scripts / functions I've come up up to make working with databases a bit easier.

## queries.sh

A bash scrip that lets you either query a database in interactive mode or run a query from a local file and export it to a CSV file on your local drive.
Databases are described through a list of aliases, see "Installation" paragraph below. 
Supports default input and output files for those days where you're too lazy to specify input and output files.
Only support postgres databases for now. Your passwords must be set up in .pgpass (see: http://www.postgresql.org/docs/current/static/libpq-pgpass.html)

### Examples

This connects to the databases with alias "database1" (interactive mode)
    queries.sh -s database1

This runs the query contained in your default input file on database1 and outputs the results to your default output file
    queries.sh -s database1 -q

This runs the query contained in source.sql on database1 and outputs the results to result.cv
    queries -s database1 -q -f source.sql -o result.csv

### Installation

1. Create your db.info file
This is the master list of aliases mapped to your host x database details.
It is basically a file like your .pgpass file, following the format: alias:hostname:port:database:user. 
All fields are mandatory.

Example:
    # alias:hostname:port:database:user
    database1:my.postgres.db.com:5432:my_database1:user1

2. Configure queries.sh
Edit queries.sh to specify the location of your default input file (must exist), the location of your db.info file and your default output file.

3. Enjoy

### Requirements
+ psql (recentish version)
+ an up-to-date .pgpass file

### Future improvements
+ Support for hosts/databases not present in .pgpass (automatically asks for password)
+ Support my MySQL
+ Export config lines to their own queries.cfg file

'k, bye.
