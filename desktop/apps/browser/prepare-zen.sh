#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-$SCRIPT_DIR/.work/zen}"
ZEN_REF="${ZEN_REF:-stable}"
ZEN_REPO="${ZEN_REPO:-https://github.com/zen-browser/desktop.git}"
BRANDING="$SCRIPT_DIR/murschol-surfer.json"

rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"

echo "[MurSchol Browser] Clonando Zen ($ZEN_REF)..."
git clone --depth 1 --branch "$ZEN_REF" "$ZEN_REPO" "$DEST"

UPSTREAM_SHA="$(git -C "$DEST" rev-parse HEAD)"
UPSTREAM_SURFER="$DEST/surfer.json"

python3 - "$UPSTREAM_SURFER" "$BRANDING" <<'PY'
import copy
import json
import pathlib
import sys

surfer_path = pathlib.Path(sys.argv[1])
branding_path = pathlib.Path(sys.argv[2])

upstream = json.loads(surfer_path.read_text())
branding = json.loads(branding_path.read_text())


def deep_merge(base, override):
    result = copy.deepcopy(base)
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = copy.deepcopy(value)
    return result

required_upstream = ["version", "buildOptions", "brands", "license"]
missing = [key for key in required_upstream if key not in upstream]
if missing:
    raise SystemExit(f"Configuración Surfer upstream incompleta: {', '.join(missing)}")

if "release" not in upstream.get("brands", {}):
    raise SystemExit("Zen upstream no contiene la marca release esperada")

release = deep_merge(upstream["brands"]["release"], branding["brands"]["release"])

result = copy.deepcopy(upstream)
result.update({
    "name": branding["name"],
    "vendor": branding["vendor"],
    "appId": branding["appId"],
    "binaryName": branding["binaryName"],
})
result["buildOptions"] = deep_merge(upstream.get("buildOptions", {}), branding.get("buildOptions", {}))
result["brands"] = {"release": release}
result["license"] = deep_merge(upstream.get("license", {}), branding.get("license", {}))

# MurSchol no debe consultar ni anunciar infraestructura de actualización de Zen.
result.pop("updateHostname", None)

surfer_path.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
PY

python3 - "$DEST/package.json" "$DEST/package-lock.json" <<'PY'
import json
import pathlib
import sys

package_path = pathlib.Path(sys.argv[1])
lock_path = pathlib.Path(sys.argv[2])

data = json.loads(package_path.read_text())
data["name"] = "murschol-browser"
data["description"] = "MurSchol Browser, navegador de estudio basado en Zen y Firefox"
data["repository"] = {
    "type": "git",
    "url": "git+https://github.com/murcafes94/MurSchol.git"
}
data["homepage"] = "https://github.com/murcafes94/MurSchol"
data["bugs"] = {"url": "https://github.com/murcafes94/MurSchol/issues"}
package_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")

# Mantener npm ci reproducible después de cambiar el nombre del paquete raíz.
if lock_path.exists():
    lock = json.loads(lock_path.read_text())
    lock["name"] = "murschol-browser"
    root = lock.get("packages", {}).get("")
    if isinstance(root, dict):
        root["name"] = "murschol-browser"
    lock_path.write_text(json.dumps(lock, indent=2, ensure_ascii=False) + "\n")
PY

ENGINE_VERSION="$(python3 - "$DEST/surfer.json" <<'PY'
import json
import pathlib
import sys
print(json.loads(pathlib.Path(sys.argv[1]).read_text())["version"]["version"])
PY
)"

cat > "$DEST/MURSCHOL_UPSTREAM.md" <<EOF
# MurSchol Browser upstream

This working tree was prepared from:

- Repository: $ZEN_REPO
- Ref: $ZEN_REF
- Commit: $UPSTREAM_SHA
- Firefox engine: $ENGINE_VERSION
- Base engine: Firefox/Gecko through Zen Browser
- MurSchol branding overlay: desktop/apps/browser/murschol-surfer.json

The MurSchol preparation layer keeps Zen's engine/build metadata but replaces product identity.
Zen update infrastructure and non-release Zen brands are intentionally removed.
Do not copy Zen trademarks or branding assets into MurSchol releases.
Keep MPL-2.0 notices for covered source files.
EOF

echo "[MurSchol Browser] Fuente preparada en: $DEST"
echo "[MurSchol Browser] Zen commit: $UPSTREAM_SHA"
echo "[MurSchol Browser] Firefox engine: $ENGINE_VERSION"
echo "Siguiente paso: cd '$DEST' && npm ci && npm run init"
