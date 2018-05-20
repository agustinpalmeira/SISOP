#!/bin/sh

### VARIABLES ###############################################################################################

GRUPO=$PWD"/grupo3"
DIRCONF="dirconf"
EJECUTABLES_DIR="EJECUTABLES"             # 1) El directorio de ejecutables
MAESTROS_TABLAS_DIR="MAESTROS"            # 2) El directorio de archivos maestros y tablas del sistema (aquí no van los datos de prueba!!)
ARRIBOS_DIR="ARRIBOS"                     # 3) El directorio de arribo de archivos externos, es decir, los archivos que remiten las subsidiarias
NOVEDADES_ACEPTADAS_DIR="NOVEDADES"       # 4) El directorio donde se depositan temporalmente las novedades aceptadas
RECHAZADOS_DIR="RECHAZADOS"               # 5) El directorio donde se depositan todos los archivos rechazados
PROCESADOS_DIR="PROCESADOS"               # 6) El directorio donde se depositan los archivos procesados 
REPORTES_DIR="REPORTES"                   # 7) El directorio donde se depositan los reportes
COMANDOS_LOGS_DIR="LOGS"                  # 8) El directorio donde se depositan los logs de los comandos 
INSTALL_CONF=$DIRCONF"/instalo.conf"

### FUNCIONES ###############################################################################################

#Devuelve 0 en caso de que la version de Perl sea mayor o igual a la 5, 1 en caso contrario.
function checkPerlVersion {
  if [ $(perl -V:version | grep "='[5-9]" -c) -eq 1 ] || [ $(perl -V:version | grep "='..\." -c) -eq 1] ;
  then
     echo 'La version de Perl es valida.'
     return 0
  else
     echo 'La version de Perl no es valida.' 
     return 1
  fi
}

function exitScript 
{
  exit
}

function createMainDirectory {
  echo $GRUPO
  mkdir -p "$GRUPO"
}

function selectOption
{
  if  [[ $1 = "-r" ]]; then
    echo "Reparar instalacion"
  fi
}

