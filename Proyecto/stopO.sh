#!/bin/sh
#detectar si el demonio esta corriendo
#HIPOTESIS: el demonio solo se ejecutara una vez.
CANTIDAD_DEMONIOS=$(ps -e | pgrep -c "detecto.")
if [$CANTIDAD_DEMONIOS -eq 1]; then
  DEMONIO_PID=$(pgrep "detecto." | head -n 1)
  kill -9 "$DEMONIO_PID"
  return 0
fi
