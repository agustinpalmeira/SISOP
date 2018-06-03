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
    declare local ROW=$(cat $PATH_T1 | grep "$COUNTRY_SYSTEM_CODE")
    FIELD_SEPARATOR="$(echo "$ROW" | sed "s/$COUNTRY_SYSTEM_CODE-\(.\)-./\1/")"
    DECIMAL_SEPARATOR=$(echo "$ROW" | sed "s/$COUNTRY_SYSTEM_CODE-.-\(.\)/\1/")
}

function read_fields
{
    declare local CURRENT_DATE=$(date +"%e/%m/%Y")
    declare local FILE_NAME="$1"
    COUNTRY=$(echo $COUNTRY_SYSTEM_CODE | cut -d - -f 1)
    SYSTEM_CODE=$(echo $COUNTRY_SYSTEM_CODE | cut -d - -f 2)
    DONE=false
    until $DONE
    do
        MT_PRES=0
        MT_IMPAGO=0
        MT_INDE=0
        MT_INNODE=0
        MT_DEB=0
        read LINE || DONE=true
        for FIELD_DESCRIPTION in $(grep "^$COUNTRY_SYSTEM_CODE" "$PATH_T2" | sed "s/^$COUNTRY_SYSTEM_CODE-\(.*\)/\1/g")
        do
            FIELD_NAME=$(echo $FIELD_DESCRIPTION | cut -d - -f 1)
            FIELD_POS=$(echo $FIELD_DESCRIPTION | cut -d - -f 2)
            FIELD_TYPE=$(echo $FIELD_DESCRIPTION | cut -d - -f 3)
            ## Leer campo
            # TODO: revisar como usar ; desde una variable
            if [ ";" != $FIELD_SEPARATOR ]
            then
                FIELD=$(echo $LINE | cut -d ';' -f "$FIELD_POS")
            else
                FIELD=$(echo $LINE | cut -d "$FIELD_SEPARATOR" -f "$FIELD_POS")
            fi
            
            ## Obtener valor del campo segun el tipo,
            ## el valor obtenido se encuentra en VALUE
            ## las fechas siempre se expresan como dd-mm-yyyy
            if [ $(echo "$FIELD_TYPE" | grep -c "^[dmy]\{6\}[0-9]\{1,2\}") -eq 1 ]
            then
                # fechas
                if [ $(echo "$FIELD_TYPE" | grep -c "^ddmmyy") -eq 1 ]
                then
                    VALUE=$(echo "$FIELD" | sed "s/\([0-9]\{2\}\).*\([0-9]\{2\}\).*\([0-9]\{4\}\)/\1-\2-\3/g")
                else
                    VALUE=$(echo "$FIELD" | sed "s/\([0-9]\{4\}\).*\([0-9]\{2\}\).*\([0-9]\{2\}\)/\3-\2-\1/g")
                fi
            elif [ $(echo "$FIELD_TYPE" | grep -c "^\$[0-9]\+") -eq 1 ]
            then
                # alfanumericos
                MAX_LONG=$(echo "$FIELD_TYPE" | grep -o "[0-9]\+")
                VALUE=$(echo "$FIELD" | sed "s/\([a-zA-Z0-9]\{0,$MAX_LONG\}\)/\1/g")
            elif [ $(echo "$FIELD_TYPE" | grep -c "^commax[0-9]\+\.[0-9]\+") -eq 1 ]
            then
                VALUE=$(echo "$FIELD" | sed "s/^\([0-9]\+\)$DECIMAL_SEPARATOR\([0-9]\+\)/\1,\2/g")
            else
                # invalidos
                VALUE=""
            fi
            
            if [ "$VALUE" ]
            then
                if [ "$FIELD_NAME" == "CTB_FE" ]
                then
                    DAY=$(echo "$VALUE" | cut -d - -f 1)
                    MONTH=$(echo "$VALUE" | cut -d - -f 2)
                    YEAR=$(echo "$VALUE" | cut -d - -f 3)
                elif [ "$FIELD_NAME" == "CTB_ESTADO" ]
                then
                    ESTADO="$VALUE"
                elif [ "$FIELD_NAME" == "PRES_ID" ]
                then
                    PRES_ID="$VALUE"
                elif [ "$FIELD_NAME" == "MT_PRES" ]
                then
                    MT_PRES="$VALUE"
                elif [ "$FIELD_NAME" == "MT_IMPAGO" ]
                then
                    MT_IMPAGO="$VALUE"
                elif [ "$FIELD_NAME" == "MT_INDE" ]
                then
                    MT_INDE="$VALUE"
                elif [ "$FIELD_NAME" == "MT_INNODE" ]
                then
                    MT_INNODE="$VALUE"
                elif [ "$FIELD_NAME" == "MT_DEB" ]
                then
                    MT_DEB="$VALUE"
                elif [ "$FIELD_NAME" == "PRES_CLI_ID" ]
                then
                    PRES_CLI_ID="$VALUE"
                elif [ "$FIELD_NAME" == "PRES_CLI" ]
                then
                    PRES_CLI="$VALUE"
                fi
            fi
        done
        MT_REST=$(echo "$MT_PRES + $MT_IMPAGO + $MT_INDE + $MT_INNODE - $MT_DEB" | sed 's/,/./g' | bc)

        REGISTER="$SYSTEM_CODE;$YEAR;$MONTH;$DAY;$CTB_ESTADO;$PRES_ID;$MT_PRES;$MT_IMPAGO;$MT_INDE;$MT_INNODE;$MT_DEB;$MT_REST;$PRES_CLI_ID;$PRES_CLI;$CURRENT_DATE;$USER"
        echo "$REGISTER" >> "$DIR_INDICTED/PRESTAMOS.$COUNTRY"
    done < "$DIR_ACCEPTED/$FILE_NAME"
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
        COUNTRY_SYSTEM_CODE=$(echo $"$FILE" | sed 's/^\(.*-.*\)-.*-.*$/\1/')
        if [ $(validate_proccessed "$FILE") -eq 0 ]
        then
            determinate_separators "$FILE"
            read_fields "$FILE"
            move_file "$FILE" "$DIR_ACCEPTED" "$DIR_INDICTED"
            
            # echo "$FIELD_SEPARATOR"
            # echo "$DECIMAL_SEPARATOR"

        else
            log "archivo $FILE_NAME rechazado - nombre duplicado"
            move_file "$FILE" "$DIR_ACCEPTED" "$DIR_REJECTED"
        fi
    done
else
    echo "$ENVIRONMENT_VALIDATE"
fi