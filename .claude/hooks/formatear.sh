#!/usr/bin/env bash
# PostToolUse (Edit|Write): formatea y revisa con lint el archivo recién tocado.
set -uo pipefail

archivo=$(jq -r '.tool_input.file_path // ""')
[ -z "$archivo" ] && exit 0

case "$archivo" in
  *.ts|*.tsx|*.js|*.jsx)
    npx prettier --write "$archivo" >/dev/null 2>&1
    if ! salida=$(npx eslint "$archivo" 2>&1); then
      echo "ESLint encontró problemas en $archivo:" >&2
      echo "$salida" >&2
      exit 2
    fi
    ;;
  *.json|*.md|*.css|*.yml|*.yaml)
    npx prettier --write "$archivo" >/dev/null 2>&1
    ;;
  *.prisma)
    npx prisma format >/dev/null 2>&1
    ;;
esac

exit 0
