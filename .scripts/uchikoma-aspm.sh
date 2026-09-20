#!/bin/bash
# Uchikoma: aplica ASPM powersave (ahorro de energia PCIe).
#
# Medido en este equipo: IRQ/s 440 -> 215 (-51%), context switches 322 -> 213.
# El wifi ath9k es PCIe y se beneficia; verificado estable (ping 0% loss,
# 0 errores RX tras el cambio).
#
# SE APLICA VIA SYSFS, NO VIA GRUB. Razon:
#   - `pcie_aspm=force` en la cmdline del kernel es MAS AGRESIVO: fuerza ASPM
#     incluso en dispositivos donde el BIOS no lo reporto. En algunos chipsets
#     eso rompe el wifi.
#   - Este equipo se administra por SSH sobre wlan0: si el wifi no arranca, se
#     pierde el acceso y hay que editar GRUB a mano desde el menu de arranque.
#   - La politica via sysfs se probo y funciona; es reversible al instante
#     (`echo default | sudo tee ...`) y no puede dejar el equipo incomunicado.
#   - El ahorro es identico: la politica gobierna los mismos enlaces PCIe.
#
# Se ejecuta desde ~/.scripts/uchikoma-battery.sh en cada login (los valores de
# /sys/module/*/parameters/* no sobreviven al reinicio).

set -u

POL=/sys/module/pcie_aspm/parameters/policy
[ -w "$POL" ] || { echo "pcie_aspm no disponible"; exit 0; }

echo powersave | sudo tee "$POL" >/dev/null 2>&1

echo "aspm policy = $(cat "$POL" | tr -d ' \n')"
