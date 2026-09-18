# uchikoma-tweaks

Ajustes de rendimiento, batería y rescate post-suspender para el Acer Aspire One "Uchikoma" corriendo Peppermint Two / Ubuntu Natty.

## Contenido

- `scripts/uchikoma-boot-optimize.sh` — desactiva servicios SysV innecesarios.
- `scripts/uchikoma-battery.sh` — governor `powersave`, USB autosuspend, blank 2 min, rescate gráfico, mata gvfs media monitors y console-kit.
- `scripts/uchikoma-resume-rescue.sh` — relanza xfwm4/panel/xfdesktop si no están vivos.
- `scripts/uchikoma-resolution.sh` — resolución virtual 1366x800 + DPI 72.
- `scripts/uchikoma-disable-x11vnc.sh` — desactiva x11vnc del boot si no se usa.
- `scripts/uchikoma-wifi.sh` — script para apagar/encender WiFi (`on`, `off`, `toggle`).
- `scripts/gvfs-media-blocker.desktop` — evita que gvfs cargue monitores de cámara/iPhone.
- `scripts/thunar.desktop` — evita que Thunar se cargue como daemon.

- `scripts/uchikoma-wifi.sh` — script para apagar/encender WiFi (`on`, `off`, `toggle`).

## Uso

1. Copiar todo a `~/scripts/`:
   ```bash
   cp -r scripts/* ~/scripts/
   chmod +x ~/scripts/uchikoma-*.sh
   ```

2. Agregar al final de `~/.xsessionrc`:
   ```bash
   ~/scripts/uchikoma-battery.sh > /tmp/uchikoma-battery.log 2>&1 &
   ```

3. Ejecutar una vez con sudo:
   ```bash
   sudo /home/madkoding/scripts/uchikoma-boot-optimize.sh
   sudo /home/madkoding/scripts/uchikoma-disable-x11vnc.sh
   sudo update-rc.d ondemand disable
   sudo sysctl -w vm.swappiness=10
   sudo update-rc.d rsync disable
   # ntp se mantiene habilitado para que el reloj no se desajuste
   ```

4. Copiar los blockers de autostart:
   ```bash
   cp ~/scripts/gvfs-media-blocker.desktop ~/.config/autostart/
   cp ~/scripts/thunar.desktop ~/.config/autostart/
   ```

5. Para ahorrar batería, apagar WiFi cuando no se use:
   ```bash
   ~/scripts/uchikoma-wifi.sh off
   ```
   Encender de nuevo:
   ```bash
   ~/scripts/uchikoma-wifi.sh on
   ```

6. Reiniciar sesión X.

## Advertencias

- `powersave` reduce rendimiento.
- USB autosuspend puede añadir latencia al reconectar dispositivos.
- No tocar servicios críticos: `networking`, `ssh`, `dbus`, `cron`, `slim`.
- `console-kit-daemon` se mata por sesión; si alguna app lo necesita, puede fallar.
- `x11vnc` se desactiva del boot; si se necesita, se puede reactivar con `sudo update-rc.d x11vnc enable`.
- `rsync` se desactiva del boot; `ntp` se mantiene habilitado para sincronización de reloj.
- `xfce4-power-manager` y `upowerd` se desactivan; la gestión de energía queda en `xset` y blank de pantalla.
