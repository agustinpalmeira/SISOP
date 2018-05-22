# #!/bin/bash
# sleep 5
# mv aceptados/* procesados

# FUNCTIONS

function environment_validate
{
   if [[ -z ${DIR_ARRIBOS} ]]
   then
    echo 1
    return 0
   fi
   if [[ -z ${DIR_LOGS} ]]
   then
    echo 2
    return 0
   fi
   if [[ -z ${PATH_T1} ]]
   then
    echo 3
    return 0
   fi
   if [[ -z ${PATH_T1} ]]
   then
    echo 4
    return 0
   fi
   if [[ -z ${DIR_ACCEPTED} ]]
   then
    echo 5
    return 0
   fi
      if [[ -z ${DIR_REJECTED} ]]
   then
    echo 6
    return 0
   fi
    if [[ -z ${DIR_INDICTED} ]]
   then
    echo 7
    return 0
   fi
   echo 0
}

LOG_FILE="$DIR_LOGS/"interpretO.log
function log
{
    declare local EVENT=$1
    echo "$(date +"%Y-%m-%e %H:%M:%S"): $EVENT" >> "$LOG_FILE"
}

function move_file
{
    declare local FILE_NAME=$1
    declare local ORIGIN_DIR=$2
    declare local DESTINATION_DIR=$3
    declare local OCURRENCIES=$(ls -1 "$DESTINATION_DIR" | grep -c "$FILE_NAME\.*[1-9]*" )
    if [ $OCURRENCIES -eq 0 ]
    then
        mv "$ORIGIN_DIR/$FILE_NAME" "$DESTINATION_DIR/$FILE_NAME"
    else
        mv "$ORIGIN_DIR/$FILE_NAME" "$DESTINATION_DIR/$FILE_NAME.$OCURRENCIES"        
    fi
}

function validate_proccessed
{
    declare local FILE_NAME="$1"
    declare local TODAY_DIR="$DIR_INDICTED/$(date +"%Y%M%e")/"
    if [ -d "$TODAY_DIR" ]
    then
        if [ $(grep -c "$FILE_NAME" "$TODAY_DIR") -gt 0 ]
        then
            # nombre de archivo duplicado
            echo 1
            return 0
        fi
    fi
    echo 0
}

function determinate_separators
{
    declare local FILE_NAME="$1"
    declare local COUNTRY_SYSTEM_CODE=$(echo $"$FILE_NAME" | sed 's/^\(.*-.*\)-.*-.*$/\1/')
    declare local ROW=$(cat $PATH_T1 | grep "$COUNTRY_SYSTEM_CODE")
    FIELD_SEPARATOR=$(echo "$ROW" | sed "s/$COUNTRY_SYSTEM_CODE-\(.\)-./\1/")
    DECIMAL_SEPARATOR=$(echo "$ROW" | sed "s/$COUNTRY_SYSTEM_CODE-.-\(.\)/\1/")
}

function determinate_fields
{
    return 0
}

# MAIN

ENVIRONMENT_VALIDATE=$(environment_validate)
FIELD_SEPARATOR=""
DECIMAL_SEPARATOR=""
if [ 0 -eq "$ENVIRONMENT_VALIDATE" ]
then
    for FILE in $(ls -1 "$DIR_ACCEPTED")
    do
        if [ $(validate_proccessed "$FILE") -eq 0 ]
        then
            determinate_separators "$FILE"
            echo "$FIELD_SEPARATOR"
            echo "$DECIMAL_SEPARATOR"

        else
            log "archivo $FILE_NAME rechazado - nombre duplicado"
            move_file "$FILE" "$DIR_ACCEPTED" "$DIR_REJECTED"
        fi
    done
else
    echo "$ENVIRONMENT_VALIDATE"
fi