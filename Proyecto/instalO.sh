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
COMMAND_LOGS_NAME="commandsLogs.log"
COMMAND_LOG="$COMANDOS_LOGS_DIR/$COMMAND_LOGS_NAME"
INSTALL_LOG=$DIRCONF"/instalo.log"

### FUNCIONES ###############################################################################################

#Devuelve 0 en caso de que la version de Perl sea mayor o igual a la 5, 1 en caso contrario.
function checkPerlVersion {
  if [ $(perl -V:version | grep "='[5-9]" -c) -eq 1 ] || [ $(perl -V:version | grep "='..\." -c) -eq 1] ;
  then
     return 0
  else
     return 1
  fi
}

function exitScript
{
  echo 'Terminando la ejecucion...'
  exit $1
}

function createMainDirectory {
  echo "Creando directorio principal $GRUPO..."
  mkdir -p "$GRUPO"
}

function selectOption
{
  if  [[ "$1" == '-r' ]]
  then
    showMessage "Reparar instalacion..."
    repairInstallation
    exitScript
  elif [[ "$1" == '-i' ]]; then
    installWithDefaultDirectories
    exitScript
  fi
}

function installWithDefaultDirectories
{
  rm -rf "$GRUPO"
  checkPerlVersionWithMessage
  createMainDirectoriesAndData
  createSubDirectories
  showDirectoriesConfiguration
  moveDataToDirectoriesAndSaveConfiguration
}

function repairInstallation
{
  checkPerlVersionWithMessage

  if [ ! -d "$GRUPO" ] ; then
    mkdir -p "$GRUPO"
  fi

  if [ ! -d "$GRUPO/$DIRCONF" ] ; then
    mkdir -p "$GRUPO/$DIRCONF"
  fi

  if [ ! -d "$GRUPO/$EJECUTABLES_DIR" ] ; then
    mkdir -p "$GRUPO/$EJECUTABLES_DIR"
  fi

  if [ ! -d "$GRUPO/$MAESTROS_TABLAS_DIR" ] ; then
    mkdir -p "$GRUPO/$MAESTROS_TABLAS_DIR"
  fi

  if [ ! -d "$GRUPO/$ARRIBOS_DIR" ] ; then
    mkdir -p "$GRUPO/$ARRIBOS_DIR"
  fi

  if [ ! -d "$GRUPO/$NOVEDADES_ACEPTADAS_DIR" ] ; then
    mkdir -p "$GRUPO/$NOVEDADES_ACEPTADAS_DIR"
  fi

  if [ ! -d "$GRUPO/$RECHAZADOS_DIR" ] ; then
    mkdir -p "$GRUPO/$RECHAZADOS_DIR"
  fi

  if [ ! -d "$GRUPO/$PROCESADOS_DIR" ] ; then
    mkdir -p "$GRUPO/$PROCESADOS_DIR"
  fi

  if [ ! -d "$GRUPO/$REPORTES_DIR" ] ; then
    mkdir -p "$GRUPO/$REPORTES_DIR"
  fi
  #Se hace dos veces lo mismo?
  if [ ! -d "$GRUPO/$COMANDOS_LOGS_DIR" ] ; then
    mkdir -p "$GRUPO/$COMANDOS_LOGS_DIR"
  fi

  if [ ! -d "$GRUPO/$COMANDOS_LOGS_DIR" ] ; then
    mkdir -p "$GRUPO/$COMANDOS_LOGS_DIR"
  fi

  if [ ! -f "$GRUPO/$COMMAND_LOG" ] ; then
    touch "$GRUPO/$COMMAND_LOGS_NAME"
  fi

  if [ ! -f "$GRUPO/$INSTALL_LOG" ] ; then
    touch "$GRUPO/$INSTALL_LOG"
  fi

  showMessage "Reinstalando directorios y archivos..." 'INF'
  showDirectoriesConfiguration
  moveDataToDirectoriesAndSaveConfiguration
}

