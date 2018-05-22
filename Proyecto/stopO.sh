#!/bin/sh
#detectar si el demonio esta corriendo
#HIPOTESIS: el demonio solo se ejecutara una vez.
CANTIDAD_DEMONIOS=$(ps -e | pgrep -c "detectO.")
if [ $CANTIDAD_DEMONIOS -eq 1 ]; then
  DEMONIO_PID=$(pgrep "detectO." | head -n 1)
  echo "El demonio detectO.sh con PID: $DEMONIO_PID ah sido detenido."
  kill -9 "$DEMONIO_PID"
  return 0
fi
