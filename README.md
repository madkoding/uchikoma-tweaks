# uchikoma-tweaks

Ajustes de rendimiento, batería y rescate post-suspender para el Acer Aspire One "Uchikoma" corriendo Peppermint Two / Ubuntu Natty.

## Contenido

- `scripts/uchikoma-battery.sh` — governor `powersave`, cap frecuencia CPU a 1066 MHz, USB autosuspend, blank 2 min, rescate gráfico, mata gvfs media monitors y console-kit. **Nota:** `vm.laptop_mode=5` fue desactivado por provocar cuelgues/corrupción ante apagados forzosos. Se fuerza `vm.laptop_mode=0`.
- `scripts/uchikoma-boot-optimize.sh` — desactiva servicios SysV innecesarios (rsync, anacron, plymouth, etc.).
- `scripts/uchikoma-resume-rescue.sh` — relanza xfwm4/panel/xfdesktop si no están vivos.
- `scripts/uchikoma-resolution.sh` — resolución virtual 1366x800 + DPI 72.
- `scripts/uchikoma-disable-x11vnc.sh` — desactiva x11vnc del boot si no se usa.
- `scripts/uchikoma-wifi.sh` — script para apagar/encender WiFi (`on`, `off`, `toggle`).
- `scripts/gvfs-media-blocker.desktop` — evita que gvfs cargue monitores de cámara/iPhone.
- `scripts/thunar.desktop` — evita que Thunar se cargue como daemon.
- `scripts/xsession` — archivo de sesión SLiM con hook de battery saver.

## Uso

1. Copiar todo a `~/scripts/` y el `xsession` al home:
   ```bash
   cp -r scripts/* ~/scripts/
   chmod +x ~/scripts/uchikoma-*.sh
   cp ~/scripts/xsession ~/.xsession
   chmod +x ~/.xsession
   ```

2. Configurar el default file manager a Thunar:
   ```bash
   sudo sed -i 's/inode\/directory=pcmanfm.desktop/inode\/directory=Thunar.desktop/g' /usr/share/applications/defaults.list
   sudo update-mime-database /usr/share/mime
   ```

3. Ejecutar una vez con sudo:
   ```bash
   sudo /home/madkoding/scripts/uchikoma-boot-optimize.sh
   sudo /home/madkoding/scripts/uchikoma-disable-x11vnc.sh
   sudo update-rc.d ondemand enable
   sudo sed -i 's/echo -n ondemand/echo -n powersave/g' /etc/init.d/ondemand
   sudo sysctl -w vm.swappiness=10
   # NOTA: laptop_mode=5 fue revertido por cuelgues; se mantiene en 0
   # sudo sysctl -w vm.laptop_mode=5
   sudo sysctl -w vm.laptop_mode=0
   sudo update-rc.d rsync disable
   sudo update-grub
   sudo apt-get remove --purge -y pcmanfm
   ```

4. Blacklist de módulos que consumen batería:
   ```bash
   printf "blacklist uvcvideo\nblacklist videodev\nblacklist jmb38x_ms\nblacklist memstick\n" | sudo tee /etc/modprobe.d/uchikoma-battery.conf
   sudo chmod 644 /etc/modprobe.d/uchikoma-battery.conf
   ```

5. Desactivar tareas cron periódicas (opcional, ahorra wakeups):
   ```bash
   sudo sh -c 'for f in /etc/cron.daily/* /etc/cron.weekly/* /etc/cron.hourly/* /etc/cron.d/*; do [ -f "$f" ] && chmod -x "$f"; done'
   ```

6. Copiar los blockers de autostart:
   ```bash
   cp ~/scripts/gvfs-media-blocker.desktop ~/.config/autostart/
   rm -f ~/.config/autostart/thunar.desktop
   ```

7. Para ahorrar batería, apagar WiFi cuando no se use:
   ```bash
   ~/scripts/uchikoma-wifi.sh off
   ```
   Encender de nuevo:
   ```bash
   ~/scripts/uchikoma-wifi.sh on
   ```

8. Reiniciar sesión X.

## Advertencias

- `powersave` reduce rendimiento.
- Frecuencia CPU capada a 1066 MHz limita rendimiento.
- USB autosuspend puede añadir latencia al reconectar dispositivos.
- No tocar servicios críticos: `networking`, `ssh`, `dbus`, `cron`, `slim`, `ntp`.
- `console-kit-daemon` se mata por sesión; si alguna app lo necesita, puede fallar.
- `x11vnc` se desactiva del boot; si se necesita, se puede reactivar con `sudo update-rc.d x11vnc enable`.
- `rsync`, `anacron` y `plymouth` se desactivan del boot.
- `ntp` se mantiene habilitado para sincronización de reloj.
- `xfce4-power-manager` y `upowerd` se desactivan; la gestión de energía queda en `xset` y blank de pantalla.
- Thunar se mantiene como daemon porque es el file manager por defecto.
- Las tareas cron diarias/semanales se desactivan; el reloj y mantenimiento manual serán necesarios.
