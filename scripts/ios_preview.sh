#!/usr/bin/env bash
# Build the SwiftUI templates into a throwaway app, run it on the booted iOS simulator, and
# screenshot every screen in light, dark and accessibility-extra-large text.
#   scripts/ios_preview.sh [output-dir]      (default: ./ios-previews)
# Requires Xcode with an iOS simulator runtime and a booted simulator (xcrun simctl boot <udid>).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="$ROOT/skills/mobile-ui-swiftui/assets"
OUT="$(mkdir -p "${1:-ios-previews}" && cd "${1:-ios-previews}" && pwd)"
BUILD="$(mktemp -d)"
APP="$BUILD/MobileUIPreview.app"
mkdir -p "$APP" && cp "$ROOT/scripts/ios-preview/Info.plist" "$APP/"

xcrun --sdk iphonesimulator swiftc -parse-as-library -target arm64-apple-ios17.0-simulator -swift-version 6 -O \
  "$ASSETS/DesignSystem.swift" "$ASSETS/Components.swift" "$ASSETS"/templates/*.swift \
  "$ROOT/scripts/ios-preview/PreviewApp.swift" -o "$APP/MobileUIPreview"
codesign -s - --force "$APP" >/dev/null
xcrun simctl install booted "$APP"

shot() { # screen name
  xcrun simctl launch --terminate-running-process booted dev.mobileui.preview -screen "$1" >/dev/null
  sleep 2.5
  xcrun simctl io booted screenshot --type=png "$OUT/$2.png" >/dev/null 2>&1
  echo "  $OUT/$2.png"
}

xcrun simctl ui booted content_size large
for mode in light dark; do
  xcrun simctl ui booted appearance "$mode"
  for s in home homeLoading settings paywall; do shot "$s" "${s}-${mode}"; done
done
xcrun simctl ui booted appearance light
xcrun simctl ui booted content_size accessibility-extra-large
for s in home settings paywall; do shot "$s" "${s}-axl"; done
xcrun simctl ui booted content_size large
rm -rf "$BUILD"
