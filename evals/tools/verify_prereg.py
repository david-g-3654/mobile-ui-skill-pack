#!/usr/bin/env python3
"""Re-hash the inputs fingerprinted in evals/PREREGISTRATION-0.4.md and report any that changed.

  python3 evals/tools/verify_prereg.py      (run from the repo root)
"""
import glob, hashlib, os, re, sys

def h(paths):
    m = hashlib.sha256()
    for p in sorted(paths):
        m.update(p.encode()); m.update(open(p, "rb").read())
    return m.hexdigest()

# The judged pack is archived in evals/pack-0.4-judged/ (skills/ itself has moved on to 0.4.1).
# Hash it with the same relative paths ("skills/...") it had when it was fingerprinted.
_root = os.getcwd()
os.chdir("evals/pack-0.4-judged")
_pack = h([p for p in glob.glob("skills/**/*", recursive=True) if os.path.isfile(p)])
os.chdir(_root)
now = {
    "pack 0.4": _pack,
    "rubric": h(["evals/rubric.md"]),
    "generator prompts": h(glob.glob("evals/prompts/*-v0.4/generate/*.txt")),
    "Claude judge prompt template": h(["evals/prompts/flutter-v0.3/judge/pair-home_1.txt"]),
    "external judge script": h(["evals/tools/judge_external.py"]),
    "scoring script": h(["evals/tools/unblind.py"]),
}
doc = open("evals/PREREGISTRATION-0.4.md").read()
ok = True
for name, digest in now.items():
    row = next((l for l in doc.splitlines() if l.startswith("| " + name)), "")
    want = re.search(r"`([0-9a-f]{64})`", row)
    same = bool(want) and want.group(1) == digest
    ok &= same
    print(("unchanged  " if same else "CHANGED    ") + name)
sys.exit(0 if ok else 1)
