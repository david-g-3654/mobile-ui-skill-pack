// components.tsx — mobile-ui core components for React Native / Expo.
// Deps: react-native-safe-area-context, expo-haptics, @expo/vector-icons (all default in Expo).
// Navigation chrome (headers, tabs, sheets) comes from Expo Router / React Navigation — not from here.

import React, { Children, Fragment, ReactNode, useEffect, useRef } from 'react';
import {
  AccessibilityRole,
  ActivityIndicator,
  Animated,
  Platform,
  Pressable,
  ScrollView,
  ScrollViewProps,
  StyleProp,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  TextInputProps,
  TextStyle,
  View,
  ViewStyle,
  AccessibilityInfo,
  useWindowDimensions,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { metrics, QPalette, radius, space, tabular, type, useQTheme } from './theme';

type IconName = React.ComponentProps<typeof Ionicons>['name'];
type TypeVariant = keyof typeof type;
type ColorRole = keyof QPalette;

const DISPLAY_VARIANTS = new Set<TypeVariant>(['hero', 'largeTitle', 'title']);

/** True at accessibility text sizes (fontScale ≥ 1.6): switch side-by-side layouts to stacked. */
export function useQLargeText() {
  return useWindowDimensions().fontScale >= 1.6;
}

// ── Text ─────────────────────────────────────────────────────────────

export function QText({
  variant = 'body',
  color = 'ink',
  style,
  children,
  numberOfLines,
  role,
  fit,
}: {
  variant?: TypeVariant;
  color?: ColorRole;
  style?: StyleProp<TextStyle>;
  children: ReactNode;
  numberOfLines?: number;
  role?: AccessibilityRole;
  /** Shrink to fit one line instead of truncating (hero numbers). */
  fit?: boolean;
}) {
  const { c } = useQTheme();
  return (
    <Text
      // Display styles grow less than body text at large sizes (as iOS large titles do); body is uncapped.
      maxFontSizeMultiplier={DISPLAY_VARIANTS.has(variant) ? 1.5 : undefined}
      numberOfLines={fit ? 1 : numberOfLines}
      adjustsFontSizeToFit={fit}
      minimumFontScale={fit ? 0.4 : undefined}
      accessibilityRole={role}
      style={[type[variant], { color: c[color] }, style]}
    >
      {children}
    </Text>
  );
}

// ── QScreen scaffolding ───────────────────────────────────────────────

/** Scrollable content screen on canvas. Use under a native stack header (Expo Router <Stack>). */
export function QScreen({ children, contentContainerStyle, ...rest }: ScrollViewProps & { children: ReactNode }) {
  const { c } = useQTheme();
  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: c.canvas }}
      contentInsetAdjustmentBehavior="automatic"
      keyboardDismissMode="interactive"
      contentContainerStyle={[{ paddingHorizontal: space.margin, paddingTop: space.xs, paddingBottom: space.xxl, gap: space.xxl }, contentContainerStyle]}
      {...rest}
    >
      {children}
    </ScrollView>
  );
}

// ── Buttons ──────────────────────────────────────────────────────────

type ButtonProps = {
  title: string;
  onPress: () => void;
  disabled?: boolean;
  loading?: boolean;
  destructive?: boolean;
  accessibilityHint?: string;
};

/** Filled primary button: one per screen. Ink fill, capsule, 52 high. */
export function QPrimaryButton({ title, onPress, disabled, loading, accessibilityHint }: ButtonProps) {
  const { c } = useQTheme();
  const inactive = disabled || loading;
  return (
    <Pressable
      onPress={onPress}
      disabled={inactive}
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityHint={accessibilityHint}
      accessibilityState={{ disabled: !!disabled, busy: !!loading }}
      style={({ pressed }) => [
        styles.button,
        { backgroundColor: disabled ? c.surface2 : c.primaryFill },
        pressed && { opacity: 0.9, transform: [{ scale: 0.98 }] },
      ]}
    >
      <QText variant="headline" color={disabled ? 'ink3' : 'onPrimary'} style={[styles.center, loading && styles.hidden]}>
        {title}
      </QText>
      {loading && <ActivityIndicator color={c.onPrimary} style={StyleSheet.absoluteFill} />}
    </Pressable>
  );
}

