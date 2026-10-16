#!/usr/bin/env bash
set -uo pipefail
S=/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/b6c2193f-51c0-46d6-ba75-345d86512b58/scratchpad
APP=$S/fl_eval/build/ios/iphonesimulator/Runner.app; O=$S/fl_eval_shots_codex; mkdir -p "$O"; V=$S/venv/bin/python
BID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $APP/Info.plist)
xcrun simctl install booted "$APP"
DOCS="$(xcrun simctl get_app_container booted $BID data)/Documents"; mkdir -p "$DOCS"
snap(){ local out="$O/$1.png"
  for t in 1 2 3; do
    xcrun simctl io booted screenshot --type=png "$out" >/dev/null 2>&1
    [ "$($V -I $S/eval/blank.py "$out")" = ok ] && return
    echo "  retry $1"; sleep 5
  done; echo "  STILL BLANK $1"; }
cold(){ xcrun simctl terminate booted $BID >/dev/null 2>&1
  xcrun simctl launch booted $BID >/dev/null; sleep 9; }
for arm in codex_base codex_pack; do for id in home settings paywall onboarding detail list stats auth; do
  k=$arm-$id
  (cd $S/fl_eval && $S/flutter-sdk/bin/flutter build ios --simulator --debug --dart-define=EVAL_SCREEN=$k >/dev/null 2>&1) || echo "  BUILD FAILED $k"
  xcrun simctl install booted "$APP"
  xcrun simctl ui booted appearance light; xcrun simctl ui booted content_size large
  cold $k; snap $k-light
  xcrun simctl ui booted appearance dark; sleep 3; snap $k-dark
  xcrun simctl ui booted appearance light; xcrun simctl ui booted content_size accessibility-extra-large
  cold $k; snap $k-axl
  echo "done $k"
done; done
xcrun simctl ui booted content_size large; xcrun simctl ui booted appearance light

# Guard: every screen must differ (catches a host that ignores the screen key)
echo "distinct light shots: $(md5 -q $O/codex_base-*-light.png $O/codex_pack-*-light.png | sort -u | wc -l | tr -d ' ') / 16"
echo FL_RENDER_DONE
