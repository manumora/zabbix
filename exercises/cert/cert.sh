#!/bin/bash
# cert_dias.sh - Días restantes hasta la caducidad de un certificado TLS
# Uso: cert_dias.sh <host> [puerto]
# Devuelve: días restantes (negativo si ya caducó), o -99999 si no se pudo comprobar
# Ejemplo: cert.sh iessantaeulalia.educarex.es 443

set -u

ERROR=-99999
HOST="${1:-}"
PUERTO="${2:-443}"

if [ -z "$HOST" ]; then
    echo $ERROR
    exit 0
fi

FECHA_FIN=$(echo | timeout 10 openssl s_client \
    -connect "${HOST}:${PUERTO}" \
    -servername "${HOST}" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2)

if [ -z "$FECHA_FIN" ]; then
    echo $ERROR
    exit 0
fi

EPOCH_FIN=$(date -d "$FECHA_FIN" +%s 2>/dev/null)

if [ -z "$EPOCH_FIN" ]; then
    echo $ERROR
    exit 0
fi

EPOCH_HOY=$(date +%s)
echo $(( (EPOCH_FIN - EPOCH_HOY) / 86400 ))
