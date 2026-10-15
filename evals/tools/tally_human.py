#!/usr/bin/env python3
"""Unblind and tally human ratings from the Screen Pair Review page.

  python3 evals/tools/tally_human.py <ratings_dir>

<ratings_dir> holds one JSON file per rater, as exported from the page's database
(`ratings/<rater-id>.json`, each {"profile": {...}, "votes": {"<platform>/<prompt>": {"pick", "file", ...}}}).
Each vote records which image the rater saw (`file`, e.g. "pairs/flutter/home_2.jpg"); that file's
A/B assignment comes from the same ab-key.json the model judges used. Python 3 standard library only.
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(os.path.dirname(HERE), "results")
KEYS = {  # the runs whose blind pairs the review page shows
    "swiftui": "2026-10-14-swiftui-v0.2",
    "react-native": "2026-10-14-react-native",
    "flutter": "2026-10-14-flutter-v0.3",
}


def sign_test(wins, losses):
    n = wins + losses
    return sum(math.comb(n, i) for i in range(wins, n + 1)) / 2 ** n if n else 1.0


def main(ratings_dir):
    keys = {p: json.load(open(os.path.join(RESULTS, run, "ab-key.json"))) for p, run in KEYS.items()}
    per_platform = collections.defaultdict(collections.Counter)
    per_rater = {}
    per_prompt = collections.defaultdict(collections.Counter)  # (platform, prompt) -> arm counts
    confidence = collections.Counter()
    for name in sorted(os.listdir(ratings_dir)):
        if not name.endswith(".json"):
            continue
        doc = json.load(open(os.path.join(ratings_dir, name)))
        doc = doc.get("data", doc)  # accept raw docs or {"id","data",...} exports
        tally = collections.Counter()
        for key, v in (doc.get("votes") or {}).items():
            platform, prompt = key.split("/")
            pair = os.path.basename(v["file"]).rsplit(".", 1)[0]  # e.g. home_2
            arm = "tie" if v.get("pick") == "tie" else keys[platform][pair][v["pick"]]
            per_platform[platform][arm] += 1
            per_prompt[(platform, prompt)][arm] += 1
            tally[arm] += 1
            if arm != "tie":
                confidence[(arm, v.get("confidence", "unrated"))] += 1
        per_rater[name[:-5]] = (doc.get("profile", {}), tally)

    print("Raters: %d" % len(per_rater))
    for rid, (profile, t) in per_rater.items():
        print("  %s  role=%s years=%s  pack %d · base %d · can't tell %d"
              % (rid[:10], profile.get("role", "?"), profile.get("years", "?"), t["pack"], t["base"], t["tie"]))
    print("\nPer platform (all raters):")
    total = collections.Counter()
    for platform in KEYS:
        t = per_platform[platform]; total.update(t)
        print("  %-13s pack %3d · base %3d · can't tell %3d   sign test p = %.4f"
              % (platform, t["pack"], t["base"], t["tie"], sign_test(t["pack"], t["base"])))
    print("  %-13s pack %3d · base %3d · can't tell %3d   sign test p = %.4f"
          % ("all", total["pack"], total["base"], total["tie"], sign_test(total["pack"], total["base"])))
    print("  (votes from one rater are not independent across prompts; treat p as indicative)")
    print("\nPrompts where raters preferred the version without the pack:")
    for (platform, prompt), t in sorted(per_prompt.items()):
        if t["base"] > t["pack"]:
            print("  %s / %s: pack %d · base %d · can't tell %d" % (platform, prompt, t["pack"], t["base"], t["tie"]))
    print("\nConfidence of decided votes:", dict(confidence))


if __name__ == "__main__":
    main(sys.argv[1])
