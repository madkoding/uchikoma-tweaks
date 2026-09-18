#!/bin/bash
# Uchikoma boot optimization - disable non-critical SysV services
# Run once with: sudo -A /home/madkoding/scripts/uchikoma-boot-optimize.sh

set -e

SERVICES_TO_DISABLE="
  bluetooth
  cups
  cups-browsed
  saned
  speech-dispatcher
  avahi-daemon
  avahi-dnsconfd
  nfs-common
  rpcbind
"

for svc in $SERVICES_TO_DISABLE; do
  if [ -f /etc/init.d/$svc ]; then
    update-rc.d $svc disable 2>/dev/null || true
    echo "disabled $svc"
  else
    echo "not found $svc"
  fi
done

echo "=== rc2.d after ==="
ls /etc/rc2.d/
