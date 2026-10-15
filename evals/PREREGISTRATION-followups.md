# Pre-registration: two follow-up studies

Written on 2026-10-15, before any screen for either study was generated. They answer two open questions in [`METHOD.md`](METHOD.md) §4:

- **Study A, a generic baseline:** how much of the pack's gain would a one-line "make it look good" instruction get on its own?
- **Study B, a second harness and model:** does the pack help when Codex, running a GPT model, does the building?

## Commitments

1. **Publish whatever the results show:** win, loss or tie, per platform and per judge, including any screen that fails to build or crashes.
2. **No retries.** Each prompt is generated once per arm. If a generation fails to produce a file, that is recorded as a failure, not re-run. If a judge reply can't be parsed, it is re-asked once and the retry is reported.
3. **The pack is frozen at 0.4.1** until both studies are published.
4. **Earlier runs stay in the record unchanged.**

## Study A: pack vs a one-line design instruction (Claude Opus 5.5 builds)

| | |
|---|---|
| New arm, "generic" | The baseline prompt with one sentence added after "…as you normally would.": *"Make it look polished and native, and respect large text sizes."* Nothing else changes except the output path. 8 prompts × 3 platforms, built by Claude Opus 5.5. Prompts: `prompts/<platform>-generic/generate/`. |
| Pack arm | The pack screens judged in the 0.4 run, unchanged. The one exception is the React Native list screen, which crashed on 0.4; the 0.4.1 regeneration is used instead, since 0.4.1 is the version people install. |
| No-instructions arm | The same baseline screens as every earlier run. |
| **A1 (primary): pack vs generic** | 8 prompts × 2 orderings × 3 platforms = 48 judgments per judge. |
| **A2 (secondary): generic vs no instructions** | The same design, 48 judgments per judge. It measures what the one line buys on its own. |
| Seeds | A1: 5001 (SwiftUI), 5002 (React Native), 5003 (Flutter). A2: 5011, 5012, 5013. |

## Study B: Codex with a GPT model, pack vs no pack

| | |
|---|---|
| Builder | Codex CLI 0.139.0 (`codex exec`, workspace-write sandbox, one fresh session per screen) with its default GPT model, signed in to ChatGPT. The model name is taken from Codex's own event log and published. |
| Arms | Without pack and with pack 0.4.1. The prompts are the existing baseline and with-pack prompts, word for word, with only output paths changed. Prompts: `prompts/<platform>-codex/generate/`. |
| Judgments | 8 prompts × 2 orderings × 3 platforms = 48 per judge. |
| Seeds | 5021 (SwiftUI), 5022 (React Native), 5023 (Flutter). |

## Shared protocol (same as 0.4)

- **Rendering:** iPhone 17 / iOS 27 simulator, light, dark and AX-XL. React Native from a release build.
- **Capture checks:** blank frames, duplicate screens, and **a crashed app showing the iOS home screen**, checked by eye on a contact sheet and in the device log. A crash is captured and judged as it is; it is not re-run.
- **Judges:** Claude Opus 5.5 (the same prompt template), GPT-6.1 Sol and Grok 4.7, both via `tools/judge_external.py`, with no retries.
- **Significance:** a prompt counts for an arm only if it wins both orderings, with a one-sided sign test over prompts.

## Input fingerprints (SHA-256, checked with `tools/verify_prereg.py --followups`)

| Input | SHA-256 |
|---|---|
| pack 0.4.1 (every file under skills/) | `d2797ab88672420f39a83b882de732d543d8d9da7d2d26f92959cbef92c067dd` |
| generic-arm generator prompts (24) | `304020242da6e5a841d95bdcf38e4baf0d0e85cd4a4ef3c0c9e4c900ff70d7af` |
| Codex generator prompts (48) | `fb4a25eb9ad30fd438467cdeacbb89ec7fec137d1abf97e09384bc6a1f0efc37` |
| Study B harness (Codex config + runner) | `f42e279d9451f4cbce575aa468da663dd24aa145092dae17943ca3cb9b366b1c` |
| rubric | `5c39dc33967ab36a1bf3f33a9e54cb40d91837079b1157388e02689e611f264b` |
| Claude judge prompt template | `6b419fa46a765f0c5c03e9d69201eaf404bf2ca6f437b301e029e4efbc39366b` |
| external judge script | `6c9cb5d8c30aa5c36afc31b83fc1082d3d8f3f5d20aa8c0b72119057b3910421` |
| scoring script | `13d4408801c95ae47d1baed3e9130c0eaecb515c956a6bbe890c912e220f214d` |

## Correction, committed before any screen was generated

The first version of this file (commit `5e076ee`) contained a path bug in 24 of the 72 generator prompts. In every Flutter prompt (8 generic, 16 Codex), the "Must analyze cleanly" command still pointed at the old file (`lib/eval/base/<id>.dart` or `lib/eval/pack04/<id>.dart`), not the file the agent writes, because the path rewrite only matched paths with a leading slash. An agent following it would have checked the wrong file. Only that one path in those 24 files changed. The fingerprints above are the corrected ones; the originals were generic `3c930be619d427c4afe9f66b9314b8d3953d4fd327bf897105efe9bf97be6809` and Codex `ccefc74f6c89ce340626b59b6e2a8634a393701ae3ccf55a8c61621d0181c353`. No screen for either study existed when this was fixed.

## Amendment: Study B builder, committed before any Study B screen was generated

The planned builder (Codex signed in to ChatGPT, default model) isn't available: the author has no Codex plan. Study B runs as follows instead. Nothing else in Study B changes: same prompts, arms, seeds, judges and scoring.

- **Builder:** Codex CLI 0.139.0 routed through OpenRouter to **`openai/gpt-6.1-sol`**, configured in [`harness/codex/codex-home/config.toml`](harness/codex/codex-home/config.toml) and run by [`harness/codex/run_study_b.sh`](harness/codex/run_study_b.sh). One fresh `codex exec --ephemeral` session per screen, all 48 run once, in the order the script lists them. The author runs the script in their own terminal; the model name and token totals are read from Codex's event logs and published.
- **Sandbox:** `workspace-write`, approvals off. `HOME` points to a folder inside each workspace so that tool caches are writable and so that no skills installed in the author's home folder (`~/.agents`, `~/.codex`) are visible to either arm. `CODEX_HOME` is the config folder above.
- **SwiftUI agents cannot typecheck.** Inside the Codex sandbox, `swiftc -typecheck` fails before reaching the code (the Swift macro plugin server can't start). TypeScript and `flutter analyze` work. SwiftUI agents in both arms are therefore told to typecheck but can't. Every screen on every platform is typechecked afterwards outside the sandbox; a screen that fails is reported as a failure, captured as whatever it renders (or a build failure), and is not fixed or regenerated.
- **Provider failures:** a screen is re-run once, and only once, if its run produced no model output at all (for example an HTTP error before the first reply). Any run with model output stands as it is, including one that wrote no file. Every re-run is listed with its original log.
- **GPT-6.1 Sol is both the builder and one of the three judges.** It judges blind, but it may favour its own style in either arm. Its results are reported next to the other two judges, and the README says so.
- **Shared workspaces:** as in earlier runs, each platform's agents work in the one eval project, so an agent can see screens already written there (earlier Claude screens, and in the with-pack arm the without-pack Codex screens). They are told not to read the evals folder; they are not prevented from reading other screens. Any log showing an agent opening another arm's screen is reported.