/** Alternative action: same shape, tonal fill. */
export function QSecondaryButton({ title, onPress, disabled, destructive }: ButtonProps) {
  const { c } = useQTheme();
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      accessibilityState={{ disabled: !!disabled }}
      style={({ pressed }) => [styles.button, { backgroundColor: c.surface2 }, pressed && { opacity: 0.7 }]}
    >
      <QText variant="headline" color={disabled ? 'ink3' : destructive ? 'negative' : 'ink'} style={styles.center}>
        {title}
      </QText>
    </Pressable>
  );
}

/** Escape hatches: "Not now", "Restore purchases", "Skip". */
export function QTertiaryButton({ title, onPress, color = 'ink2' }: ButtonProps & { color?: ColorRole }) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      hitSlop={metrics.hitSlop}
      style={({ pressed }) => [styles.tertiary, pressed && { opacity: 0.5 }]}
    >
      <QText variant="subhead" color={color} style={styles.semibold}>
        {title}
      </QText>
    </Pressable>
  );
}

/** Icon-only button for headers and overlays. `label` is required for screen readers. */
export function QIconButton({ icon, label, onPress, filled }: { icon: IconName; label: string; onPress: () => void; filled?: boolean }) {
  const { c } = useQTheme();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      hitSlop={metrics.hitSlop}
      style={({ pressed }) => [
        styles.iconButton,
        filled && { backgroundColor: c.surface2 },
        pressed && { opacity: 0.5 },
      ]}
    >
      <Ionicons name={icon} size={20} color={filled ? c.ink2 : c.ink} />
    </Pressable>
  );
}

// ── Bottom action bar ────────────────────────────────────────────────

/**
 * Pins the primary action above the home indicator. Render it as a sibling after <QScreen> (never
 * overlay it on the scroll content). `footer` (terms, legal line, secondary links) is pinned at normal
 * text sizes but NOT at accessibility sizes — a tall pinned bar would cover the screen — so also render
 * the same footer at the end of the scroll content inside <QLargeTextFooter>.
 */
export function QBottomActionBar({ children, footer }: { children: ReactNode; footer?: ReactNode }) {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const large = useQLargeText();
  return (
    <View
      style={{
        paddingHorizontal: space.margin,
        paddingTop: space.sm,
        paddingBottom: Math.max(insets.bottom, space.md) + space.xs,
        backgroundColor: c.canvas,
        borderTopWidth: StyleSheet.hairlineWidth,
        borderTopColor: c.hairline,
        gap: space.xs,
      }}
    >
      {children}
      {!large && footer}
    </View>
  );
}

/** Renders its children only at accessibility text sizes — pair with QBottomActionBar's `footer`. */
export function QLargeTextFooter({ children }: { children: ReactNode }) {
  if (!useQLargeText()) return null;
  return <View style={{ gap: space.xs, paddingTop: space.xl }}>{children}</View>;
}

// ── Section header & grouped section ─────────────────────────────────

export function QSectionHeader({ title, action }: { title: string; action?: { title: string; onPress: () => void } }) {
  return (
    <View style={styles.sectionHeader}>
      <QText variant="title" role="header">
        {title}
      </QText>
      {action && <QTertiaryButton title={action.title} onPress={action.onPress} />}
    </View>
  );
}

/** Inset-grouped section: surface on canvas, radius 20, hairlines between rows. No shadow. */
export function QGroupedSection({ header, footer, children }: { header?: string; footer?: string; children: ReactNode }) {
  const { c } = useQTheme();
  const rows = Children.toArray(children).filter(Boolean);
  return (
    <View style={{ gap: space.xs }}>
      {header && (
        <QText variant="overline" color="ink2" role="header" style={{ paddingHorizontal: space.md }}>
          {header}
        </QText>
      )}
      <View style={{ backgroundColor: c.surface, borderRadius: radius.l, overflow: 'hidden' }}>
        {rows.map((row, i) => (
          <Fragment key={i}>
            {row}
            {i < rows.length - 1 && <View style={[styles.separator, { backgroundColor: c.hairline }]} />}
          </Fragment>
        ))}
      </View>
      {footer && (
        <QText variant="footnote" color="ink2" style={{ paddingHorizontal: space.md }}>
          {footer}
        </QText>
      )}
    </View>
  );
}

