#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Este script necesita privilegios de root para ejecutar live-build."
  echo "Uso: sudo ./desktop/os/live/build-live.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${OS_DIR}/../.." && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUTPUT_ISO="${SCRIPT_DIR}/MurSchol-OS-0.1-Live-amd64.iso"
OUTPUT_SHA="${OUTPUT_ISO}.sha256"

rm -rf "${WORK_DIR}"
rm -f "${OUTPUT_ISO}" "${OUTPUT_SHA}"
mkdir -p "${WORK_DIR}"
cp -a "${SCRIPT_DIR}/config" "${WORK_DIR}/config"

# El shell y las apps integradas se compilan dentro del chroot Debian para
# evitar incompatibilidades de glibc/Qt entre el runner y la ISO final.
copy_source() {
  local source="$1"
  local target="$2"
  mkdir -p "${WORK_DIR}/config/includes.chroot/usr/src/${target}"
  cp -a "${source}/." "${WORK_DIR}/config/includes.chroot/usr/src/${target}/"
}

copy_source "${OS_DIR}/shell" "murschol-shell"
copy_source "${REPO_DIR}/desktop/apps/photos" "murschol-photos"
copy_source "${REPO_DIR}/desktop/apps/capture" "murschol-capture"
copy_source "${REPO_DIR}/desktop/apps/settings" "murschol-settings"
copy_source "${REPO_DIR}/desktop/apps/media" "murschol-media"
copy_source "${REPO_DIR}/desktop/apps/music" "murschol-music"
copy_source "${REPO_DIR}/desktop/apps/calculator" "murschol-calculator"
copy_source "${REPO_DIR}/desktop/apps/calendar" "murschol-calendar"
copy_source "${REPO_DIR}/desktop/apps/reader" "murschol-reader"

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
  --bootappend-live "boot=live components username=user hostname=murschol locales=es_EC.UTF-8 keyboard-layouts=latam timezone=America/Guayaquil quiet"

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
