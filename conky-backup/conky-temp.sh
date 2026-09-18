#!/bin/sh
# Sensores termicos + bateria para conky (Uchikoma / acerhdf).
# Uso: conky-temp.sh {int|dec|fan|mode|trip|bat|batstate}
TZ=/sys/class/thermal/thermal_zone0
BAT=/sys/class/power_supply/BAT1/uevent

case "${1:-int}" in
  int)
    t=$(cat "$TZ/temp" 2>/dev/null)
    [ -z "$t" ] && t=0
    echo $((t / 1000))
    ;;
  dec)
    t=$(cat "$TZ/temp" 2>/dev/null)
    [ -z "$t" ] && t=0
    echo "$((t / 1000)).$(( (t % 1000) / 100 ))"
    ;;
  fan)
    s=$(cat /sys/class/thermal/cooling_device2/cur_state 2>/dev/null)
    if [ "$s" = "1" ]; then echo "ON"; else echo "off"; fi
    ;;
  mode)
    cat "$TZ/mode" 2>/dev/null || echo "n/a"
    ;;
  trip)
    t=$(cat "$TZ/trip_point_0_temp" 2>/dev/null)
    [ -z "$t" ] && t=0
    # Con acerhdf en kernel mode el valor viene en grados (45);
    # con la BIOS venia en milesimas (45000). Normalizar.
    if [ "$t" -gt 1000 ] 2>/dev/null; then
      echo $((t / 1000))
    else
      echo "$t"
    fi
    ;;
  bat)
    n=$(sed -n 's/^POWER_SUPPLY_CHARGE_NOW=//p' "$BAT")
    f=$(sed -n 's/^POWER_SUPPLY_CHARGE_FULL=//p' "$BAT")
    [ -z "$f" ] && f=1
    [ -z "$n" ] && n=0
    echo $((100 * n / f))
    ;;
  batstate)
    s=$(sed -n 's/^POWER_SUPPLY_STATUS=//p' "$BAT")
    case "$s" in
      Charging)    echo "cargando" ;;
      Discharging) echo "descargando" ;;
      Full)        echo "completa" ;;
      *)           echo "${s:-n/a}" ;;
    esac
    ;;
  *)
    echo "uso: $0 {int|dec|fan|mode|trip|bat|batstate}"
    ;;
esac
