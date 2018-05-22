export GRUPO="./"
export DIR_ARRIBOS="$GRUPO""arribos"
export DIR_LOGS="$GRUPO""logs"
export PATH_MASTER="$GRUPO""install_files/master_files/p-s.mae"
export DIR_ACCEPTED="$GRUPO""aceptados/"
export DIR_REJECTED="$GRUPO""rechazados/"
export DIR_INDICTED="$GRUPO""procesados"
export PATH_T1="$GRUPO""install_files/master_files/T1.tab"
export PATH_T2="$GRUPO""install_files/master_files/T2.tab"

./detectO.sh&
DAEMON_PID=$!
echo "daemon pid: $DAEMON_PID" > ".ignoreme"
read A
kill -9 "$DAEMON_PID"