// ── Rows ─────────────────────────────────────────────────────────────

type RowProps = {
  title: string;
  subtitle?: string;
  icon?: IconName;
  /** QAvatar or thumbnail; replaces `icon`. */
  leading?: ReactNode;
  value?: string;
  onPress?: () => void;
  /** navigate → chevron (pushes a screen) · action → no accessory · link → ↗ (opens outside). */
  kind?: 'navigate' | 'action' | 'link';
  destructive?: boolean;
  trailing?: ReactNode;
};

export function QListRow({ title, subtitle, icon, leading, value, onPress, kind = 'navigate', destructive, trailing }: RowProps) {
  const { c } = useQTheme();
  // At accessibility sizes the trailing value moves under the title and the leading avatar sits on top,
  // so titles never break mid-word ("Appear-ance") and avatars never get squeezed.
  const stacked = useQLargeText();
  const valueText = value && (
    <QText color="ink2" style={tabular}>
      {value}
    </QText>
  );
  const content = (pressed: boolean) => (
    <View style={[styles.row, pressed && { backgroundColor: c.surface2 }]}>
      {!stacked && leading}
      {icon && !leading && !stacked && (
        <View style={styles.rowIcon}>
          <Ionicons name={icon} size={20} color={c.ink2} />
        </View>
      )}
      <View style={{ flex: 1, gap: 2 }}>
        {stacked && leading}
        <QText variant={leading ? 'headline' : 'body'} color={destructive ? 'negative' : 'ink'}>
          {title}
        </QText>
        {subtitle && (
          <QText variant="subhead" color="ink2" numberOfLines={stacked ? undefined : 2}>
            {subtitle}
          </QText>
        )}
        {stacked && valueText}
      </View>
      {!stacked && valueText}
      {trailing}
      {onPress && !trailing && kind === 'navigate' && <Ionicons name="chevron-forward" size={16} color={c.ink3} />}
      {onPress && !trailing && kind === 'link' && <Ionicons name="arrow-up-outline" size={16} color={c.ink3} style={styles.external} />}
    </View>
  );
  if (!onPress) return <View accessible accessibilityLabel={[title, subtitle, value].filter(Boolean).join(', ')}>{content(false)}</View>;
  return (
    <Pressable onPress={onPress} accessibilityRole={kind === 'link' ? 'link' : 'button'} accessibilityLabel={[title, value].filter(Boolean).join(', ')}>
      {({ pressed }) => content(pressed)}
    </Pressable>
  );
}

/** Toggle row: applies immediately (no Save). The whole row toggles. */
export function QToggleRow({ title, subtitle, value, onValueChange }: { title: string; subtitle?: string; value: boolean; onValueChange: (v: boolean) => void }) {
  const { c } = useQTheme();
  const toggle = (v: boolean) => {
    Haptics.selectionAsync();
    onValueChange(v);
  };
  return (
    <Pressable
      onPress={() => toggle(!value)}
      accessibilityRole="switch"
      accessibilityLabel={title}
      accessibilityHint={subtitle}
      accessibilityState={{ checked: value }}
    >
      <View style={styles.row}>
        <View style={{ flex: 1, gap: 2 }}>
          <QText>{title}</QText>
          {subtitle && (
            <QText variant="subhead" color="ink2">
              {subtitle}
            </QText>
          )}
        </View>
        <Switch
          value={value}
          onValueChange={toggle}
          trackColor={{ true: c.positive, false: c.track }}
          ios_backgroundColor={c.track}
          // Android draws a flat thumb: a white off-thumb on a light track vanishes into the row
          // (eval finding, Pixel 8). Use a dark off-thumb there, like Material 3; iOS keeps its shadowed thumb.
          thumbColor={Platform.OS === 'android' && !value ? c.ink2 : c.thumb}
          importantForAccessibility="no-hide-descendants"
          accessibilityElementsHidden
        />
      </View>
    </Pressable>
  );
}

