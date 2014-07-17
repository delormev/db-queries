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
    echo "ERROR - config file $DIR/queries.config doesn't exist"
    exit 1
fi

function queries-all-usage(){
    echo "Usage:"
    echo "queries-all -s DB_SOUCE -f INPUT_DIR[-o OUTPUT_FILE]"
    echo "options:"
    echo "-h                        show brief help"
    echo "-f INPUT_DIR              specify input directory to use."
    echo "-o OUTPUT_FILE            specify output file. Default: STDOUT"
    exit 0
}

INPUT=
OUTPUT=

if [[ $# -lt 2 ]]; then
    echo "ERROR - not enough arugemnts."
    queries-all-usage
    exit 1
fi

while getopts ":hs:f:o:" opt; do
    case "$opt" in
        h)
            queries-all-usage
            exit 0
            ;;
        s)
            SOURCE=${OPTARG}
            ;;
        f)
            if [ -d "${OPTARG}" ]; then
                INPUT="${OPTARG}"
            else
                echo "ERROR - input directory ${OPTARG} doesn't exist"
                exit 1
            fi
            ;;
        o)
            OUTPUT=${OPTARG}
            ;;
        \?)
            echo "WARNING - invalid option: -$OPTARG."
            ;;
    esac
done

if [[ -z $SOURCE ]]; then
    echo "ERROR - Missing DB_SOURCE."
    queries-all-usage
    exit 1
fi

if [[ -z $INPUT ]]; then
    echo "ERROR - Missing INPUT_DIR."
    queries-all-usage
    exit 1
fi

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for FILE in `ls $INPUT/*.sql | sort`; do
    read -p "Execute "$FILE" against $SOURCE? " yn
    case $yn in
        [Yy]* ) queries -s $SOURCE -q -f $FILE;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
IFS=$SAVEIFS