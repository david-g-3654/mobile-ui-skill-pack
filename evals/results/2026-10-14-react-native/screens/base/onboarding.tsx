import React, { useEffect, useRef, useState } from 'react';
import {
  AccessibilityInfo,
  Animated,
  Easing,
  NativeScrollEvent,
  NativeSyntheticEvent,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle, Defs, RadialGradient, Stop } from 'react-native-svg';

const C = {
  bg: '#0B0D12',
  bg2: '#141821',
  card: '#171B25',
  border: 'rgba(255,255,255,0.08)',
  text: '#F4F5F7',
  sub: '#A3A9B7',
  muted: '#6B7280',
  accent: '#FF7A59',
  accent2: '#FFB36B',
  teal: '#5EEAD4',
};

type Page = {
  key: string;
  eyebrow: string;
  title: string;
  body: string;
};

const PAGES: Page[] = [
  {
    key: 'capture',
    eyebrow: 'Capture',
    title: 'Talk. We’ll\ntake the notes.',
    body: 'Tap once to record meetings, walks, or 2 a.m. ideas. Works offline and keeps going with the screen locked.',
  },
  {
    key: 'transcribe',
    eyebrow: 'Transcribe',
    title: 'Every word,\nsearchable.',
    body: 'Accurate transcripts in 40+ languages with speaker labels, so you can jump straight to the part that matters.',
  },
  {
    key: 'summarize',
    eyebrow: 'Summarize',
    title: 'From rambling\nto ready.',
    body: 'Get a clean summary and to-dos from each note, ready to drop into your calendar, email, or task list.',
  },
];

const BARS = [
  0.35, 0.6, 0.45, 0.8, 0.55, 0.95, 0.7, 0.4, 0.65, 0.9, 0.5, 0.75, 0.3, 0.6, 0.85, 0.45, 0.7,
  0.5, 0.35, 0.6,
];

function Waveform({ reduceMotion }: { reduceMotion: boolean }) {
  const t = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (reduceMotion) return;
    const loop = Animated.loop(
      Animated.timing(t, {
        toValue: 1,
        duration: 1600,
        easing: Easing.inOut(Easing.sin),
        useNativeDriver: true,
      }),
    );
    loop.start();
    return () => loop.stop();
  }, [reduceMotion, t]);

  return (
    <View style={styles.waveRow}>
      {BARS.map((h, i) => {
        const phase = (i % 5) / 5;
        const scale = reduceMotion
          ? h
          : t.interpolate({
              inputRange: [0, 0.5, 1],
              outputRange: [h * (0.6 + phase * 0.3), h, h * (0.6 + phase * 0.3)],
            });
        return (
          <Animated.View
            key={i}
            style={[
              styles.waveBar,
              {
                backgroundColor: i < 13 ? C.accent : 'rgba(255,255,255,0.22)',
                transform: [{ scaleY: scale }],
              },
            ]}
          />
        );
      })}
    </View>
  );
}

function CaptureVisual({ reduceMotion }: { reduceMotion: boolean }) {
  return (
    <View style={styles.visualWrap}>
      <Svg width={260} height={260} style={StyleSheet.absoluteFill as object}>
        <Defs>
          <RadialGradient id="glow" cx="50%" cy="50%" r="50%">
            <Stop offset="0%" stopColor={C.accent} stopOpacity={0.45} />
            <Stop offset="100%" stopColor={C.accent} stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Circle cx={130} cy={130} r={130} fill="url(#glow)" />
        <Circle cx={130} cy={130} r={92} stroke="rgba(255,255,255,0.08)" strokeWidth={1} fill="none" />
        <Circle cx={130} cy={130} r={118} stroke="rgba(255,255,255,0.05)" strokeWidth={1} fill="none" />
      </Svg>
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <View style={styles.liveDot} />
          <Text style={styles.cardMeta}>Recording · 03:42</Text>
        </View>
        <Text style={styles.cardTitle}>Product sync with Maya</Text>
        <Waveform reduceMotion={reduceMotion} />
        <View style={styles.micButton}>
          <Ionicons name="mic" size={22} color="#fff" />
        </View>
      </View>
    </View>
  );
}

