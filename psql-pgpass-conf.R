# Dependencies
# RPostgreSQL
if (!"RPostgreSQL" %in% installed.packages()) install.packages("RPostgreSQL")
library("RPostgreSQL")
# StringR
if (!"stringr" %in% installed.packages()) install.packages("string")
library("stringr")

# Set-up: Specify the location of your config and .pgpass files below
createPostgresConnection <- function(dbAlias, pgPassFile = "~/.pgpass", dbConfFile = "~/db.conf", silent = FALSE) {
  # Creates a PostgreSQL driver and a connection to the database `dbAlias`
  # using the pgpass and db.conf files specified.
  #
  # Args:
  #   pgPassFilex: Location of ".pgpass" on your filesystem.
  #   dbConfFile: Location of "db.conf" on your filesystem.
  #   dbAlias: Alias of the database you want to connect to (must be
  #            present in db.conf).
  #
  # Returns:
  #   Nothing. These variables will be created as a side-effect:
  #   drv: PostgreSQL Driver
  #   con: PosgreSQL Connection to `dbAlias`
  
  processFileRegex <- function(filename, regex, header = TRUE) {
    # Create data frame based on the data from `filename`. Filters out anything that doesn't match the 
    # regex. Capturing groups define the columns of the data frame.
    # 
    # Args:
    #   filename: Location of the file to be processed.
    #   regex: Regular expression to process the file with
    #   header: if TRUE, first row is used as column names and removed from the data frame.
    #           Defaults to TRUE.
    #   silent: if TRUE, won't output the logs / reminders after running. Defaults to FALSE.
    # 
    # Returns:
    #   A data frame corresponding to the data from filename matching the regex, broken down in colums.
    rawFile <- readLines(filename)
    rawClean <- rawFile[grep(regex, rawFile)]
    rawFrame <- as.data.frame(str_match(rawClean, regex), stringsAsFactors = FALSE)[,-1]
    if (header) {
      colnames(rawFrame) <- as.vector(rawFrame[1,])
      rawFrame <- rawFrame[-1,]
    }
    return(rawFrame)
  }
  
  # Parses passwords aliases files
  dbPass <- processFileRegex(pgPassFile, "^([^#][^:]*):([^:]*):([^:]*):([^:]*):(.*)$")
  dbConf <- processFileRegex(dbConfFile, "^([^#][^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$")
  
  # Merges the files, also accounts for potential "*" in db
  dbMerged <- merge(dbPass, dbConf, by=c("hostname", "username", "port"))
  dbMerged <- dbMerged[(dbMerged$database.x == "*") || (dbMerged$database.x == dbMerged$database.y), !(names(dbMerged) == "database.x")]
  names(dbMerged)[names(dbMerged) == "database.y"] <- "database"
  
  dbInfo <- subset(dbMerged, dbMerged$alias == dbAlias)
  
  # Creates driver + connection in the Global environment 
  drv <<- dbDriver("PostgreSQL")
  con <<- dbConnect(drv,
                   host=dbInfo$hostname,
                   dbname=dbInfo$database,
                   user=dbInfo$username,
                   port=as.integer(dbInfo$port),
                   password=dbInfo$password
  )
  
  if (!silent) {
    cat("The following variables have been created your Global Environment:",
        "\n\tdrv: PostgreSQL Driver\n\tcon: PostgreSQL connection to ", dbAlias, 
        "\nDon't forget to release them at the end of your script, like this:",
        "\ndbDisconnect(con) # Closes the connection",
        "\ndbUnloadDriver(drv) # Frees up the resources used by the driver")
  }
}