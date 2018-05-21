export GRUPO="./"
export DIR_ARRIBOS="$GRUPO/arribos"
export DIR_LOGS="$GRUPO/logs"
export MASTER_CONTRY_SYSTEM="$GRUPO/config/master.txt"
export DIR_ACCEPTED="$GRUPO/aceptados/"
export DIR_REJECTED="$GRUPO/rechazados/"
export DIR_INDICTED="$GRUPO/procesados"

./detecto.sh&
DAEMON_PID=$!
read A
kill -9 "$DAEMON_PID"