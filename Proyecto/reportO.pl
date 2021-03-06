#!/usr/bin/perl
#
########################################################
#          SSOO Grupo 03 - 2018, 1° Cuatrimestre      #
#                       Comando reporO.pl              #
########################################################

# Levanto las variables de ambiente.
if ( !exists $ENV{DIR_MASTER} ) {
	print "El sistema no se halla inicializado.\n";
	exit;
}
if (&validoInstancias) {
	print "No puede ejecutarse mas de una instancia del InfPro a la vez\n";
	exit;
}
$BINDIR      = $ENV{DIR_EXECUTE} . "/";
$MAEDIR      = $ENV{DIR_MASTER} . "/";
$PROCDIR     = $ENV{DIR_INDICTED} . "/";
$REPODIR     = $ENV{DIR_REPORTS} . "/";

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
	localtime(time);
$year += 1900;

# Chequeo que no haya mas de una instancia corriendo
sub validoInstancias {
	@array = `ps -ef | grep ReporO`;
	$largo = 0;
	foreach (@array) {
		@tmp = split( " ", $_ );
		if ( ( $$ == $tmp[1] ) or ( $$ == $tmp[2] ) or ( $_ =~ /grep/ ) ) {
			next;
		}
		print $_. "\n";
		$largo++;
	}
	return ( $largo != 0 );
}

# Cargo archivos maestros para utilizarlos luego.
my %paises;
my %sistemas;
open( my $fh,"<:crlf", $MAEDIR . "p-s.mae" )
	|| die "No se pudo encontrar el archivo de maestros  de Paises y Sistemas";
while (my $row = <$fh>) {
	chomp $row;
	($cod_pais, $nom_pais, $cod_sis, $nom_sis)= split( "-", $row);
	my @regTemp = split( "-", $_ );
	if (! exists($paises{$cod_pais})) {
		$paises{$cod_pais} = $nom_pais;
	}
	$sistemas{$cod_pais}{$cod_sis}{nombre} = $nom_sis;
}
close($fh);
open( my $fh,"<:crlf", $MAEDIR . "T1.tab" )
	|| die "No se pudo encontrar el archivo de tabla de separadores";
while (my $row = <$fh>) {
	chomp $row;
	($cod_pais, $cod_sis, $sep_camp, $sep_dec)= split( "-", $row);
	if (! exists($sistemas{$cod_pais}{$cod_sis})) {
		$sistemas{$cod_pais}{$cod_sis}{nombre} = 'Sin Definir';
	}
	$sistemas{$cod_pais}{$cod_sis}{sep_camp} = $sep_camp;
	$sistemas{$cod_pais}{$cod_sis}{sep_dec} = $sep_dec;
}
close($fh);
%Campos = cargoTablaCampos();

main();

sub cargoTablaCampos{
	my %campos;
	open( my $fh,"<:crlf", $MAEDIR . "T2.tab" )
		|| die "No se pudo encontrar el archivo de tabla de campos";
	while (my $row = <$fh>) {
		chomp $row;
		($cod_pais, $cod_sis, $nom_camp, $ord_camp,$fmt_camp)= split( "-", $row);
		$campos{$cod_pais}{ $cod_sis}{$ord_camp}{ord_camp} = $nom_camp;
		$campos{$cod_pais}{ $cod_sis}{$ord_camp}{fmt_camp} = $fmt_camp;
	}
	close($fh);
	return %campos;
}

