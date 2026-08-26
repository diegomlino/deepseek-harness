#!/usr/bin/env bash

set -Eeuo pipefail

if [[ -z "${GATEWAY_AUTH_USER:-}" ]]; then
    echo "ERRO: GATEWAY_AUTH_USER não configurado."
    exit 1
fi

if [[ -z "${GATEWAY_AUTH_PASSWORD:-}" ]]; then
    echo "ERRO: GATEWAY_AUTH_PASSWORD não configurado."
    exit 1
fi

# Gera o hash bcrypt usado pelo Caddy
export GATEWAY_AUTH_HASH
GATEWAY_AUTH_HASH="$(caddy hash-password --plaintext "${GATEWAY_AUTH_PASSWORD}")"

# A senha em texto puro não precisa ser herdada
# pelos processos DSH e Caddy.
unset GATEWAY_AUTH_PASSWORD

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