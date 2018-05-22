export GRUPO="./"
export DIR_ARRIBOS="$GRUPO/arribos"
export DIR_LOGS="$GRUPO/logs"
export PATH_MASTER="$GRUPO/install_files/master_files/p-s.mae"
export DIR_ACCEPTED="$GRUPO/aceptados/"
export DIR_REJECTED="$GRUPO/rechazados/"
export DIR_INDICTED="$GRUPO/procesados"

./detectO.sh&
DAEMON_PID=$!
read A
kill -9 "$DAEMON_PID"