# Cargo el maestro de Prestamos a partir de los parametros indicados de la busqueda
sub cargoPPI{
	my %prestamosImpagos;
	open( my $fh,"<:crlf", $MAEDIR . "PPI.mae" )
		|| die "No se pudo encontrar el Archivo Maestro Contable de Préstamos Personales Impagos";
		print "prestamos:\n\n";
	while (my $row = <$fh>) {
		chomp $row;

		($pais_id,$sis_id,$ctb_anio,$ctb_mes,$ctb_dia,$ctb_estado,$pres_fe, $pres_id, $pres_ti, $mt_pres, $mt_impago, $mt_inde, $mt_innode, $mt_deb)  = split(";",$row);
		if ($pais ne $pais_id){
			next;
		}
		$ctb_mes =&convNum2Dig($ctb_mes);
		$ctb_dia =&convNum2Dig($ctb_dia);
		if ($sistema!=0 and $sistema!=$sis_id){
			next;
		}
		if ($periodos ne ""){
			my ($periodoInicial, $periodoFinal) = split("-",$periodos);

			$auxPeriodo = $ctb_anio.&convNum2Dig($ctb_mes);
			if ($auxPeriodo lt $periodoInicial or $auxPeriodo gt $periodoFinal){
				next;
			}
		}
		if ($sistemas{$pais_id}{$sis_id}{sep_dec} eq ','){
			$mt_pres  =~ s/\,/./g;
			$mt_impago  =~ s/\,/./g;
			$mt_inde  =~ s/\,/./g;
			$mt_innode  =~ s/\,/./g;
			$mt_deb  =~ s/\,/./g;
		}

		$prestamosImpagos{$pres_id}{sis_id} = $sis_id;
		$prestamosImpagos{$pres_id}{ctb_anio} = $ctb_anio;
		$prestamosImpagos{$pres_id}{ctb_mes} = $ctb_mes;
		$prestamosImpagos{$pres_id}{ctb_dia} = $ctb_dia;
		$prestamosImpagos{$pres_id}{ctb_estado} = $ctb_estado;
		$prestamosImpagos{$pres_id}{pres_fe} = $pres_fe;
		$prestamosImpagos{$pres_id}{pres_ti} = $pres_ti;
		$prestamosImpagos{$pres_id}{mt_pres} = sprintf("%.2f",$mt_pres);
		$prestamosImpagos{$pres_id}{mt_impago} = sprintf("%.2f",$mt_impago);
		$prestamosImpagos{$pres_id}{mt_inde} = sprintf("%.2f",$mt_inde);
		$prestamosImpagos{$pres_id}{mt_innode} = sprintf("%.2f",$mt_innode);
		$prestamosImpagos{$pres_id}{mt_deb} = sprintf("%.2f",$mt_deb);
		$prestamosImpagos{$pres_id}{mt_res} = sprintf("%.2f",$mt_pres+$mt_impago+$mt_inde+$mt_innode-$mt_deb);
	}
	close($fh);
	return %prestamosImpagos;
}
# Cargo archivos de prestamos para el pais indiccado en los parametros de la busqueda
sub cargoPrestamos{
	my %prestamos;
	open( my $fh,"<:crlf", $PROCDIR . "PRESTAMOS.".$pais )
		|| return %prestamosImpagos;

	while (my $row = <$fh>) {
		chomp $row;
		my @regTemp = split(";",$row);
		if ($sistema!=0 and $sistema != $regTemp[0]){
			next;
		}
		if ($periodos ne ""){
			my ($periodoInicial, $periodoFinal) = split("-",$periodos);
			$auxPeriodo = $regTemp[1].&convNum2Dig($regTemp[2]);
			if ($auxPeriodo lt $periodoInicial or $auxPeriodo gt $periodoFinal){
				next;
			}
		}

		$auxFecha = $regTemp[14];
		$auxFecha  =~ s|(\d{2})/(\d{2})/(\d{4})|$3$2$1|;

		$mt_pres = sprintf("%.2f",$regTemp[6]);
		$mt_impago = sprintf("%.2f",$regTemp[7]);
		$mt_inde = sprintf("%.2f",$regTemp[8]);
		$mt_innode = sprintf("%.2f",$regTemp[9]);
		$mt_deb = sprintf("%.2f",$regTemp[10]);
		$mt_res = sprintf("%.2f",$regTemp[11]);
		if ($sistemas{$pais_id}{$regTemp[0]}{sep_dec} eq ','){
			$mt_pres   =~ s/\,/./g;
			$mt_inde  =~ s/\,/./g;
			$mt_impago  =~ s/\,/./g;
			$mt_innode  =~ s/\,/./g;
			$mt_deb  =~ s/\,/./g;
			$mt_res   =~ s/\,/./g;
		}
		if (!exists($prestamos{$regTemp[5]})){
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{sis_id} = $regTemp[0];
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{ctb_dia} = $regTemp[3];
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{ctb_estado} = $regTemp[4];
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_pres} =$mt_pres;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_impago} = $mt_impago;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_inde} = $mt_inde;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_innode} = $mt_innode;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_deb} = $mt_deb;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_res} = $mt_res;
			$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{fecha_grabacion} = $auxFecha;
		} else {
			$fechaGrabada = &convNum2Dig($prestamos{$regTemp[5]}{ctb_dia}).$prestamos{$regTemp[5]}{fecha_grabacion};
			$fechaRegistro =  &convNum2Dig($regTemp[3]).$auxFecha;
			if ($fechaRegistro gt $fechaGrabada){
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{sis_id} = $regTemp[0];
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{ctb_dia} = $regTemp[3];
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{ctb_estado} = $regTemp[4];
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_pres} =$mt_pres;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_impago} = $mt_impago;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_inde} = $mt_inde;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_innode} = $mt_innode;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_deb} = $mt_deb;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{mt_res} = $mt_res;
				$prestamos{$regTemp[5]}{$regTemp[1]}{$regTemp[2]}{fecha_grabacion} = $auxFecha;
			}
		}
	}
	close($fh);
	return %prestamos;
}


