import React, { useEffect, useMemo, useRef } from 'react';
import {
  Animated,
  Easing,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useColorScheme,
  useWindowDimensions,
  AccessibilityInfo,
} from 'react-native';
import { Stack, router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Rect } from 'react-native-svg';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

const SAMPLE_NOTE = {
  title: 'Q3 roadmap sync with Priya',
  duration: '4:12',
  recordedAt: 'Today, 9:41 AM',
  transcript:
    '“…so let’s push the offline mode to October and make sure search ships first. Priya will send the revised timeline by Friday.”',
  summary: [
    'Offline mode moves to October',
    'Search ships first',
  ],
  action: 'Priya: send revised timeline by Fri',
};

const FEATURES: { icon: IconName; title: string; body: string }[] = [
  {
    icon: 'mic',
    title: 'Just talk',
    body: 'Tap once to record. Works offline and in 40+ languages.',
  },
  {
    icon: 'sparkles',
    title: 'Instant summaries',
    body: 'Get key points, action items and a clean transcript in seconds.',
  },
  {
    icon: 'search',
    title: 'Find anything you said',
    body: 'Search every note by what was said, not when you said it.',
  },
  {
    icon: 'lock-closed',
    title: 'Private by default',
    body: 'Notes are encrypted on your device. You choose what syncs.',
  },
];

// Deterministic waveform heights (0–1)
const WAVE = [
  0.25, 0.4, 0.62, 0.35, 0.8, 0.55, 0.92, 0.48, 0.7, 0.3, 0.58, 0.85, 0.45, 0.66,
  0.38, 0.9, 0.52, 0.28, 0.74, 0.6, 0.42, 0.82, 0.36, 0.64, 0.5, 0.3, 0.56, 0.22,
];

function palette(dark: boolean) {
  return dark
    ? {
        bg: '#0B0B12',
        card: '#17171F',
        cardBorder: 'rgba(255,255,255,0.08)',
        text: '#F5F5F7',
        secondary: 'rgba(235,235,245,0.68)',
        tertiary: 'rgba(235,235,245,0.45)',
        accent: '#8B7CFF',
        accentSoft: 'rgba(139,124,255,0.18)',
        chip: 'rgba(255,255,255,0.08)',
        heroTop: '#2A1F5C',
        heroBottom: '#0B0B12',
        buttonText: '#FFFFFF',
        separator: 'rgba(255,255,255,0.1)',
      }
    : {
        bg: '#F7F6FB',
        card: '#FFFFFF',
        cardBorder: 'rgba(17,17,40,0.06)',
        text: '#111128',
        secondary: 'rgba(17,17,40,0.66)',
        tertiary: 'rgba(17,17,40,0.45)',
        accent: '#5B47F5',
        accentSoft: 'rgba(91,71,245,0.1)',
        chip: 'rgba(17,17,40,0.05)',
        heroTop: '#E4DEFF',
        heroBottom: '#F7F6FB',
        buttonText: '#FFFFFF',
        separator: 'rgba(17,17,40,0.08)',
      };
}

function Waveform({ color, dim, height = 36 }: { color: string; dim: string; height?: number }) {
  const barW = 4;
  const gap = 3;
  const width = WAVE.length * (barW + gap) - gap;
  const played = Math.round(WAVE.length * 0.4);
  return (
    <Svg width="100%" height={height} viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
      {WAVE.map((h, i) => {
        const bh = Math.max(4, h * height);
        return (
          <Rect
            key={i}
            x={i * (barW + gap)}
            y={(height - bh) / 2}
            width={barW}
            height={bh}
            rx={2}
            fill={i < played ? color : dim}
          />
        );
      })}
    </Svg>
  );
}

function PulsingMic({ accent, reduceMotion }: { accent: string; reduceMotion: boolean }) {
  const pulse = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (reduceMotion) return;
    const loop = Animated.loop(
      Animated.timing(pulse, {
        toValue: 1,
        duration: 2200,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    );
    loop.start();
    return () => loop.stop();
  }, [pulse, reduceMotion]);

  const ringStyle = {
    opacity: pulse.interpolate({ inputRange: [0, 1], outputRange: [0.45, 0] }),
    transform: [{ scale: pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 1.9] }) }],
  };

  return (
    <View style={styles.micWrap} accessible={false} importantForAccessibility="no-hide-descendants">
      {!reduceMotion && (
        <Animated.View style={[styles.micRing, { backgroundColor: accent }, ringStyle]} />
      )}
      <LinearGradient
        colors={[accent, '#C25BFF']}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.micCircle}
      >
        <Ionicons name="mic" size={34} color="#FFFFFF" />
      </LinearGradient>
    </View>
  );
}

