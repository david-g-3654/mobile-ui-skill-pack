"""collect_judgments.py <agents.txt> <out.jsonl>: pull each judge's final JSON reply from its transcript."""
import json, re, sys
T = "/private/tmp/claude-502/-Users-User-Downloads-Mein-mobile-ui-skill-pack/cb000a37-8c92-4e2f-a61b-bc785dd610fb/tasks/%s.output"
def texts(o):
    if isinstance(o, dict):
        if o.get("type") == "text" and isinstance(o.get("text"), str): yield o["text"]
        if o.get("type") == "tool_use" and o.get("name") == "SubagentHandback": yield str(o["input"].get("message", ""))
        for k, v in o.items():
            yield from texts(v)
    elif isinstance(o, list):
        for v in o: yield from texts(v)
out = []
for line in open(sys.argv[1]):
    pair, aid = line.split()
    cands = []
    for l in open(T % aid):
        try: cands += list(texts(json.loads(l)))
        except ValueError: pass
    got = None
    for t in reversed(cands):
        m = re.search(r"\{.*\}", t, re.S)
        if not m: continue
        try: j = json.loads(m.group(0))
        except ValueError: continue
        if "preference" in j and "A" in j: got = j; break
    if not got: print("NO JSON", pair); continue
    out.append(json.dumps({"pair": pair, **got}))
open(sys.argv[2], "w").write("\n".join(out) + "\n")
print(len(out), "judgments")