sub procesoComparado{
	%ppi = &cargoPPI();
	%prestamos = &cargoPrestamos();
	foreach $pres_id(keys(%ppi)){
		if (!exists($prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}})){
			next;
		}
		my @regAux;

		$regAux[0] = $pais;
		$regAux[1] = $ppi{$pres_id}{sis_id};
		$regAux[2] = $pres_id;
		if (($ppi{$pres_id}{ctb_estado} eq 'SMOR' and  $prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}}{ctb_estado} ne "SMOR") or
			$ppi{$pres_id}{mt_res}< $prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}}{mt_res}){
			$regAux[3] = "RECAL";
		} else {
			$regAux[3] = "NO-RECAL";
		}
		$regAux[4] = $ppi{$pres_id}{ctb_estado};
		$regAux[5] = $prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}}{ctb_estado};
		$regAux[6] = $ppi{$pres_id}{mt_res};
		$regAux[7] = $prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}}{mt_res};
		$regAux[8] = sprintf("%.2f",$regAux[6] - $regAux[7]);
		$regAux[9] = $ppi{$pres_id}{ctb_anio};
		$regAux[10] = $ppi{$pres_id}{ctb_mes};
		$regAux[11] = $ppi{$pres_id}{ctb_dia};
		$regAux[12] = $prestamos{$pres_id}{$ppi{$pres_id}{ctb_anio}}{$ppi{$pres_id}{ctb_mes}}{ctb_dia};
		push(@comparado,join(";",@regAux));
	}
	return @comparado;
}

# Escribo a disco las comparaciones realizadas para los parametros indicados.
sub escriboComparado{
	my $nombreArchivo = "comparado.$pais";
	my $crearArchivo = 0;
	if ( !&existeComparado($nombreArchivo) ) {
		$crearArchivo = 1;
	}
	open( ARCH, ">>$REPODIR" . $nombreArchivo );
	#Si el archivo no existe, imprimo la fila de encabezados, sino se añade al archivo
	#existente
	if ($crearArchivo){

		my $filaEncabezado = "Código de País;Código de Sistema;"
			."Código Préstamo;RECOMENDACIÓN;"
			."Estado contable maestro;Estado contable préstamo;"
			."Monto Restante Maestro;"
			."Monto Restante préstamo;Diferencia en \$;"
			."Año contable;Mes contable;Día contable maestro;Día contable préstamo\n";
		print ARCH $filaEncabezado;
	}
	foreach $filaComparada ( @comparado ) {
		print ARCH $filaComparada."\n";
	}
	close(ARCH);
	print "El nombre de comparaciones generado es $REPODIR". $nombreArchivo . "\n";
}
# Muestro por pantalla las comparaciones realizadas para los parametros indicados.
sub muestroComparado{

	my $filaEncabezado = "Código de País;Código de Sistema;"
		."Código Préstamo;RECOMENDACIÓN;"
		."Estado contable maestro;Estado contable préstamo;"
		."Monto Restante Maestro;"
		."Monto Restante préstamo;Diferencia en \$;"
		."Año contable;Mes contable;Día contable maestro;Día contable préstamo\n";
	print  $filaEncabezado;

	foreach $filaComparada ( @comparado ) {
		print $filaComparada."\n";
	}
}