// ── Hero metric & metric row ─────────────────────────────────────────

export function QHeroMetric({
  label,
  value,
  prefix,
  suffix,
  context,
  delta,
}: {
  label: string;
  value: string;
  prefix?: string;
  suffix?: string;
  context?: string;
  delta?: { text: string; up: boolean; upIsGood?: boolean };
}) {
  const { c } = useQTheme();
  const { fontScale } = useWindowDimensions();
  const good = delta ? delta.up === (delta.upIsGood ?? true) : true;
  return (
    <View accessible accessibilityLabel={[label, `${prefix ?? ''}${value}${suffix ?? ''}`, delta?.text, context].filter(Boolean).join(', ')} style={{ gap: space.xs }}>
      <QText variant="overline" color="ink2">
        {label}
      </QText>
      <View style={styles.heroLine}>
        {prefix && (
          <QText variant="title" color="ink2">
            {prefix}
          </QText>
        )}
        <QText variant="hero" fit style={styles.heroValue}>
          {value}
        </QText>
        {suffix && (
          <QText variant="title" color="ink2">
            {suffix}
          </QText>
        )}
      </View>
      {(delta || context) && (
        <View style={styles.inline}>
          {delta && (
            <View style={styles.inlineTight}>
              <Ionicons name={delta.up ? 'arrow-up' : 'arrow-down'} size={Math.round(14 * fontScale)} color={good ? c.positive : c.negative} />
              <QText variant="subhead" color={good ? 'positive' : 'negative'} style={[styles.semibold, styles.shrink]}>
                {delta.text}
              </QText>
            </View>
          )}
          {context && (
            <QText variant="subhead" color="ink2">
              {context}
            </QText>
          )}
        </View>
      )}
    </View>
  );
}

/** 2–3 secondary metrics in a quiet row. No icons, no tiles. Wraps at large text sizes. */
export function QMetricRow({ items }: { items: { value: string; label: string }[] }) {
  return (
    <View style={styles.metricRow}>
      {items.map((m) => (
        <View key={m.label} accessible accessibilityLabel={`${m.value} ${m.label}`} style={{ gap: 2, minWidth: 72 }}>
          <QText variant="title" style={tabular}>
            {m.value}
          </QText>
          <QText variant="footnote" color="ink2">
            {m.label}
          </QText>
        </View>
      ))}
    </View>
  );
}

// ── Card (object) ────────────────────────────────────────────────────

/** Cards are for objects (a plan, a booking, a media tile) — not for wrapping sections. */
export function QObjectCard({ children, style, onPress, accessibilityLabel }: { children: ReactNode; style?: StyleProp<ViewStyle>; onPress?: () => void; accessibilityLabel?: string }) {
  const { c } = useQTheme();
  const base = [{ backgroundColor: c.surface, borderRadius: radius.l, padding: space.lg }, style];
  if (!onPress) return <View style={base}>{children}</View>;
  return (
    <Pressable onPress={onPress} accessibilityRole="button" accessibilityLabel={accessibilityLabel} style={({ pressed }) => [base, pressed && { opacity: 0.8 }]}>
      {children}
    </Pressable>
  );
}

// ── QSegmented control ────────────────────────────────────────────────
// Prefer @react-native-segmented-control/segmented-control for a true native control on iOS.

export function QSegmented<T extends string>({ options, value, onChange }: { options: { value: T; label: string }[]; value: T; onChange: (v: T) => void }) {
  const { c } = useQTheme();
  return (
    <View accessibilityRole="tablist" style={[styles.segmented, { backgroundColor: c.surface2 }]}>
      {options.map((o) => {
        const selected = o.value === value;
        return (
          <Pressable
            key={o.value}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => {
              if (!selected) Haptics.selectionAsync();
              onChange(o.value);
            }}
            style={[styles.segment, selected && { backgroundColor: c.surface }]}
          >
            <QText variant="subhead" color={selected ? 'ink' : 'ink2'} style={styles.semibold}>
              {o.label}
            </QText>
          </Pressable>
        );
      })}
    </View>
  );
}

