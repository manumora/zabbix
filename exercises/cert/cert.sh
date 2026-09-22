#!/bin/bash
# cert.sh - Días restantes hasta la caducidad de un certificado TLS
# Uso: cert.sh <host> [puerto]
# Ejemplo: cert.sh iessantaeulalia.educarex.es 443

set -u

HOST="${1:-}"
PUERTO="${2:-443}"

if [ -z "$HOST" ]; then
    echo -1
    exit 0
fi

FECHA_FIN=$(echo | timeout 10 openssl s_client \
    -connect "${HOST}:${PUERTO}" \
    -servername "${HOST}" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2)

if [ -z "$FECHA_FIN" ]; then
    echo -1
    exit 0
fi

EPOCH_FIN=$(date -d "$FECHA_FIN" +%s 2>/dev/null)

if [ -z "$EPOCH_FIN" ]; then
    echo -1
    exit 0
fi

EPOCH_HOY=$(date +%s)
echo $(( (EPOCH_FIN - EPOCH_HOY) / 86400 ))
