"""unblind.py <judgments.jsonl> <ab-key.json>

Maps blind A/B verdicts back to arms and prints wins, per-prompt results, mean scores and a
prompt-level sign test. Judgments of the same prompt (two orderings) are not independent, so the
significance test counts prompts, not judgments: a prompt counts for an arm only if that arm won
both orderings."""
import json, math, statistics as st, sys

jfile, kfile = sys.argv[1:3]
key = json.load(open(kfile)); J = [json.loads(l) for l in open(jfile)]
crit = ["focal", "restraint", "typography", "spacing", "platform_fit", "dark_mode", "accessibility", "content"]
wins = {'pack': 0, 'base': 0, 'tie': 0}; per = {}; sc = {a: {c: [] for c in crit} for a in ('pack', 'base')}; ov = {'pack': [], 'base': []}
for j in J:
    k = key[j['pair']]; w = k[j['preference']] if j['preference'] in ('A', 'B') else 'tie'
    wins[w] += 1; per.setdefault(j['pair'].rsplit('_', 1)[0], []).append(w)
    for slot in 'AB':
        arm = k[slot]; vals = [j[slot][c] for c in crit]
        for c, v in zip(crit, vals): sc[arm][c].append(v)
        ov[arm].append(sum(vals) / len(vals))
n_prompts = len(per)
pack_prompts = sum(1 for v in per.values() if all(x == 'pack' for x in v))
base_prompts = sum(1 for v in per.values() if all(x == 'base' for x in v))
split = n_prompts - pack_prompts - base_prompts
decided = pack_prompts + base_prompts
# one-sided exact binomial sign test over decided prompts, H0: p = 0.5
p = sum(math.comb(decided, i) for i in range(pack_prompts, decided + 1)) / 2 ** decided if decided else 1.0
print("judgments: %d (%d prompts x 2 orderings) | pack %d, base %d, tie %d | position A chosen %d"
      % (len(J), n_prompts, wins['pack'], wins['base'], wins['tie'], sum(j['preference'] == 'A' for j in J)))
print("prompts won in both orderings: pack %d, base %d, split %d | one-sided sign test p = %.4f" % (pack_prompts, base_prompts, split, p))
print("per prompt:", per)
print("mean overall (1-5): pack %.2f base %.2f" % (st.mean(ov['pack']), st.mean(ov['base'])))
for c in crit: print("  %-13s %.2f / %.2f" % (c, st.mean(sc['pack'][c]), st.mean(sc['base'][c])))
