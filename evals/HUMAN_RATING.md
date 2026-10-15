# Human rating protocol

The model-judged results in `results/` need a human check before anyone quotes them as "designers prefer…". This is the protocol for 2–3 designers rating the same blind pairs.

## What raters see

A review page shows 24 pairs: 8 prompts × 3 platforms (SwiftUI 0.2, React Native, Flutter 0.3). Each image is the same blind composite the model judges saw: row A over row B, with light, dark and largest-text columns. Raters answer one question per pair: **"Which one looks like a designer worked on it?"** The choices are A, B or can't tell, with an optional confidence and an optional sentence.

- **Blind:** the page doesn't contain the answer key. Which ordering of a prompt a rater sees (A on top or B on top) and the order of the 24 pairs are both seeded from the rater's account id. That makes them stable across reloads and different for each rater.
- **Private:** each rater can read and write only their own answers. Only the page owner can read the collection.
- **No priming:** the page never mentions a skill pack, AI, or which side is "new".

## Running it

1. Pick 2–3 people who design or build mobile apps for a living, and who haven't seen this repo or the gallery images.
2. Share the review page with each of them **by email**, as **Editor** if they're outside your organization, or as **Contributor** if they're inside it. Don't share it by public link. People at view level can't save answers, and a public link limits outside raters to view.
3. Ask them to do it in one sitting, on a laptop or larger screen, without discussing it with each other. It takes about 10–15 minutes.
4. Export the answers (each rater's doc in the page's `ratings` collection, saved as JSON files) and run:

```bash
python3 evals/tools/tally_human.py path/to/exported/ratings
```

The script maps every pick back to an arm through the same `ab-key.json` files the model judges used. It prints results per rater, per platform and per prompt, plus a sign test.

## Reporting

Report human results next to the model results without averaging them together. Give the raters' roles and years of experience, how many votes each platform got, every prompt where the humans preferred the version without the pack, and how often raters answered "can't tell". With 2–3 raters this is a sanity check on the model judges, not a study. If humans disagree with the model judges, say so in the README.
