#!/bin/bash
# Hipotesis: los UNC ABRT dependen del LARGO de lectura sostenida, no de la ubicacion.
# Prueba: leer longitudes crecientes desde una zona "buena" (0 MB) y ver cuando falla.
# Solo lectura -> /dev/null.

err() { sudo dmesg | grep -c "I/O error"; }

echo "errores iniciales: $(err)"
echo ""
echo "=== lectura sostenida desde 0 MB, longitudes crecientes ==="
for mb in 100 200 400 800 1600 2000; do
  b=$(err)
  if sudo dd if=/dev/sda of=/dev/null bs=1M skip=0 count=$mb iflag=direct 2>/dev/null; then
    r=OK
  else
    r=FAIL
  fi
  a=$(err)
  printf "  %5s MB -> %-4s  errores nuevos: %s\n" "$mb" "$r" "$((a-b))"
done
echo ""
echo "=== ahora con cache (sin iflag=direct) ==="
for mb in 200 400 800; do
  b=$(err)
  if sudo dd if=/dev/sda of=/dev/null bs=1M skip=0 count=$mb 2>/dev/null; then
    r=OK
  else
    r=FAIL
  fi
  a=$(err)
  printf "  %5s MB -> %-4s  errores nuevos: %s\n" "$mb" "$r" "$((a-b))"
done
echo ""
echo "errores finales: $(err)"
echo "temp: $(cat /sys/class/thermal/thermal_zone0/temp)"
