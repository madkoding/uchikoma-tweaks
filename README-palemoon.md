# Navegador en Uchikoma

Pale Moon 28.7.1 i686 se instaló como navegador por defecto porque:
- Firefox moderno y Chromium no tienen builds i386.
- Firefox 52 ESR oficial requiere GTK3, que no existe en Natty.
- Pale Moon 28.x todavía usaba GTK2 y tiene build linux-i686.
- Funciona razonablemente en web básica (foros, documentación, páginas estáticas).

Rutas:
- Binario: `~/.local/lib/palemoon/palemoon`
- Wrapper: `~/bin/palemoon`
- Desktop: `/usr/share/applications/palemoon.desktop`
- Default browser: `palemoon.desktop` para http/https/html

Para reinstalar o actualizar, usar `~/scripts/install-palemoon.sh`.
