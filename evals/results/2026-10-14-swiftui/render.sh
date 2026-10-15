#!/usr/bin/env bash
# render.sh <arm: base|pack>  — build all screens of an arm into one app and screenshot them.
set -uo pipefail
E="$(cd "$(dirname "$0")" && pwd)"; ARM=$1
ASSETS=/Users/User/Downloads/Mein/mobile-ui-skill-pack/skills/mobile-ui-swiftui/assets
IDS="home settings paywall onboarding detail list stats auth"
B=$E/build/$ARM; mkdir -p "$B/App.app" "$E/shots/$ARM"
OK=""
for id in $IDS; do
  f=$E/$ARM/$id/Screen.swift; [ -f "$f" ] || { echo "MISSING $id"; continue; }
  extra=""; [ $ARM = pack ] && extra="$ASSETS/DesignSystem.swift $ASSETS/Components.swift"
  if xcrun --sdk iphonesimulator swiftc -typecheck -target arm64-apple-ios17.0-simulator -swift-version 5 $extra "$f" >/dev/null 2>"$B/$id.err"; then OK="$OK $id"; echo "COMPILES $id"; else echo "FAILS $id"; fi
done
{ echo 'import SwiftUI'; echo '@main struct EvalApp: App { let s = UserDefaults.standard.string(forKey: "screen") ?? ""'
  echo '  var body: some Scene { WindowGroup { switch s {'
  for id in $OK; do echo "    case \"$id\": S_$id()"; done
  echo '    default: Text("missing") } } } }'; } > "$B/App.swift"
files=""; for id in $OK; do cp "$E/$ARM/$id/Screen.swift" "$B/$id.swift"; files="$files $B/$id.swift"; done
extra=""; [ $ARM = pack ] && extra="$ASSETS/DesignSystem.swift $ASSETS/Components.swift"
xcrun --sdk iphonesimulator swiftc -parse-as-library -target arm64-apple-ios17.0-simulator -swift-version 5 -O $extra $files "$B/App.swift" -o "$B/App.app/EvalApp" 2>"$B/build.err" || { echo BUILD_FAILED; tail -20 "$B/build.err"; exit 1; }
sed "s/dev.mobileui.preview/dev.mobileui.eval.$ARM/; s/MobileUIPreview/EvalApp/g" /Users/User/Downloads/Mein/mobile-ui-skill-pack/scripts/ios-preview/Info.plist > "$B/App.app/Info.plist"
codesign -s - --force "$B/App.app" >/dev/null 2>&1; xcrun simctl install booted "$B/App.app"
shot(){ local out="$E/shots/$ARM/$1-$2.png"
  for try in 1 2 3; do
    xcrun simctl launch --terminate-running-process booted dev.mobileui.eval.$ARM -screen $1 >/dev/null; sleep 7
    xcrun simctl io booted screenshot --type=png "$out" >/dev/null 2>&1
    [ "$(/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/b6c2193f-51c0-46d6-ba75-345d86512b58/scratchpad/venv/bin/python -I $E/blank.py "$out")" = ok ] && return
    echo "  retry $1-$2"
  done; echo "  STILL BLANK $1-$2"; }
for id in $OK; do
  xcrun simctl ui booted content_size large
  xcrun simctl ui booted appearance light; shot $id light
  xcrun simctl ui booted appearance dark; shot $id dark
  xcrun simctl ui booted appearance light; xcrun simctl ui booted content_size accessibility-extra-large; shot $id axl
done
xcrun simctl ui booted content_size large; xcrun simctl ui booted appearance light
echo RENDER_DONE $ARM
