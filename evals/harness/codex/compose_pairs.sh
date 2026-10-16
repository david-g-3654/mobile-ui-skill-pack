#!/usr/bin/env bash
# Compose Study B pairs (pre-registered seeds) and Claude judge prompts from the v0.3 template.
set -euo pipefail
S=/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/b6c2193f-51c0-46d6-ba75-345d86512b58/scratchpad
REPO=/Users/User/Downloads/Mein/mobile-ui-skill-pack; E=$REPO/evals; V=$S/venv/bin/python
C=$E/results/2026-10-15-react-native-v0.4/harness/compose2.py
T=$E/prompts/flutter-v0.3/judge
# platform  shots(base) shots(pack) pattern seed judgedir
run(){ local plat=$1 b=$2 p=$3 pat=$4 seed=$5 jd=$6
  local R=$E/results/2026-10-16-studyB-$plat
  rm -rf $S/$jd $S/$jd.KEY.json; $V -I $C $S/$jd $b $p $seed "$pat"
  cp $E/rubric.md $S/$jd/rubric.md
  mkdir -p $R/pairs $E/prompts/$plat-codex/judge
  cp $S/$jd/*.png $R/pairs/; cp $S/$jd.KEY.json $R/ab-key.json
  for png in $S/$jd/*.png; do k=$(basename $png .png)
    sed "s#$S/judge_fl3/#$S/$jd/#g" $T/pair-$k.txt > $E/prompts/$plat-codex/judge/pair-$k.txt
  done
  echo "$plat: $(ls $R/pairs | wc -l) pairs"; }
run swiftui      $S/eval_codex/shots/base $S/eval_codex/shots/pack '{id}-{v}' 5021 judge_cx_sw
run react-native $S/rn_eval_shots_codex   $S/rn_eval_shots_codex    'codex_{arm}-{id}-{v}' 5022 judge_cx_rn
run flutter      $S/fl_eval_shots_codex   $S/fl_eval_shots_codex    'codex_{arm}-{id}-{v}' 5023 judge_cx_fl