// ── Text field ───────────────────────────────────────────────────────

export function QTextField({ label, error, helper, style, ...input }: TextInputProps & { label: string; error?: string; helper?: string }) {
  const { c } = useQTheme();
  const [focused, setFocused] = React.useState(false);
  return (
    <View style={{ gap: space.xs }}>
      <QText variant="subhead" color="ink2">
        {label}
      </QText>
      <TextInput
        accessibilityLabel={label}
        accessibilityHint={error ?? helper}
        placeholderTextColor={c.ink3}
        selectionColor={c.accent}
        onFocus={(e) => {
          setFocused(true);
          input.onFocus?.(e);
        }}
        onBlur={(e) => {
          setFocused(false);
          input.onBlur?.(e);
        }}
        style={[
          type.body,
          styles.field,
          {
            color: c.ink,
            backgroundColor: c.surface,
            borderColor: error ? c.negative : focused ? c.ink : c.hairline,
            borderWidth: error || focused ? 1.5 : 1,
          },
          style,
        ]}
        {...input}
      />
      {(error || helper) && (
        <QText variant="footnote" color={error ? 'negative' : 'ink2'}>
          {error ?? helper}
        </QText>
      )}
    </View>
  );
}

// ── Color swatch (product variants) ───────────────────────────────

/**
 * A product color (content, not UI — mark its definition with `// mobile-ui: content-color`). Always
 * ringed with a hairline so a black swatch survives dark mode and a white one survives light mode.
 */
export function QSwatch({ name, color, selected, onPress, size = 32 }: { name: string; color: string; selected?: boolean; onPress: () => void; size?: number }) {
  const { c } = useQTheme();
  return (
    <Pressable
      onPress={() => {
        if (!selected) Haptics.selectionAsync();
        onPress();
      }}
      accessibilityRole="radio"
      accessibilityLabel={name}
      accessibilityState={{ selected: !!selected }}
      hitSlop={metrics.hitSlop}
      style={{ padding: space.xxs, borderRadius: size, borderWidth: 2, borderColor: selected ? c.ink : 'transparent' }}
    >
      <View style={{ width: size, height: size, borderRadius: size / 2, backgroundColor: color, borderWidth: StyleSheet.hairlineWidth * 2, borderColor: c.hairline }} />
    </Pressable>
  );
}

// ── QChip, avatar, badge ──────────────────────────────────────────────

export function QChip({ title, selected, onPress }: { title: string; selected?: boolean; onPress: () => void }) {
  const { c } = useQTheme();
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityState={{ selected: !!selected }}
      style={({ pressed }) => [styles.chip, { backgroundColor: selected ? c.primaryFill : c.surface2 }, pressed && { opacity: 0.7 }]}
    >
      <QText variant="subhead" color={selected ? 'onPrimary' : 'ink'} style={selected && styles.semibold}>
        {title}
      </QText>
    </Pressable>
  );
}

export function QAvatar({ name, size = 40 }: { name: string; size?: number }) {
  const { c } = useQTheme();
  const initials = name
    .split(' ')
    .slice(0, 2)
    .map((p) => p[0])
    .join('');
  return (
    <View
      accessible
      accessibilityLabel={name}
      style={{ width: size, height: size, borderRadius: size / 2, flexShrink: 0, backgroundColor: c.accentSoft, alignItems: 'center', justifyContent: 'center' }}
    >
      <Text maxFontSizeMultiplier={1} style={{ color: c.accent, fontSize: Math.round(size * 0.38), fontWeight: '600' }}>
        {initials}
      </Text>
    </View>
  );
}

export function QBadge({ text, color = 'accent' }: { text: string; color?: 'accent' | 'positive' | 'negative' | 'warning' }) {
  const { c } = useQTheme();
  return (
    <View style={styles.badge}>
      <View style={[StyleSheet.absoluteFill, { backgroundColor: c[color], opacity: 0.12, borderRadius: radius.capsule }]} />
      <QText variant="footnote" color={color} style={styles.semibold}>
        {text}
      </QText>
    </View>
  );
}

