#!/usr/bin/env bash

set -Eeuo pipefail

if [[ -z "${DSH_AUTH_USER:-}" ]]; then
    echo "ERRO: DSH_AUTH_USER não configurado."
    exit 1
fi

if [[ -z "${DSH_AUTH_PASSWORD:-}" ]]; then
    echo "ERRO: DSH_AUTH_PASSWORD não configurado."
    exit 1
fi

# Gera hash bcrypt da senha em memória.
# A senha em texto puro não é gravada no Caddyfile.
export DSH_AUTH_HASH
DSH_AUTH_HASH="$(caddy hash-password --plaintext "${DSH_AUTH_PASSWORD}")"

cleanup() {
    kill "${DSH_PID:-}" "${CADDY_PID:-}" 2>/dev/null || true
    wait "${DSH_PID:-}" "${CADDY_PID:-}" 2>/dev/null || true
}

trap cleanup EXIT SIGTERM SIGINT

echo "Iniciando DeepSeek Harness em 127.0.0.1:3080..."

pnpm dsh web \
    --host 127.0.0.1 \
    --port 3080 \
    --no-open &

DSH_PID=$!

echo "Iniciando gateway autenticado em 0.0.0.0:7860..."

caddy run \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile &

CADDY_PID=$!

set +e
wait -n "${DSH_PID}" "${CADDY_PID}"
STATUS=$?
set -e

exit "${STATUS}"