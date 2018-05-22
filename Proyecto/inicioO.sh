#!/bin/sh
### HIPOTESIS ###############################################################################################
#- Dado que el proceso de incioO.sh se ejecuta una sola vez, no se concidera necesario adoptar un postura restrictiva respecto del tamaño de su archivo de log.
#- Previa a la instancia en que se verifica la correcta instalacion de los directorios, no es posible determinar cual es el direccion del archivo inicio.log, por lo que no se realizaran operaciones de logueo.
### VARIABLES
#	-El demonio no permitira ser lanzado si antes no fue inicializado el ambiente.
# -El demonio no permitira ser lanzado si fue lanzado previamente.

###############################################################################################
#Suponemos que esta sera la direccion del archivo de configuracion dejado por instalO.sh
CONFIGURACION="./dirconf/instalo.conf"
#Una vez que veamos que todos los directorios fueron creados, usaremos estas variables para el logueo de eventos
LOGINICIO=""
DEMONIO=""

### FUNCIONES ###############################################################################################


function mostrarLoguearEvento() {
	#Parameters:
	#$1: Ruta del archivo
	#$2: Tipo de mensaje
	#$3: Mensaje

	# Formato: W5. when, who, where, what and why.
	#1. Fecha Formato a Elección. Es la fecha y hora en el momento de grabación del registro.
	#2. Usuario Es el login del usuario que graba el registro
	#3. Origen  Es el nombre del Comando, función o rutina que produce el evento que se registra en el log
	#4. Tipo de Error Indica que tipo de error es: Informativo (INF), Alerta (ALE) Error (ERR)
	#5. Mensaje Mensaje de log propiamente dicho

	when="$(date +"%Y%m%d %T")"
	who=$(whoami)
	where="$(echo "${1##*/}" | cut -d "." -f 1)"
	what=$2
	why=$3
	new_line="$when-$who-$where-$what-$why"
	echo "$why"
	echo "$new_line" >> "$1"
}

function verificarArchivoConfiguracion() {
	if [ ! -f $CONFIGURACION ]; then
		echo "El archivo $CONFIGURACION no existe."
		return 0
	fi
	if [ ! -r $CONFIGURACION ]; then
		echo "No se tiene permiso de lectura para el archivo $CONFIGURACION."
		chmod +r $CONFIGURACION
	fi
	if [ ! -r $CONFIGURACION ]; then
		echo "No se pudo modificar los permisos para el archivo $CONFIGURACION."
		return 0
	fi
	return 1
}

### VERIFICAR QUE LA INSTALACION ESTE COMPLETA ###############################################################################################

function verificarDirectorio() {
  DIRECTORIO=$1
  if [ ! -d "$DIRECTORIO" ]; then
    echo "La carpeta $DIRECTORIO no se encuentra"
    echo "Asegurese de haber ejecutado el proceso: instalO"
    echo "Para reparar la instalacion, ejecutar el comando: instalO -r"
		echo ""
		return 0
  fi
  return 1
}

function verificarDirectorios() {
  EJECUTABLES=$(grep "EJECUTABLES_DIR" $CONFIGURACION | cut -d "=" -f 2)
  MAESTROS=$(grep "MAESTROS_TABLAS_DIR" $CONFIGURACION | cut -d "=" -f 2)
  ACEPTADOS=$(grep "NOVEDADES_ACEPTADAS_DIR" $CONFIGURACION | cut -d "=" -f 2)
  RECHAZADOS=$(grep "RECHAZADOS_DIR" $CONFIGURACION | cut -d "=" -f 2)
  ARRIBOS=$(grep "ARRIBOS_DIR" $CONFIGURACION | cut -d "=" -f 2)
  REPORTES=$(grep "REPORTES_DIR" $CONFIGURACION | cut -d "=" -f 2)
  LOGS=$(grep "COMANDOS_LOGS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	PROCESADOS=$(grep "PROCESADOS_DIR" $CONFIGURACION | cut -d "=" -f 2)

	verificarDirectorio $PROCESADOS
	if [ $? -eq 0 ]; then
		return 0
	fi
  verificarDirectorio $EJECUTABLES
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $MAESTROS
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $ACEPTADOS
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $RECHAZADOS
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $ARRIBOS
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $REPORTES
  if [ $? -eq 0 ]; then
    return 0
  fi
  verificarDirectorio $LOGS
  if [ $? -eq 0 ]; then
    return 0
  fi
	#Inicializamos variables importantes
	LOGINICIO="$LOGS/inicio.log"
	DEMONIO="$EJECUTABLES"
	mostrarLoguearEvento "$LOGINICIO" "INF" "Se pudo verificar la correcta instalacion de los directorios principales."
  return 1
}

function verirficarPermisoLectura() {
  ARCHIVO=$1
  if [ -r $ARCHIVO ]; then
		mostrarLoguearEvento "$LOGINICIO" "INF" "Permisos para lectura del archivo $ARCHIVO estaban OK."
	fi
  if [ ! -r $ARCHIVO ]; then
		mostrarLoguearEvento "$LOGINICIO" "ALE" "Permisos para lectura del archivo $ARCHIVO seran modificados."
		chmod +r $ARCHIVO
		if [ ! -r $ARCHIVO ]; then
			mostrarLoguearEvento "$LOGINICIO" "ERR" "Permisos para lectura del archivo $ARCHIVO fueron negados."
			return 0
		fi
  fi
  return 1
}

function verirficarPermisoEjecucion() {
	ARCHIVO=$1
  if [ -x $ARCHIVO ]; then
		mostrarLoguearEvento "$LOGINICIO" "INF" "Permisos para escritura del archivo $ARCHIVO estaban OK."
		return 1
	fi
  if [ ! -x $ARCHIVO ]; then
		mostrarLoguearEvento "$LOGINICIO" "ALE" "Permisos para escritura del archivo $ARCHIVO seran modificados."
		chmod +x $ARCHIVO
		if [ ! -x $ARCHIVO ]; then
			mostrarLoguearEvento "$LOGINICIO" "ERR" "Permisos para escritura del archivo $ARCHIVO fueron negados."
			return 0
		fi
  fi
  return 1
}

function verificarCorregirPermisos() {
	GRUPO=$(grep "GRUPO" $CONFIGURACION | cut -d "=" -f 2)
	EJECUTABLES=$(grep "EJECUTABLES_DIR" $CONFIGURACION | cut -d "=" -f 2)
	MAESTROS=$(grep "MAESTROS_TABLAS_DIR" $CONFIGURACION | cut -d "=" -f 2)

	cd "$MAESTROS"
  for MAESTRO in $(ls -CU) ; do
    verirficarPermisoLectura $MAESTRO
    if [ $? -eq 0 ]; then
      return 0
    fi
  done
	cd "$EJECUTABLES"
  for EJECUTABLE in $(ls -CU) ; do
    verirficarPermisoEjecucion $EJECUTABLE
    if [ $? -eq 0 ]; then
      return 0
    fi
  done
	cd "$GRUPO"

	mostrarLoguearEvento "$LOGINICIO" "INF" "Los permisos fueron seteados correctamente."
  return 1
}

function verificarInstalacionCompleta() {
	verificarArchivoConfiguracion
	if [ $? -ne 1 ]; then
		return $?
	fi
	verificarDirectorios
	if [ $? -ne 1 ]; then
		return $?
	fi
	verificarCorregirPermisos
	if [ $? -ne 1 ]; then
		return $?
	fi
	mostrarLoguearEvento "$LOGINICIO" "INF" "Se pudo verificar la correcta instalacion de la aplicacion."
	return 1
}

### SETEAR VARIABLES DE AMBIENTE ###############################################################################################

function setearVariablesDeAmbiente() {
	export GRUPO=$(grep "GRUPO" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable GRUPO con valor $GRUPO fue seteada."

	export INSTALL_CONF=$(grep "INSTALL_CONF" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable INSTALL_CONF con valor $INSTALL_CONF fue seteada."

  export DIR_EXECUTE=$(grep "EJECUTABLES_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_EXECUTE con valor $DIR_EXECUTE fue seteada."

  export DIR_MASTER=$(grep "MAESTROS_TABLAS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_MASTER con valor $DIR_MASTER fue seteada."

  export DIR_ACCEPTED=$(grep "NOVEDADES_ACEPTADAS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_ACCEPTED con valor $DIR_ACCEPTED fue seteada."

  export DIR_REJECTED=$(grep "RECHAZADOS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_REJECTED con valor $DIR_REJECTED fue seteada."

  export DIR_ARRIBOS=$(grep "ARRIBOS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_ARRIBOS con valor $DIR_ARRIBOS fue seteada."

  export DIR_REPORTS=$(grep "REPORTES_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_REPORTS con valor $DIR_REPORTS fue seteada."

  export DIR_LOGS=$(grep "COMANDOS_LOGS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_LOGS con valor $DIR_LOGS fue seteada."

	export DIR_INDICTED=$(grep "PROCESADOS_DIR" $CONFIGURACION | cut -d "=" -f 2)
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable DIR_INDICTED con valor $DIR_INDICTED fue seteada."

	#Deberia verificar si estos archivos existen?
	export PATH_MASTER="$GRUPO/install_files/master_files/p-s.mae"
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable PATH_MASTER con valor $PATH_MASTER fue seteada."

	export PATH_T1="$GRUPO/install_files/master_files/T1.tab"
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable PATH_T1 con valor $PATH_T1 fue seteada."

	export PATH_T2="$GRUPO""install_files/master_files/T2.tab"
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable PATH_T2 con valor $PATH_T2 fue seteada."

	export VARIABLES_SETEADAS=1
	mostrarLoguearEvento "$LOGINICIO" "INF" "La variable VARIABLES_SETEADAS con valor $VARIABLES_SETEADAS fue seteada."

	mostrarLoguearEvento "$LOGINICIO" "INF" "Las variables de ambiente fueron definidas"
	return 1
}
### ARRANCAR DEMONIO ###############################################################################################
function arrancarDemonio() {

	CANTIDAD_DEMONIOS=$(ps -e | pgrep -c "detectO.")
	if [ $CANTIDAD_DEMONIOS -eq 1 ]; then
		DEMONIO_PID=$(pgrep "detectO." | head -n 1)
		mostrarLoguearEvento "$LOGINICIO" "ALE" "El demonio detectO ya fue lanzado y es identificado con el PID: $DEMONIO_PID"
		echo "Para detener el proceso detectO.sh, se debe hacer uso del comando stopO.sh o . ./stopO.sh"
		return 0
	fi
	cd $DEMONIO
	./detectO.sh &
	CANTIDAD_DEMONIOS=$(ps -e | pgrep -c "detectO.")
	if [ $CANTIDAD_DEMONIOS -eq 0 ]; then
		mostrarLoguearEvento "$LOGINICIO" "ERR" "El demonio detectO NO fue lanzado."
		return 0
	fi
	DEMONIO_PID=$!
	mostrarLoguearEvento "$LOGINICIO" "INF" "El demonio detectO fue lanzado y se identifica con el PID: $DEMONIO_PID."
	echo "Para detener el proceso detectO.sh, se debe hacer uso del comando stopO.sh o . ./stopO.sh"
	return 1
}

### PROGRAMA PRINCIPAL ###############################################################################################

#DEBERIA SER EL LOG DE CUALQUIER EVENTO EN ESTA FUNCION?
function main() {
	echo "arrancamos"
	verificarInstalacionCompleta
	if [ $? -ne 1 ]; then
		return 0
	fi
	echo "verificamos instalacion"
	setearVariablesDeAmbiente
	if [ $? -ne 1 ]; then
		return 0
	fi
	echo "seteamos variables"
	arrancarDemonio
	if [ $? -ne 1 ]; then
		return 0
	fi

	mostrarLoguearEvento "$LOGINICIO" "INF" "El proceso inicioO ha finalizado."
	return 1
}

cd ..
main
