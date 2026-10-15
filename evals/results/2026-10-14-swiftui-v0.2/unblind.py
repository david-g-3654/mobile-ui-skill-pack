import json, statistics as st, sys
jfile, kfile = sys.argv[1:3]
key = json.load(open(kfile)); J = [json.loads(l) for l in open(jfile)]
crit = ["focal","restraint","typography","spacing","platform_fit","dark_mode","accessibility","content"]
wins = {'pack':0,'base':0,'tie':0}; per = {}; sc = {a:{c:[] for c in crit} for a in ('pack','base')}; ov = {'pack':[], 'base':[]}
for j in J:
    k = key[j['pair']]; w = k[j['preference']] if j['preference'] in ('A','B') else 'tie'
    wins[w] += 1; per.setdefault(j['pair'].split('_')[0], []).append(w)
    for slot in 'AB':
        arm = k[slot]; vals = [j[slot][c] for c in crit]
        for c,v in zip(crit,vals): sc[arm][c].append(v)
        ov[arm].append(sum(vals)/len(vals))
print("wins", wins, "of", len(J), "| A chosen", sum(j['preference']=='A' for j in J))
print("per prompt:", {p: v for p, v in per.items()})
print("mean overall pack %.2f base %.2f" % (st.mean(ov['pack']), st.mean(ov['base'])))
for c in crit: print("  %-13s %.2f / %.2f" % (c, st.mean(sc['pack'][c]), st.mean(sc['base'][c])))
