#!/bin/bash
# Watchdog singleton: garantiza UN solo guardian y que xfsettingsd nunca muera.
# Sin xfsettingsd, _XSETTINGS_S0 queda sin dueno y las apps GTK vuelven a
# defaults (Sans 10 / Raleigh / hicolor): la Apariencia "no se guarda".
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority

LOCK=/tmp/xfsettingsd-watchdog.lock
exec 9>"$LOCK"
if ! flock -n 9; then
    # ya hay otro watchdog corriendo: salir en silencio
    exit 0
fi

while true; do
    if ! pgrep -x xfsettingsd >/dev/null 2>&1; then
        sleep 2
        if ! pgrep -x xfsettingsd >/dev/null 2>&1; then
            setsid xfsettingsd --force >/dev/null 2>&1 &
            sleep 3
        fi
    fi
    sleep 20
done
