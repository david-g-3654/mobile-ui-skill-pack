import React, { useRef, useState } from 'react';
import { Animated, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';

const waveform = [10, 18, 28, 17, 36, 49, 25, 38, 59, 32, 46, 65, 39, 24, 51, 72, 44, 60, 33, 47, 28, 55, 37, 22, 42, 29, 16, 25, 12];
const pages = [
  { eyebrow: 'LESS TYPING. MORE LIVING.', title: 'A little voice.\nA lot of clarity.', description: 'Turn your thoughts into organized notes.\nJust speak. We’ll take it from here.' },
  { eyebrow: 'YOUR THOUGHTS, UNTANGLED.', title: 'From rambling\nto remarkable.', description: 'Get a clear summary, key ideas, and next\nsteps from every voice note.' },
  { eyebrow: 'MAKE ROOM FOR YOUR IDEAS.', title: 'Good thoughts\ndeserve a home.', description: 'Capture the moment. Find the meaning.\nKeep your best ideas close.' },
];

export default function Onboarding() {
  const insets = useSafeAreaInsets();
  const [page, setPage] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [started, setStarted] = useState(false);
  const pulse = useRef(new Animated.Value(1)).current;
  const animation = useRef<Animated.CompositeAnimation | null>(null);
  const content = pages[page];

  React.useEffect(() => () => animation.current?.stop(), []);

  const togglePreview = () => {
    void Haptics.selectionAsync();
    if (playing) {
      animation.current?.stop();
      pulse.setValue(1);
    } else {
      animation.current = Animated.loop(Animated.sequence([
        Animated.timing(pulse, { toValue: 0.45, duration: 600, useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 1, duration: 600, useNativeDriver: true }),
      ]));
      animation.current.start();
    }
    setPlaying(!playing);
  };

  const advance = () => {
    void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (page < 2) setPage(page + 1);
    else setStarted(true);
  };

  return (
    <View style={styles.screen}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <View style={[styles.header, { paddingTop: insets.top + 17 }]}>
        <View style={styles.brand}>
          <View style={styles.brandIcon}>
            {[12, 22, 16, 9].map((height, index) => <View key={index} style={[styles.brandBar, { height }]} />)}
          </View>
          <Text style={styles.brandName}>murmur<Text style={styles.brandPeriod}>.</Text></Text>
        </View>
        <Pressable accessibilityRole="button" onPress={() => { setPage(2); void Haptics.selectionAsync(); }} hitSlop={14}>
          <Text style={styles.skip}>Skip intro <Ionicons name="arrow-forward" size={13} /></Text>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false} bounces={false}>
        <View style={styles.artwork}>
          <View style={styles.orbitOuter} />
          <View style={styles.orbitInner} />
          <View style={styles.orbitDot} />
          <View style={styles.littleSpark}><Ionicons name="sparkles" size={22} color="#85966D" /></View>
          <View style={styles.voiceCard}>
            <View style={styles.cardHeader}>
              <View style={styles.recordingLabel}><View style={styles.recordDot} /><Text style={styles.cardLabel}>A MOMENT OF INSPIRATION</Text></View>
              <Ionicons name="ellipsis-horizontal" size={19} color="#999B92" />
            </View>
            <Text style={styles.noteTitle}>An idea on my morning walk</Text>
            <Text style={styles.noteDate}>Today, 8:42 AM <Text style={styles.dateDot}> · </Text> 1 min 24 sec</Text>
            <View style={styles.audioRow}>
              <Pressable onPress={togglePreview} accessibilityRole="button" accessibilityLabel={playing ? 'Pause waveform preview' : 'Play waveform preview'} style={styles.playButton}>
                <Ionicons name={playing ? 'pause' : 'play'} size={19} color="#FFFFFF" style={{ marginLeft: playing ? 0 : 2 }} />
              </Pressable>
              <Animated.View style={[styles.waveform, { opacity: pulse }]}>
                {waveform.map((height, index) => <View key={index} style={[styles.waveBar, { height: height * 0.59, backgroundColor: index < 18 ? '#758A59' : '#D9DFD0' }]} />)}
              </Animated.View>
              <Text style={styles.duration}>{playing ? '0:13' : '0:12'}</Text>
            </View>
          </View>

          <View style={styles.summaryCard}>
            <View style={styles.summaryHeader}>
              <View style={styles.summaryLabel}><Ionicons name="sparkles" size={14} color="#6C8052" /><Text style={styles.summaryLabelText}>A little clarity, by AI</Text></View>
              <View style={styles.readyPill}><Text style={styles.readyText}>Ready</Text></View>
            </View>
            <Text style={styles.summaryTitle}>Small steps. Big ideas.</Text>
            <Text style={styles.summaryBody}>Create a space to capture everyday ideas,{'\n'}before the moment passes.</Text>
            <View style={styles.summaryDivider} />
            <View style={styles.taskRow}><View style={styles.checkbox}><Ionicons name="checkmark" size={10} color="#74825F" /></View><Text style={styles.taskText}>Make something worth remembering</Text></View>
          </View>
          <View style={styles.floatingBadge}><Ionicons name="checkmark" size={13} color="#647B49" /><Text style={styles.floatingBadgeText}>Thoughts, beautifully sorted.</Text></View>
        </View>

        <View style={styles.copy}>
          <View style={styles.eyebrowRow}><View style={styles.eyebrowLine} /><Text style={styles.eyebrow}>{started ? 'YOUR NEXT GREAT IDEA STARTS HERE.' : content.eyebrow}</Text><View style={styles.eyebrowLine} /></View>
          <Text style={styles.title}>{started ? 'You’re ready.\nLet it all out.' : content.title}</Text>
          <Text style={styles.description}>{started ? 'Your space is ready for a fresh thought.\nTap the microphone to make it a note.' : content.description}</Text>
        </View>
      </ScrollView>

      <View style={[styles.footer, { paddingBottom: Math.max(insets.bottom, 18) + 8 }]}>
        <View style={styles.pagination}>
          {pages.map((_, index) => <Pressable key={index} onPress={() => { setPage(index); setStarted(false); }} accessibilityRole="button" accessibilityLabel={`Onboarding page ${index + 1}`} accessibilityState={{ selected: page === index }} hitSlop={10}><View style={[styles.pageDot, page === index && styles.activeDot]} /></Pressable>)}
        </View>
        <Pressable accessibilityRole="button" onPress={started ? togglePreview : advance} style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85, transform: [{ scale: 0.99 }] }]}>
          <LinearGradient colors={['#74895D', '#5D7446']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.ctaGradient}>
            <Text style={styles.ctaText}>{started ? (playing ? 'Pause your preview' : 'Try the voice preview') : page === 0 ? 'Find your clarity' : page === 1 ? 'That sounds good' : 'Let’s get started'}</Text>
            <Ionicons name={started ? (playing ? 'pause' : 'mic-outline') : 'arrow-forward'} size={20} color="white" />
          </LinearGradient>
        </Pressable>
        <View style={styles.privacy}><Ionicons name="lock-closed-outline" size={12} color="#8B8D81" /><Text style={styles.privacyText}>Your thoughts stay yours. Always.</Text></View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#F8F7F2' },
  header: { paddingHorizontal: 27, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingBottom: 12 },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  brandIcon: { flexDirection: 'row', alignItems: 'center', gap: 3, height: 26 },
  brandBar: { width: 4, borderRadius: 3, backgroundColor: '#71865A' },
  brandName: { fontSize: 27, fontWeight: '700', letterSpacing: -1.4, color: '#2E3529' },
  brandPeriod: { color: '#7B8D64' },
  skip: { fontSize: 12, color: '#898C7F', fontWeight: '500' },
  scrollContent: { flexGrow: 1, justifyContent: 'center', paddingTop: 10, paddingBottom: 16 },
  artwork: { height: 346, width: '100%', maxWidth: 430, alignSelf: 'center', justifyContent: 'center' },
  orbitOuter: { position: 'absolute', width: 336, height: 336, borderRadius: 168, borderWidth: 1, borderColor: '#E5E8DC', alignSelf: 'center', top: 0 },
  orbitInner: { position: 'absolute', width: 279, height: 279, borderRadius: 140, backgroundColor: '#EEF0E5', alignSelf: 'center', top: 28 },
  orbitDot: { position: 'absolute', width: 8, height: 8, borderRadius: 4, backgroundColor: '#C4CDB5', top: 31, left: '20%' },
  littleSpark: { position: 'absolute', right: 32, top: 20, transform: [{ rotate: '9deg' }] },
  voiceCard: { marginHorizontal: 28, marginTop: -89, backgroundColor: '#FFFFFF', borderRadius: 19, padding: 20, borderWidth: 1, borderColor: '#EEEFE7', transform: [{ rotate: '-4deg' }], shadowColor: '#455139', shadowOpacity: 0.08, shadowRadius: 18, shadowOffset: { width: 0, height: 8 }, elevation: 3 },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 13 },
  recordingLabel: { flexDirection: 'row', gap: 6, alignItems: 'center' },
  recordDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: '#98A882' },
  cardLabel: { fontSize: 8, fontWeight: '700', letterSpacing: 1.1, color: '#8B9280' },
  noteTitle: { fontSize: 17, fontWeight: '600', letterSpacing: -0.6, color: '#343B2E' },
  noteDate: { fontSize: 10, color: '#999C91', marginTop: 7 },
  dateDot: { color: '#C2C5B9' },
  audioRow: { flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 18, height: 47 },
  playButton: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#73895A', justifyContent: 'center', alignItems: 'center' },
  waveform: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', height: 46 },
  waveBar: { width: 3, borderRadius: 3 },
  duration: { fontSize: 9, color: '#8C9580', fontVariant: ['tabular-nums'] },
  summaryCard: { position: 'absolute', top: 166, left: 53, right: 21, padding: 18, backgroundColor: '#FDFDF9', borderRadius: 17, borderColor: '#E4E8D9', borderWidth: 1, transform: [{ rotate: '3deg' }], shadowColor: '#4A5437', shadowOpacity: 0.09, shadowRadius: 16, shadowOffset: { width: 0, height: 8 }, elevation: 5 },
  summaryHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  summaryLabel: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  summaryLabelText: { color: '#7B8867', fontSize: 10, fontWeight: '500' },
  readyPill: { backgroundColor: '#EDF1E5', borderRadius: 5, paddingHorizontal: 7, paddingVertical: 3 },
  readyText: { color: '#7A8A66', fontSize: 8, fontWeight: '600' },
  summaryTitle: { fontSize: 17, fontWeight: '600', color: '#3B4331', letterSpacing: -0.5 },
  summaryBody: { fontSize: 11, lineHeight: 17, color: '#8A8E7E', marginTop: 7 },
  summaryDivider: { height: 1, backgroundColor: '#ECEEE4', marginTop: 12, marginBottom: 10 },
  taskRow: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  checkbox: { width: 13, height: 13, borderWidth: 1, borderColor: '#CDD6BF', borderRadius: 4, alignItems: 'center', justifyContent: 'center', backgroundColor: '#F1F4EA' },
  taskText: { fontSize: 9, color: '#7D8670' },
  floatingBadge: { position: 'absolute', bottom: 1, alignSelf: 'center', flexDirection: 'row', gap: 5, alignItems: 'center', backgroundColor: '#E8EDDE', paddingHorizontal: 12, paddingVertical: 7, borderRadius: 20, transform: [{ rotate: '-3deg' }] },
  floatingBadgeText: { color: '#74805F', fontSize: 9, fontWeight: '500' },
  copy: { alignItems: 'center', paddingHorizontal: 20, paddingTop: 27 },
  eyebrowRow: { flexDirection: 'row', alignItems: 'center', gap: 9 },
  eyebrowLine: { width: 15, height: 1, backgroundColor: '#B3BEA3' },
  eyebrow: { color: '#82916E', fontSize: 8, fontWeight: '700', letterSpacing: 1.6 },
  title: { fontFamily: 'Georgia', fontSize: 43, lineHeight: 49, letterSpacing: -1.9, textAlign: 'center', color: '#303B27', marginTop: 15 },
  description: { color: '#8B8F80', fontSize: 13, lineHeight: 21, textAlign: 'center', marginTop: 14, letterSpacing: 0.05 },
  footer: { paddingHorizontal: 28, paddingTop: 5 },
  pagination: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, marginBottom: 24 },
  pageDot: { height: 5, width: 5, borderRadius: 3, backgroundColor: '#D7DCCF' },
  activeDot: { width: 20, backgroundColor: '#7F906B' },
  cta: { borderRadius: 16, overflow: 'hidden' },
  ctaGradient: { minHeight: 57, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 18, paddingHorizontal: 16 },
  ctaText: { color: '#FFFFFF', fontSize: 15, fontWeight: '600', letterSpacing: 0.1 },
  privacy: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 5, marginTop: 16 },
  privacyText: { fontSize: 10, color: '#95998B', letterSpacing: 0.1 },
});
