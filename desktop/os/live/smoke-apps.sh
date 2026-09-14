#!/bin/sh
# Run installed Qt applications against a real, headless Wayland compositor.
# This checks startup/QML loading, not hardware or interactive operations.
set -eu
TEST_DIR="$(mktemp -d /tmp/murschol-smoke.XXXXXX)"
REPORT_DIR=/usr/share/murschol/validation
mkdir -p "$TEST_DIR/config" "$TEST_DIR/runtime" "$TEST_DIR/data" "$TEST_DIR/cache" "$REPORT_DIR"
chmod 700 "$TEST_DIR/runtime"
trap 'rm -rf "$TEST_DIR"' EXIT HUP INT TERM
: > "$TEST_DIR/config/autostart"
export XDG_RUNTIME_DIR="$TEST_DIR/runtime"
export XDG_CONFIG_HOME="$TEST_DIR/config"
export XDG_DATA_HOME="$TEST_DIR/data"
export XDG_CACHE_HOME="$TEST_DIR/cache"
export MURSCHOL_SMOKE_DIR="$TEST_DIR"
export LC_ALL=C.UTF-8
export WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1
export QT_QPA_PLATFORM=wayland QT_QUICK_BACKEND=software
export XDG_CURRENT_DESKTOP=MurSchol XDG_SESSION_TYPE=wayland
unset DISPLAY WAYLAND_DISPLAY MURSCHOL_EXTERNAL_PANEL
cat > "$TEST_DIR/run" <<'EOF'
#!/bin/sh
set -eu
failed=0
for binary in \
  /usr/local/bin/murschol-desktop \
  /usr/local/bin/murschol-panel \
  /usr/local/bin/murschol-files \
  /usr/local/lib/murschol/murschol-settings-bin \
  /usr/local/lib/murschol/murschol-photos-bin \
  /usr/local/bin/murschol-capture \
  /usr/local/bin/murschol-reader \
  /usr/local/bin/murschol-media \
  /usr/local/bin/murschol-music \
  /usr/local/bin/murschol-calculator \
  /usr/local/bin/murschol-calendar; do
  name="$(basename "$binary")"
  log="$MURSCHOL_SMOKE_DIR/$name.log"
  result=0
  timeout --kill-after=2 6 "$binary" > "$log" 2>&1 || result=$?
  if [ "$result" -ne 124 ] || grep -Eq \
    'QQmlApplicationEngine failed|ReferenceError:|TypeError:|module .* is not installed|Cannot load library|error while loading shared libraries' "$log"; then
    echo "FAIL $name (exit=$result)"
    cat "$log"
    failed=1
  else
    echo "PASS $name: Wayland startup survived 6 seconds"
  fi
done
echo "$failed" > "$MURSCHOL_SMOKE_DIR/result"
labwc --exit
EOF
chmod 700 "$TEST_DIR/run"
result=0
timeout --kill-after=5 110 dbus-run-session -- \
  labwc --config-dir "$TEST_DIR/config" --startup "$TEST_DIR/run" \
  > "$TEST_DIR/session.log" 2>&1 || result=$?
cat "$TEST_DIR/session.log"
cp "$TEST_DIR/"*.log "$REPORT_DIR/"
if [ "$result" -ne 0 ] || [ "$(cat "$TEST_DIR/result" 2>/dev/null || echo 1)" -ne 0 ]; then
  echo "MurSchol: failed headless Wayland startup checks" >&2
  exit 1
fi
printf '%s\n' "PASS: 11 Qt applications started on headless labwc." \
  "Not tested: physical hardware, installation, suspend/resume, interactive actions." \
  > "$REPORT_DIR/startup.txt"
