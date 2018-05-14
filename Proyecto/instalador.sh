#!/bin/sh

### VARIABLES ###############################################################################################

GRUPO=$PWD"/grupo3"
EJECUTABLES_DIR="EJECUTABLES"             # 1) El directorio de ejecutables
MAESTROS_TABLAS_DIR="MAESTROS"            # 2) El directorio de archivos maestros y tablas del sistema (aquí no van los datos de prueba!!)
ARRIBOS_DIR="ARRIBOS"                     # 3) El directorio de arribo de archivos externos, es decir, los archivos que remiten las subsidiarias
NOVEDADES_ACEPTADAS_DIR="NOVEDADES"       # 4) El directorio donde se depositan temporalmente las novedades aceptadas
RECHAZADOS_DIR="RECHAZADOS"               # 5) El directorio donde se depositan todos los archivos rechazados
PROCESADOS_DIR="PROCESADOS"               # 6) El directorio donde se depositan los archivos procesados 
REPORTES_DIR="REPORTES"                   # 7) El directorio donde se depositan los reportes
COMANDOS_LOGS_DIR="LOGS"                  # 8) El directorio donde se depositan los logs de los comandos 



### FUNCIONES ###############################################################################################

#Devuelve 0 en caso de que la version de Perl sea mayor o igual a la 5, 1 en caso contrario.
function checkPerlVersion
{
  if [ $(perl -V:version | grep "='[5-9]" -c) -eq 1 ] || [ $(perl -V:version | grep "='..\." -c) -eq 1] ;
  then
     echo 'La version de Perl es valida.'
     return 0
  else
     echo 'La version de Perl no es valida.' 
     return 1
  fi
}

function createMainDirectory
{
  echo $GRUPO
  mkdir -p "$GRUPO"
}

function selectOption
{
  if  [[ $1 = "-r" ]]; then
    echo "Reparar instalacion"
  fi
}

function createSubDirectory
{
  echo $2
  DIRECTORY=$1
  read -r NEW_DIR
  if [ ! "$NEW_DIR" == "" ]
  then
    DIRECTORY="$NEW_DIR"
    break;
  fi
  mkdir -p "$DIRECTORY"
}

function createSubDirectories 
{
  createSubDirectory "$EJECUTABLES_DIR" "Por favor introduzca el directorio de ejecutables (Si presiona ENTER se creara el Default: $EJECUTABLES_DIR)"
  createSubDirectory "$MAESTROS_TABLAS_DIR" "Por favor introduzca el directorio de archivos maestros y tablas (Si presiona ENTER se creara el Default: $MAESTROS_TABLAS_DIR)"
  createSubDirectory "$ARRIBOS_DIR" "Por favor introduzca el directorio de los arribos (Si presiona ENTER se creara el Default: $ARRIBOS_DIR)"  
  createSubDirectory "NOVEDADES_ACEPTADAS_DIR" "Por favor introduzca el directorio de novedades aceptadas (Si presiona ENTER se creara el Default: $NOVEDADES_ACEPTADAS_DIR)"
  createSubDirectory "$RECHAZADOS_DIR" "Por favor introduzca el directorio de rechazados (Si presiona ENTER se creara el Default: $RECHAZADOS_DIR)"
  createSubDirectory "$PROCESADOS_DIR" "Por favor introduzca el directorio de procesados (Si presiona ENTER se creara el Default: $PROCESADOS_DIR)"
  createSubDirectory "$REPORTES_DIR" "Por favor introduzca el directorio de reportes (Si presiona ENTER se creara el Default: $REPORTES_DIR)"
  createSubDirectory "$COMANDOS_LOGS_DIR" "Por favor introduzca el directorio de command logs (Si presiona ENTER se creara el Default: $COMANDOS_LOGS_DIR)"
}

##############################################################################################################
### MAIN PROGRAM #############################################################################################

checkPerlVersion
  if [ $? -eq 0 ] ; then
    echo 'La version de Perl es compatible (mayor o igual a la 5.0)'
  else
    echo 'La version de Perl no es compatible (menor a la 5.0)'
  fi
selectOption
createMainDirectory
createSubDirectories

##############################################################################################################