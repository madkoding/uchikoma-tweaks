#!/bin/bash
# Uchikoma resume rescue - recover WM/panel/desktop after suspend/resume
export DISPLAY=:0.0
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}

LOG=/tmp/uchikoma-resume.log
> "$LOG"

alive() {
  pgrep -x "$1" > /dev/null 2>&1
}

if ! alive xfwm4; then
  pkill -f xfce4-panel 2>/dev/null || true
  pkill -f xfdesktop 2>/dev/null || true
  setsid xfwm4 --replace --sm-client-disable >> "$LOG" 2>&1 &
  sleep 4
fi

if ! alive xfce4-panel; then
  setsid xfce4-panel >> "$LOG" 2>&1 &
  sleep 3
fi

if ! alive xfdesktop; then
  setsid xfdesktop >> "$LOG" 2>&1 &
  sleep 2
fi

# Apply background again
xfdesktop --reload 2>/dev/null || true

# Ensure no screen-locker is active
pkill -x xscreensaver 2>/dev/null || true
pkill -x light-locker 2>/dev/null || true

# NOT launching lxterminal: the user does not want it auto-starting.
# (Previously this script opened lxterminal at every session start.)

echo "resume rescue completed" >> "$LOG"
date >> "$LOG"