// ── Progress bar ─────────────────────────────────────────────────────

export function QProgressBar({ progress, label }: { progress: number; label: string }) {
  const { c } = useQTheme();
  const pct = Math.min(Math.max(progress, 0), 1);
  return (
    <View
      accessibilityRole="progressbar"
      accessibilityLabel={label}
      accessibilityValue={{ min: 0, max: 100, now: Math.round(pct * 100) }}
      style={{ height: 6, borderRadius: 3, backgroundColor: c.surface2, overflow: 'hidden' }}
    >
      <View style={{ width: `${pct * 100}%`, height: '100%', borderRadius: 3, backgroundColor: c.accent }} />
    </View>
  );
}

// ── Plan card (paywall) ──────────────────────────────────────────────

export function QPlanCard({
  name,
  price,
  period,
  detail,
  badge,
  selected,
  onPress,
}: {
  name: string;
  price: string;
  period: string;
  detail?: string;
  badge?: string;
  selected: boolean;
  onPress: () => void;
}) {
  const { c } = useQTheme();
  return (
    <Pressable
      onPress={() => {
        if (!selected) Haptics.selectionAsync();
        onPress();
      }}
      accessibilityRole="radio"
      accessibilityState={{ selected }}
      accessibilityLabel={`${name}, ${price} ${period}${detail ? `, ${detail}` : ''}${badge ? `, ${badge}` : ''}`}
      style={[
        styles.plan,
        { backgroundColor: c.surface, borderColor: selected ? c.ink : c.hairline, borderWidth: selected ? 2 : 1 },
      ]}
    >
      <View style={styles.planTop}>
        <QText variant="headline">{name}</QText>
        <Ionicons name={selected ? 'checkmark-circle' : 'ellipse-outline'} size={22} color={selected ? c.ink : c.ink3} />
      </View>
      <View style={styles.heroLine}>
        <QText variant="title" style={tabular}>
          {price}
        </QText>
        <QText variant="subhead" color="ink2">
          {period}
        </QText>
      </View>
      {detail && (
        <QText variant="footnote" color="ink2">
          {detail}
        </QText>
      )}
      {badge && <QBadge text={badge} />}
    </Pressable>
  );
}

// ── Empty state ──────────────────────────────────────────────────────

export function QEmptyState({ icon, title, message, action }: { icon?: IconName; title: string; message: string; action?: { title: string; onPress: () => void } }) {
  const { c } = useQTheme();
  return (
    <View style={styles.empty}>
      {icon && <Ionicons name={icon} size={44} color={c.ink3} accessibilityElementsHidden importantForAccessibility="no" />}
      <QText variant="title" style={styles.center} role="header">
        {title}
      </QText>
      <QText color="ink2" style={styles.center}>
        {message}
      </QText>
      {action && (
        <View style={{ marginTop: space.xs, alignSelf: 'center', minWidth: 200 }}>
          <QSecondaryButton title={action.title} onPress={action.onPress} />
        </View>
      )}
    </View>
  );
}

// ── QSkeleton ─────────────────────────────────────────────────────────

export function QSkeleton({ width, height, radius: r = radius.s, style }: { width: ViewStyle['width']; height: number; radius?: number; style?: StyleProp<ViewStyle> }) {
  const { c } = useQTheme();
  const opacity = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    let loop: Animated.CompositeAnimation | undefined;
    AccessibilityInfo.isReduceMotionEnabled().then((reduce) => {
      if (reduce) return;
      loop = Animated.loop(
        Animated.sequence([
          Animated.timing(opacity, { toValue: 0.45, duration: 900, useNativeDriver: true }),
          Animated.timing(opacity, { toValue: 1, duration: 900, useNativeDriver: true }),
        ]),
      );
      loop.start();
    });
    return () => loop?.stop();
  }, [opacity]);
  return <Animated.View accessibilityElementsHidden importantForAccessibility="no-hide-descendants" style={[{ width, height, borderRadius: r, backgroundColor: c.surface2, opacity }, style]} />;
}

