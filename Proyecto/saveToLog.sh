#!/bin/sh
##################################################################################################################################
#Parameters:
#$1: Ruta del archivo
#$2: Tipo de mensaje
#$3: Mensaje
##################################################################################################################################
# Formato: W5. when, who, where, what and why.
#1. Fecha Formato a Elección. Es la fecha y hora en el momento de grabación del registro.
#2. Usuario Es el login del usuario que graba el registro 
#3. Origen  Es el nombre del Comando, función o rutina que produce el evento que se registra en el log
#4. Tipo de Error Indica que tipo de error es: Informativo (INF), Alerta (ALE) Error (ERR)
#5. Mensaje Mensaje de log propiamente dicho
##################################################################################################################################
when="$(date +"%Y%m%d %T")"
who=$(whoami)
where="$(echo "${1##*/}" | cut -d "." -f 1)"
what=$2
why=$3
new_line="$when-$who-$where-$what-$why"
echo "$new_line" >> "$1"
##################################################################################################################################