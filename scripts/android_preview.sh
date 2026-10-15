#!/usr/bin/env bash
# Run the React Native or Flutter templates on a booted Android emulator (or a USB device with
# debugging on) and screenshot every screen in light, dark and the largest font scale.
#
#   scripts/android_preview.sh rn      [output-dir] [app-dir]
#   scripts/android_preview.sh flutter [output-dir] [app-dir]
#
#     output-dir  where screenshots go (default: ./android-previews)
#     app-dir     host app to (re)use; scaffolded if missing (default: $TMPDIR/mobile-ui-<stack>-android)
#
# Release builds (no Expo Go dev button): build the app once with
#   npx expo prebuild --platform android && npx expo run:android --variant release
# then RN_RELEASE_PACKAGE=<android package> RN_SCHEME=<app.json scheme> scripts/android_preview.sh rn …
# opens each template by deep link in that build instead of Expo Go.
#
# Requires: adb on PATH and exactly one device in `adb devices`; for rn, Node and network access the
# first time (create-expo-app, npm, Expo Go); for flutter, the Flutter SDK (`flutter` on PATH or
# $FLUTTER) and an Android SDK (ANDROID_HOME). Port 8081 must be free for rn.
#
# Text size: Android's largest font scale (Settings → Display → Font size) is 2.0, used here. The
# pack's large-text layouts switch on at 1.6, so this exercises them. The script restores light mode
# and font scale 1.0 on exit.
set -euo pipefail
STACK="${1:?usage: android_preview.sh rn|flutter [output-dir] [app-dir]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "${2:-android-previews}" && cd "${2:-android-previews}" && pwd)"
APP="${3:-${TMPDIR:-/tmp}/mobile-ui-$STACK-android}"
FLUTTER="${FLUTTER:-flutter}"

[ "$(adb devices | grep -c -w device)" = 1 ] || { echo "Need exactly one device in 'adb devices'"; exit 1; }
adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = 1 ]; do sleep 2; done

restore() { adb shell cmd uimode night no >/dev/null 2>&1 || true; adb shell settings put system font_scale 1.0 >/dev/null 2>&1 || true; }
trap restore EXIT
snap() { sleep "${2:-3}"; adb exec-out screencap -p > "$OUT/$1.png"; echo "  $OUT/$1.png"; }
light() { adb shell cmd uimode night no >/dev/null; }
dark() { adb shell cmd uimode night yes >/dev/null; }
scale() { adb shell settings put system font_scale "$1"; sleep 3; }  # let the config change settle before launching
# Hide the transient navigation hint and status-bar noise for cleaner captures.
adb shell settings put global policy_control immersive.navigation=* >/dev/null 2>&1 || true