/** QSkeleton in the shape of a QListRow. */
export function QSkeletonRow() {
  return (
    <View style={styles.row}>
      <QSkeleton width={28} height={28} radius={14} />
      <View style={{ flex: 1, gap: space.xs }}>
        <QSkeleton width="60%" height={14} />
        <QSkeleton width="40%" height={12} />
      </View>
    </View>
  );
}

// ── QToast ────────────────────────────────────────────────────────────

/** Inverse capsule. Mount at the root of the screen; parent controls visibility/timeout. */
export function QToast({ message }: { message: string }) {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  useEffect(() => {
    AccessibilityInfo.announceForAccessibility(message);
  }, [message]);
  return (
    <View pointerEvents="none" style={[styles.toastWrap, { top: insets.top + space.xs }]}>
      <View style={[styles.toast, { backgroundColor: c.primaryFill }]}>
        <QText variant="subhead" color="onPrimary" style={styles.semibold}>
          {message}
        </QText>
      </View>
    </View>
  );
}

// ── Styles ───────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  button: {
    minHeight: metrics.buttonHeight,
    borderRadius: radius.capsule,
    paddingHorizontal: space.margin,
    alignItems: 'center',
    justifyContent: 'center',
  },
  hidden: { opacity: 0 },
  tertiary: { minHeight: metrics.minTap, justifyContent: 'center', paddingHorizontal: space.xs },
  iconButton: { width: metrics.minTap, height: metrics.minTap, borderRadius: metrics.minTap / 2, alignItems: 'center', justifyContent: 'center' },
  semibold: { fontWeight: '600' },
  center: { textAlign: 'center' },
  sectionHeader: { flexDirection: 'row', alignItems: 'baseline', justifyContent: 'space-between' },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: space.md },
  row: {
    minHeight: metrics.rowMinHeight,
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
    paddingHorizontal: space.md,
    paddingVertical: space.sm,
  },
  rowIcon: { width: 28, alignItems: 'center' },
  external: { transform: [{ rotate: '45deg' }] },
  heroLine: { flexDirection: 'row', alignItems: 'baseline', gap: space.xxs },
  heroValue: { flexShrink: 1 },
  inline: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
  // maxWidth + a shrinking label: the delta wraps at large text instead of running off-screen.
  inlineTight: { flexDirection: 'row', alignItems: 'center', gap: 2, maxWidth: '100%' },
  shrink: { flexShrink: 1 },
  metricRow: { flexDirection: 'row', flexWrap: 'wrap', columnGap: space.xl, rowGap: space.sm },
  segmented: { flexDirection: 'row', borderRadius: radius.m - 4, padding: 2, minHeight: 36 },
  segment: { flex: 1, alignItems: 'center', justifyContent: 'center', borderRadius: radius.m - 6, minHeight: 32 },
  field: { minHeight: metrics.fieldHeight, borderRadius: radius.m, paddingHorizontal: space.md },
  chip: { minHeight: 36, paddingHorizontal: space.sm, borderRadius: radius.capsule, alignItems: 'center', justifyContent: 'center' },
  badge: { alignSelf: 'flex-start', paddingHorizontal: space.xs, paddingVertical: 2, borderRadius: radius.capsule },
  plan: { flex: 1, borderRadius: radius.l, padding: space.md, gap: space.xs, minHeight: 132 },
  planTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  empty: { alignItems: 'center', gap: space.sm, paddingVertical: space.xxxl, paddingHorizontal: space.xl },
  toastWrap: { position: 'absolute', left: 0, right: 0, alignItems: 'center' },
  toast: { minHeight: 44, paddingHorizontal: space.md, borderRadius: radius.capsule, justifyContent: 'center' },
});

// ── Bar chart ────────────────────────────────────────────────────────

/** One bar in a QBarChart. `shortLabel` is what the axis shows when the full label doesn't fit ("M" for "Mon"). */
export type QBar = { label: string; shortLabel: string; value: number; spokenValue?: string };

