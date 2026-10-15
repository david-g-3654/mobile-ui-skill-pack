# Sheet / dialog / action menu

**Job:** a quick decision or task without losing context. **Focal:** the sheet title or the first action. **Primary action:** ≤1.

## Choose the container

| Need | Use |
|---|---|
| Confirm a destructive or irreversible action | **System alert / confirmation dialog** (iOS `confirmationDialog`/`.alert`, M3 `AlertDialog`) |
| Choose one of ≤6 actions on an item | **Context menu** (long-press) or **action sheet** |
| A quick task with a few controls (filters, share, add tag, pick time) | **Bottom sheet** with detents (medium → large) |
| A separate mode (compose, camera, editor, onboarding) | **Full-screen modal** |
| Transient feedback | **Toast**, not a dialog |

## Bottom sheet anatomy

```
│           ───────               │  ← grabber (system)
│ Filters                  Reset  │  ← title (title style) + tertiary action
│                                 │
│ SORT BY                         │
│ (Recommended)(Nearest)(Rating)  │  ← chips / rows / native controls
│ PRICE                           │
│ ($) ($$) ($$$)                  │
│ Open now                    ◉   │  ← toggle row
│ [      Show 48 places      ]    │  ← one primary: label reflects result
```

## Action sheet anatomy

```
│ ┌─────────────────────────────┐ │  ← grouped rows, glyph + label
│ │ ⤴  Share post               │ │
│ │ ⧉  Copy link                │ │
│ │ ⚑  Report post              │ │  ← destructive in negative, last
│ └─────────────────────────────┘ │
│ [           Cancel           ]  │  ← separate group (iOS), or grabber/scrim tap
```

## Rules

1. **Prefer system sheets** with detents; respect the grabber and swipe-to-dismiss; never a custom half-height `View` without gestures.
2. **Title left-aligned + one trailing tertiary** (Reset/Done) — or centered title with Cancel/Done on iOS for form-like sheets. One style per app.
3. **≤6 actions**, glyph + verb label, destructive last in `negative`.
4. **Dialogs use specific verbs**: "Delete 3 photos?" body "This can't be undone." buttons "Delete" (destructive) / "Cancel". Never "Are you sure?" + Yes/No.
5. **Don't stack sheets more than 2 deep**; push inside the sheet instead.
6. **Scrim** behind sheets: system default (~30–40% black); tapping it dismisses unless there's unsaved input (then confirm discard).

## Budget

≤1 primary · ≤6 actions · ≤1 accent.