if [ "$STACK" = rn ]; then
  ASSETS="$ROOT/skills/mobile-ui-react-native/assets"
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
  mkdir -p "$APP/app"
  cp "$ASSETS/theme.ts" "$ASSETS/components.tsx" "$APP/"
  cp "$ASSETS/templates/_layout.tsx" "$APP/app/_layout.tsx"
  cp "$ASSETS/templates/HomeScreen.tsx" "$APP/app/index.tsx"
  cp "$ASSETS/templates/SettingsScreen.tsx" "$APP/app/settings.tsx"
  cp "$ASSETS/templates/PaywallScreen.tsx" "$APP/app/paywall.tsx"
  (cd "$APP" && npx tsc --noEmit -p .) && echo "Typecheck OK"

  if [ -n "${RN_RELEASE_PACKAGE:-}" ]; then
    open_route() {
      adb shell am force-stop "$RN_RELEASE_PACKAGE"; adb shell input keyevent KEYCODE_HOME
      local path=""; [ "$1" = home ] || path="$1"
      for _ in 1 2 3; do   # first cold start of a release build can be slow; check it's really in front
        adb shell am start -a android.intent.action.VIEW -d "${RN_SCHEME:?set RN_SCHEME}:///$path" "$RN_RELEASE_PACKAGE" >/dev/null
        sleep 8
        adb shell dumpsys activity activities | grep -m1 topResumedActivity | grep -q "$RN_RELEASE_PACKAGE" && break
      done
      sleep 2
    }
    for route in home settings paywall; do
      light; scale 1.0; open_route "$route"; snap "rn-android-$route-light"
      dark; snap "rn-android-$route-dark" 4
      light; scale 2.0; open_route "$route"; snap "rn-android-$route-axl"
    done
    exit 0
  fi
  adb reverse tcp:$PORT tcp:$PORT >/dev/null
  # One Metro only. When Expo Go is missing, `--android` makes this same Metro install it
  # (a second `expo start` would find the port taken and fail silently).
  ANDROID_FLAG=""
  adb shell pm list packages | grep -q host.exp.exponent || { echo "Installing Expo Go on the device"; ANDROID_FLAG="--android"; }
  (cd "$APP" && CI=1 EXPO_NO_TELEMETRY=1 npx expo start $ANDROID_FLAG --port "$PORT" >"$APP/metro.log" 2>&1) &
  METRO=$!
  trap '{ restore; kill $METRO; wait $METRO; pkill -f "expo start"; } >/dev/null 2>&1 || true' EXIT
  until curl -s "http://localhost:$PORT/status" | grep -q running; do sleep 1; done
  for _ in $(seq 1 60); do adb shell pm list packages | grep -q host.exp.exponent && break; sleep 5; done
  adb shell pm list packages | grep -q host.exp.exponent || { echo "Expo Go did not install; see $APP/metro.log"; exit 1; }
  open_route() {  # cold start so navigation state and font scale are fresh
    adb shell am force-stop host.exp.exponent
    adb shell input keyevent KEYCODE_HOME   # another app left in front would otherwise stay on top
    local path=""; [ "$1" = home ] || path="/--/$1"
    # Expo Go's launcher sometimes swallows the link right after a config change (font scale, dark
    # mode); resend it until the experience activity is actually in front.
    for _ in 1 2 3; do
      adb shell am start -a android.intent.action.VIEW -d "exp://127.0.0.1:$PORT$path" host.exp.exponent >/dev/null
      sleep 8
      adb shell dumpsys activity activities | grep -m1 topResumedActivity | grep -q ExperienceActivity && break
    done
    sleep 17
  }
  for route in home settings paywall; do
    light; scale 1.0; open_route "$route"; snap "rn-android-$route-light"
    dark; snap "rn-android-$route-dark" 4
    light; scale 2.0; open_route "$route"; snap "rn-android-$route-axl"
  done
  echo "Note: Expo Go may show its dev-menu button; it is not part of the UI."

elif [ "$STACK" = flutter ]; then
  ASSETS="$ROOT/skills/mobile-ui-flutter/assets"
  if [ ! -f "$APP/pubspec.yaml" ]; then
    echo "Scaffolding Flutter app in $APP"
    "$FLUTTER" create --org dev.mobileui --project-name mobileui_preview --platforms android "$APP" >/dev/null
  fi
  mkdir -p "$APP/lib/mobile_ui/templates"
  cp "$ASSETS/theme.dart" "$ASSETS/components.dart" "$APP/lib/mobile_ui/"
  cp "$ASSETS"/templates/*.dart "$APP/lib/mobile_ui/templates/"
  cat > "$APP/lib/main.dart" <<'EOF'
// Preview host: shows the template named by --dart-define=SCREEN=home|settings|paywall.
import 'package:flutter/material.dart';
import 'mobile_ui/theme.dart';
import 'mobile_ui/templates/home_screen.dart';
import 'mobile_ui/templates/settings_screen.dart';
import 'mobile_ui/templates/paywall_screen.dart';

void main() {
  const screen = String.fromEnvironment('SCREEN', defaultValue: 'home');
  final Widget home = switch (screen) {
    'settings' => const SettingsScreen(),
    'paywall' => const PaywallScreen(),
    _ => const HomeScreen(),
  };
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    home: home,
  ));
}
EOF
  (cd "$APP" && "$FLUTTER" analyze --suppress-analytics lib) | tail -1
  for route in home settings paywall; do
    (cd "$APP" && "$FLUTTER" build apk --debug --suppress-analytics --dart-define=SCREEN=$route >/dev/null)
    adb install -r "$APP/build/app/outputs/flutter-apk/app-debug.apk" >/dev/null
    launch() { adb shell am force-stop dev.mobileui.mobileui_preview; adb shell input keyevent KEYCODE_HOME; adb shell am start -n dev.mobileui.mobileui_preview/.MainActivity >/dev/null; sleep 8; }
    light; scale 1.0; launch; snap "flutter-android-$route-light"
    dark; snap "flutter-android-$route-dark" 3
    light; scale 2.0; launch; snap "flutter-android-$route-axl"
  done
  adb shell am force-stop dev.mobileui.mobileui_preview
else
  echo "unknown stack: $STACK (use rn or flutter)"; exit 1
fi
