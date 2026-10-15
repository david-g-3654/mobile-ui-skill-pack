# Copy & sample data

Generic copy makes a well-built screen look like a template. Specific copy makes an average layout look intentional.

## Voice defaults

- Sentence case. Plain words. Second person ("your balance"), not "user".
- Short: titles ≤ 4 words, buttons ≤ 3 words where possible, body ≤ 2 lines per idea.
- No "Oops!", no "Uh-oh", no exclamation marks except real celebrations ("You're all set").
- Numbers as numerals ("3 days", not "three days").

## Buttons

| Instead of | Write |
|---|---|
| Submit | Save address · Send request · Create account |
| OK | Got it (info) · the action itself ("Delete") for confirmations |
| Continue (on a paywall) | Start 7-day free trial · Subscribe for $4.99/mo |
| Learn more | See how it works · Read the privacy policy |
| Cancel (destructive context) | Keep my account |
| Yes / No | Delete 3 photos / Keep them |

## Titles & labels

- Screen titles are nouns ("Budgets", "Settings", "Your people").
- Onboarding/paywall headlines are outcomes, not features: "Wake up without the snooze spiral", not "Advanced alarm features".
- Row labels name the thing, values show the state: `Currency · USD ›`, `Wake up · 8:00 AM`.

## Empty, error, permission

| Situation | Pattern | Example |
|---|---|---|
| First use | What goes here + how to add it | "Saved places show up here. Tap ♡ on any place to save it." |
| Cleared / done | Positive closure | "You're all caught up." |
| No results | Echo query + suggestion | "No results for "thai brunch". Try "thai" or a nearby area." |
| Error | What happened + what to do, no blame | "Couldn't load your balance. Check your connection and try again." + [Try again] |
| Permission pre-prompt | Benefit first, then ask | "Get a heads-up when your package is 10 minutes away." [Turn on notifications] [Not now] |

## Legal & paywall

Always visible on paywalls: price, period, trial length, auto-renew statement, Restore purchases, Terms, Privacy. Write the auto-renew statement plainly: "$34.99/year after a 7-day free trial. Cancel anytime in Settings."

## Sample data rules (for previews, mocks, seeds)

1. **Names:** diverse, realistic, varied length — "Amara Okafor", "Lucas Wei", "Sofía Ramírez-Castillo", "Theo". Never John Doe / Jane Smith / User 1.
2. **Money:** uneven, plausible values — `$1,284.06`, `€12.40`, `−$38.99`. Include one large and one tiny value. **One format per screen**: format every amount with the same formatter (SwiftUI `.formatted(.currency(code: "USD"))`, `Intl.NumberFormat`, `NumberFormat.currency`) — mixing a hand-typed `$` with a locale-formatted `US$` on one screen looks broken (eval finding). Need the symbol separately for a hero number? SwiftUI and Flutter can format the parts; **React Native must split `format()`'s string**, because `formatToParts` doesn't exist in Hermes on iOS and the screen crashes (see `mobile-ui-react-native` → Money and numbers on Hermes; eval finding, 0.4).
3. **Dates:** relative to today — "Today, 9:41", "Yesterday", "Mon", "Sep 3".
4. **Text length:** include one long title that wraps, one short, one item with a missing optional field (no avatar, no subtitle).
5. **Counts:** realistic — 3 unread, 128 followers, 2.4K plays — not all zeros, not all round numbers.
6. **Images:** real-looking placeholders (solid `surface2` blocks with correct aspect ratio are better than random stock photos with mismatched subjects).
7. **Domain-true:** a running app shows paces like `5'12" /km`, a finance app shows merchant names like "Blue Bottle Coffee", a habit app shows streaks like "12-day streak".

Sample data is design material. A layout that only works with "Item 1" doesn't work.
