#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Este script necesita privilegios de root para ejecutar live-build."
  echo "Uso: sudo ./desktop/os/live/build-live.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUTPUT_ISO="${SCRIPT_DIR}/MurSchol-OS-0.1-Live-amd64.iso"
OUTPUT_SHA="${OUTPUT_ISO}.sha256"

rm -rf "${WORK_DIR}"
rm -f "${OUTPUT_ISO}" "${OUTPUT_SHA}"
mkdir -p "${WORK_DIR}"
cp -a "${SCRIPT_DIR}/config" "${WORK_DIR}/config"

# El shell se compila dentro del chroot Debian para evitar incompatibilidades
# de glibc/Qt entre el runner y la ISO final.
mkdir -p "${WORK_DIR}/config/includes.chroot/usr/src/murschol-shell"
cp -a "${OS_DIR}/shell/." "${WORK_DIR}/config/includes.chroot/usr/src/murschol-shell/"

cd "${WORK_DIR}"

lb clean --purge || true
lb config \
  --mode debian \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer none \
  --archive-areas "main contrib non-free-firmware" \
  --apt-recommends false \
  --memtest none \
  --iso-application "MurSchol OS 0.1 Live" \
  --iso-publisher "MurSchol" \
  --iso-volume "MURSCHOL_0_1" \
  --bootappend-live "boot=live components username=murschol hostname=murschol locales=es_EC.UTF-8 keyboard-layouts=latam timezone=America/Guayaquil quiet"

lb build

ISO_PATH="$(find . -maxdepth 1 -type f \( -name 'live-image-*.hybrid.iso' -o -name 'live-image-*.iso' \) | head -n 1)"
if [[ -z "${ISO_PATH}" ]]; then
  echo "live-build terminó pero no produjo una ISO reconocible."
  exit 2
fi

mv "${ISO_PATH}" "${OUTPUT_ISO}"
sha256sum "${OUTPUT_ISO}" > "${OUTPUT_SHA}"

printf '\nMurSchol OS Live generado correctamente:\n'
ls -lh "${OUTPUT_ISO}" "${OUTPUT_SHA}"
cat "${OUTPUT_SHA}"
