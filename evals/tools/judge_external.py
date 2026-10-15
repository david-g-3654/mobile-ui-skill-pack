#!/usr/bin/env python3
"""Re-judge an eval run with a model from a different family than the one that generated the screens.

The published runs were generated AND judged by Claude models. This script sends the exact same
blind pair images, user prompt, rubric and output schema to another provider, writes judgments in
the same JSONL format, and `unblind.py` scores them. Python 3 standard library only.

  # OpenAI (or any OpenAI-compatible endpoint, e.g. OpenRouter, via --base-url)
  OPENAI_API_KEY=... python3 evals/tools/judge_external.py --run evals/results/2026-10-14-react-native \
      --provider openai --model <vision-model-id> --out judgments.openai.jsonl

  # Google Gemini
  GEMINI_API_KEY=... python3 evals/tools/judge_external.py --run evals/results/2026-10-14-flutter \
      --provider gemini --model <vision-model-id> --out judgments.gemini.jsonl

  python3 evals/tools/unblind.py judgments.openai.jsonl evals/results/2026-10-14-react-native/ab-key.json

  # All published runs in one go (80 images); writes <out-dir>/<run>.jsonl and prints each run's tally
  OPENAI_API_KEY=... python3 evals/tools/judge_external.py --all --provider openai --model <id> --out-dir judged-openai

  # OpenRouter (one key, any model family)
  OPENROUTER_API_KEY=... python3 evals/tools/judge_external.py --all --provider openrouter --model google/<model> --out-dir judged-gemini

  # Check everything (files, prompt, request size) without a key or any network call
  python3 evals/tools/judge_external.py --all --provider openai --model any --out-dir /tmp/x --dry-run

The model never sees ab-key.json. Use a model id your account has access to; the script does not
pick one for you. Cost: one request per pair image (one image of ~1.5k×1.9k px plus ~1.5k tokens of
text), so 80 requests for --all; at typical vision-model prices that is a few US dollars at most.
Interrupted runs resume: pairs already in the output file are skipped.
"""
import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
EVALS = os.path.dirname(HERE)

USER_PROMPTS = {
    "home": "Build the home screen for a personal budgeting app.",
    "settings": "Add a settings screen with notifications, appearance, subscription and account options.",
    "paywall": "Create a paywall for our journaling app with monthly and yearly plans.",
    "onboarding": "Make a welcome/onboarding screen for an AI voice notes app.",
    "detail": "Product detail page for a sneaker store.",
    "list": "Transactions list for a banking app.",
    "stats": "Weekly running stats screen.",
    "auth": "Sign-in screen with Apple, Google and email.",
}

# Same instructions the Claude judges received (see evals/prompts/*/judge/), minus local file paths:
# the image and rubric are attached instead of opened from disk.
JUDGE = """You are a senior mobile product designer judging two iOS screen implementations. Be critical and specific.

A user asked: "{request}"
Two different implementations (A and B) were built and run on an iPhone simulator.

The attached image: top row = implementation A, bottom row = implementation B. Columns, left to right: light mode, dark mode, light mode at the largest accessibility text size (AX-XL). Ignore simulator artifacts such as a developer-tools gear button or a "◀ AppName" status-bar back label.

The rubric:
---
{rubric}
---

Score each implementation 1–5 on every rubric criterion that is visible in the screenshots (for "States", score only if empty/loading/error states are visible; otherwise null). Use zoom-level scrutiny: hierarchy, restraint, typography, spacing, platform fit, dark mode, behavior at AX-XL, content realism.

Reply with ONLY a JSON object, no prose before or after:
{{"A": {{"focal": n, "restraint": n, "typography": n, "spacing": n, "platform_fit": n, "dark_mode": n, "accessibility": n, "content": n, "states": n_or_null}},
 "B": {{...same keys...}},
 "preference": "A" | "B" | "tie",
 "confidence": "low" | "medium" | "high",
 "reason": "<= 60 words: the decisive differences"}}"""


def post(url, headers, body):
    req = urllib.request.Request(url, data=json.dumps(body).encode(), headers={"Content-Type": "application/json", **headers})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:  # show the provider's explanation, never the request (it holds the key)
        detail = e.read().decode("utf-8", "replace")[:800]
        sys.exit("HTTP %d from %s\n%s\nRe-run the same command after fixing it; finished pairs are kept." % (e.code, url.split("?")[0], detail))