/**
 * Single-series bar chart for stats screens (screen-stats.md): one highlighted bar in `accent`, the rest in
 * ink, an optional dashed goal line, minimal axes.
 *
 * Axis labels never collide, at any text size: full labels when they fit their column, single letters when
 * they don't (and always at accessibility sizes), every other letter as a last resort, and each label shrinks
 * to fit rather than wrap. (Eval finding: hand-rolled charts ran their day names together at large text.)
 */
export function QBarChart({
  bars,
  highlighted,
  goal,
  goalLabel,
  height = 180,
}: {
  bars: QBar[];
  highlighted?: number;
  goal?: number;
  goalLabel?: string;
  height?: number;
}) {
  const { c } = useQTheme();
  const { fontScale } = useWindowDimensions();
  const large = useQLargeText();
  const [width, setWidth] = React.useState(0);
  const top = Math.max(...bars.map((b) => b.value), goal ?? 0) * 1.15;
  const maxValue = top > 0 ? top : 1;
  const column = width / Math.max(bars.length, 1);
  // React Native can't measure text synchronously: estimate the footnote glyph width at this font scale.
  const estimate = (s: string) => s.length * (type.footnote.fontSize ?? 13) * fontScale * 0.62;
  const widest = (key: 'label' | 'shortLabel') => Math.max(...bars.map((b) => estimate(b[key])));
  const labels: (string | null)[] =
    !large && widest('label') <= column - 4
      ? bars.map((b) => b.label)
      : widest('shortLabel') <= column - 2
        ? bars.map((b) => b.shortLabel)
        : bars.map((b, i) => (i % 2 === 0 ? b.shortLabel : null));

  return (
    <View
      accessible
      accessibilityRole="image"
      accessibilityLabel={bars.map((b) => `${b.label} ${b.spokenValue ?? b.value}`).join(', ')}
      onLayout={(e) => setWidth(e.nativeEvent.layout.width)}
    >
      <View style={{ height }}>
        <View style={chartStyles.bars}>
          {bars.map((b, i) => (
            <View key={i} style={chartStyles.column}>
              <View
                style={{
                  width: '55%',
                  height: b.value > 0 ? `${Math.min(100, (b.value / maxValue) * 100)}%` : 2,
                  backgroundColor: b.value <= 0 ? c.hairline : i === highlighted ? c.accent : c.ink,
                  opacity: b.value > 0 && i !== highlighted ? 0.85 : 1,
                  borderTopLeftRadius: 4,
                  borderTopRightRadius: 4,
                }}
              />
            </View>
          ))}
        </View>
        {goal != null && (
          <View style={[chartStyles.goal, { bottom: (height * goal) / maxValue }]} pointerEvents="none">
            {goalLabel ? (
              <QText variant="footnote" color="ink2" style={chartStyles.goalLabel} numberOfLines={1}>
                {goalLabel}
              </QText>
            ) : null}
            <View style={chartStyles.dashes}>
              {Array.from({ length: 80 }, (_, k) => (
                <View key={k} style={[chartStyles.dash, { backgroundColor: c.ink3 }]} />
              ))}
            </View>
          </View>
        )}
      </View>
      <View style={chartStyles.labels}>
        {labels.map((l, i) => (
          <Text
            key={i}
            numberOfLines={1}
            adjustsFontSizeToFit
            style={[
              type.footnote,
              { flex: 1, textAlign: 'center', color: i === highlighted ? c.ink : c.ink2 },
              i === highlighted && { fontWeight: '600' },
            ]}
          >
            {l ?? ''}
          </Text>
        ))}
      </View>
    </View>
  );
}

const chartStyles = StyleSheet.create({
  bars: { flex: 1, flexDirection: 'row', alignItems: 'flex-end' },
  column: { flex: 1, alignItems: 'center', justifyContent: 'flex-end', height: '100%' },
  goal: { position: 'absolute', left: 0, right: 0 },
  goalLabel: { position: 'absolute', right: 0, bottom: 4 },
  dashes: { flexDirection: 'row', overflow: 'hidden', height: 1 },
  dash: { width: 4, height: 1, marginRight: 4 },
  labels: { flexDirection: 'row', marginTop: space.xs },
});
