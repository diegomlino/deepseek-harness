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

if [[ -z "${PUBLIC_HOST:-}" ]]; then
    echo "ERRO: PUBLIC_HOST não configurado."
    exit 1
fi

# PUBLIC_HOST deve ser somente uma autoridade:
#
# correto:
# deepseek.iaengenharia.ia.br
#
# incorreto:
# https://deepseek.iaengenharia.ia.br
# deepseek.iaengenharia.ia.br/
#
if [[ "${PUBLIC_HOST}" == *"://"* || "${PUBLIC_HOST}" == */* || "${PUBLIC_HOST}" =~ [[:space:]] ]]; then
    echo "ERRO: PUBLIC_HOST deve conter somente host ou host:porta, sem http://, https://, caminho ou espaços."
    exit 1
fi

# Gera hash bcrypt para o Basic Auth do Caddy.
# A senha em texto puro nunca é gravada no Caddyfile.
export GATEWAY_AUTH_HASH
GATEWAY_AUTH_HASH="$(
    caddy hash-password \
        --algorithm bcrypt \
        --plaintext "${GATEWAY_AUTH_PASSWORD}"
)"

# A partir daqui o Caddy precisa apenas do hash.
unset GATEWAY_AUTH_PASSWORD

echo "Validando configuração do Caddy..."

caddy validate \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile

cleanup() {
    kill "${DSH_PID:-}" "${CADDY_PID:-}" 2>/dev/null || true
    wait "${DSH_PID:-}" "${CADDY_PID:-}" 2>/dev/null || true
}

trap cleanup EXIT SIGTERM SIGINT

echo "Iniciando DeepSeek Harness em 127.0.0.1:3080..."
echo "Host público confiável: ${PUBLIC_HOST}"

pnpm dsh web \
    --host 127.0.0.1 \
    --port 3080 \
    --trusted-host "${PUBLIC_HOST}" \
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