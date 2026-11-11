#!/usr/bin/env bash
# Stop: antes de que el agente dé la tarea por terminada, el código debe
# compilar y las pruebas unitarias deben pasar. Si no, se le devuelve el error.
set -uo pipefail

entrada=$(cat)
# Evita bucles: si este hook ya bloqueó una vez en este turno, deja terminar.
if [ "$(echo "$entrada" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

# Solo verifica si hay cambios en código
if ! git diff --name-only HEAD 2>/dev/null | grep -Eq '\.(ts|tsx|prisma)$'; then
  exit 0
fi

if ! salida=$(npm run -s typecheck 2>&1); then
  echo "TypeScript no compila. Corrige antes de terminar:" >&2
  echo "$salida" | tail -n 30 >&2
  exit 2
fi

if ! salida=$(npm test -s -- --run 2>&1); then
  echo "Las pruebas unitarias fallan. Corrige antes de terminar:" >&2
  echo "$salida" | tail -n 30 >&2
  exit 2
fi

exit 0
