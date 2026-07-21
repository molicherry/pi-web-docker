#!/bin/bash
set -e
# ── pi-web entrypoint ──────────────────────────────────────────────
# Dynamic user setup: injects /etc/passwd entry when --user is used.

RUNTIME_UID=$(id -u)
RUNTIME_GID=$(id -g)

if [ "$RUNTIME_UID" = "0" ]; then
  exec gosu piuser node node_modules/.bin/next start -p "${PORT:-30141}" -H "${HOSTNAME:-0.0.0.0}"
fi

if ! getent passwd "$RUNTIME_UID" >/dev/null 2>&1; then
  echo "piuser:x:${RUNTIME_UID}:${RUNTIME_GID}:pi-user:${HOME}:/bin/bash" >> /etc/passwd
fi

mkdir -p "$HOME/.pi/agent"
exec node node_modules/.bin/next start -p "${PORT:-30141}" -H "${HOSTNAME:-0.0.0.0}"