const TRANSCRIPT = [
  { who: 'Maya', time: '01:12', text: 'Can we ship the export feature before the Berlin launch?' },
  { who: 'You', time: '01:19', text: 'If design signs off Thursday, yes — I’ll draft the release notes.' },
  { who: 'Maya', time: '01:31', text: 'Great. Let’s loop in Theo on pricing too.' },
];

function TranscribeVisual() {
  return (
    <View style={styles.visualWrap}>
      <View style={[styles.card, { gap: 12 }]}>
        <View style={styles.searchPill}>
          <Ionicons name="search" size={14} color={C.sub} />
          <Text style={styles.searchText}>“release notes”</Text>
        </View>
        {TRANSCRIPT.map((line) => (
          <View key={line.time} style={styles.line}>
            <View style={[styles.avatar, line.who === 'You' && { backgroundColor: C.teal }]}>
              <Text style={styles.avatarText}>{line.who[0]}</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.lineMeta}>
                {line.who} · {line.time}
              </Text>
              <Text style={styles.lineText}>
                {line.text.includes('release notes') ? (
                  <>
                    {line.text.split('release notes')[0]}
                    <Text style={styles.highlight}>release notes</Text>
                    {line.text.split('release notes')[1]}
                  </>
                ) : (
                  line.text
                )}
              </Text>
            </View>
          </View>
        ))}
      </View>
    </View>
  );
}

const TODOS = [
  { text: 'Draft release notes for export', due: 'Wed', done: true },
  { text: 'Get design sign-off', due: 'Thu', done: false },
  { text: 'Ask Theo about Berlin pricing', due: 'Fri', done: false },
];

