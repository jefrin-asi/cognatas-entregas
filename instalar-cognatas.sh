#!/usr/bin/env bash
# Actualiza el sistema de Cognata's desde este repositorio:
#   git clone https://github.com/jefrin-asi/cognatas-entregas.git && cd cognatas-entregas && bash instalar-cognatas.sh <clave>
# El paquete (paquete.enc) va cifrado; la clave se escribe en el comando, no está en el repositorio.
# Solo pide la clave de sudo de esta PC. No usa ninguna cuenta de GitHub.
set -euo pipefail
cd "$(dirname "$0")"
CLAVE="${1:-}"; [ -n "$CLAVE" ] || { echo "Falta la clave del paquete:  bash instalar-cognatas.sh <clave>" >&2; exit 1; }
HUELLA="255485cdada472a3e5f85b6b574c4c70f3dd383b15affb1bfdadeeadf5d7e4ff"   # SHA-256 del paquete descifrado
DIR="$HOME/entrega"
paso() { printf '\n== %s\n' "$*"; }
falla() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
command -v openssl >/dev/null || falla "Falta openssl: sudo apt install -y openssl"
paso "Descifrando y verificando el paquete"
rm -rf "$DIR"; mkdir -p "$DIR"
openssl enc -d -aes-256-cbc -pbkdf2 -in paquete.enc -out "$DIR/paquete.tar.gz" -pass "pass:$CLAVE" || falla "Clave incorrecta o archivo dañado."
[ "$(sha256sum "$DIR/paquete.tar.gz" | cut -d' ' -f1)" = "$HUELLA" ] || falla "La huella no coincide: el archivo está dañado. Repita 'git pull'."
cd "$DIR" && tar -xzf paquete.tar.gz 2>/dev/null || true   # los avisos «com.apple.provenance» son normales
[ -f actualizar.sh ] || falla "El paquete no trae actualizar.sh."
chmod +x ./*.sh cognatas-escpos
paso "Actualizando el sistema (pide la clave de esta PC)"
sudo ./actualizar.sh
paso "Instalando el filtro de la impresora"
sudo ./instalar-impresora.sh
printf '\nListo. Cierre y abra «Cognatas Caja» y haga una venta de prueba.\n'
