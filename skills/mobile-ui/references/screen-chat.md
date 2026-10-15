# Chat (people or AI)

**Job:** read and reply in a conversation. **Focal:** the latest messages. **Primary action:** send (the composer), never a separate big button.

## Anatomy

```
┌─────────────────────────────────┐
│ (‹)  (AO) Amara Okafor    (☏)   │  ← compact bar: avatar 32 + name; ≤2 actions
│            active now           │     (subtitle footnote ink2)
│                                 │
│              Yesterday 18:02    │  ← timestamp separators (footnote ink2, centered)
│ ╭───────────────────────╮       │  ← received: surface/surface2, ink text, left
│ │ Did you sign the lease│       │
│ ╰───────────────────────╯       │
│       ╭─────────────────────╮   │  ← sent: primaryFill or accent, onPrimary, right
│       │ Yes! Sending it now │   │     max width 75%, radius 20, tail optional
│       ╰─────────────────────╯   │     grouped bubbles: 2pt gap, 12pt between turns
│                           Read  │  ← status (footnote ink2), last sent only
│ ┌─────────────────────────────┐ │
│ │ (+) Message…          (↑)  │ │  ← composer: capsule field, send = filled circle
│ └─────────────────────────────┘ │     only when text present; keyboard-aware
└─────────────────────────────────┘
```

## Rules

1. **Bubbles**: radius 20, padding 10×14, body text, max width 75%. Consecutive messages from one sender group with 2pt gaps and only the last bubble gets the tail/avatar.
2. **Sent color** = `primaryFill` (ink) by default, or `accent` if the brand is color-led and contrast passes. Received = `surface` on canvas (light) / `surface2` (dark).
3. **Timestamps** as separators every gap > 1h, not on every bubble.
4. **Composer** grows to 5 lines then scrolls; attachments behind a `+`; send button appears/enables only with content; mic when empty (if voice exists).
5. **AI chat specifics**: assistant messages are *not bubbles* — full-width text on canvas with markdown typography (headings 17 semibold, lists, code blocks in mono on `surface2`), user messages are bubbles. Streaming shows text progressively, not a typing dots bubble for long. Action row under the answer (copy, retry, thumbs) as `ink3` glyphs. Suggested prompts as chips above the composer on an empty chat.
6. **Keyboard**: list inverts/anchors to bottom; dismiss interactively on drag.
7. **Long-press** for reactions/copy/reply via native context menu.

## Budget

1 composer · 1 accent (sent bubble or send button) · ≤2 nav actions.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Blue/grey iMessage clone | Ink/surface bubbles or brand accent; AI answers as full-width text |
| Timestamp under every message | Separators |
| Composer covered by keyboard | Keyboard-avoiding layout |
