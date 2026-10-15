// theme.ts — mobile-ui "Quiet" skin for React Native / Expo.
// Screens use these roles only: no raw hex, no raw font sizes, no magic spacing numbers.
// To rebrand: change `accent` (and optionally neutrals). See mobile-ui/references/style-guide.md.

import { Platform, TextStyle, useColorScheme } from 'react-native';

const light = {
  canvas: '#F5F5F2',
  surface: '#FFFFFF',
  surface2: '#EDEDEA',
  ink: '#121212',
  ink2: '#5E5E5B',
  /** Placeholder and disabled only — never information. */
  ink3: '#9B9B97',
  hairline: 'rgba(18,18,18,0.10)',
  /** Editorial accent: ≤2 elements per screen. */
  accent: '#C2410C',
  accentSoft: 'rgba(194,65,12,0.10)',
  primaryFill: '#121212',
  onPrimary: '#FFFFFF',
  positive: '#1E7F46',
  negative: '#C8312A',
  warning: '#9A5B00',
  scrim: 'rgba(0,0,0,0.32)',
  /** Off-state switch track. */
  track: '#DADAD6',
  thumb: '#FFFFFF',
};

export type QPalette = typeof light;

const dark: QPalette = {
  canvas: '#111113',
  surface: '#1E1E21',
  surface2: '#2A2A2E',
  ink: '#F4F4F2',
  ink2: '#A3A3A0',
  ink3: '#6E6E6B',
  hairline: 'rgba(255,255,255,0.10)',
  accent: '#FF6B35',
  accentSoft: 'rgba(255,107,53,0.16)',
  primaryFill: '#F4F4F2',
  onPrimary: '#121212',
  positive: '#3DD27A',
  negative: '#FF6159',
  warning: '#F5B342',
  scrim: 'rgba(0,0,0,0.56)',
  track: '#3A3A3C',
  thumb: '#FFFFFF',
};

export const palettes = { light, dark };

// ── Spacing (4pt grid) ──────────────────────────────────────────────
export const space = {
  xxs: 4,
  xs: 8,
  sm: 12,
  md: 16,
  /** QScreen margin: matches iOS large titles, inset-grouped lists and M3 compact margins. */
  margin: 16,
  lg: 20, // card padding
  xl: 24,
  xxl: 32, // between unrelated sections
  xxxl: 48,
} as const;

export const radius = {
  s: 8,
  m: 14,
  l: 20,
  xl: 28,
  capsule: 999,
} as const;

/** Concentric inner radius for an element inset by `padding` inside a container of `outer` radius. */
export const innerRadius = (outer: number, padding: number) => Math.max(4, outer - padding);

export const metrics = {
  buttonHeight: 52,
  rowMinHeight: 52,
  fieldHeight: 52,
  minTap: Platform.OS === 'ios' ? 44 : 48,
  hitSlop: { top: 8, bottom: 8, left: 8, right: 8 },
} as const;

// ── Typography ───────────────────────────────────────────────────────
// System font by default (SF Pro on iOS, Roboto on Android).
// Personality: set DISPLAY_FAMILY to one loaded font (expo-font) — used for hero/largeTitle/title only.
export const DISPLAY_FAMILY: string | undefined = undefined;

const ios = Platform.OS === 'ios';

const t = (size: number, lineHeight: number, weight: TextStyle['fontWeight'], extra: TextStyle = {}): TextStyle => ({
  fontSize: size,
  lineHeight,
  fontWeight: weight,
  ...extra,
});

export const type = {
  hero: t(56, 60, '600', { letterSpacing: -1.1, fontVariant: ['tabular-nums'], fontFamily: DISPLAY_FAMILY }),
  largeTitle: t(ios ? 34 : 32, ios ? 41 : 40, '700', { letterSpacing: ios ? -0.4 : 0, fontFamily: DISPLAY_FAMILY }),
  title: t(22, 28, '600', { fontFamily: DISPLAY_FAMILY }),
  headline: t(ios ? 17 : 16, ios ? 22 : 24, '600'),
  body: t(ios ? 17 : 16, ios ? 22 : 24, '400'),
  subhead: t(ios ? 15 : 14, 20, '400'),
  footnote: t(ios ? 13 : 12, ios ? 18 : 16, '400'),
  overline: t(ios ? 12 : 11, 16, '600', { letterSpacing: 0.7, textTransform: 'uppercase' }),
} satisfies Record<string, TextStyle>;

/** Use on any number that updates or aligns in columns. */
export const tabular: TextStyle = { fontVariant: ['tabular-nums'] };

// ── Elevation (light mode only; dark mode uses surface steps) ────────
export const floatingShadow = Platform.select({
  ios: { shadowColor: '#000', shadowOpacity: 0.08, shadowRadius: 12, shadowOffset: { width: 0, height: 8 } },
  default: { elevation: 6 },
});

// ── Motion ───────────────────────────────────────────────────────────
export const motion = {
  snappy: { damping: 20, stiffness: 260, mass: 1 }, // Reanimated withSpring config
  smooth: { duration: 280 },
} as const;

// ── Hook ─────────────────────────────────────────────────────────────
export type QTheme = {
  c: QPalette;
  dark: boolean;
};

export function useQTheme(): QTheme {
  const dark = useColorScheme() === 'dark';
  return { c: dark ? palettes.dark : palettes.light, dark };
}
