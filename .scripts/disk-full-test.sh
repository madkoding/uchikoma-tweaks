#!/bin/bash
# Test riguroso del disco: captura el exit code REAL de dd (sin pipe que lo enmascare),
# y cuenta errores de forma fiable (dmesg hace wrap-around, asi que guarda el total
# acumulado desde el arranque con --ctime o cuenta por sector unico).

OUT=/tmp/disk-full-test.txt
: > "$OUT"

# dmesg puede dar wrap: usar "dmesg | wc -l" no sirve. Contamos sectores unicos vistos.
unique_bad() { sudo dmesg | grep -oE "sector [0-9]+" | awk '{print $2}' | sort -n -u | wc -l; }

echo "sectores malos unicos antes: $(unique_bad)" >> "$OUT"

# dd a un archivo temporal (no pipe) para capturar su exit code real
sudo dd if=/dev/sda of=/dev/null bs=1M iflag=direct > /tmp/ddout.txt 2>&1
RC=$?
echo "dd exit code: $RC" >> "$OUT"
echo "salida dd:" >> "$OUT"
tail -3 /tmp/ddout.txt >> "$OUT"

echo "sectores malos unicos despues: $(unique_bad)" >> "$OUT"
cat "$OUT"
