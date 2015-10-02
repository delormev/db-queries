#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
if [ -f "$DIR/queries.conf" ]; then
    source "$DIR/queries.conf" 
else
    echo "ERROR - config file $DIR/queries.conf doesn't exist"
    exit 1
fi

function getDatabaseInfo(){
    if [ -z $SOURCE ]; then
        echo "getDatabaseInfo: ERROR - no source provided."
        exit 1
    fi
    IFS=$'\r\n' DB_LIST=($(cat $DB_INFO))
    for LINE in "${DB_LIST[@]}"; do
        if [[ $LINE =~ ^([^#][^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == $SOURCE ]]; then
                DBTYPE="${BASH_REMATCH[2]}"
                HOST="${BASH_REMATCH[3]}"
                PORT="${BASH_REMATCH[4]}"
                DATABASE="${BASH_REMATCH[5]}"
                USER="${BASH_REMATCH[6]}"
                case "$DBTYPE" in 
                    psql) 
                        ;;
                    mysql) 
                        ;;
                    *) 
                        echo "getDatabasesInfo: ERROR - database type '$DBTYPE' not recognised. Supported values: psql, mysql."
                        exit 1
                        ;;
                esac
                return
            fi
        fi
    done
    echo "getDatabasesInfo: ERROR - source $SOURCE not found in $DB_INFO."
    exit 1
}

function checkDatabaseInfo(){
    if [[ -z $HOST ]] || [[ -z $PORT ]] || [[ -z $DATABASE ]] || [[ -z $USER ]] || [[ -z $DBTYPE ]]; then
        echo "ERROR - Something went wrong when looking up your database information. Check $DB_INFO."
        exit 1
    fi
}

function queriesUsage(){
    echo "Usage:"
    echo "queries -s DB_SOUCE [options]"
    echo "options:"
    echo "-h                show brief help"
    echo "-q                query mode"
    echo "-f INPUT_SQL      specify input SQL to use. Default: $DEFAULT_INPUT"
    echo "-o OUTPUT_CSV     specify output CSV. Default: STDOUT"
    exit 0
}


function connectPsql(){
    # Check if querying from file or interactive queries
    if [ $QUERY -eq 0 ]; then
        echo "psql -h $HOST -p $PORT -d $DATABASE --user=$USER $TUPLE_ONLY"
        psql -h $HOST -p $PORT -d $DATABASE --user=$USER $TUPLE_ONLY
    else
        # Use default input if no INPUT provided
        if [[ -z $INPUT ]]; then
            echo "Using default input SQL: $DEFAULT_INPUT"
            INPUT=$DEFAULT_INPUT
        fi
        
        # Use default output if no OUTPUT provided
        if [[ -z $OUTPUT ]]; then
            echo "Using default output: $DEFAULT_OUTPUT"
            OUTPUT=$DEFAULT_OUTPUT
        fi
        echo "psql -h $HOST -p $PORT -d $DATABASE --user=$USER -A -F ',' -f $INPUT -o $OUTPUT $TUPLE_ONLY -P footer"
        psql -h $HOST -p $PORT -d $DATABASE --user=$USER -A -F ',' -f $INPUT -o $OUTPUT $TUPLE_ONLY -P footer
    fi
    return
}

function connectMysql(){
    echo "psql -h $HOST -P $PORT -d $DATABASE -u $USER $DATABASE"
    psql -h $HOST -P $PORT -d $DATABASE -u $USER $DATABASE
    return
}

# Variable Initialisation
QUERY=0
SOURCE=
INPUT=
OUTPUT=

DBTYPE=
HOST=
PORT=
DATABASE=
USER=
TUPLE_ONLY=

# Parsing Variables
if [[ $# -lt 2 ]]; then
    echo "ERROR - not enough arugemnts."
    queriesUsage
    exit 1
fi

while getopts ":hs:qtf:o:" opt; do
    case "$opt" in
        h)
            queriesUsage
            exit 0
            ;;
        s)
            SOURCE=${OPTARG}
            getDatabaseInfo
            checkDatabaseInfo
            ;;
        q)
            QUERY=1
            ;;
        f)
            if [ -f ${OPTARG} ]; then
                INPUT=${OPTARG}
            else
                echo "ERROR - input file ${OPTARG} doesn't exist"
                exit 1
            fi
            ;;
        t)
            TUPLE_ONLY="-t"
            ;;
        o)
            OUTPUT=${OPTARG}
            ;;
        \?)
            echo "WARNING - invalid option: -$OPTARG."
            ;;
    esac
done

case $DBTYPE in
    psql)
        connectPsql
        ;;
    mysql)
        connectMysql
        ;;
esac

exit 0
