#!/bin/bash
# Uchikoma battery saver - applies per-login and persistent settings
# This script runs automatically from ~/.xsessionrc
export DISPLAY=:0.0
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

# 1. CPU governor to powersave (requires root)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  sudo sh -c "echo powersave > '$cpu'" 2>/dev/null || true
done

# 2. Reduce wakeups from USB/ACPI devices (requires root)
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

# 6. Resume rescue after login
sleep 5
~/scripts/uchikoma-resume-rescue.sh

# 7. Report
echo "governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
