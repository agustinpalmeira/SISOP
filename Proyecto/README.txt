README.txt

1.1. Indicaciones de instalacion
	1. Ubicarse en el directorio en el cual se desea realizar la instalacion.
	2. Copiar grupo03.tar.gz en ese directorio.
	3. Extraer los archivos del tar.gz en ese mismo directorio. Se puede descomprimir por consolta de la siguiente manera: tar -zxvf grupo03.tar.gz

1.2. Instrucciones de instalacion
	1. Debera tener instalada una version de Perl igual o superior a la 5.0.
	1. Abrir la terminal/consola.
	2. Dirigirse al directorio de trabajo.
	3. Ejecutar el archivo instalO.sh.
	4. Debera seguir todos los pasos mostrados por pantalla para realizar la instalacion.
	5. Se verificara si hubo una instalacion previa y si se encuentra completa se terminara la ejecucion.
	6. Si se realiza la instalacion exitosamente, se crearan los directorios ingresados por el usuario dentro de la ruta /grupo03 y tambien la ruta /grupo03/dirconf en la cual se encontraran los logs de instalacion y el archivo de configuracion de directorios.

1.3. Opciones
	1. Opcion -r: Se verifica que esten todos los directorios necesarios junto con los archivos, de no ser asi, se vuelven a crear los faltantes.
	2. Opcion -i: Se elimina el directorio /grupo06 y todo lo que haya adentro y se hace una reinstalacion completa.

2.1. Indicaciones para inicializar el ambiente
	1. Dirijase a la carpeta ./grupo03/EJECUTABLES
	2. Abrir una terminal en el directorio y ejecute la siguiente instruccion.
		. ./inicioO.sh
	2. El proceso iniciara e indicara, tras realizar validaciones acerca del directorio de instalacion y el seteo de variables de ambiente, el arranque de un proceso demonio con el nombre de detectO.sh
	3. Para matar el proceso se utiliza el siguiente comando . ./stopO.sh
