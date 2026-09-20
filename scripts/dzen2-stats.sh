#!/bin/sh
# Widget de stats tipo conky usando dzen2 (Uchikoma)
# Muestra: CPU, RAM, temperatura, bateria

WIDTH=300
HEIGHT=22
X=1066
Y=0
BG="#000000"
FG="#00d9ff"
FONT="fixed"

get_cpu() {
    # Leer dos muestras de /proc/stat y calcular delta
    read -r _ u1 n1 s1 i1 _ < /proc/stat
    idle1=$((i1 + n1))
    total1=$((u1 + n1 + s1 + i1))
    sleep 0.5
    read -r _ u2 n2 s2 i2 _ < /proc/stat
    idle2=$((i2 + n2))
    total2=$((u2 + n2 + s2 + i2))
    totald=$((total2 - total1))
    idled=$((idle2 - idle1))
    if [ "$totald" -eq 0 ]; then totald=1; fi
    awk -v id="$idled" -v tot="$totald" 'BEGIN{printf "%d", 100*(1-id/tot)}'
}

while :; do
    cpu=$(get_cpu)
    ram=$(free -m | awk '/^Mem:/{printf "%d/%dMB", $3, $2}')
    temp=$(awk '{printf "%d", $1/1000}' /sys/class/thermal/thermal_zone0/temp)
    bat=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo "?")
    ac=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "?")
    if [ "$ac" = "Charging" ]; then sym="+"; else sym=""; fi
    echo "CPU ${cpu}% | RAM ${ram} | ${temp}C | BAT ${bat}${sym}%"
    sleep 1.5
done | dzen2 -x $X -y $Y -w $WIDTH -h $HEIGHT -ta r -fg "$FG" -bg "$BG" -fn "$FONT" -p
