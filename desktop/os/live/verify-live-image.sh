#!/bin/sh
set -eu

ISO="${1:-}"
if [ -z "$ISO" ] || [ ! -s "$ISO" ]; then
    echo "Uso: $0 /ruta/MurSchol.iso" >&2
    exit 2
fi

for command in xorriso unsquashfs; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Falta $command para verificar la ISO." >&2
        exit 3
    fi
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM
SQUASHFS="$TMP_DIR/filesystem.squashfs"
LISTING="$TMP_DIR/filesystem.list"

# Verifica el sistema que está realmente dentro de la ISO, no solo los archivos
# fuente usados por live-build.
xorriso -osirrox on -indev "$ISO" \
    -extract /live/filesystem.squashfs "$SQUASHFS" >/dev/null 2>&1
[ -s "$SQUASHFS" ]
unsquashfs -ll "$SQUASHFS" > "$LISTING"

require_path() {
    path="$1"
    if ! grep -Fq "squashfs-root${path}" "$LISTING"; then
        echo "Falta en la ISO: $path" >&2
        exit 10
    fi
}

for path in \
    /usr/share/murschol/build-commit \
    /usr/share/murschol/validation/startup.txt \
    /usr/bin/nm-applet \
    /usr/bin/blueman-applet \
    /usr/local/bin/murschol-desktop \
    /usr/local/bin/murschol-panel \
    /usr/local/bin/murschol-files \
    /usr/local/bin/murschol-settings \
    /usr/local/bin/murschol-reader \
    /usr/local/bin/murschol-media \
    /usr/local/bin/murschol-browser \
    /usr/local/bin/murschol-update \
    /usr/local/bin/murschol-session-menu \
    /usr/local/bin/murschol-trash \
    /usr/share/applications/murschol-reader.desktop \
    /usr/share/applications/murschol-session-menu.desktop \
    /usr/share/applications/murschol-trash.desktop \
    /etc/skel/.config/mimeapps.list \
    /etc/skel/.config/labwc/rc.xml \
    /etc/systemd/zram-generator.conf; do
    require_path "$path"
done

OS_RELEASE="$(unsquashfs -cat "$SQUASHFS" etc/os-release 2>/dev/null)"
printf '%s\n' "$OS_RELEASE" | grep -q '^PRETTY_NAME="MurSchol OS 0.1"$'

READER_DESKTOP="$(unsquashfs -cat "$SQUASHFS" usr/share/applications/murschol-reader.desktop 2>/dev/null)"
printf '%s\n' "$READER_DESKTOP" | grep -q '^Name=MurSchol Reader$'
printf '%s\n' "$READER_DESKTOP" | grep -q '^Exec=/usr/local/bin/murschol-reader %f$'
printf '%s\n' "$READER_DESKTOP" | grep -q '^MimeType=application/pdf;$'

MIMEAPPS="$(unsquashfs -cat "$SQUASHFS" etc/skel/.config/mimeapps.list 2>/dev/null)"
printf '%s\n' "$MIMEAPPS" | grep -q '^application/pdf=murschol-reader.desktop;$'
printf '%s\n' "$MIMEAPPS" | grep -q '^application/vnd.openxmlformats-officedocument.wordprocessingml.document=libreoffice-writer.desktop;$'
printf '%s\n' "$MIMEAPPS" | grep -q '^application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=libreoffice-calc.desktop;$'
printf '%s\n' "$MIMEAPPS" | grep -q '^application/vnd.openxmlformats-officedocument.presentationml.presentation=libreoffice-impress.desktop;$'

DPKG_STATUS="$TMP_DIR/dpkg-status"
unsquashfs -cat "$SQUASHFS" var/lib/dpkg/status > "$DPKG_STATUS" 2>/dev/null
for package in \
    network-manager \
    wireplumber \
    bluez \
    udisks2 \
    cups \
    simple-scan \
    calamares \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress; do
    if ! awk -v package="$package" 'BEGIN { RS=""; FS="\n"; found=0 }
      { name=""; status=""; for (i=1; i<=NF; i++) {
          if ($i ~ /^Package: /) name=substr($i,10);
          if ($i ~ /^Status: /) status=substr($i,9);
        }
        if (name == package && status == "install ok installed") found=1;
      }
      END { exit !found }' "$DPKG_STATUS"; then
        echo "Paquete crítico ausente de la ISO: $package" >&2
        exit 11
    fi
done

echo "MurSchol ISO: contenido crítico y asociaciones verificados correctamente."