function readSubDirectories {

  directoresArray=("$DIRCONF")

  continueToNextStep=1

  #Ejecutables
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de ejecutables (Si presiona ENTER se creara el Default: $EJECUTABLES_DIR)"
    read -r NEW_DIR

    checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    continueToNextStep=$?
    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        EJECUTABLES_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR")

  continueToNextStep=1

  #Maestros
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de archivos maestros y tablas (Si presiona ENTER se creara el Default: $MAESTROS_TABLAS_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$MAESTROS_TABLAS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        MAESTROS_TABLAS_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR")

  continueToNextStep=1

  #Arribos
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de los arribos (Si presiona ENTER se creara el Default: $ARRIBOS_DIR)" 
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$ARRIBOS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?


    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        ARRIBOS_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR")

  continueToNextStep=1

  #Novedades
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de novedades aceptadas (Si presiona ENTER se creara el Default: $NOVEDADES_ACEPTADAS_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NOVEDADES_ACEPTADAS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        NOVEDADES_ACEPTADAS_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR")

  continueToNextStep=1

  #Rechazados
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de rechazados (Si presiona ENTER se creara el Default: $RECHAZADOS_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$RECHAZADOS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        RECHAZADOS_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR")

  continueToNextStep=1

  #Procesados
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de procesados (Si presiona ENTER se creara el Default: $PROCESADOS_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$PROCESADOS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        PROCESADOS_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR" "$PROCESADOS_DIR")

  continueToNextStep=1

  #Reportes
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de reportes (Si presiona ENTER se creara el Default: $REPORTES_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$REPORTES_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        REPORTES_DIR="$NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR" "$PROCESADOS_DIR" "$REPORTES_DIR")

  continueToNextStep=1

  #Command Logs
  while [ ! $continueToNextStep -eq 0 ]
  do
    echo "Por favor introduzca el directorio de command logs (Si presiona ENTER se creara el Default: $COMANDOS_LOGS_DIR)"
    read -r NEW_DIR

    if [ "$NEW_DIR" == "" ]
    then
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$COMANDOS_LOGS_DIR"
    else
      checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    fi

    continueToNextStep=$?

    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        COMANDOS_LOGS_DIR="$NEW_DIR"
      fi
    fi
  done

  #directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR" "$PROCESADOS_DIR" "$REPORTES_DIR" "$COMANDOS_LOGS_DIR")

  echo ${directoresArray[@]}
}

function createSubDirectories {
  mkdir -p "$GRUPO/$EJECUTABLES_DIR"
  mkdir -p "$GRUPO/$MAESTROS_TABLAS_DIR"
  mkdir -p "$GRUPO/$ARRIBOS_DIR"
  mkdir -p "$GRUPO/$NOVEDADES_ACEPTADAS_DIR"
  mkdir -p "$GRUPO/$RECHAZADOS_DIR"
  mkdir -p "$GRUPO/$PROCESADOS_DIR"
  mkdir -p "$GRUPO/$REPORTES_DIR"
  mkdir -p "$GRUPO/$COMANDOS_LOGS_DIR"
  echo "Estado de la instalación: LISTA" 
}

function showDirectoriesConfiguration {
  echo "TP SO7508 Primer Cuatrimestre 2018. Tema O Copyright © Grupo 03"
  echo "Librería del Sistema: $GRUPO/$DIRCONF"
  echo "Ejecutables en: $GRUPO/$EJECUTABLES_DIR"
  echo "Directorio para los archivos maestros: $GRUPO/$MAESTROS_TABLAS_DIR"
  echo "Directorio para el arribo de archivos externos: $GRUPO/$ARRIBOS_DIR"
  echo "Directorio para los archivos aceptados: $GRUPO/$NOVEDADES_ACEPTADAS_DIR"
  echo "Directorio para los archivos rechazados: $GRUPO/$RECHAZADOS_DIR"
  echo "Directorio para Archivos procesados: $GRUPO/$PROCESADOS_DIR"
  echo "Directorio para los reportes: $GRUPO/$REPORTES_DIR"
  echo "Logs de auditoria del Sistema: $GRUPO/$COMANDOS_LOGS_DIR"
}

function checkIfDirectoryNameIsInUse {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++))
    do
      if [ "${!i}" == "${value}" ]
        then
          echo "El directorio $value ya se encuentra en uso."
          return 1
      fi
    done
  return 0 # Directory available.
}

function moveMastersData 
{
  echo "Instalando Tablas de Configuración..."
  for file in "$PWD/install_files/master_files/*.*"
  do
    mv $file "$GRUPO/$MAESTROS_TABLAS_DIR/"
  done
}

function moveExecData 
{
  echo "Instalando Ejecutables..."
for f in "*.sh"
  do
    mv $f "$GRUPO/$EJECUTABLES_DIR/"
  done
}

function createConfigurationFile 
{
  echo "$GRUPO/$DIRCONF"
  mkdir -p "$GRUPO/$DIRCONF"
  #Formato: Identificador_del_directorio-Valor-Usuario-Fecha
  #Se chequea si existe el archivo de log y se crea si no existe.
  if [ ! -f "$GRUPO/$INSTALL_CONF" ] 
   then 
    #Creo archivo de log de la instalación
    echo "Creando archivo .conf de la instalación..."
    touch "$GRUPO/$INSTALL_CONF"
  fi  
}

function saveDirectoryConfiguration
{
  echo "GRUPO=$GRUPO=$(whoami)=$(date)" > $GRUPO/$INSTALL_CONF
  echo "INSTALL_CONF=$GRUPO/$INSTALL_CONF=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "EJECUTABLES_DIR=$GRUPO/$EJECUTABLES_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "MAESTROS_TABLAS_DIR=$GRUPO/$MAESTROS_TABLAS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "ARRIBOS_DIR=$GRUPO/$ARRIBOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "NOVEDADES_ACEPTADAS_DIR=$GRUPO/$NOVEDADES_ACEPTADAS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "RECHAZADOS_DIR=$GRUPO/$RECHAZADOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "PROCESADOS_DIR=$GRUPO/$PROCESADOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "REPORTES_DIR=$GRUPO/$REPORTES_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "COMANDOS_LOGS_DIR=$GRUPO/COMANDOS_LOGS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
}

##############################################################################################################
### MAIN PROGRAM #############################################################################################
createConfigurationFile
checkPerlVersion
  
  if [ $? -eq 0 ] ; then
    echo 'La version de Perl es compatible (mayor o igual a la 5.0)'
  else
    echo 'La version de Perl no es compatible (menor a la 5.0)'
    exitScript
  fi

selectOption
createMainDirectory

userConfirmation='No'
while [ ! "$userConfirmation" == 'Si' ]
do
  readSubDirectories
  showDirectoriesConfiguration
  echo ''
  echo '¿Confirma la instalación? (Si-No): '
  read -r userConfirmation

  if [ "$userConfirmation" == 'Si' ] ; then
    createSubDirectories
  elif [[ $userConfirmation == 'No' ]]; then
    echo 'Ingrese los directorios nuevamente.'
  else 
    while [ ! "$userConfirmation" == 'Si' ] && [ ! "$userConfirmation" == 'No' ]
    do
      echo 'Ingrese una opcion correcta (Si-No).'
      read -r userConfirmation
    done
  fi
done

moveMastersData

moveExecData

saveDirectoryConfiguration

#if [ $userConfirmation == 'Si' ] ; then
#  createSubDirectories
#elif [ "$confirma" == "No" ] ; then



##############################################################################################################