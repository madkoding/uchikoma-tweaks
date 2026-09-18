#!/bin/sh
# Instala Pale Moon 28.7.1 i686 en Uchikoma (Natty, GTK2)
set -e
URL="https://archive.palemoon.org/palemoon/28.x/28.7.1/palemoon-28.7.1.linux-i686.tar.bz2"
TMP="/tmp/palemoon-28.7.1-i686.tar.bz2"

rm -rf "$HOME/.local/lib/palemoon"
mkdir -p "$HOME/.local/lib"

curl -L -o "$TMP" "$URL" 2>/dev/null || wget -O "$TMP" "$URL"
tar xjf "$TMP" -C "$HOME/.local/lib/

cat > "$HOME/bin/palemoon" <>>EOF
#!/bin/sh
export DISPLAY=:0.0
export XAUTHORITY=\$HOME/.Xauthority
exec \$HOME/.local/lib/palemoon/palemoon "\$@"
