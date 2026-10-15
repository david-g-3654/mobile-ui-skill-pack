# Search

**Job:** find a specific thing fast. **Focal:** the search field, then the top result. **Primary action:** none; typing is the action.

## States

```
IDLE (focused, empty)            TYPING                         RESULTS / NO RESULTS
┌───────────────────────┐       ┌───────────────────────┐      ┌───────────────────────┐
│ [🔍 Search      ] Cancel│       │ [🔍 tha|      ] Cancel│      │ [🔍 thai brunch ] Cancel│
│ RECENT          Clear │       │ ⌕ thai                │      │ (All)(Places)(People) │
│ ◷ ramen near me     × │       │ ⌕ thai brunch         │      │ Top result            │
│ ◷ Lucas Wei         × │       │ ⌕ thailand trip       │      │ ▣ Kin Khao  ·  0.4 mi │
│ SUGGESTED             │       │ ▣ Thai Basil (place)  │      │ ...                   │
│ (Brunch)(Open now)    │       │                       │      │ No results for "…"    │
└───────────────────────┘       └───────────────────────┘      └───────────────────────┘
```

## Rules

1. **Native search field** (iOS `.searchable`, M3 `SearchBar`/`SearchView`): capsule/rounded, `surface2`, glyph + placeholder that says what's searchable ("Search places, people").
2. **Idle state is useful**: recent searches (removable, "Clear"), and ≤8 suggestions or categories as chips. Never a blank screen.
3. **Suggestions while typing** highlight the matched part (semibold the typed prefix, or the remainder — pick one), with type glyphs for mixed entities.
4. **Results**: scopes as chips/segmented under the field when results mix types; "Top result" first; rows reuse the list anatomy of their type.
5. **No results** echoes the query and suggests a fix (spelling, broader term, clear filters).
6. **Debounce 150–250ms**; keep previous results visible while loading new ones (no flash to spinner).
7. **Dismiss keyboard on scroll**.

## Budget

≤8 idle suggestions · ≤4 scopes · 1 accent (selected scope).