def ask_openai(model, base_url, text, png_b64, key_env="OPENAI_API_KEY"):
    key = os.environ.get(key_env) or sys.exit("Set " + key_env)
    out = post(base_url.rstrip("/") + "/chat/completions", {"Authorization": "Bearer " + key}, {
        "model": model,
        "messages": [{"role": "user", "content": [
            {"type": "text", "text": text},
            {"type": "image_url", "image_url": {"url": "data:image/png;base64," + png_b64}},
        ]}],
    })
    return out["choices"][0]["message"]["content"]


def ask_gemini(model, text, png_b64):
    key = os.environ.get("GEMINI_API_KEY") or sys.exit("Set GEMINI_API_KEY")
    url = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent" % model
    out = post(url, {"x-goog-api-key": key}, {
        "contents": [{"parts": [{"text": text}, {"inline_data": {"mime_type": "image/png", "data": png_b64}}]}],
    })
    return "".join(p.get("text", "") for p in out["candidates"][0]["content"]["parts"])


def parse(reply):
    m = re.search(r"\{.*\}", reply, re.S)
    if not m:
        raise ValueError("no JSON object in reply: %r" % reply[:200])
    return json.loads(m.group(0))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--run", action="append", default=[], help="results directory containing pairs/ and ab-key.json (repeatable)")
    ap.add_argument("--all", action="store_true", help="every run in evals/results/ that has pairs/ and ab-key.json")
    ap.add_argument("--out-dir", help="with several runs: write <out-dir>/<run name>.jsonl")
    ap.add_argument("--dry-run", action="store_true", help="build every request but send nothing")
    ap.add_argument("--provider", required=True, choices=["openai", "gemini", "openrouter"],
                    help="openrouter = OpenAI-compatible API at openrouter.ai with OPENROUTER_API_KEY (any family, e.g. openai/…, google/…)")
    ap.add_argument("--model", required=True)
    ap.add_argument("--base-url", default="https://api.openai.com/v1", help="OpenAI-compatible endpoint")
    ap.add_argument("--out", help="output JSONL (single run)")
    a = ap.parse_args()

    runs = list(a.run)
    if a.all:
        base = os.path.join(EVALS, "results")
        runs += [os.path.join(base, d) for d in sorted(os.listdir(base))
                 if os.path.isdir(os.path.join(base, d, "pairs")) and os.path.exists(os.path.join(base, d, "ab-key.json"))]
    if not runs:
        sys.exit("give --run <dir> (repeatable) or --all")
    if len(runs) > 1 and not a.out_dir:
        sys.exit("several runs: give --out-dir")
    rubric = open(os.path.join(EVALS, "rubric.md")).read()
    total = sum(len([f for f in os.listdir(os.path.join(r, "pairs")) if f.endswith(".png")]) for r in runs)
    print("%d run(s), %d pair images, provider %s, model %s%s" % (len(runs), total, a.provider, a.model, " (dry run)" if a.dry_run else ""))
    for run in runs:
        out = a.out if (a.out and len(runs) == 1) else os.path.join(a.out_dir, os.path.basename(run.rstrip("/")) + ".jsonl")
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        judge_run(a, run, out, rubric)
        if not a.dry_run:
            print("--", os.path.basename(run.rstrip("/")))
            os.system("python3 %s %s %s" % (os.path.join(HERE, "unblind.py"), out, os.path.join(run, "ab-key.json")))


def judge_run(a, run, out, rubric):
    pairs = sorted(f for f in os.listdir(os.path.join(run, "pairs")) if f.endswith(".png"))
    done = set()
    if os.path.exists(out):
        done = {json.loads(l)["pair"] for l in open(out) if l.strip()}
    with open(out, "a") as fh:
        for f in pairs:
            pair = f[:-4]
            if pair in done:
                continue
            prompt_id = pair.rsplit("_", 1)[0]
            text = JUDGE.format(request=USER_PROMPTS[prompt_id], rubric=rubric)
            png = base64.b64encode(open(os.path.join(run, "pairs", f), "rb").read()).decode()
            if a.dry_run:
                print("  would send %-16s %6.0f KB image + %5d chars text" % (pair, len(png) * 3 / 4 / 1024, len(text)))
                continue
            if a.provider == "gemini":
                reply = ask_gemini(a.model, text, png)
            elif a.provider == "openrouter":
                reply = ask_openai(a.model, "https://openrouter.ai/api/v1", text, png, key_env="OPENROUTER_API_KEY")
            else:
                reply = ask_openai(a.model, a.base_url, text, png)
            j = parse(reply)
            j["pair"] = pair
            j["judge"] = "%s:%s" % (a.provider, a.model)
            fh.write(json.dumps(j) + "\n"); fh.flush()
            print(pair, j.get("preference"), j.get("confidence"))


if __name__ == "__main__":
    main()
