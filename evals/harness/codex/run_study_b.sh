#!/usr/bin/env bash
# Study B runner: 48 Codex generations (3 platforms x 8 prompts x {without, with} pack 0.4.1).
# Usage (from the repo root, with OPENROUTER_API_KEY exported in YOUR terminal):
#   evals/harness/codex/run_study_b.sh --smoke   # one throwaway request to check the provider works
#   evals/harness/codex/run_study_b.sh           # the 48 pre-registered generations
# Each screen gets one fresh `codex exec` session. A finished screen (logs present) is never re-run.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
S=/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/b6c2193f-51c0-46d6-ba75-345d86512b58/scratchpad
export CODEX_HOME="$REPO/evals/harness/codex/codex-home"
LOG="$S/codex_logs"; mkdir -p "$LOG"
: "${OPENROUTER_API_KEY:?export OPENROUTER_API_KEY in this terminal first}"

run_one() { # name workdir prompt_file
  local name=$1 wd=$2 pf=$3
  if [ -s "$LOG/$name.events.jsonl" ]; then echo "skip $name (already run)"; return; fi
  mkdir -p "$wd/.home"
  # HOME points inside the workspace: tool caches stay writable under the sandbox, and the
  # user's own ~/.agents and ~/.codex skills are invisible to the agent (isolation).
  HOME="$wd/.home" codex exec --skip-git-repo-check --ephemeral -s workspace-write -C "$wd" \
    --json -o "$LOG/$name.last.txt" "$(cat "$pf")" > "$LOG/$name.events.jsonl" 2> "$LOG/$name.stderr"
  echo "$name exit=$?" | tee -a "$LOG/status.txt"
}

if [ "${1:-}" = "--smoke" ]; then
  T="$S/codex_smoke"; mkdir -p "$T/.home"
  HOME="$T/.home" codex exec --skip-git-repo-check --ephemeral -s workspace-write -C "$T" --json \
    -o "$T/last.txt" "Write the word ok into a file named ok.txt in the current directory, then reply done." > "$T/events.jsonl" 2> "$T/stderr"
  echo "exit=$?"; cat "$T/ok.txt" 2>/dev/null; cat "$T/last.txt" 2>/dev/null; tail -3 "$T/stderr"
  exit
fi

P="$REPO/evals/prompts"; IDS="home settings paywall onboarding detail list stats auth"
platform() { # plat workdir
  local plat=$1 wd=$2
  for arm in without-pack with-pack; do for id in $IDS; do
    run_one "$plat-$arm-$id" "$wd" "$P/$plat-codex/generate/$arm-$id.txt"
  done; done
}
platform swiftui "$S/eval_codex" &
platform react-native "$S/rn_eval_app" &
platform flutter "$S/fl_eval" &
wait
echo "ALL DONE: $(grep -c . "$LOG/status.txt") runs logged in $LOG"
# Model and token totals, read from Codex's own event logs (published with the results).
python3 - "$LOG" <<'PY'
import glob, json, sys
models, tok = set(), {}
for f in glob.glob(sys.argv[1] + "/*.events.jsonl"):
    for line in open(f):
        try: e = json.loads(line)
        except ValueError: continue
        if isinstance(e.get("model"), str): models.add(e["model"])
        for k, v in (e.get("usage") or {}).items():
            if isinstance(v, int): tok[k] = tok.get(k, 0) + v
print("models seen:", sorted(models) or "none reported in events")
print("tokens:", tok)
PY