# A partir de un archivo procesado de comparaciones, obtengo las divergencias para
# el porcentaje indicado.
# retorna: lista de filas de resultados
sub procesoDivergenciaPorcentaje{

	open( my $fh,"<:crlf", $REPODIR . "comparado.".$pais )
		|| return @divergencia;
	while (my $row = <$fh>) {
		chomp $row;
		@regTemp = split(";", $row);
		my @regAux;
		if ($regTemp[6]!=0){
			$divPorc =  sprintf ("%.2f",abs(($regTemp[8]/$regTemp[6])*100))	;
			if ($divPorc>$porc){
				next;
			}
		} else {
			$divPorc = 0;
		}
		$divAbs  = abs($regTemp[8]);
		$regAux[0] = $regTemp[0];
		$regAux[1] = $regTemp[1];
		$regAux[2] = $regTemp[2];
		$regAux[3] = $regTemp[3];
		$regAux[4] = $regTemp[6];
		$regAux[5] = $regTemp[7];
		$regAux[7] = $divPorc;
		$regAux[6] = $divAbs;
		$auxFila = join(";",@regAux);
		push(@divergencia,$auxFila);
	}
	return @divergencia;
}
# A partir de un archivo procesado de comparaciones, obtengo las divergencias para
# el monto indicado.
# retorna: lista de filas de resultados
sub procesoDivergenciaMonto{

	open( my $fh,"<:crlf", $REPODIR . "comparado.".$pais )
		|| return @divergencia;
	while (my $row = <$fh>) {
		chomp $row;
		@regTemp = split(";", $row);
		my @regAux;
		$divAbs  = sprintf ("%.2f",abs($regTemp[8]));
		if ($divAbs>$monto){
			next;
		}
		if ($regTemp[6]!=0){
			$divPorc =  sprintf ("%.2f",abs(($regTemp[8]/$regTemp[6])*100))	;
		} else {
			$divPorc = 0;
		}
		$regAux[0] = $regTemp[0];
		$regAux[1] = $regTemp[1];
		$regAux[2] = $regTemp[2];
		$regAux[3] = $regTemp[3];
		$regAux[4] = $regTemp[6];
		$regAux[5] = $regTemp[7];
		$regAux[7] = $divPorc;
		$regAux[6] = $divAbs;
		$auxFila = join(";",@regAux);
		push(@divergencia,$auxFila);
	}
	return @divergencia;
}
# Obtengo el nombre que utilizare para generar el archivo de informe de las divergencias.
sub proxNomResu {
	my ( @array, $temp1, $largo );
	my ($ultimo) = 0;    # No tengo estadisticas, entonces sera la primera.
	@array = `ls -1 $REPODIR | sort -r | grep resultado_ | sed 's/_0*/_/'`;
	$largo = @array;
	if ( $largo != 0 ) {
		$temp1 = $array[0];
		$ultimo = substr $temp1, 10;
	}
	$ultimo++;
	$retval = "resultado_" . &convNumInf($ultimo);
}
# Convierte el numero del ultimo informe al formato XXX para escribir el archivo.
#Recibe: numero
sub convNumInf {
	my ($temp);
	my ($val) = @_;
	if ( $val < 10 ) {
		$temp = sprintf "00%1.0f", $val;
	}
	elsif ( $val < 100 ) {
		$temp = sprintf "0%2.0f", $val;
	}
	else {
		$temp = sprintf "%3.0f", $val;
	}
	$retval = $temp;
}
sub convNum2Dig{
	my ($temp);
	my ($val) = @_;
	if ( $val < 10 ) {
		$temp = sprintf "0%1.0f", $val;
	}
	else {
		$temp = sprintf "%2.0f", $val;
	}
	$retval = $temp;
}
# Escribo a disco el listado de divergencias dentro de los parametros indicados
sub escriboDivergencia{
	my $nombreArchivo = &proxNomResu();
	open( ARCH, ">$REPODIR" . $nombreArchivo );
	my $filaEncabezado = "Código de País;Código de Sistema;"
		."Código Préstamo;RECOMENDACIÓN;"
		."Monto Restante Maestro;"
		."Monto Restante préstamo;Diferencia en \$;Diferencia en %;\n";
	print ARCH $filaEncabezado;
	foreach $filaDiv ( @divergencia ) {
		print ARCH $filaDiv."\n";
	}
	close(ARCH);
	print "El nombre del archivo generado es $REPODIR". $nombreArchivo . "\n";
}
# Muestro por pantalla el listado de divergencias dentro de los parametros indicados
sub muestroDivergencia{
	my $filaEncabezado = "Código de País;Código de Sistema;"
		."Código Préstamo;RECOMENDACIÓN;"
		."Monto Restante Maestro;"
		."Monto Restante préstamo;Diferencia en \$;Diferencia en %;\n";
	print  $filaEncabezado;

	foreach $filaDiv ( @divergencia ) {
		print $filaDiv."\n";
	}
}


