# Motion & feedback

Motion explains change; it isn't decoration. Default to the platform's transitions and add motion only where it tells the user what happened.

## Durations & curves

| Change | Duration | Curve |
|---|---|---|
| Press feedback | immediate in, 150ms out | spring (snappy) |
| Toggle, selection, chip | 200ms | spring (snappy, no bounce) |
| Expanding a row / accordion | 250–300ms | spring (smooth) |
| Sheet / push | system | system |
| Hero number change | 400–600ms | numeric content transition / count-up |
| Success moment | 500–800ms | spring with slight bounce |

Platform mapping: SwiftUI `.snappy` / `.smooth` / `.bouncy`; React Native Reanimated `withSpring({ damping: 18, stiffness: 220 })` for snappy, `withTiming(…, { duration: 250, easing: Easing.out(Easing.cubic) })` otherwise; Flutter `Curves.easeOutCubic` + `Durations.medium2` (300ms), or `SpringDescription` for physics.

## Rules

1. **Respect Reduce Motion**: replace movement with opacity cross-fades; disable shimmer, parallax, and auto-playing loops.
2. **Never block input** with an animation longer than 300ms.
3. **Animate the thing that changed**, not the whole screen. A new list item slides/fades in; the list doesn't re-render with a fade.
4. **One choreographed moment per flow max** (onboarding completion, purchase success). Everything else is quiet.
5. **No linear easing**, no 1s+ fades, no bouncing on destructive actions.

## Haptics (iOS; Android equivalents in parentheses)

| Event | Haptic |
|---|---|
| Toggle, segmented change, picker tick | selection (`HapticFeedbackConstants.CLOCK_TICK` / `SEGMENT_TICK`) |
| Button that commits (save, send) | light impact (`CONFIRM` on API 30+) |
| Success: purchase, completion, goal met | notification success |
| Error: failed validation, declined payment | notification error (`REJECT`) |
| Long-press menu | system (don't add your own) |

Never on scroll, never on every tap, never repeating.

## Pressed states

Everything tappable responds within one frame: rows → `surface2` background; buttons → scale 0.98 + slight dim; glyph buttons → 0.5 opacity. Android may use the Material ripple on Android only (bounded, `ink` at 10%).

## Loading

- < 300ms: show nothing.
- 300ms–2s: skeleton in the final layout, or an inline spinner inside the button that triggered it.
- > 2s or determinate: progress bar with a label ("Uploading 3 of 12").
- Optimistic UI for likes, toggles, reorders: update instantly, roll back with a toast on failure.
