#!/bin/bash
# Toggle WiFi on/off to save battery when not needed.
# Usage: uchikoma-wifi.sh [on|off|toggle]
IFACE=${WIFI_IFACE:-wlan0}

state() {
  cat /sys/class/net/$IFACE/operstate 2>/dev/null || echo "unknown"
}

case "${1:-toggle}" in
  on|up)
    sudo ip link set $IFACE up 2>/dev/null || sudo ifconfig $IFACE up 2>/dev/null || true
    echo "wifi up: $(state)"
    ;;
  off|down)
    sudo ip link set $IFACE down 2>/dev/null || sudo ifconfig $IFACE down 2>/dev/null || true
    echo "wifi down: $(state)"
    ;;
  toggle)
    if [ "$(state)" = "up" ]; then
      sudo ip link set $IFACE down 2>/dev/null || sudo ifconfig $IFACE down 2>/dev/null || true
      echo "wifi toggled down"
    else
      sudo ip link set $IFACE up 2>/dev/null || sudo ifconfig $IFACE up 2>/dev/null || true
      echo "wifi toggled up"
    fi
    ;;
  *)
    echo "usage: $0 [on|off|toggle]"
    exit 1
    ;;
esac
