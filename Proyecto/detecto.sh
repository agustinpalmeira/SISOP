#!/bin/bash
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
   if [[ -z ${MASTER_CONTRY_SYSTEM} ]]
   then
    echo 3
    return 0
   fi
   if [[ -z ${DIR_ACCEPTED} ]]
   then
    echo 4
    return 0
   fi
      if [[ -z ${DIR_REJECTED} ]]
   then
    echo 5
    return 0
   fi
    if [[ -z ${DIR_INDICTED} ]]
   then
    echo 6
    return 0
   fi
   echo 0
}

MAX_SIZE=30720
LOG_FILE="$DIR_LOGS/"detecto.log
function log
{
    declare local EVENT=$1
    if [ -f "$LOG_FILE" ] 
    then
        declare local LOG_SIZE=$(stat --printf="%s" "$LOG_FILE")
        if [ $LOG_SIZE -gt $MAX_SIZE ]
        then
            tail -n 50 $LOG_FILE > "$LOG_FILE.tmp"
            rm "$LOG_FILE"
            mv "$LOG_FILE.tmp" "$LOG_FILE"
            echo "log truncado" >> "$LOG_FILE"
        fi
    fi
    echo "$(date +"%Y-%m-%e %H:%M:%S") - cycle number $COUNTER: $EVENT" >> "$LOG_FILE"
}


function file_name_validate
{
    declare local FILE_NAME=$1
    if [ $(echo "$FILE_NAME" | grep "^[A-Z]-[1-9]-201[6-8]-[0-1][0-9]$") ]
    then
        declare local COUNTRY_SYSTEM=$(echo "$FILE_NAME" | sed 's/^\(.*-.*\)-.*-.*$/\1/')
        declare local YEAR=$(echo "$FILE_NAME" | sed 's/^.*-.*-\(.*\)-.*$/\1/')
        declare local MONTH=$(echo "$FILE_NAME" | sed 's/^.*-.*-.*-\(.*\)$/\1/')
        if [ $(grep -c "$COUNTRY_SYSTEM" "$MASTER_CONTRY_SYSTEM") -lt 1 ]
        then
            # convinacion Pais-CodigoSistema no valido
            MESSAGE="novedad rechazada: $FILE_NAME - convinacion pais y codigo sistema invalido"
            log "$MESSAGE"
            echo 2
            return 0
        fi
        # no hace falta validar el año, ya que solo se admite 2016/2017/2018
        # (esto es porque la fecha no puede superar la actual)
        if [[ "$MONTH" -lt 1 ]] 
        then
            # numero de mes invalido
            MESSAGE="novedad rechazada: $FILE_NAME - numero de mes invalido"
            log "$MESSAGE"
            echo 3
            return 0
        fi
        if [ $(date +"%Y") -lt "$YEAR" ] || ([ $(date +"%Y") -eq "$YEAR" ] && [ "$MONTH" -gt $(date +"%m") ])
        then
            # fecha futura
            MESSAGE="novedad rechazada: $FILE_NAME - periodo adelantado"
            log "$MESSAGE"
            echo 4
            return 0
        fi
    else
        # no cumple con la estructura basica del nombre
        MESSAGE="novedad rechazada: $FILE_NAME - formato nombre invalido"
        log "$MESSAGE"
        echo 1
        return 0
    fi
    echo 0
}

function file_content_validate
{
    declare local FILE_NAME=$1
    if [ ! -f "$DIR_ARRIBOS/$FILE_NAME" ]
    then
        # archivo no regular
        MESSAGE="novedad rechazada: $FILE_NAME - archivo no regular" 
        log "$MESSAGE"
        echo 1
        return 0
    fi
    # TODO: no toma validacion, revisar
    if [ -s "$DIR_ARRIBOS/$FILE_NAME" ]
    then
        # archivo vacio
        MESSAGE="novedad rechazada: $FILE_NAME - archivo vacio" 
        log "$MESSAGE"
        echo 2
        return 0
    fi
    echo 0
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

function start_interpreter
{
    if [ $PID_INTERPRETER ]
    then
        if [ $(ps -e | grep -c "$PID_INTERPRETER") -gt 0 ]
        then
            return 0
        fi
    fi
    if [ $(ls -1 $DIR_ACCEPTED/ | wc -l) -eq 0 ]
    then
        return 0
    fi
    ./interpretO.sh &
    PID_INTERPRETER=$!
    log "interpreter is runing - PID: $PID_INTERPRETER"
}

# -----------------------------------------------------------------------
# MAIN
ENVIRONMENT_VALIDATE=$(environment_validate)
if [ 0 -eq "$ENVIRONMENT_VALIDATE" ]
then
    COUNTER=0
    while [ true ]
    do
        let COUNTER=COUNTER+1
        if [ "$(ls $DIR_ARRIBOS | wc -l)" -gt 0 ]
        then
            for FILE in $(ls -1 "$DIR_ARRIBOS") 
            do
                if [ $(file_name_validate "$FILE") -eq 0 ]
                then
                    if [ $(file_content_validate "$FILE") -eq 0 ]
                    then
                        move_file "$FILE" "$DIR_ARRIBOS" "$DIR_ACCEPTED"
                        log "$FILE aceptado"
                    else
                        move_file "$FILE" "$DIR_ARRIBOS" "$DIR_REJECTED"
                    fi
                else
                        move_file "$FILE" "$DIR_ARRIBOS" "$DIR_REJECTED"
                fi
            done
        fi
        start_interpreter
        sleep 1
    done
else
    echo "$ENVIRONMENT_VALIDATE"
fi
