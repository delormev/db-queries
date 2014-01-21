#!/bin/bash
    
# Set this to your default input/output files
DEFAULT_INPUT="path/to/your/default/input.sql"
DEFAULT_OUTPUT="path/to/your/default/result.csv"
DB_INFO="path/to/your/db.info" # alias:hostname:port:database:user, 1 per line

function getDatabasesInfo(){
    if [ -z $SOURCE ]; then
        echo "getDatabaseInfo: ERROR - no source provided."
        exit 1
    fi
    IFS=$'\r\n' DB_LIST=($(cat $DB_INFO))
    for i in "${DB_LIST[@]}"; do
        if [ "${i:0:1}" == "#" ]; then
            continue
        fi
        IFS=':' read -a fields <<< "$i"
        if [ "${fields[0]}" == $SOURCE ]; then
            HOST="${fields[1]}"
            PORT="${fields[2]}"
            DATABASE="${fields[3]}"
            USER="${fields[4]}"
            return
        fi
    done
    echo "getDatabasesInfo: ERROR - source $SOURCE not found in $DB_INFO."
    exit 1
}

function queries-usage(){
    echo "Usage:"
    echo "queries -s DB_SOUCE [options]"
    echo "options:"
    echo "-h                show brief help"
    echo "-q                query mode"
    echo "-f INPUT_SQL      specify input SQL to use. Default: $DEFAULT_INPUT"
    echo "-o OUTPUT_CSV     specify output CSV. Default: $DEFAULT_OUTPUT"
    exit 0
}

# Variable Initialisation
QUERY=0
SOURCE=
INPUT=
OUTPUT=

HOST=
PORT=
DATABASE=
USER=

# Parsing Variables
if [[ $# -lt 2 ]]; then
    echo "ERROR - not enough arugemnts."
    queries-usage
    exit 1
fi

while getopts ":hs:qf:o:" opt; do
    case "$opt" in
        h)
            queries-usage
            exit 0
            ;;
        s)
            SOURCE=${OPTARG}
            getDatabasesInfo
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
        o)
            OUTPUT=${OPTARG}
            ;;
        \?)
            echo "WARNING - nvalid option: -$OPTARG."
            ;;
    esac
done

# Check database information
if [[ -z $HOST ]] || [[ -z $PORT ]] || [[ -z $DATABASE ]] || [[ -z $USER ]]; then
    echo "ERROR - Something went wrong when looking up your database information. Check $DB_INFO."
    exit 1
fi

# Check if querying from file or interactive queries
if [ $QUERY -eq 0 ]; then
    echo "psql -h $HOST -p $PORT -d $DATABASE --user=$USER"
    psql -h $HOST -p $PORT -d $DATABASE --user=$USER
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
    echo "psql -h $HOST -p $PORT -d $DATABASE --user=$USER -A -F ',' -f $INPUT -o $OUTPUT"
    psql -h $HOST -p $PORT -d $DATABASE --user=$USER -A -F ',' -f $INPUT -o $OUTPUT
fi

exit 0
