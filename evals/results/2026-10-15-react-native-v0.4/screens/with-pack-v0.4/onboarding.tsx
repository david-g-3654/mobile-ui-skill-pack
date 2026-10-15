// Onboarding — single welcome + value list (mobile-ui, default "Quiet" skin).
// Job: get a new user to record their first note. Focal: the outcome headline.
// Primary: "Record your first note". Cut: carousel, permission prompts (asked in context on first record).

import React from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { radius, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QLargeTextFooter,
  QBottomActionBar,
  QObjectCard,
  QPrimaryButton,
  QSecondaryButton,
  QText,
  useQLargeText,
} from '../../pack04/components';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

const VALUE_PROPS: { icon: IconName; title: string; subtitle: string }[] = [
  {
    icon: 'mic-outline',
    title: 'Ramble for as long as you like',
    subtitle: 'Up to two hours per note, transcribed in 38 languages.',
  },
  {
    icon: 'sparkles-outline',
    title: 'Get the gist, not the transcript',
    subtitle: 'Summaries, to-dos and key quotes pulled out for you.',
  },
  {
    icon: 'search-outline',
    title: 'Find what you meant',
    subtitle: 'Search by idea, even if you never said the exact words.',
  },
];

// Sample note shown as the hero object: a real-looking recording mid-transcription.
const SAMPLE_NOTE = {
  title: 'Walk home — pricing idea',
  meta: 'Tue 8:42 PM',
  duration: '3:17',
  summary: 'Drop the monthly tier to $6.99, keep annual at $49. Ask Priya about the student discount before Friday.',
};

// Deterministic waveform heights (0–1). First 60% has "played".
const WAVE = [0.35, 0.6, 0.45, 0.8, 0.55, 0.95, 0.7, 0.4, 0.65, 0.85, 0.5, 0.3, 0.55, 0.75, 0.6, 0.9, 0.45, 0.35, 0.6, 0.5, 0.7, 0.4, 0.3, 0.55, 0.45, 0.25, 0.4, 0.3];
const PLAYED = Math.round(WAVE.length * 0.6);
const WAVE_HEIGHT = 32;

function Waveform() {
  const { c } = useQTheme();
  return (
    <View style={styles.wave} importantForAccessibility="no-hide-descendants" accessibilityElementsHidden>
      {WAVE.map((h, i) => (
        <View
          key={i}
          style={[
            styles.waveBar,
            { height: Math.max(4, h * WAVE_HEIGHT), backgroundColor: i < PLAYED ? c.accent : c.hairline },
          ]}
        />
      ))}
    </View>
  );
}

function SampleNoteCard() {
  return (
    <QObjectCard
      accessibilityLabel={`Example note: ${SAMPLE_NOTE.title}, ${SAMPLE_NOTE.duration} long. Summary: ${SAMPLE_NOTE.summary}`}
      style={styles.card}
    >
      <View style={styles.cardHeader}>
        <QText variant="headline" style={styles.flex} numberOfLines={2}>
          {SAMPLE_NOTE.title}
        </QText>
        <QText variant="footnote" color="ink2" style={tabular}>
          {SAMPLE_NOTE.duration}
        </QText>
      </View>
      <Waveform />
      <QText variant="subhead" color="ink2">
        {SAMPLE_NOTE.summary}
      </QText>
      <QText variant="footnote" color="ink2">
        {SAMPLE_NOTE.meta}
      </QText>
    </QObjectCard>
  );
}

function ValueRow({ icon, title, subtitle }: (typeof VALUE_PROPS)[number]) {
  const { c } = useQTheme();
  const large = useQLargeText();
  return (
    <View style={[styles.valueRow, large && styles.valueRowStacked]} accessible accessibilityLabel={`${title}. ${subtitle}`}>
      <Ionicons name={icon} size={24} color={c.ink} style={styles.valueIcon} />
      <View style={styles.flex}>
        <QText variant="headline">{title}</QText>
        <QText variant="subhead" color="ink2">
          {subtitle}
        </QText>
      </View>
    </View>
  );
}

function TermsLine() {
  return (
    <QText variant="footnote" color="ink2" style={styles.terms}>
      By continuing you agree to the Terms and Privacy Policy. Recordings stay private to you.
    </QText>
  );
}

export default function OnboardingScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const start = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    // Mic permission is requested in context on the record screen, with its own pre-prompt.
    if (router.canGoBack()) router.back();
  };
  const logIn = () => {
    if (router.canGoBack()) router.back();
  };

  return (
    <View style={[styles.flex, { backgroundColor: c.canvas }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="auto" />
      <ScrollView
        style={styles.flex}
        contentInsetAdjustmentBehavior="never"
        contentContainerStyle={[styles.content, { paddingTop: insets.top + space.xl }]}
      >
        <View style={styles.brand}>
          <Ionicons name="radio-outline" size={20} color={c.ink} />
          <QText variant="headline">Murmur</QText>
        </View>

        <SampleNoteCard />

        <View style={styles.headlineBlock}>
          <QText variant="largeTitle" role="header">
            Think out loud. Read it back sorted.
          </QText>
          <QText variant="body" color="ink2">
            Murmur turns voice memos into clean notes you can skim, search and share.
          </QText>
        </View>

        <View style={styles.values}>
          {VALUE_PROPS.map((v) => (
            <ValueRow key={v.title} {...v} />
          ))}
        </View>

        <QLargeTextFooter>
          <TermsLine />
        </QLargeTextFooter>
      </ScrollView>

      <QBottomActionBar footer={<TermsLine />}>
        <QPrimaryButton title="Record your first note" onPress={start} />
        <QSecondaryButton title="Log in" onPress={logIn} />
      </QBottomActionBar>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: {
    paddingHorizontal: space.margin,
    paddingBottom: space.xxl,
    gap: space.xxl,
  },
  brand: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  card: { gap: space.sm },
  cardHeader: { flexDirection: 'row', alignItems: 'flex-start', gap: space.sm },
  wave: { flexDirection: 'row', alignItems: 'center', height: WAVE_HEIGHT, gap: space.xxs },
  waveBar: { flex: 1, borderRadius: radius.capsule },
  headlineBlock: { gap: space.sm },
  values: { gap: space.xl },
  valueRow: { flexDirection: 'row', alignItems: 'flex-start', gap: space.md },
  valueRowStacked: { flexDirection: 'column', gap: space.xs },
  valueIcon: { marginTop: 1 },
  terms: { textAlign: 'center' },
});
