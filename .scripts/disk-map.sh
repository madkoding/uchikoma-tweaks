#!/bin/bash
# Mapea que zonas del /dev/sda son ilegibles leyendo en trozos de 200 MB.
# No escribe nada. Solo lectura con dd -> /dev/null.
# Salida: /tmp/disko-map.txt con OK/FAIL por zona.
OUT=/tmp/disko-map.txt
: > "$OUT"
CHUNK_MB=200
SKIP=0
TOTAL_MB=8069

while [ $SKIP -lt $TOTAL_MB ]; do
    if sudo dd if=/dev/sda of=/dev/null bs=1M skip=$SKIP count=$CHUNK_MB 2>/dev/null; then
        echo "OK   ${SKIP}-$((SKIP+CHUNK_MB)) MB" >> "$OUT"
    else
        echo "FAIL ${SKIP}-$((SKIP+CHUNK_MB)) MB" >> "$OUT"
    fi
    SKIP=$((SKIP+CHUNK_MB))
done
echo "DONE" >> "$OUT"