# Imprime la ayuda de la función.
sub mostrarAyuda() {
	system(clear);
	print " Descripción:\n";
	print
		" Parte del sistema CONTROLO. Nos permite realizar consultas sobre los\n";
	print
		" préstamos personales impagos. Los resultados se emitiran por salida stdout\n";
	print " , y podran  ser generados a archivo.\n";
	print "\n";
	print " Argumentos:\n";
	print " -a\n";
	print "    muestra la ayuda.\n";
	print " -g\n";
	print "    indica que la consulta se escribira a archivo\n";
	print " -c\n";
	print "    realizará la comparación y se mostrara por pantalla\n";
	print " -divPor\n";
	print
		"    se mostrara todos aquellos en los que el monto restante del maestro y el monto restante del país es mayor al X %\n";
	print
		"    Puede ir en conjunto con el parámetro -c para ingresar claves y filtros para la búsqueda.\n";
	print " -divMon\n";
	print
		"    se mostrara todos aquellos en los que el monto restante del maestro y el monto restante del país es mayor al X \$\n";
	print
		"    Puede ir en conjunto con el parámetro -c para ingresar claves y filtros para la búsqueda.\n";
	print " \n";
	print " El parámetro -divPor no puede ir junto con -divMon.\n";
	print "\n";
}
# Proceso los argumentos ingresados al sistema
# Presupone que existe una lista con las claves, y las variables $i, $e, $c
# No devuelve ningun valor
sub procesoArgumentos() {
	@argumentos = split( " ", $_[0] );
	$largo = @argumentos;
	for ( my $cont = 0 ; $cont < $largo ; $cont++ ) {
		if ( $argumentos[$cont] eq "-a" ) {
			$a =1;
			next;
		}
		if ( $argumentos[$cont] eq "-g" ) {
			$g = 1;
			next;
		}
		if ( $argumentos[$cont] eq "-c" ) {
			$c = 1;
			next;
		}

		if ( $argumentos[$cont] eq "-divPor" ) {
			$divPor = 1;
			next;
		}

		if ( $argumentos[$cont] eq "-divMon" ) {
			$divMon = 1;
			next;
		}

	}
}
# Valido que el rango de periodos ingresado sea correcto
# Si es un rango, valido las dos fechas
sub validoPeriodos{
	my (@periodos) = split('-',$_[0]);
	if ($_[0] eq ''){
		return 0;
	}
	if (@periodos != 2){
		print "Rango de periodos inválido\n";
		return 1;
	}
	else {
		if (&validoPeriodo($periodos[0])){
			print "Valor inferior del rango de periodos inválido\n";
			return 1;
		}
		if (&validoPeriodo($periodos[1])){
			print "Valor superior del rango de periodos inválido\n";
			return 1;
		}
		if ($periodos[0] gt $periodos[1]){
			print "El valor inferior del rango de periodos no puede ser mayor al valor inferior.\n";
			return 1;
		}
	}
	return 0;
}

