export GRUPO="/home/phazan/Documentos/Fiuba/SistemasOperativos/Practica/tp"
export DIR_ARRIBOS="$GRUPO/arribos"
export DIR_LOGS="$GRUPO/logs"
export MASTER_CONTRY_SYSTEM="$GRUPO/config/master.txt"
export DIR_ACCEPTED="$GRUPO/aceptados/"
export DIR_REJECTED="$GRUPO/rechazados/"
export DIR_INDICTED="$GRUPO/procesados"

echo "$MASTER_CONTRY_SYSTEM"

./detecto.sh&
DAEMON_PID=$!
read A
kill -9 "$DAEMON_PID"