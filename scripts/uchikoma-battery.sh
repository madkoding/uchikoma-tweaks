#!/bin/bash
# Uchikoma battery saver - applies per-login and persistent settings
# This script runs automatically from ~/.xsessionrc
export DISPLAY=:0.0
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

# 1. CPU governor to conservative (sube gradualmente ante carga, baja en idle).
# powersave se quedaba siempre a 800 MHz y causaba tirones con 512 MB de RAM.
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  sudo sh -c "echo conservative > '$cpu'" 2>/dev/null || true
done

# 1b. Cap max CPU frequency to 1333 MHz (balance bateria/fluidez).
# Con ventilador kernelmode a 38C el sistema puede mantener 1333 MHz sin
# sobrecalentarse. Antes estaba en 1066 MHz y causaba tirones visibles.
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
  sudo sh -c "echo 1333000 > '$cpu'" 2>/dev/null || true
done

# 1e. Swappiness: con solo 512 MB de RAM, 10 es demasiado bajo y fuerza OOM.
# 40 permite usar swap de forma razonable sin convertir el disco en un cuello de botella.
sudo sysctl -w vm.swappiness=40 >/dev/null 2>&1 || true

# 1f. Dirty ratio ajustado: con poca RAM, bajar dirty_ratio evita que el kernel
# acumule demasiadas paginas sucias antes de escribir.
sudo sysctl -w vm.dirty_ratio=10 >/dev/null 2>&1 || true
sudo sysctl -w vm.dirty_background_ratio=3 >/dev/null 2>&1 || true

# 1g. Cache pressure: con poca RAM, favorecer liberar cache de inodos/dentry
# para dejar espacio a las aplicaciones.
sudo sysctl -w vm.vfs_cache_pressure=500 >/dev/null 2>&1 || true

# 1c. Laptop mode - DESACTIVADO por estabilidad
# El laptop_mode=5 retrasa escrituras y aumenta riesgo de corrupcion si el
# sistema se cuelga / apaga forzosamente (paso en Uchikoma 2026-09-18).
# Se mantiene vm.laptop_mode=0 para evitar esos cuelgues.
sudo sysctl -w vm.laptop_mode=0 >/dev/null 2>&1 || true

for dev in USB0 USB1 USB2 USB3 UHC1 UHC2 UHC3 UHC4 UHC5 UHC6 EHC1 EHC2; do
  grep -q "^$dev" /proc/acpi/wakeup 2>/dev/null && sudo sh -c "echo '$dev' > /proc/acpi/wakeup" 2>/dev/null || true
done

# 3. USB autosuspend (requires root, harmless if fails)
for f in /sys/bus/usb/devices/*/power/autosuspend; do
  sudo sh -c "echo 2 > '$f'" 2>/dev/null || true
done
for f in /sys/bus/usb/devices/*/power/control; do
  sudo sh -c "echo auto > '$f'" 2>/dev/null || true
done

# 4. Reduce screen blank to 2 minutes (XFCE)
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 2 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 2 2>/dev/null || true
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -n -t int -s 2 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -s 2 2>/dev/null || true

# 5. Ensure screensaver does not lock / steal focus
pkill -x xscreensaver 2>/dev/null || true
pkill -x light-locker 2>/dev/null || true

# 5b. Kill memory-heavy daemons not needed in Uchikoma
pkill -x console-kit-daemon 2>/dev/null || true
pkill -f "gvfs-gphoto2-volume-monitor" 2>/dev/null || true
pkill -f "gvfs-afc-volume-monitor" 2>/dev/null || true
pkill -f "gvfsd-trash" 2>/dev/null || true
# NOT killing Thunar: it is now the default file manager daemon.

# 5c. Ensure governor stays conservative and max freq stays capped (some sessions reset it)
sleep 10
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  sudo sh -c "echo conservative > '$cpu'" 2>/dev/null || true
done
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
  sudo sh -c "echo 1333000 > '$cpu'" 2>/dev/null || true
done

# 5d. Laptop mode re-disable (algunas sesiones lo cambian)
sudo sysctl -w vm.laptop_mode=0 >/dev/null 2>&1 || true

# 5e. Re-apply swappiness/dirty/cache pressure after 10s (some sessions reset it)
sleep 10
sudo sysctl -w vm.swappiness=40 >/dev/null 2>&1 || true
sudo sysctl -w vm.dirty_ratio=10 >/dev/null 2>&1 || true
sudo sysctl -w vm.dirty_background_ratio=3 >/dev/null 2>&1 || true
sudo sysctl -w vm.vfs_cache_pressure=500 >/dev/null 2>&1 || true

# 6. Resume rescue after login
sleep 5
~/scripts/uchikoma-resume-rescue.sh

# 7. Report
echo "governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
echo "max_freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)"
echo "swappiness: $(cat /proc/sys/vm/swappiness 2>/dev/null)"
echo "temp: $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)"
