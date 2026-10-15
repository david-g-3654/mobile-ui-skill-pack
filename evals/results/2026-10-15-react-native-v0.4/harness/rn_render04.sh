#!/usr/bin/env bash
# Release-build captures for the 0.4 run: base (recaptured) and pack04, selected via -screen launch arg.
set -uo pipefail
S=/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/b6c2193f-51c0-46d6-ba75-345d86512b58/scratchpad
O=$S/rn_eval_shots04; mkdir -p "$O"; V=$S/venv/bin/python; BID=dev.mobileui.evalrn
shot(){ local out="$O/$1-$2.png"
  for t in 1 2 3; do
    xcrun simctl launch --terminate-running-process booted $BID -screen $1 >/dev/null; sleep 8
    xcrun simctl io booted screenshot --type=png "$out" >/dev/null 2>&1
    [ "$($V -I $S/eval/blank.py "$out")" = ok ] && return
    echo "  retry $1-$2"
  done; echo "  STILL BLANK $1-$2"; }
for arm in base pack04; do for id in home settings paywall onboarding detail list stats auth; do
  k=$arm-$id
  xcrun simctl ui booted content_size large
  xcrun simctl ui booted appearance light; shot $k light
  xcrun simctl ui booted appearance dark; shot $k dark
  xcrun simctl ui booted appearance light; xcrun simctl ui booted content_size accessibility-extra-large; shot $k axl
  echo "done $k"
done; done
xcrun simctl ui booted content_size large; xcrun simctl ui booted appearance light
for arm in base pack04; do echo "$arm distinct light: $(md5 -q $O/$arm-*-light.png | sort -u | wc -l | tr -d ' ') / 8"; done
echo RN_RENDER_DONE
