#!/bin/sh
# Batería para conky 1.8 (BAT1: charge_now/charge_full).
# conky 1.8 tiene battery_bar roto y este sysfs no expone 'capacity'.
# Uso: conky-bat.sh {pct|state|volt|tech|ac}
U=/sys/class/power_supply/BAT1/uevent

case "${1:-pct}" in
  pct)
    n=$(sed -n 's/^POWER_SUPPLY_CHARGE_NOW=//p' "$U")
    f=$(sed -n 's/^POWER_SUPPLY_CHARGE_FULL=//p' "$U")
    [ -z "$f" ] && f=1
    [ -z "$n" ] && n=0
    echo $((100 * n / f))
    ;;
  state)
    st=$(sed -n 's/^POWER_SUPPLY_STATUS=//p' "$U")
    case "$st" in
      Charging)    echo "Cargando" ;;
      Discharging) echo "Descargando" ;;
      Full)        echo "Completa" ;;
      *)           echo "${st:-n/a}" ;;
    esac
    ;;
  volt)
    v=$(sed -n 's/^POWER_SUPPLY_VOLTAGE_NOW=//p' "$U")
    [ -z "$v" ] && v=0
    echo "$((v / 1000000)).$(( (v % 1000000) / 100000 ))"
    ;;
  tech)
    sed -n 's/^POWER_SUPPLY_TECHNOLOGY=//p' "$U"
    ;;
  ac)
    on=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)
    if [ "$on" = "1" ]; then echo "conectado"; else echo "desconectado"; fi
    ;;
  *)
    echo "uso: $0 {pct|state|volt|tech|ac}"
    ;;
esac
