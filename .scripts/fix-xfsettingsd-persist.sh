#!/bin/bash
# Fix raiz #2: xfsettingsd (el gestor XSETTINGS) se muere y nadie posee
# _XSETTINGS_S0. Sin el, TODAS las apps GTK leen defaults (Sans 10, Raleigh,
# hicolor) y la Apariencia "no se guarda" nunca. Hay que garantizar que:
#   1) xfsettingsd arranque SIEMPRE con la sesion (watchdog en autostart).
#   2) haya un guardian que lo relance si muere.
set -u

# --- A. autostart explicito con fase Initialization ---
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/xfsettingsd.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Xfce Settings Daemon
Comment=Gestor XSETTINGS (tema, iconos, fuente, DPI, cursor)
Exec=xfsettingsd --force
Terminal=false
StartupNotify=false
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
X-XFCE-Autostart-Phase=Initialization
X-XFCE-Autostart-Notify=true
EOF
echo "autostart xfsettingsd.desktop creado"

# --- B. watchdog: relanza xfsettingsd si muere (y re-publica XSETTINGS) ---
cat > "$HOME/.local/bin/xfsettingsd-watchdog.sh" <<'EOF'
#!/bin/bash
# Relanza xfsettingsd si desaparece. Sin el, _XSETTINGS_S0 queda sin dueno y
# las apps GTK vuelven a defaults: apariencia "no se guarda".
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
while true; do
    if ! pgrep -x xfsettingsd >/dev/null 2>&1; then
        sleep 2
        # re-chequear evita relanzarlo mientras xfce4-session lo reinicia
        if ! pgrep -x xfsettingsd >/dev/null 2>&1; then
            setsid xfsettingsd --force >/dev/null 2>&1 &
            sleep 3
        fi
    fi
    sleep 20
done
EOF
chmod +x "$HOME/.local/bin/xfsettingsd-watchdog.sh"
echo "watchdog creado"

cat > "$HOME/.config/autostart/xfsettingsd-watchdog.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Xfce Settings Watchdog
Comment=Garantiza que xfsettingsd nunca muera (apariencia persistente)
Exec=/home/madkoding/.local/bin/xfsettingsd-watchdog.sh
Terminal=false
StartupNotify=false
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
X-XFCE-Autostart-Phase=Application
EOF
echo "autostart watchdog creado"

# --- C. arrancar ahora mismo ---
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
pkill -x xfsettingsd 2>/dev/null || true
sleep 1
setsid xfsettingsd --force >/dev/null 2>&1 &
sleep 3
pkill -f xfsettingsd-watchdog 2>/dev/null || true
sleep 1
setsid "$HOME/.local/bin/xfsettingsd-watchdog.sh" >/dev/null 2>&1 &
sleep 2

echo "--- verificacion ---"
ps -C xfsettingsd -o pid,args || echo "ERROR: xfsettingsd no corre"
pgrep -f xfsettingsd-watchdog >/dev/null && echo "watchdog OK" || echo "ERROR: sin watchdog"
echo "XSETTINGS_S0: $(xprop -root _XSETTINGS_S0 2>/dev/null || echo 'sin atom (normal, lo posee por selection)')"

python - <<'PY'
import gtk
s = gtk.settings_get_default()
print "app GTK2 ve -> font=%s theme=%s icons=%s" % (
    s.get_property("gtk-font-name"),
    s.get_property("gtk-theme-name"),
    s.get_property("gtk-icon-theme-name"))
PY
