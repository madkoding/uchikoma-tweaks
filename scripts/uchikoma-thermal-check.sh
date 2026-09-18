#!/bin/bash
# Uchikoma thermal + health check
# Reports CPU temperature, fan (acerhdf) state, thermal throttling,
# disk errors, and the current battery/power settings.
#
# Usage: ~/scripts/uchikoma-thermal-check.sh

echo "=== Temperatura CPU ==="
for z in /sys/class/thermal/thermal_zone*/; do
  [ -d "$z" ] || continue
  type=$(cat "$z/type" 2>/dev/null)
  temp=$(cat "$z/temp" 2>/dev/null)
  if [ -n "$temp" ]; then
    echo "$type: $((temp / 1000)).$((temp % 1000 / 100)) C"
  fi
done

echo
echo "=== Sensores coretemp (si existen) ==="
for h in /sys/class/hwmon/hwmon*/; do
  [ -d "$h" ] || continue
  name=$(cat "$h/name" 2>/dev/null)
  case "$name" in
    coretemp|acpi)
      for t in "$h"/temp*_input; do
        [ -f "$t" ] || continue
        label=$(cat "${t%_input}_label" 2>/dev/null || basename "$t")
        val=$(cat "$t" 2>/dev/null)
        [ -n "$val" ] && echo "$name $label: $((val / 1000)) C"
      done
      ;;
  esac
done

echo
echo "=== acerhdf (ventilador Acer Aspire One) ==="
if [ -d /sys/class/thermal/cooling_device0 ]; then
  for c in /sys/class/thermal/cooling_device*/; do
    [ -d "$c" ] || continue
    echo "$(cat "$c/type" 2>/dev/null): state $(cat "$c/cur_state" 2>/dev/null) / max $(cat "$c/max_state" 2>/dev/null)"
  done
else
  echo "no cooling devices"
fi
lsmod | grep -q acerhdf && echo "acerhdf: cargado" || echo "acerhdf: NO cargado"
for f in /sys/class/thermal/thermal_zone*/policy; do
  [ -f "$f" ] && echo "$(dirname "$f" | xargs basename) policy: $(cat "$f")"
done

echo
echo "=== Throttling / errores térmicos en dmesg ==="
dmesg 2>/dev/null | grep -iE "thermal|throttl|temperature|critical" | tail -15 || echo "sin eventos (o requiere sudo)"

echo
echo "=== Errores de disco ==="
dmesg 2>/dev/null | grep -iE "ata[0-9]+\.[0-9]+.*(error|failed|reset)|I/O error|EXT4-fs error" | tail -15 || echo "sin errores"

echo
echo "=== Estado S.M.A.R.T. (si smartctl existe) ==="
if which smartctl > /dev/null 2>&1; then
  sudo smartctl -H -A /dev/sda 2>/dev/null | head -30 || echo "smartctl falló"
else
  echo "smartctl no instalado"
fi

echo
echo "=== Configuración de energía actual ==="
echo "governor:     $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
echo "max freq:     $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)"
echo "cur freq:     $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)"
echo "laptop_mode:  $(cat /proc/sys/vm/laptop_mode 2>/dev/null)"
echo "swappiness:   $(cat /proc/sys/vm/swappiness 2>/dev/null)"
echo "dirty_ratio:  $(cat /proc/sys/vm/dirty_ratio 2>/dev/null)"
echo "dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio 2>/dev/null)"

echo
echo "=== Uptime y carga ==="
uptime
cat /proc/loadavg

echo
echo "=== Memoria ==="
free -m
