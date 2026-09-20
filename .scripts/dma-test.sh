#!/bin/bash
# Caracteriza el fallo del SSD: que tamano de transferencia dispara los UNC ABRT.
# Zona 2000-2100 MB (FAIL conocida). Solo lectura. coreutils 8.5 -> usar skip/count.
# Nota: skip/count en bloques exige bs fijo; usar bs=1M y variar solo con bs=4K etc
# requiere convertir MB a bloques.

START_MB=2000
LEN_MB=100

err() { sudo dmesg | grep -c "I/O error"; }

echo "errores iniciales: $(err)"
echo ""
echo "=== zona ${START_MB}-$((START_MB+LEN_MB)) MB con distintos bs ==="
# bs en KB -> skip = START_MB*1024/bs_kb ; count = LEN_MB*1024/bs_kb
for bskb in 1024 512 256 128 64 32 16 4; do
  skip=$((START_MB*1024/bskb))
  count=$((LEN_MB*1024/bskb))
  b=$(err)
  if sudo dd if=/dev/sda of=/dev/null bs=${bskb}K skip=$skip count=$count iflag=direct 2>/dev/null; then
    r=OK
  else
    r=FAIL
  fi
  a=$(err)
  printf "  bs=%-6s -> %-4s  errores nuevos: %s\n" "${bskb}K" "$r" "$((a-b))"
done
echo ""
echo "errores finales: $(err)"
echo "temp: $(cat /sys/class/thermal/thermal_zone0/temp)"
