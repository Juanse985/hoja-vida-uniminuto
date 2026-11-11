#!/usr/bin/env bash
# PreToolUse (Bash): bloquea comandos destructivos o que exponen secretos.
# Salir con código 2 bloquea la acción y le devuelve el motivo al agente.
set -euo pipefail

cmd=$(jq -r '.tool_input.command // ""')

patrones=(
  'rm -rf'
  'prisma migrate reset'
  'prisma db push --force-reset'
  'DROP (TABLE|DATABASE|SCHEMA)'
  'git push (-f|--force)'
  'cat .*\.env'
  'printenv'
)

for p in "${patrones[@]}"; do
  if echo "$cmd" | grep -Eiq "$p"; then
    echo "Bloqueado por el harness: el comando coincide con '$p'. Pide confirmación al humano o usa una alternativa segura." >&2
    exit 2
  fi
done

exit 0
