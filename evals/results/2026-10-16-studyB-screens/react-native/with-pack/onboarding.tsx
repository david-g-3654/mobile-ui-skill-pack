import React, { useRef, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { metrics, radius, space, useQTheme } from '../../pack04/theme';
import {
  QBottomActionBar,
  QLargeTextFooter,
  QPrimaryButton,
  QText,
  useQLargeText,
} from '../../pack04/components';

const waveform = [2, 3, 5, 3, 7, 10, 6, 4, 8, 12, 9, 5, 7, 4, 2, 4, 7, 11, 8, 5, 9, 12, 7, 4, 6, 9, 5, 3, 6, 8, 4, 2];
const sample = {
  title: 'The bookshop idea',
  transcript: '“Saturday, let’s try that little bookshop on Bell Street. Maybe coffee with Maya after? Oh, and take the camera. I keep forgetting to bring it.”',
  summary: 'Visit the Bell Street bookshop, then meet Maya for coffee.',
  action: 'Bring the camera.',
};

export default function OnboardingScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const largeText = useQLargeText();
  const scrollRef = useRef<ScrollView>(null);
  const [started, setStarted] = useState(false);
  const [saved, setSaved] = useState(false);
  const [tab, setTab] = useState<'summary' | 'transcript'>('summary');

  const reset = () => {
    setStarted(false);
    setSaved(false);
    setTab('summary');
    scrollRef.current?.scrollTo({ y: 0, animated: false });
  };

  const handlePrimary = () => {
    if (saved) {
      reset();
      return;
    }
    if (!started) {
      setStarted(true);
      scrollRef.current?.scrollTo({ y: 0, animated: false });
      return;
    }
    setSaved(true);
    void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    scrollRef.current?.scrollTo({ y: 0, animated: false });
  };

  const footer = started ? (
    <Pressable
      accessibilityRole="button"
      onPress={reset}
      style={({ pressed }) => [styles.footerLink, pressed && { backgroundColor: c.surface2 }]}
    >
      <QText variant="footnote" color="ink2">Back to welcome</QText>
    </Pressable>
  ) : (
    <QText variant="footnote" color="ink2" style={styles.center}>
      No account. Just a little clarity.
    </QText>
  );

  return (
    <View style={[styles.screen, { backgroundColor: c.canvas, paddingTop: insets.top }]}>
      <Stack.Screen options={{ headerShown: false, contentStyle: { backgroundColor: c.canvas } }} />
      <StatusBar style="auto" />
      <ScrollView
        ref={scrollRef}
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        contentInsetAdjustmentBehavior="never"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.column}>
          <View style={styles.brand} accessible accessibilityLabel="Still, AI voice notes">
            <Ionicons name="mic-outline" color={c.ink} size={space.xl} />
            <QText variant="headline">still</QText>
            <View style={[styles.brandDivider, { backgroundColor: c.hairline }]} />
            <QText variant="footnote" color="ink2">AI voice notes</QText>
          </View>

          <View style={styles.intro} accessibilityLiveRegion="polite">
            <QText variant="hero" role="header">
              {saved ? 'One thought.\nAll sorted.' : started ? 'A ramble.\nNow a plan.' : 'Speak now.\nFind it later.'}
            </QText>
            <QText variant="subhead" color="ink2" style={styles.description}>
              {saved
                ? 'Your sample is saved for this session. The good parts, all in one place.'
                : started
                  ? 'Same thought. A little more structure.\nCompare the words with the takeaway.'
                  : 'Catch the thought before it goes.\nLet AI take care of the tidy version.'}
            </QText>
          </View>

          <View style={[styles.note, { backgroundColor: c.surface }]}>
            <View style={styles.noteMeta}>
              <QText variant="footnote" color="ink2">{saved ? 'Saved sample' : 'A thought, on a walk'}</QText>
              <QText variant="footnote" color="ink2">0:18</QText>
            </View>

            <View
              style={styles.waveform}
              accessible={false}
              accessibilityElementsHidden
              importantForAccessibility="no-hide-descendants"
            >
              {waveform.map((height, index) => (
                <View
                  key={`wave-${index}`}
                  style={[
                    styles.waveBar,
                    { height: height * space.xxs, backgroundColor: c.accent },
                  ]}
                />
              ))}
            </View>

            <View style={[styles.divider, { backgroundColor: c.hairline }]} />

            {started && !saved ? (
              <View style={[styles.tabs, largeText && styles.stackedTabs]} accessibilityRole="tablist">
                {(['summary', 'transcript'] as const).map((item) => (
                  <Pressable
                    key={item}
                    accessibilityRole="tab"
                    accessibilityState={{ selected: tab === item }}
                    onPress={() => setTab(item)}
                    style={({ pressed }) => [
                      styles.tab,
                      { backgroundColor: tab === item ? c.surface2 : c.surface },
                      pressed && { backgroundColor: c.surface2 },
                    ]}
                  >
                    <QText variant="footnote" color={tab === item ? 'ink' : 'ink2'}>
                      {item === 'summary' ? 'AI summary' : 'Original words'}
                    </QText>
                  </Pressable>
                ))}
              </View>
            ) : (
              <View style={styles.summaryLabel}>
                <Ionicons name={saved ? 'checkmark-circle-outline' : 'sparkles-outline'} size={space.md} color={c.ink2} />
                <QText variant="footnote" color="ink2">{saved ? 'Saved to your sample notes' : 'A little help from AI'}</QText>
              </View>
            )}

            <View style={styles.noteContent} accessibilityLiveRegion="polite">
              <QText variant="headline" role="header">{sample.title}</QText>
              {started && tab === 'transcript' && !saved ? (
                <QText variant="subhead" color="ink2">{sample.transcript}</QText>
              ) : (
                <>
                  <QText variant="subhead" color="ink2">{sample.summary}</QText>
                  <View style={styles.takeaway}>
                    <Ionicons name="checkbox-outline" size={space.md} color={c.ink2} />
                    <QText variant="subhead" color="ink2" style={styles.flexText}>{sample.action}</QText>
                  </View>
                </>
              )}
            </View>
          </View>

          {started && (
            <View style={styles.reassurance}>
              <QText variant="footnote" color="ink2">
                {saved ? 'Sample only · no microphone used' : 'An example note, not a live recording'}
              </QText>
            </View>
          )}
          <QLargeTextFooter>{footer}</QLargeTextFooter>
        </View>
      </ScrollView>

      <View style={styles.bottomColumn}>
        <QBottomActionBar footer={footer}>
          <QPrimaryButton
            title={saved ? 'Try again' : started ? 'Save sample note' : 'Try a sample'}
            onPress={handlePrimary}
            accessibilityHint={saved ? 'Returns to the welcome screen' : started ? 'Saves this example in the current session' : 'Explore an example voice note without using your microphone'}
          />
        </QBottomActionBar>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1 },
  scroll: { flex: 1 },
  scrollContent: { flexGrow: 1, paddingHorizontal: space.margin, paddingTop: space.md, paddingBottom: space.xl },
  column: { width: '100%', maxWidth: 640, alignSelf: 'center', flexGrow: 1 },
  brand: { flexDirection: 'row', alignItems: 'center', gap: space.xs, flexWrap: 'wrap' },
  brandDivider: { height: space.md, width: StyleSheet.hairlineWidth, marginHorizontal: space.xxs },
  intro: { gap: space.md, paddingTop: space.xl, paddingBottom: space.xl },
  description: { maxWidth: 480 },
  note: { padding: space.lg, borderRadius: radius.xl, gap: space.sm },
  noteMeta: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: space.xs },
  waveform: { height: space.xxxl, flexDirection: 'row', gap: space.xxs, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  waveBar: { width: space.xxs, flexShrink: 1, borderRadius: radius.capsule },
  divider: { height: StyleSheet.hairlineWidth },
  summaryLabel: { flexDirection: 'row', alignItems: 'center', gap: space.xs, flexWrap: 'wrap' },
  noteContent: { gap: space.xs },
  takeaway: { flexDirection: 'row', alignItems: 'center', gap: space.xs, paddingTop: space.xxs },
  flexText: { flex: 1 },
  tabs: { flexDirection: 'row', gap: space.xs },
  stackedTabs: { flexDirection: 'column' },
  tab: { flex: 1, minHeight: metrics.minTap, padding: space.xs, justifyContent: 'center', alignItems: 'center', borderRadius: radius.s },
  reassurance: { paddingTop: space.xl, paddingBottom: space.xs },
  bottomColumn: { width: '100%', maxWidth: 640, alignSelf: 'center' },
  footerLink: { minHeight: metrics.minTap, alignItems: 'center', justifyContent: 'center', borderRadius: radius.s, paddingHorizontal: space.xs },
  center: { textAlign: 'center' },
});