# Chequeo si existe el archivo de comparaciones para el país seleccionado
sub existeComparado{
	if (-e $REPODIR."comparado.".$pais) {
		return 1;
	} else {
		return 0;
	}
}
# Valido si un periodo ingresado esta en el formato valido( yyyymm)
sub validoPeriodo{
	my ($periodo) = @_;
	if ($periodo !~ /^\d{6}$/){
		return 1;
	}
	$anio = substr($periodo,0,4);
	if ($anio < 1900 or $anio>$year){
		return 1;
	}
	$mes = substr($periodo,4);
	if ($mes>12 or $mes<1){
		return 1;
	}
	return 0;
}
# Ingreso el filtro para los paises
sub filtroPais {
	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un codigo de país valido
	while (1) {
		$cadena = "";
		print "Ingrese el código de país por el que desea filtrar(q para volver al menú): ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( exists $paises{$cadena} ) || ( $cadena eq "q" ) ) {
			last;
		}
		else {
			print "El código de país no existe, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}
# Ingreso el filtro para los sistemas
sub filtroSistema {
	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un codigo de sistema valido
	while (1) {
		$cadena = "";
		print "Ingrese el código de sistema para el país por el que desea filtrar(vacio para omitir, 'q' para volver al menú): ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( exists $sistemas{$pais}{$cadena} ) || ( $cadena eq "q" ) || ( $cadena eq "" ) ) {
			last;
		}
		else {
			print "El código de sistema no existe, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}
# Ingreso el filtro para el porcentaje
sub filtroPorcentaje {
	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un porcentaje valido
	while (1) {
		$cadena = "";
		print "Ingrese el porcentaje de divergencia a considerar(el mismo deberá estar entre 0 y 100) o q para volver al menú: ";
		$cadena = <STDIN>;
		chomp($cadena);

		if  ( $cadena eq "q" ){
			last;
		}
		if( not length $cadena ) {
			print "Debe ingresar un porcentaje\n";
			next;
		}
		if( $cadena =~ /[^0-9]/ ) {
			print "El porcentaje debe ser un número\n";
			next;
		}
		if ($cadena<0 or $cadena>100){
			print "El porcentaje debe estar entre 0 y 100\n";
			next;
		}
		last;
	}
	$retval = $cadena;
}
# Ingreso el filtro para el monto
sub filtroMonto {
	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un monto valido
	while (1) {
		$cadena = "";
		print "Ingrese el monto de divergencia ( en \$)a considerar(el mismo deberá ser mayor a 0) o 'q' para volver al menú: ";
		$cadena = <STDIN>;
		chomp($cadena);

		if  ( $cadena eq "q" ){
			last;
		}
		if( not length $cadena ) {
			print "Debe ingresar un monto\n";
			next;
		}
		if( $cadena =~ /[^0-9]/ ) {
			print "El monto debe ser un número\n";
			next;
		}
		if ($cadena<0){
			print "El monto debe ser mayor a 0(cero)\n";
			next;
		}
		last;
	}
	$retval = $cadena;
}
# Ingreso el filtro para el rango solicitado de periodos
sub filtroRangoPeriodo{

	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un rango de periodos valido
	while (1) {
		$cadena = "";
		print "Ingrese el rango de periodos, el mismo deberá ser del tipo desde-hasta y \n"
			."sigue el formato de los periodos sera yyyymm(vacio para omitir, q para volver al menú): ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( !&validoPeriodos($cadena) ) || ( $cadena eq "q" ) || ( $cadena eq "" ) ) {
			last;
		}
		else {
			print "El rango de periodos no es válido, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}

# Proceso Principal
sub main {
	local ( $a, $c, $g, $pais, $sistema, $divPor, $divMon, $monto, $porc);
	local ( $periodos,$periodoInicial,$periodoFinal, @comparado, @divergencia );

	my $cadena = "";
	my $error  = 0;

	while (1) {

		if ($error) {
			print "No se ingresaron los parametros correctos\n";
		}

		# Blanqueo las variables del comando.
		$error      	= 0;
		$a          	= 0;
		$g          	= 0;
		$c          	= 0;
		$pais      	 	= '';
		$sistema   	 	= 0;
		$divPor			= 0;
		$divMon			= 0;
		$porc 			= 0;
		$monto 			= 0;
		$periodos 		= "";
		@comparado = ();
		@divergencia = ();
		print "Ingrese la acción a realizar(q para salir, -a para ayuda): ";
		$cadena = <STDIN>;

		system(clear);
		chomp($cadena);
		if ( $cadena eq "q" ) {
			last;
		}
		&procesoArgumentos($cadena);

		if ($a){
			&mostrarAyuda();
			next();
		}
		if ($c+$divPor+$divMon>1){
			print "No se puede listar el comparado, los porcentajes y/o montos al mismo tiempo \n";
			$error =1;
			next;
		} elsif ($c+$divPor+$divMon==0){
			print "Parámetro incorrecto. Intente nuevamente\n";
			next;
		}

		$pais = &filtroPais();
		if ($pais eq 'q'){
			next
		}

		if ($c){
			$sistema = &filtroSistema();
			if ($sistema eq 'q'){
				next
			}

			$periodos = &filtroRangoPeriodo();
			if ($periodos eq 'q'){
				next
			}
			&procesoComparado();
			&muestroComparado();
			if ($g==1){
				&escriboComparado()
			}
		}

		if ($divPor){
			if (!&existeComparado()){
				print "No existe el archivo de comparado para el país ingresado\n";
			}
			$porc = &filtroPorcentaje();
			if ($porc eq 'q'){
				next
			}
			&procesoDivergenciaPorcentaje();
			&muestroDivergencia();
			if ($g==1){
				&escriboDivergencia()
			}
		}
		if ($divMon){
			if (!&existeComparado()){
				print "No existe el archivo de comparado para el país ingresado\n";
			}
			$monto = &filtroMonto();
			if ($monto eq 'q'){
				next
			}
			&procesoDivergenciaMonto();
			&muestroDivergencia();
			if ($g==1){
				&escriboDivergencia()
			}
		}
	}

	exit;
}