function readSubDirectories {

  directoresArray=("$DIRCONF")

  continueToNextStep=1

  #Ejecutables
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de ejecutables (Si presiona ENTER se creara el Default: $EJECUTABLES_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de ejecutables que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de ejecutables que desea utilizar es: $NEW_DIR"

    checkIfDirectoryNameIsInUse "${directoresArray[@]}" "$NEW_DIR"
    continueToNextStep=$?
    if [ $continueToNextStep -eq 0 ]
    then
      if [ ! "$NEW_DIR" == "" ]
      then
        EJECUTABLES_DIR="$NEW_DIR"
        saveToInstallLog 'INF' "El directorio de ejecutables elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR")

  continueToNextStep=1

  #Maestros
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de archivos maestros y tablas (Si presiona ENTER se creara el Default: $MAESTROS_TABLAS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de archivos maestros y tablas que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de archivos maestros y tablas que desea utilizar es: $NEW_DIR"


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
        saveToInstallLog 'INF' "El directorio de archivos maestros y tablas elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR")

  continueToNextStep=1

  #Arribos
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de los arribos (Si presiona ENTER se creara el Default: $ARRIBOS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de arribos que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de arribos que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de arribos elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR")

  continueToNextStep=1

  #Novedades
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de novedades aceptadas (Si presiona ENTER se creara el Default: $NOVEDADES_ACEPTADAS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de novedades que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de novedades que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de novedades elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR")

  continueToNextStep=1

  #Rechazados
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de rechazados (Si presiona ENTER se creara el Default: $RECHAZADOS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de rechazados que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de rechazados que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de rechazados elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR")

  continueToNextStep=1

  #Procesados
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de procesados (Si presiona ENTER se creara el Default: $PROCESADOS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de procesados que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de procesados que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de procesados elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR" "$PROCESADOS_DIR")

  continueToNextStep=1

  #Reportes
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de reportes (Si presiona ENTER se creara el Default: $REPORTES_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de reportes que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de reportes que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de reportes elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  directoresArray=("$DIRCONF" "$EJECUTABLES_DIR" "$MAESTROS_TABLAS_DIR" "$ARRIBOS_DIR" "$NOVEDADES_ACEPTADAS_DIR" "$RECHAZADOS_DIR" "$PROCESADOS_DIR" "$REPORTES_DIR")

  continueToNextStep=1

  #Command Logs
  while [ ! $continueToNextStep -eq 0 ]
  do
    showMessage "Por favor introduzca el directorio de command logs (Si presiona ENTER se creara el Default: $COMANDOS_LOGS_DIR)" 'INF'
    read -r NEW_DIR
    saveToInstallLog 'INF' "El directorio de command logs que desea utilizar es: $NEW_DIR"
    saveToCommandLog 'INF' "El directorio de command que desea utilizar es: $NEW_DIR"

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
        saveToInstallLog 'INF' "El directorio de command logs elegido y disponible es: $NEW_DIR"
      fi
    fi
  done

  saveToInstallLog 'INF' "Los nombres de los directorios seleccionados son: ${directoresArray[@]}"
}

function createSubDirectories {
  showMessage 'Creando sub directorios...' 'INF'
  showMessage "Creando sub directorio $GRUPO/$EJECUTABLES_DIR..." 'INF'
  mkdir -p "$GRUPO/$EJECUTABLES_DIR"
  showMessage "Creando sub directorio $GRUPO/$MAESTROS_TABLAS_DIR..." 'INF'
  mkdir -p "$GRUPO/$MAESTROS_TABLAS_DIR"
  showMessage "Creando sub directorio $GRUPO/$ARRIBOS_DIR..." 'INF'
  mkdir -p "$GRUPO/$ARRIBOS_DIR"
  showMessage "Creando sub directorio $GRUPO/$NOVEDADES_ACEPTADAS_DIR..." 'INF'
  mkdir -p "$GRUPO/$NOVEDADES_ACEPTADAS_DIR"
  showMessage "Creando sub directorio $GRUPO/$RECHAZADOS_DIR..." 'INF'
  mkdir -p "$GRUPO/$RECHAZADOS_DIR"
  showMessage "Creando sub directorio $GRUPO/$PROCESADOS_DIR..." 'INF'
  mkdir -p "$GRUPO/$PROCESADOS_DIR"
  showMessage "Creando sub directorio $GRUPO/$REPORTES_DIR..." 'INF'
  mkdir -p "$GRUPO/$REPORTES_DIR"
  showMessage "Creando sub directorio $GRUPO/$COMANDOS_LOGS_DIR..." 'INF'
  mkdir -p "$GRUPO/$COMANDOS_LOGS_DIR"
}

function showDirectoriesConfiguration {
  showMessage "TP SO7508 Primer Cuatrimestre 2018. Tema O Copyright © Grupo 03" 'INF'
  showMessage "Librería del Sistema: $GRUPO/$DIRCONF" 'INF'
  showMessage "Ejecutables en: $GRUPO/$EJECUTABLES_DIR" 'INF'
  showMessage "Directorio para los archivos maestros: $GRUPO/$MAESTROS_TABLAS_DIR" 'INF'
  showMessage "Directorio para el arribo de archivos externos: $GRUPO/$ARRIBOS_DIR" 'INF'
  showMessage "Directorio para los archivos aceptados: $GRUPO/$NOVEDADES_ACEPTADAS_DIR" 'INF'
  showMessage "Directorio para los archivos rechazados: $GRUPO/$RECHAZADOS_DIR" 'INF'
  showMessage "Directorio para Archivos procesados: $GRUPO/$PROCESADOS_DIR" 'INF'
  showMessage "Directorio para los reportes: $GRUPO/$REPORTES_DIR" 'INF'
  showMessage "Logs de auditoria del Sistema: $GRUPO/$COMANDOS_LOGS_DIR" 'INF'
}

function checkIfDirectoryNameIsInUse {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++))
    do
      if [ "${!i}" == "${value}" ]
        then
          showMessage "El directorio $value ya se encuentra en uso." 'ALE'
          return 1
      fi
    done
  return 0 # Directory available.
}

function moveMastersData
{
  showMessage 'Instalando Tablas de Configuración...' 'INF'
  for file in "$PWD/install_files/master_files/*"
    do
      showMessage "Moviendo archivos maestros y tablas..." 'INF'
      cp $file "$GRUPO/$MAESTROS_TABLAS_DIR/"
    done
}

function moveExecData
{
  for f in "*.pl"
  do
    mv $f "$GRUPO/$EJECUTABLES_DIR/"
  done

  for f in "*.sh"
  do
    mv $f "$GRUPO/$EJECUTABLES_DIR/"
  done
}

function createConfigurationFile
{
  #Formato: Identificador_del_directorio-Valor-Usuario-Fecha
  #Se chequea si existe el archivo de config y se crea si no existe.
  if [ ! -f "$GRUPO/$INSTALL_CONF" ]
   then
    #Creo archivo de log de la instalación
    showMessage 'Creando archivo .conf de la instalación...' 'INF'
    touch "$GRUPO/$INSTALL_CONF"
  fi
}

function createCommandsLogFile
{ #MTodo lo que se muestra al usuario por pantalla y sus respuestas.
  #Formato: Identificador_del_directorio-Valor-Usuario-Fecha
  #Se chequea si existe el archivo de log y se crea si no existe.
  if [ ! -f "$GRUPO/$COMANDOS_LOGS_DIR" ]
   then
    #Creo archivo de log de la instalación
    showMessage 'Creando archivo .log de la instalación...' 'INF'
    touch "$GRUPO/$COMANDOS_LOGS_DIR"
  fi
}

function createInstallerLogFile
{
  #Formato: Identificador_del_directorio-Valor-Usuario-Fecha
  #Se chequea si existe el archivo de config y se crea si no existe.
  if [ ! -f "$GRUPO/$INSTALL_LOG" ]
   then
    #Creo archivo de log de la instalación
    echo "Creando archivo .conf de la instalación..."
    touch "$GRUPO/$INSTALL_LOG"
  fi
}

function saveDirectoryConfiguration
{
  showMessage 'Creating directories...' 'INF'
  echo "GRUPO=$GRUPO=$(whoami)=$(date)" > $GRUPO/$INSTALL_CONF
  echo "INSTALL_CONF=$GRUPO/$INSTALL_CONF=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "EJECUTABLES_DIR=$GRUPO/$EJECUTABLES_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "MAESTROS_TABLAS_DIR=$GRUPO/$MAESTROS_TABLAS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "ARRIBOS_DIR=$GRUPO/$ARRIBOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "NOVEDADES_ACEPTADAS_DIR=$GRUPO/$NOVEDADES_ACEPTADAS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "RECHAZADOS_DIR=$GRUPO/$RECHAZADOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "PROCESADOS_DIR=$GRUPO/$PROCESADOS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "REPORTES_DIR=$GRUPO/$REPORTES_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
  echo "COMANDOS_LOGS_DIR=$GRUPO/$COMANDOS_LOGS_DIR=$(whoami)=$(date)" >> $GRUPO/$INSTALL_CONF
}

function showMessage
{
  echo "$1"
  saveToCommandLog "$1" "$2"
  saveToInstallLog "$1" "$2"
  return 0
}

function saveToInstallLog
{
  ./saveToLog.sh "$GRUPO/$INSTALL_LOG" "$2" "$1" #W5: when, who, where, what and why.
  return 0
}

function saveToCommandLog
{
  ./saveToLog.sh "$GRUPO/$COMMAND_LOGS_NAME" "$2" "$1" #W5: when, who, where, what and why.
  return 0
}

function checkInstallation
{
# DESCRIPCION: Si el archivo de configuración no existe, el sistema no está instalado, y si existe el sistema está instalado.
# POST CONDICIONES:
# 0: El sistema esta instalado.
# 1: El sistema no esta instalado.
  if [ -f "$GRUPO/$INSTALL_CONF" ]
  then
    echo 'El sistema ya esta instalado.'
    return 0
  else
    echo 'El sistema no esta instalado.'
    return 1
  fi
}

function moveDataToDirectoriesAndSaveConfiguration
{
  saveDirectoryConfiguration
  saveToInstallLog 'INF' "Moviendo .log de comandos a: $GRUPO/$COMANDOS_LOGS_DIR"
  showMessage "Instalando Ejecutables..." 'INF'
  showMessage "Moviendo archivos ejecutables..." 'INF'
  moveMastersData
  showMessage 'Estado de la instalación: LISTA' 'INF'
  moveExecData
  mv "$GRUPO/$COMMAND_LOGS_NAME" "$GRUPO/$COMANDOS_LOGS_DIR"
}

function createMainDirectoriesAndData
{
  createMainDirectory
  mkdir -p "$GRUPO/$DIRCONF"
  createInstallerLogFile
  showMessage 'Creando archivo de comandos .log...' 'INF'
  touch "$GRUPO/$COMMAND_LOGS_NAME"
  showMessage 'Creando directorio para configuracion...' 'INF'
  createConfigurationFile #Se crea el archivo de configuracion de directorios.
}

function checkPerlVersionWithMessage
{
  checkPerlVersion
  if [ $? -eq 0 ] ; then
    echo 'La version de Perl es compatible (mayor o igual a la 5.0)'
  else
    echo 'La version de Perl no es compatible (menor a la 5.0)'
    exitScript
  fi
}
##############################################################################################################
### MAIN PROGRAM #############################################################################################

selectOption "$1"

checkInstallation
if [ $? -eq 0 ]
then
    exitScript
fi

checkPerlVersionWithMessage
createMainDirectoriesAndData

userConfirmation='No'
while [ ! "$userConfirmation" == 'Si' ]
do
  readSubDirectories
  showDirectoriesConfiguration
  echo ''
  showMessage '¿Confirma la instalación? (Si-No): ' 'INF'
  read -r userConfirmation
  saveToInstallLog 'INF' "La confirmacion de la instalacion fue: $userConfirmation"
  saveToCommandLog 'INF' "La re-confirmacion de la instalacion fue: $userConfirmation"

  if [ "$userConfirmation" == 'Si' ] ; then
    createSubDirectories
  elif [[ $userConfirmation == 'No' ]]; then
    showMessage 'Ingrese los directorios nuevamente.' 'INF'
  else
    while [ ! "$userConfirmation" == 'Si' ] && [ ! "$userConfirmation" == 'No' ]
    do
      showMessage 'Ingrese una opcion correcta (Si-No).' 'ALE'
      read -r userConfirmation
      saveToInstallLog 'INF' "La re-confirmacion de la instalacion fue: $userConfirmation"
      saveToCommandLog 'INF' "La re-confirmacion de la instalacion fue: $userConfirmation"
    done
  fi
done

moveDataToDirectoriesAndSaveConfiguration

##############################################################################################################
