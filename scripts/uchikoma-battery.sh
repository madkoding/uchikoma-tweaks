#!/bin/bash
# Uchikoma battery/thermal saver - applies per-login settings
# This script runs automatically from ~/.xsessionrc
export DISPLAY=:0.0
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

# Underclock: cap max CPU frequency to 800 MHz to reduce heat.
# Governor powersave keeps CPU at the lowest voltage/freq.
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
  sudo sh -c "echo 800000 > '$cpu'" 2>/dev/null || true
done
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  sudo sh -c "echo powersave > '$cpu'" 2>/dev/null || true
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

# 4. Screen/DPMS timings (minutes) - aggressive for battery/thermal savings.
# blank = screensaver-like blank, sleep = DPMS standby, off = DPMS off.
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 5 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 5 2>/dev/null || true
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -n -t int -s 3 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -s 3 2>/dev/null || true
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -n -t int -s 10 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 10 2>/dev/null || true
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -n -t int -s 15 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 15 2>/dev/null || true
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-sleep -n -t int -s 5 2>/dev/null || \
  xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-sleep -s 5 2>/dev/null || true
# critical-power-action 3 = shutdown (no hibernate/suspend confiable); power-button 3 = ask.

# 5. Ensure screensaver does not lock / steal focus
pkill -x xscreensaver 2>/dev/null || true
pkill -x light-locker 2>/dev/null || true

# 5b. Kill memory-heavy daemons not needed in Uchikoma
pkill -x console-kit-daemon 2>/dev/null || true
pkill -f "gvfs-gphoto2-volume-monitor" 2>/dev/null || true
pkill -f "gvfs-afc-volume-monitor" 2>/dev/null || true
pkill -f "gvfsd-trash" 2>/dev/null || true
# NOT killing Thunar: it is now the default file manager daemon.

# 5c. Re-apply underclock after 10s (some sessions reset it)
sleep 10
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
  sudo sh -c "echo 800000 > '$cpu'" 2>/dev/null || true
done
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  sudo sh -c "echo powersave > '$cpu'" 2>/dev/null || true
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
