#!/bin/bash
# Resolucion virtual 1366x800 escalada al panel fisico 1024x600 en Uchikoma.
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
sleep 2
xrandr --fb 1366x800
xrandr --output LVDS1 --mode 1024x600 --scale 1.3333x1.3333 --pos 0x0
xrandr --dpi 72
