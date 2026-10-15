#!/usr/bin/env bash
# Run the React Native templates in Expo Go on the booted iOS simulator and screenshot every
# screen in light, dark and accessibility-extra-large text.
#
#   scripts/rn_preview.sh [output-dir] [app-dir]
#     output-dir  where screenshots go (default: ./rn-previews)
#     app-dir     Expo app to (re)use; scaffolded with create-expo-app if missing
#                 (default: $TMPDIR/mobile-ui-rn-preview)
#
# Requires Node, Xcode with an iOS simulator runtime, a booted simulator, and network access the
# first time (create-expo-app, npm, Expo Go). Port 8081 must be free.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/skills/mobile-ui-react-native/assets"
OUT="$(mkdir -p "${1:-rn-previews}" && cd "${1:-rn-previews}" && pwd)"
APP="${2:-${TMPDIR:-/tmp}/mobile-ui-rn-preview}"
PORT=8081

if [ ! -f "$APP/package.json" ]; then
  echo "Scaffolding Expo app in $APP"
  mkdir -p "$(dirname "$APP")"
  CI=1 npx --yes create-expo-app@latest "$APP" --template blank-typescript --no-install >/dev/null
  (cd "$APP" && npm install --silent --no-audit --no-fund >/dev/null \
    && npx expo install expo-router react-native-safe-area-context react-native-screens expo-linking \
       expo-constants expo-haptics @expo/vector-icons >/dev/null)
  rm -f "$APP/index.ts" "$APP/App.tsx"
  node -e '
    const fs = require("fs"), dir = process.argv[1];
    const p = JSON.parse(fs.readFileSync(dir + "/package.json")); p.main = "expo-router/entry";
    fs.writeFileSync(dir + "/package.json", JSON.stringify(p, null, 2));
    const a = JSON.parse(fs.readFileSync(dir + "/app.json"));
    a.expo.scheme = "mobileuipreview"; a.expo.userInterfaceStyle = "automatic";
    fs.writeFileSync(dir + "/app.json", JSON.stringify(a, null, 2));
  ' "$APP"
fi

# Install the pack's files exactly as shipped.
mkdir -p "$APP/app"
cp "$ASSETS/theme.ts" "$ASSETS/components.tsx" "$APP/"
cp "$ASSETS/templates/_layout.tsx" "$APP/app/_layout.tsx"
cp "$ASSETS/templates/HomeScreen.tsx" "$APP/app/index.tsx"
cp "$ASSETS/templates/SettingsScreen.tsx" "$APP/app/settings.tsx"
cp "$ASSETS/templates/PaywallScreen.tsx" "$APP/app/paywall.tsx"
(cd "$APP" && npx tsc --noEmit -p .) && echo "Typecheck OK"

# Metro in the background; stop it on exit.
(cd "$APP" && CI=1 EXPO_NO_TELEMETRY=1 npx expo start --port "$PORT" >"$APP/metro.log" 2>&1) &
METRO=$!
trap '{ kill $METRO; wait $METRO; pkill -f "expo start --port $PORT"; } >/dev/null 2>&1 || true' EXIT
until curl -s "http://localhost:$PORT/status" | grep -q running; do sleep 1; done

# First launch installs Expo Go if needed.
if ! xcrun simctl listapps booted 2>/dev/null | grep -q host.exp.Exponent; then
  (cd "$APP" && CI=1 npx expo start --ios --port "$PORT" >/dev/null 2>&1 &) ; sleep 60
fi

snap() { sleep 4; xcrun simctl io booted screenshot --type=png "$OUT/$1.png" >/dev/null 2>&1; echo "  $OUT/$1.png"; }
open_route() { # cold start so navigation state and text size are fresh
  xcrun simctl terminate booted host.exp.Exponent >/dev/null 2>&1 || true
  local path=""; [ "$1" = home ] || path="/--/$1"
  xcrun simctl openurl booted "exp://127.0.0.1:$PORT$path"
  sleep 30
}
for route in home settings paywall; do
  xcrun simctl ui booted appearance light
  xcrun simctl ui booted content_size large
  open_route "$route"
  snap "$route-light"
  xcrun simctl ui booted appearance dark; snap "$route-dark"    # appearance switches cleanly live
  xcrun simctl ui booted appearance light
  # A live text-size change re-lays out over several seconds in RN; relaunch instead.
  xcrun simctl ui booted content_size accessibility-extra-large
  open_route "$route"
  snap "$route-axl"
done
xcrun simctl ui booted content_size large
echo "Note: Expo Go's dev-menu button appears top-right in every capture; it is not part of the UI. For clean screenshots use a release build: see evals/harness/react-native-release/README.md."
