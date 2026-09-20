#!/bin/sh
# Instala Pale Moon 28.7.1 i686 en Uchikoma (Natty, GTK2)
set -e
URL="https://archive.palemoon.org/palemoon/28.x/28.7.1/palemoon-28.7.1.linux-i686.tar.bz2"
TMP="/tmp/palemoon-28.7.1-i686.tar.bz2"

rm -rf "$HOME/.local/lib/palemoon"
mkdir -p "$HOME/.local/lib"

curl -L -o "$TMP" "$URL" 2>/dev/null || wget -O "$TMP" "$URL"
tar xjf "$TMP" -C "$HOME/.local/lib/"

cat > "$HOME/bin/palemoon" <<'EOF'
#!/bin/sh
export DISPLAY=:0.0
export XAUTHORITY=$HOME/.Xauthority
exec $HOME/.local/lib/palemoon/palemoon "$@"
EOF
chmod +x "$HOME/bin/palemoon"

# desktop file
sudo tee /usr/share/applications/palemoon.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Pale Moon
Comment=Web browser
Exec=$HOME/bin/palemoon %u
Icon=$HOME/.local/lib/palemoon/icons/mozicon128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler=http;x-scheme-handler=https;
StartupNotify=true
EOF

# default browser
sudo sed -i 's/^x-scheme-handler\/http=.*/x-scheme-handler\/http=palemoon.desktop/' /usr/share/applications/defaults.list
sudo sed -i 's/^x-scheme-handler\/https=.*/x-scheme-handler\/https=palemoon.desktop/' /usr/share/applications/defaults.list
sudo sed -i 's/^text\/html=.*/text\/html=palemoon.desktop/' /usr/share/applications/defaults.list
sudo update-mime-database /usr/share/mime 2>/dev/null || true

echo "Pale Moon instalado: $HOME/bin/palemoon"
