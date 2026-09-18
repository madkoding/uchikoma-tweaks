# uchikoma-tweaks

Ajustes de rendimiento, batería y rescate post-suspender para el Acer Aspire One "Uchikoma" corriendo Peppermint Two / Ubuntu Natty.

## Contenido

- `scripts/uchikoma-boot-optimize.sh` — desactiva servicios SysV innecesarios.
- `scripts/uchikoma-battery.sh` — governor `powersave`, USB autosuspend, blank 2 min, rescate gráfico, mata gvfs media monitors y console-kit.
- `scripts/uchikoma-resume-rescue.sh` — relanza xfwm4/panel/xfdesktop si no están vivos.
- `scripts/uchikoma-resolution.sh` — resolución virtual 1366x800 + DPI 72.
- `scripts/gvfs-media-blocker.desktop` — evita que gvfs cargue monitores de cámara/iPhone.
- `scripts/thunar.desktop` — evita que Thunar se cargue como daemon.

## Uso

1. Copiar todo a `~/scripts/`:
   ```bash
   cp -r scripts/* ~/scripts/
   chmod +x ~/scripts/uchikoma-*.sh
   ```

2. Agregar al final de `~/.xsessionrc`:
   ```bash
   ~/scripts/uchikoma-battery.sh >/tmp/uchikoma-battery.log 2>&1 &
   ```

3. Ejecutar una vez con sudo:
   ```bash
   sudo /home/madkoding/scripts/uchikoma-boot-optimize.sh
   sudo update-rc.d ondemand disable
   sudo sysctl -w vm.swappiness=10
   ```

4. Reiniciar sesión X.

## Advertencias

- `powersave` reduce rendimiento.
- USB autosuspend puede añadir latencia al reconectar dispositivos.
- No tocar servicios críticos: `networking`, `ssh`, `dbus`, `cron`, `slim`, `x11vnc`.
- `console-kit-daemon` se mata por sesión; si alguna app lo necesita, puede fallar.
