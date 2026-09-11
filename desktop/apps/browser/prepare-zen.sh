#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-$SCRIPT_DIR/.work/zen}"
ZEN_REF="${ZEN_REF:-dev}"
ZEN_REPO="${ZEN_REPO:-https://github.com/zen-browser/desktop.git}"

rm -rf "$DEST"
mkdir -p "$(dirname "$DEST")"

echo "[MurSchol Browser] Clonando Zen ($ZEN_REF)..."
git clone --depth 1 --branch "$ZEN_REF" "$ZEN_REPO" "$DEST"

cp "$SCRIPT_DIR/murschol-surfer.json" "$DEST/surfer.json"

python3 - "$DEST/package.json" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["name"] = "murschol-browser"
data["description"] = "MurSchol Browser, navegador de estudio basado en Zen y Firefox"
data["repository"] = {
    "type": "git",
    "url": "git+https://github.com/murcafes94/MurSchol.git"
}
data["homepage"] = "https://github.com/murcafes94/MurSchol"
data["bugs"] = {"url": "https://github.com/murcafes94/MurSchol/issues"}
path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
PY

cat > "$DEST/MURSCHOL_UPSTREAM.md" <<EOF
# MurSchol Browser upstream

This working tree was prepared from:

- Repository: $ZEN_REPO
- Ref: $ZEN_REF
- Base engine: Firefox/Gecko through Zen Browser
- MurSchol branding config: desktop/apps/browser/murschol-surfer.json

Do not copy Zen trademarks or branding assets into MurSchol releases.
Keep MPL-2.0 notices for covered source files.
EOF

echo "[MurSchol Browser] Fuente preparada en: $DEST"
echo "Siguiente paso: cd '$DEST' && npm ci && npm run init"
