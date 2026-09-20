#!/bin/bash
# Arregla la raiz del problema: capas que fuerzan apariencia sobre la sesion.
# 1) ~/.gtkrc-2.0 escrito por gtk-chtheme forzaba tema Xfce-orange + fuente Exo 2 9
#    a TODAS las apps GTK2, ganandole a XSettings (xfsettingsd).
# 2) uchikoma-battery.sh forzaba xsettings (sounds, MenuImages, icon sizes) al login.
# 3) ~/.xsessionrc forzaba cursor theme/size al login.
# 4) /Xft/DPI quedo en unidades mal (98304) y xfsettingsd lo mastico a 1000.

set -u
BK="$HOME/backup-appearance-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BK"
echo "backup en $BK"

for f in "$HOME/.gtkrc-2.0" \
         "$HOME/.config/gtk-3.0/settings.ini" \
         "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" \
         "$HOME/.xsessionrc" \
         "$HOME/.local/bin/uchikoma-resolution.sh" \
         "$HOME/scripts/uchikoma-battery.sh"; do
  [ -f "$f" ] && cp "$f" "$BK/$(basename "$f")" && echo "  backup $(basename "$f")"
done

# --- 1. Neutralizar .gtkrc-2.0 (que GTK2 vuelva a obedecer a XSettings) ---
cat > "$HOME/.gtkrc-2.0" <<'EOF'
# Intencionalmente vacio.
# Las apps GTK2 toman tema, iconos, fuente y cursor de XSettings (xfsettingsd),
# es decir de lo que se elige en Configuracion -> Apariencia y Configuracion -> Raton.
# NO poner aqui style/font_name/include: gana a XSettings y la Apariencia "no se guarda".
EOF
echo "gtkrc-2.0 neutralizado"

# --- 2. Quitar el forzado de apariencia de uchikoma-battery.sh ---
if [ -f "$HOME/scripts/uchikoma-battery.sh" ]; then
  python - "$HOME/scripts/uchikoma-battery.sh" <<'PY'
import sys, re
p = sys.argv[1]
src = open(p).read()
# borrar bloque "# 8." .. hasta "# 9. Report"
start = src.find("# 8. Reduce GPU/redraw load")
end = src.find("# 9. Report")
if start != -1 and end != -1 and end > start:
    src = src[:start] + src[end:]
    # quitar la linea del reporte de compositor
    src = src.replace('echo "compositor: $(xfconf-query -c xfwm4 -p /general/use_compositing 2>/dev/null)"\n', '')
    src = src.replace("# 9. Report", "# 7. Report")
    open(p, "w").write(src)
    print("battery.sh: bloque de forzado de apariencia eliminado")
else:
    print("battery.sh: bloque no encontrado (revisar)")
PY
  chmod +x "$HOME/scripts/uchikoma-battery.sh"
fi

# --- 3. xsessionrc / resolution: geometria si, forzado de cursor no; dpi 96 ---
cat > "$HOME/.xsessionrc" <<'EOF'
#!/bin/bash
# Geometria de la sesion Uchikoma (no toca apariencia: eso lo manda la sesion XFCE)
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
sleep 2
xrandr --fb 1366x800
xrandr --output LVDS1 --mode 1024x600 --scale 1.3333x1.3333 --pos 0x0
xrandr --dpi 96
EOF
cat > "$HOME/.local/bin/uchikoma-resolution.sh" <<'EOF'
#!/bin/bash
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
sleep 2
xrandr --fb 1366x800
xrandr --output LVDS1 --mode 1024x600 --scale 1.3333x1.3333 --pos 0x0
xrandr --dpi 96
EOF
chmod +x "$HOME/.local/bin/uchikoma-resolution.sh"
echo "xsessionrc/resolution: forzado de cursor eliminado, dpi 96"

# --- 4. Xresources coherente (dpi 96) ---
sed -i 's/^Xft\.dpi:.*/Xft.dpi: 96/' "$HOME/.Xresources" 2>/dev/null || echo "Xft.dpi: 96" >> "$HOME/.Xresources"
grep -n "Xft.dpi" "$HOME/.Xresources"

# --- 5. quitar stub de autostart roto (sin Exec) ---
rm -f "$HOME/.config/autostart/xfce4-settings-helper-autostart.desktop"

# --- 6. gtk-3.0 coherente ---
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Haiku
gtk-icon-theme-name=Haiku
gtk-font-name=Exo 2 10
EOF
echo "gtk-3.0 settings.ini sincronizado"

# --- 7. DPI en xfconf en unidades REALES (sin multiplicar por 1024) ---
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
xfconf-query -c xsettings -p /Xft/DPI -s 96
xfconf-query -c xsettings -p /Xfce/LastCustomDPI -s 96
echo "xfconf /Xft/DPI = $(xfconf-query -c xsettings -p /Xft/DPI)"

# --- 8. reiniciar xfsettingsd para publicar XSettings limpio ---
pkill -x xfsettingsd 2>/dev/null || true
sleep 1
setsid xfsettingsd --force >/dev/null 2>&1 &
sleep 4
echo "--- RESOURCE_MANAGER ---"
xprop -root RESOURCE_MANAGER
echo "--- panel (GTK2) reiniciado para tomar el tema/fuente nuevos ---"
pkill -x xfce4-panel 2>/dev/null || true
sleep 2
setsid xfce4-panel >/dev/null 2>&1 &
sleep 3
echo "listo"