export default function OnboardingScreen() {
  const scheme = useColorScheme();
  const dark = scheme === 'dark';
  const c = useMemo(() => palette(dark), [dark]);
  const insets = useSafeAreaInsets();
  const { fontScale, width } = useWindowDimensions();
  const largeText = fontScale >= 1.35;
  const [reduceMotion, setReduceMotion] = React.useState(false);

  useEffect(() => {
    let mounted = true;
    AccessibilityInfo.isReduceMotionEnabled().then((v) => mounted && setReduceMotion(v));
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduceMotion);
    return () => {
      mounted = false;
      sub.remove();
    };
  }, []);

  const contentWidth = Math.min(width, 560);

  const onStart = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    router.push('/');
  };

  const onSignIn = () => {
    Haptics.selectionAsync();
  };

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={dark ? 'light' : 'dark'} />

      <LinearGradient
        colors={[c.heroTop, c.heroBottom]}
        style={StyleSheet.absoluteFill}
        end={{ x: 0.5, y: 0.55 }}
        pointerEvents="none"
      />

      <ScrollView
        contentContainerStyle={[
          styles.scroll,
          { paddingTop: insets.top + 24, alignItems: 'center' },
        ]}
        showsVerticalScrollIndicator={false}
        contentInsetAdjustmentBehavior="never"
      >
        <View style={{ width: contentWidth, paddingHorizontal: 24 }}>
          {/* Hero */}
          <View style={styles.hero}>
            <PulsingMic accent={c.accent} reduceMotion={reduceMotion} />
            <Text
              accessibilityRole="header"
              style={[styles.title, { color: c.text }]}
              maxFontSizeMultiplier={1.8}
            >
              Speak your mind.{'\n'}We’ll take the notes.
            </Text>
            <Text style={[styles.subtitle, { color: c.secondary }]} maxFontSizeMultiplier={2}>
              Murmur turns your voice into clear, searchable notes with summaries and to-dos — in seconds.
            </Text>
          </View>

          {/* Sample note preview */}
          <View
            style={[
              styles.card,
              { backgroundColor: c.card, borderColor: c.cardBorder },
              !dark && styles.cardShadow,
            ]}
            accessible
            accessibilityLabel={`Example note: ${SAMPLE_NOTE.title}, ${SAMPLE_NOTE.duration} long. Summary: ${SAMPLE_NOTE.summary.join(
              ', ',
            )}. Action item: ${SAMPLE_NOTE.action}.`}
          >
            <View style={[styles.cardHeader, largeText && styles.stack]}>
              <View style={{ flexShrink: 1 }}>
                <Text style={[styles.cardTitle, { color: c.text }]} maxFontSizeMultiplier={2}>
                  {SAMPLE_NOTE.title}
                </Text>
                <Text style={[styles.meta, { color: c.tertiary }]} maxFontSizeMultiplier={2}>
                  {SAMPLE_NOTE.recordedAt} · {SAMPLE_NOTE.duration}
                </Text>
              </View>
              <View style={[styles.aiBadge, { backgroundColor: c.accentSoft }]}>
                <Ionicons name="sparkles" size={12} color={c.accent} />
                <Text style={[styles.aiBadgeText, { color: c.accent }]} maxFontSizeMultiplier={1.6}>
                  AI summary
                </Text>
              </View>
            </View>

            <View style={styles.waveRow}>
              <View style={[styles.playBtn, { backgroundColor: c.accent }]}>
                <Ionicons name="play" size={14} color="#FFFFFF" style={{ marginLeft: 2 }} />
              </View>
              <View style={{ flex: 1 }}>
                <Waveform color={c.accent} dim={c.separator} />
              </View>
            </View>

            <Text style={[styles.transcript, { color: c.secondary }]} maxFontSizeMultiplier={2}>
              {SAMPLE_NOTE.transcript}
            </Text>

            <View style={[styles.divider, { backgroundColor: c.separator }]} />

            {SAMPLE_NOTE.summary.map((s) => (
              <View key={s} style={styles.bulletRow}>
                <View style={[styles.bullet, { backgroundColor: c.accent }]} />
                <Text style={[styles.bulletText, { color: c.text }]} maxFontSizeMultiplier={2}>
                  {s}
                </Text>
              </View>
            ))}
            <View style={[styles.actionChip, { backgroundColor: c.chip }]}>
              <Ionicons name="checkbox-outline" size={16} color={c.accent} />
              <Text style={[styles.actionText, { color: c.text }]} maxFontSizeMultiplier={2}>
                {SAMPLE_NOTE.action}
              </Text>
            </View>
          </View>

          {/* Features */}
          <View style={styles.features}>
            {FEATURES.map((f) => (
              <View
                key={f.title}
                style={[styles.featureRow, largeText && styles.stack]}
                accessible
                accessibilityLabel={`${f.title}. ${f.body}`}
              >
                <View style={[styles.featureIcon, { backgroundColor: c.accentSoft }]}>
                  <Ionicons name={f.icon} size={20} color={c.accent} />
                </View>
                <View style={styles.featureText}>
                  <Text style={[styles.featureTitle, { color: c.text }]}>{f.title}</Text>
                  <Text style={[styles.featureBody, { color: c.secondary }]}>{f.body}</Text>
                </View>
              </View>
            ))}
          </View>
        </View>
      </ScrollView>

      {/* Bottom actions */}
      <View
        style={[
          styles.footer,
          {
            paddingBottom: Math.max(insets.bottom, 16) + 4,
            backgroundColor: c.bg,
            borderTopColor: c.separator,
          },
        ]}
      >
        <View style={{ width: contentWidth, paddingHorizontal: 24, alignSelf: 'center' }}>
          <Pressable
            onPress={onStart}
            accessibilityRole="button"
            accessibilityLabel="Get started"
            accessibilityHint="Sets up microphone access and opens your notes"
            style={({ pressed }) => [
              styles.primary,
              { backgroundColor: c.accent, opacity: pressed ? 0.85 : 1 },
              pressed && { transform: [{ scale: 0.98 }] },
            ]}
          >
            <Text style={[styles.primaryText, { color: c.buttonText }]} maxFontSizeMultiplier={1.6}>
              Get started
            </Text>
          </Pressable>
          <Pressable
            onPress={onSignIn}
            accessibilityRole="button"
            hitSlop={8}
            style={({ pressed }) => [styles.secondary, { opacity: pressed ? 0.6 : 1 }]}
          >
            <Text style={[styles.secondaryText, { color: c.secondary }]} maxFontSizeMultiplier={1.6}>
              Already have an account?{' '}
              <Text style={{ color: c.accent, fontWeight: '600' }}>Sign in</Text>
            </Text>
          </Pressable>
          <Text style={[styles.legal, { color: c.tertiary }]} maxFontSizeMultiplier={1.6}>
            Free for 30 minutes of recording a month. No credit card needed.
          </Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  scroll: { paddingBottom: 32 },
  hero: { alignItems: 'center', marginBottom: 28 },
  micWrap: {
    width: 96,
    height: 96,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 24,
  },
  micRing: {
    position: 'absolute',
    width: 88,
    height: 88,
    borderRadius: 44,
  },
  micCircle: {
    width: 88,
    height: 88,
    borderRadius: 44,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 32,
    lineHeight: 38,
    fontWeight: '800',
    letterSpacing: -0.6,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 17,
    lineHeight: 24,
    textAlign: 'center',
    marginTop: 12,
  },
  card: {
    borderRadius: 22,
    borderWidth: StyleSheet.hairlineWidth,
    padding: 18,
    marginBottom: 28,
  },
  cardShadow: Platform.select({
    ios: {
      shadowColor: '#2A1F5C',
      shadowOpacity: 0.12,
      shadowRadius: 24,
      shadowOffset: { width: 0, height: 10 },
    },
    default: { elevation: 4 },
  }) as object,
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    gap: 12,
  },
  stack: { flexDirection: 'column', alignItems: 'flex-start' },
  cardTitle: { fontSize: 17, fontWeight: '700' },
  meta: { fontSize: 13, marginTop: 2 },
  aiBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
  },
  aiBadgeText: { fontSize: 12, fontWeight: '700' },
  waveRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 16,
    marginBottom: 14,
  },
  playBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  transcript: { fontSize: 15, lineHeight: 21, fontStyle: 'italic' },
  divider: { height: StyleSheet.hairlineWidth, marginVertical: 14 },
  bulletRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 10, marginBottom: 8 },
  bullet: { width: 6, height: 6, borderRadius: 3, marginTop: 8 },
  bulletText: { flex: 1, fontSize: 15, lineHeight: 21 },
  actionChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 12,
    marginTop: 6,
  },
  actionText: { flex: 1, fontSize: 15, fontWeight: '600' },
  features: { gap: 20 },
  featureRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 14 },
  featureIcon: {
    width: 40,
    height: 40,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  featureText: { flex: 1, flexShrink: 1 },
  featureTitle: { fontSize: 17, fontWeight: '600' },
  featureBody: { fontSize: 15, lineHeight: 21, marginTop: 2 },
  footer: {
    paddingTop: 14,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  primary: {
    minHeight: 54,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
    paddingVertical: 14,
  },
  primaryText: { fontSize: 17, fontWeight: '700' },
  secondary: {
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 6,
  },
  secondaryText: { fontSize: 15, textAlign: 'center' },
  legal: { fontSize: 12, textAlign: 'center', marginTop: 2 },
});
