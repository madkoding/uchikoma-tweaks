#!/bin/bash
# Uchikoma: optimiza el I/O del SSD para reducir errores UNC ABRT.
#
# El kernel detecta el SanDisk SSDPAMM0008G1 como disco GIRATORIO
# (rotational=1) y usa cfq, que es el scheduler de discos mecanicos. Para un
# SSD PATA lento y con zonas debiles esto es contraproducente:
#   - cfq reordena y agrupa requests -> transferencias mas grandes que abarcan
#     mas sectores, aumentando la probabilidad de tocar una zona mala.
#   - read_ahead alto lee especulativamente zonas que quiza no se necesitan.
#   - max_sectors alto permite un solo request de 128 KB; si dentro hay un
#     sector malo, falla el request COMPLETO.
#
# Ajustes (aplicados en caliente, verificados escribibles):
#   rotational=0   -> tratar como SSD
#   scheduler=deadline -> mas predecible, sin reordenamiento agresivo de cfq
#   read_ahead_kb=64  -> menos lectura especulativa
#   max_sectors_kb=64 -> requests mas chicos: si hay un sector malo, falla
#                        menos datos y el driver reintenta mas facil
#
# NO es una reparacion: no arregla los sectores fisicamente dañados. Reduce la
# probabilidad de que una operacion normal caiga en una zona debil.

set -u
DEV=sda

for kv in "rotational 0" "read_ahead_kb 64" "max_sectors_kb 64"; do
    set -- $kv
    f=/sys/block/$DEV/queue/$1
    [ -w "$f" ] && echo "$2" | sudo tee "$f" >/dev/null 2>&1
done

# scheduler: el archivo escribe el nombre en corchetes
if [ -w /sys/block/$DEV/queue/scheduler ]; then
    echo deadline | sudo tee /sys/block/$DEV/queue/scheduler >/dev/null 2>&1
fi

echo "rotational   = $(cat /sys/block/$DEV/queue/rotational 2>/dev/null)"
echo "scheduler    = $(cat /sys/block/$DEV/queue/scheduler 2>/dev/null)"
echo "read_ahead   = $(cat /sys/block/$DEV/queue/read_ahead_kb 2>/dev/null)"
echo "max_sectors  = $(cat /sys/block/$DEV/queue/max_sectors_kb 2>/dev/null)"

# NOTA: para persistir en cada arranque, llamar a este script desde
# ~/.scripts/uchikoma-battery.sh (que corre en el login). Los valores de
# /sys/block/*/queue/* NO sobreviven a un reinicio.

