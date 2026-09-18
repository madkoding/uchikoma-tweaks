#!/bin/bash
# Disable x11vnc server at boot (requires root)
sudo update-rc.d x11vnc disable
pkill -x x11vnc 2>/dev/null || true
echo "x11vnc disabled and stopped"
