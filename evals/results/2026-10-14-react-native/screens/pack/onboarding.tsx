// Onboarding — single welcome + value list (mobile-ui "Quiet" skin).
// Job: get a new user recording their first note. Focal: the outcome headline.
// Primary: "Record my first note". Cut: carousel, permission prompts (asked in context later).

import React, { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Rect } from 'react-native-svg';
import { space, useTheme } from '../../pack/theme';
import {
  BottomActionBar,
  LargeTextFooter,
  ObjectCard,
  PrimaryButton,
  SecondaryButton,
  Txt,
} from '../../pack/components';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

const VALUE_PROPS: { icon: IconName; title: string; subtitle: string }[] = [
  { icon: 'mic-outline', title: 'Record in one tap', subtitle: 'Keeps going with the screen locked or offline' },
  { icon: 'sparkles-outline', title: 'Get the gist in seconds', subtitle: 'Summaries, key quotes and to-dos, written for you' },
  { icon: 'search-outline', title: 'Search what you said', subtitle: 'Find last Tuesday’s idea by any word in it' },
];

// A realistic sample note to show the outcome before asking for anything.
const SAMPLE_NOTE = {
  title: 'Walk home — pricing idea',
  meta: '3:47 · Yesterday, 6:12 PM',
  summary: 'Try a $4.99 starter tier for students; ask Priya to pull last term’s churn numbers before Friday.',
};

// Pseudo-random but fixed waveform amplitudes (0–1).
const WAVE = [0.3, 0.55, 0.8, 0.45, 0.95, 0.6, 0.35, 0.7, 1, 0.5, 0.25, 0.65, 0.85, 0.4, 0.6, 0.3, 0.75, 0.5, 0.9, 0.45, 0.2, 0.55, 0.7, 0.35, 0.6, 0.4, 0.8, 0.3];

function Waveform() {
  const { c } = useTheme();
  const barW = 3;
  const gap = 3;
  const h = 28;
  const width = WAVE.length * (barW + gap) - gap;
  return (
    <Svg width={width} height={h} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      {WAVE.map((a, i) => {
        const bh = Math.max(4, a * h);
        return <Rect key={i} x={i * (barW + gap)} y={(h - bh) / 2} width={barW} height={bh} rx={barW / 2} fill={c.accent} />;
      })}
    </Svg>
  );
}

export default function OnboardingScreen() {
  const { c } = useTheme();
  const insets = useSafeAreaInsets();
  const [starting, setStarting] = useState(false);

  const start = () => {
    setStarting(true);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    setTimeout(() => setStarting(false), 900);
  };

  const terms = (
    <Txt variant="footnote" color="ink2" style={styles.centerText}>
      By continuing you agree to the Terms and Privacy Policy. Recordings stay on your phone until you choose to sync.
    </Txt>
  );

  return (
    <View style={[styles.fill, { backgroundColor: c.canvas }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="auto" />

      <ScrollView
        style={styles.fill}
        contentInsetAdjustmentBehavior="never"
        contentContainerStyle={{
          paddingTop: insets.top + space.xxl,
          paddingHorizontal: space.margin,
          paddingBottom: space.xxl,
          gap: space.xxl,
        }}
      >
        <View style={{ gap: space.sm }}>
          <Txt variant="largeTitle" role="header">
            Say it once.{'\n'}Find it whenever.
          </Txt>
          <Txt variant="subhead" color="ink2">
            Murmur turns rambling voice memos into clean notes you can skim, search and share.
          </Txt>
        </View>

        <ObjectCard accessibilityLabel={`Example note: ${SAMPLE_NOTE.title}, ${SAMPLE_NOTE.meta}. ${SAMPLE_NOTE.summary}`}>
          <View style={{ gap: space.sm }}>
            <View style={styles.cardTop}>
              <Txt variant="headline" numberOfLines={1} style={styles.shrink}>
                {SAMPLE_NOTE.title}
              </Txt>
              <Txt variant="footnote" color="ink2">
                {SAMPLE_NOTE.meta}
              </Txt>
            </View>
            <Waveform />
            <Txt variant="subhead" color="ink2">
              {SAMPLE_NOTE.summary}
            </Txt>
          </View>
        </ObjectCard>

        <View style={{ gap: space.xl }}>
          {VALUE_PROPS.map((p) => (
            <View key={p.title} style={styles.prop} accessible accessibilityLabel={`${p.title}. ${p.subtitle}`}>
              <Ionicons name={p.icon} size={24} color={c.ink} />
              <View style={[styles.shrink, { gap: space.xxs }]}>
                <Txt variant="headline">{p.title}</Txt>
                <Txt variant="subhead" color="ink2">
                  {p.subtitle}
                </Txt>
              </View>
            </View>
          ))}
        </View>

        <LargeTextFooter>{terms}</LargeTextFooter>
      </ScrollView>

      <BottomActionBar footer={terms}>
        <PrimaryButton
          title="Record my first note"
          onPress={start}
          loading={starting}
          accessibilityHint="Asks for microphone access, then starts recording"
        />
        <SecondaryButton title="Log in" onPress={() => {}} />
      </BottomActionBar>
    </View>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  cardTop: { flexDirection: 'row', alignItems: 'baseline', justifyContent: 'space-between', gap: space.sm, flexWrap: 'wrap' },
  shrink: { flexShrink: 1 },
  prop: { flexDirection: 'row', alignItems: 'flex-start', gap: space.md },
  centerText: { textAlign: 'center' },
});
