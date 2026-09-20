#!/bin/bash
# Aplica y persiste los parametros de GRUB para Uchikoma.
#
# VERIFICADO EMPIRICAMENTE antes de agregar cada uno:
#
#   pcie_aspm=force
#     ASPM (ahorro de energia en el bus PCIe). Medido: IRQ/s 440 -> 215 (-51%)
#     y context switches 322 -> 213. El wifi ath9k es PCIe y sigue estable
#     (ping 0% loss, 0 errores en 30 min). ASPM venia en "default" que en este
#     chipset 945GME deja varios puertos Disabled.
#     RIESGO CONOCIDO: en algunos chipsets ASPM rompe el wifi. En ESTE equipo
#     se probo y funciona. Si tras un reinicio el wifi no aparece, quitar este
#     parametro desde GRUB (editar la linea en el menu, tecla 'e') o via el
#     kernel anterior.
#
# Lo que NO se agrego (y por que):
#   * i915.i915_enable_rc6 / fbc / lvds_downclock  -> NO EXISTEN en 2.6.38.
#     Meterlos rompio i915 y dejo el equipo en vesafb 800x600. NUNCA repetir.
#   * nmi_watchdog=0 -> el parametro NO existe en este kernel (no hay
#     /proc/sys/kernel/nmi_watchdog). No hay nada que desactivar.
#   * nohz=on / highres=on -> ya activos de fabrica (CONFIG_NO_HZ=y,
#     CONFIG_HIGH_RES_TIMERS=y).
#   * elevator=deadline -> ya aplicado por sysfs (uchikoma-ssd-tune.sh).
#
# GRUB_CMDLINE_LINUX_DEFAULT estaba VACIO; tambien se quito "quiet splash"
# (ya no estaba) para ver los mensajes de arranque, util al diagnosticar.

set -euo pipefail

BK=/root/backup-grub-$(date +%Y%m%d-%H%M%S)
sudo cp /etc/default/grub "$BK"
echo "backup: $BK"

# Parametros verificados
PARAMS="pcie_aspm=force"

sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$PARAMS\"|" /etc/default/grub

echo "--- /etc/default/grub (lineas relevantes) ---"
grep -E "^GRUB_CMDLINE" /etc/default/grub

echo ""
echo "--- regenerando grub.cfg ---"
sudo update-grub 2>&1 | tail -5

echo ""
echo "--- verificacion: el parametro quedo en grub.cfg? ---"
grep -o "pcie_aspm=force" /boot/grub/grub.cfg | head -2

echo ""
echo "NOTA: se aplica en el proximo reinicio. Ahora mismo ya esta activo"
echo "      en caliente via /sys/module/pcie_aspm/parameters/policy"
