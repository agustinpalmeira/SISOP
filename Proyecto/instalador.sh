#!/bin/sh

### VARIABLES ###############################################################################################

NUMEROGRUPO=$PWD"/grupo3"


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

##############################################################################################################

if  [[ $1 = "-r" ]]; then
    echo "Reparar instalacion"
fi

checkPerlVersion

if [ $? -eq 0 ] ; then
	echo 'La version de Perl es compatible (mayor o igual a la 5.0)'
else
	echo 'La version de Perl no es compatible (menor a la 5.0)'
fi