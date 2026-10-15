# Auth (sign in / sign up / verify)

**Job:** get the user in with minimum typing. **Focal:** the title + the fastest method. **Primary action:** the user's most likely method (Sign in with Apple on iOS, Google on Android, or passkey).

## Anatomy — entry

```
┌─────────────────────────────────┐
│                                 │
│       [ app mark / art ]        │  ← brand moment: icon 64–80 or full-bleed art top half
│                                 │
│ Designer toys for your          │  ← title: outcome or brand line, 2 lines max
│ home screen                     │
│                                 │
│ [  Continue with Apple       ]  │  ← primary: platform provider (system-styled button)
│ [  Continue with Google      ]  │  ← secondary: outlined/surface2
│ [  Continue with email       ]  │  ← secondary
│                                 │
│ By continuing you agree to the  │  ← footnote ink2, links underlined or accent
│ Terms and Privacy Policy.       │
└─────────────────────────────────┘
```

## Rules

1. **≤3 methods visible.** More go behind "Other options".
2. **Use the official provider buttons, with their marks. Never draw the logos yourself, and never drop them.** A text "G" in a circle reads as fake, and a provider button with no mark reads as unfinished (both eval findings; judges marked down logo-less buttons on every platform).
   - Apple: `SignInWithAppleButton` (SwiftUI, AuthenticationServices) · `AppleAuthenticationButton` (`expo-apple-authentication`) · `SignInWithAppleButton` (`sign_in_with_apple`). If you build your own pill, the mark is the platform glyph: SF Symbol `apple.logo`, Ionicons `logo-apple`, `Icons.apple`.
   - Google: `GoogleSignInButton` (GoogleSignInSwift) · `GoogleSigninButton` (`@react-native-google-signin/google-signin`) · `SignInButton(Buttons.google)` (`sign_in_button`). If you build your own, use the official multicolor "G" asset from Google's sign-in branding guidelines, bundled in the project, unmodified.
   - Don't restyle official buttons into your own pill. Match their height to yours (52) and keep their marks.
3. **Email flow is one field per screen** on phones: Email → (password *or* magic link/code). Use `textContentType`/`autofillHints` (`username`, `password`, `newPassword`, `oneTimeCode`) so the OS fills them.
4. **OTP**: 6 boxes *or* one field with letter-spacing; auto-advance and auto-submit; paste supported; "Resend code in 0:24" as tertiary.
5. **Passwords**: show/hide toggle (eye glyph, labeled), requirements shown *before* failure as a checklist that ticks, not as an error after submit.
6. **Errors inline** under the field, specific ("That code expired. We sent a new one."), never a modal alert.
7. **Sign up vs sign in**: one "Continue with email" that branches after the email is known is better than two flows.
8. **Keyboard**: the primary button rides above the keyboard (bottom action bar keyboard-aware); fields scroll into view; return key = next/go.

## Budget

1 primary · ≤3 methods · 1 field per step · 0–1 accent.

## Failure modes → fixes

| Seen | Fix |
|---|---|
| Username + password + confirm + "Forgot?" + 4 social buttons on one screen | Providers first, email as one-field steps |
| Placeholder-as-label inputs | Label above |
| Custom-drawn or logo-less Apple/Google buttons | Official buttons with their marks |
| Primary button hidden behind keyboard | Keyboard-aware bottom bar |