function SummarizeVisual() {
  return (
    <View style={styles.visualWrap}>
      <View style={[styles.card, { gap: 12 }]}>
        <View style={styles.cardHeader}>
          <Ionicons name="sparkles" size={14} color={C.accent2} />
          <Text style={[styles.cardMeta, { color: C.accent2 }]}>AI summary</Text>
        </View>
        <Text style={styles.summaryText}>
          Export ships before the Berlin launch, pending Thursday design review. Pricing needs
          Theo’s input.
        </Text>
        <View style={styles.divider} />
        {TODOS.map((todo) => (
          <View key={todo.text} style={styles.todo}>
            <Ionicons
              name={todo.done ? 'checkmark-circle' : 'ellipse-outline'}
              size={18}
              color={todo.done ? C.teal : C.muted}
            />
            <Text style={[styles.todoText, todo.done && styles.todoDone]} numberOfLines={1}>
              {todo.text}
            </Text>
            <Text style={styles.todoDue}>{todo.due}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

export default function OnboardingScreen() {
  const { width } = useWindowDimensions();
  const scrollRef = useRef<ScrollView>(null);
  const scrollX = useRef(new Animated.Value(0)).current;
  const [index, setIndex] = useState(0);
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    AccessibilityInfo.isReduceMotionEnabled().then(setReduceMotion).catch(() => {});
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduceMotion);
    return () => sub.remove();
  }, []);

  const isLast = index === PAGES.length - 1;

  const tap = () => {
    if (Platform.OS !== 'web') Haptics.selectionAsync().catch(() => {});
  };

  const goTo = (i: number) => {
    scrollRef.current?.scrollTo({ x: i * width, animated: !reduceMotion });
    setIndex(i);
  };

  const onNext = () => {
    if (isLast) {
      if (Platform.OS !== 'web') {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
      }
      // In the real app: router.replace('/(tabs)') after requesting mic permission.
      return;
    }
    tap();
    goTo(index + 1);
  };

  const onSkip = () => {
    tap();
    goTo(PAGES.length - 1);
  };

  const onMomentumEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const i = Math.round(e.nativeEvent.contentOffset.x / width);
    if (i !== index) {
      tap();
      setIndex(i);
    }
  };

  const renderVisual = (key: string) => {
    if (key === 'capture') return <CaptureVisual reduceMotion={reduceMotion} />;
    if (key === 'transcribe') return <TranscribeVisual />;
    return <SummarizeVisual />;
  };

  return (
    <View style={styles.root}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="light" />
      <LinearGradient colors={[C.bg2, C.bg]} style={StyleSheet.absoluteFill} />

      <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
        <View style={styles.topBar}>
          <View style={styles.brand}>
            <LinearGradient
              colors={[C.accent, C.accent2]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.logo}
            >
              <Ionicons name="mic" size={14} color="#fff" />
            </LinearGradient>
            <Text style={styles.brandText}>Murmur</Text>
          </View>
          {!isLast && (
            <Pressable
              onPress={onSkip}
              hitSlop={12}
              accessibilityRole="button"
              accessibilityLabel="Skip introduction"
              style={({ pressed }) => [styles.skip, pressed && { opacity: 0.6 }]}
            >
              <Text style={styles.skipText}>Skip</Text>
            </Pressable>
          )}
        </View>

        <Animated.ScrollView
          ref={scrollRef as unknown as React.RefObject<ScrollView>}
          horizontal
          pagingEnabled
          bounces={false}
          showsHorizontalScrollIndicator={false}
          onMomentumScrollEnd={onMomentumEnd}
          scrollEventThrottle={16}
          onScroll={Animated.event([{ nativeEvent: { contentOffset: { x: scrollX } } }], {
            useNativeDriver: true,
          })}
          style={{ flex: 1 }}
        >
          {PAGES.map((page, i) => {
            const range = [(i - 1) * width, i * width, (i + 1) * width];
            const opacity = scrollX.interpolate({
              inputRange: range,
              outputRange: [0, 1, 0],
              extrapolate: 'clamp',
            });
            const translateY = scrollX.interpolate({
              inputRange: range,
              outputRange: [24, 0, 24],
              extrapolate: 'clamp',
            });
            return (
              <View
                key={page.key}
                style={[styles.page, { width }]}
                accessibilityLabel={`Step ${i + 1} of ${PAGES.length}`}
              >
                <View style={styles.visualArea}>{renderVisual(page.key)}</View>
                <Animated.View style={[styles.copy, { opacity, transform: [{ translateY }] }]}>
                  <Text style={styles.eyebrow}>{page.eyebrow.toUpperCase()}</Text>
                  <Text style={styles.title} accessibilityRole="header">
                    {page.title}
                  </Text>
                  <Text style={styles.body}>{page.body}</Text>
                </Animated.View>
              </View>
            );
          })}
        </Animated.ScrollView>

        <View style={styles.footer}>
          <View style={styles.dots}>
            {PAGES.map((p, i) => {
              const w = scrollX.interpolate({
                inputRange: [(i - 1) * width, i * width, (i + 1) * width],
                outputRange: [8, 24, 8],
                extrapolate: 'clamp',
              });
              const op = scrollX.interpolate({
                inputRange: [(i - 1) * width, i * width, (i + 1) * width],
                outputRange: [0.3, 1, 0.3],
                extrapolate: 'clamp',
              });
              return (
                <Pressable
                  key={p.key}
                  onPress={() => {
                    tap();
                    goTo(i);
                  }}
                  hitSlop={8}
                  accessibilityRole="button"
                  accessibilityLabel={`Go to step ${i + 1}`}
                  accessibilityState={{ selected: i === index }}
                >
                  <Animated.View style={[styles.dot, { width: w, opacity: op }]} />
                </Pressable>
              );
            })}
          </View>

          <Pressable
            onPress={onNext}
            accessibilityRole="button"
            accessibilityLabel={isLast ? 'Get started' : 'Continue'}
            style={({ pressed }) => [styles.ctaWrap, pressed && { transform: [{ scale: 0.98 }] }]}
          >
            <LinearGradient
              colors={[C.accent, C.accent2]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={styles.cta}
            >
              <Text style={styles.ctaText}>{isLast ? 'Start my first note' : 'Continue'}</Text>
              <Ionicons name={isLast ? 'mic' : 'arrow-forward'} size={18} color="#1A0E08" />
            </LinearGradient>
          </Pressable>

          <Text style={styles.legal}>
            {isLast
              ? 'We’ll ask for microphone access next. Recordings stay private to you.'
              : 'Already have an account? Sign in'}
          </Text>
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: C.bg },
  safe: { flex: 1 },
  topBar: {
    height: 52,
    paddingHorizontal: 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  logo: {
    width: 28,
    height: 28,
    borderRadius: 9,
    alignItems: 'center',
    justifyContent: 'center',
  },
  brandText: { color: C.text, fontSize: 17, fontWeight: '700', letterSpacing: -0.2 },
  skip: { paddingHorizontal: 12, paddingVertical: 8, minHeight: 44, justifyContent: 'center' },
  skipText: { color: C.sub, fontSize: 15, fontWeight: '600' },

  page: { flex: 1, paddingHorizontal: 24 },
  visualArea: { flex: 1, alignItems: 'center', justifyContent: 'center', minHeight: 280 },
  visualWrap: { width: 300, height: 260, alignItems: 'center', justifyContent: 'center' },
  copy: { paddingBottom: 8 },
  eyebrow: { color: C.accent, fontSize: 12, fontWeight: '700', letterSpacing: 1.6, marginBottom: 10 },
  title: { color: C.text, fontSize: 34, lineHeight: 40, fontWeight: '800', letterSpacing: -0.8 },
  body: { color: C.sub, fontSize: 16, lineHeight: 23, marginTop: 12, maxWidth: 360 },

  card: {
    width: 290,
    backgroundColor: C.card,
    borderRadius: 22,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: C.border,
    padding: 18,
    shadowColor: '#000',
    shadowOpacity: 0.4,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 12 },
    elevation: 10,
  },
  cardHeader: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  liveDot: { width: 8, height: 8, borderRadius: 4, backgroundColor: '#FF4D4D' },
  cardMeta: { color: C.sub, fontSize: 12, fontWeight: '600', fontVariant: ['tabular-nums'] },
  cardTitle: { color: C.text, fontSize: 17, fontWeight: '700', marginTop: 8 },
  waveRow: {
    height: 56,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginTop: 14,
  },
  waveBar: { flex: 1, height: 56, borderRadius: 3 },
  micButton: {
    alignSelf: 'center',
    marginTop: 16,
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: C.accent,
    alignItems: 'center',
    justifyContent: 'center',
  },

  searchPill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: 'rgba(255,255,255,0.06)',
    borderRadius: 10,
    paddingHorizontal: 10,
    paddingVertical: 8,
  },
  searchText: { color: C.text, fontSize: 13 },
  line: { flexDirection: 'row', gap: 10 },
  avatar: {
    width: 26,
    height: 26,
    borderRadius: 13,
    backgroundColor: C.accent2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: { color: '#1A0E08', fontSize: 12, fontWeight: '800' },
  lineMeta: { color: C.muted, fontSize: 11, fontWeight: '600', fontVariant: ['tabular-nums'] },
  lineText: { color: C.text, fontSize: 13, lineHeight: 18, marginTop: 2 },
  highlight: { backgroundColor: 'rgba(255,122,89,0.3)', color: '#fff', fontWeight: '600' },

  summaryText: { color: C.text, fontSize: 14, lineHeight: 20 },
  divider: { height: StyleSheet.hairlineWidth, backgroundColor: C.border },
  todo: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  todoText: { flex: 1, color: C.text, fontSize: 14 },
  todoDone: { color: C.muted, textDecorationLine: 'line-through' },
  todoDue: { color: C.muted, fontSize: 12, fontWeight: '600' },

  footer: { paddingHorizontal: 24, paddingTop: 12, paddingBottom: 8, gap: 18 },
  dots: { flexDirection: 'row', gap: 6, alignItems: 'center', height: 20 },
  dot: { height: 8, borderRadius: 4, backgroundColor: C.text },
  ctaWrap: { borderRadius: 16, overflow: 'hidden' },
  cta: {
    height: 56,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  ctaText: { color: '#1A0E08', fontSize: 17, fontWeight: '700' },
  legal: { color: C.muted, fontSize: 13, textAlign: 'center', lineHeight: 18 },
});
