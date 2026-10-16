import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Feather, Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import Svg, { Path, Circle } from 'react-native-svg';

const weeks = [
  { label: 'OCT 5 – OCT 11, 2026', distance: '24.8', change: '12%', time: '2h 26m', pace: '5:53', values: [4.2, 0, 6.1, 3.4, 0, 8, 3.1] },
  { label: 'OCT 12 – OCT 18, 2026', distance: '28.4', change: '15%', time: '2h 42m', pace: '5:42', values: [5.2, 0, 6.4, 4, 0, 9.6, 3.2] },
];
const runs = [
  { name: 'Sunday reset', date: 'SUN, OCT 18 · 8:12 AM', distance: '3.2', pace: '6:02', time: '19m 18s', route: 'M4 39 C18 36 8 18 24 17 S46 7 44 25 S25 32 38 48 S60 43 61 29' },
  { name: 'A little further', date: 'SAT, OCT 17 · 7:04 AM', distance: '9.6', pace: '5:38', time: '54m 05s', route: 'M7 43 L17 17 Q26 6 33 17 L49 15 L59 35 L43 49 L29 41 L17 48 Z' },
  { name: 'Lunch break miles', date: 'THU, OCT 15 · 12:26 PM', distance: '4.0', pace: '5:48', time: '23m 12s', route: 'M9 40 Q16 9 31 19 T57 14 L55 39 Q33 52 9 40' },
];

export default function WeeklyStats() {
  const [weekIndex, setWeekIndex] = useState(1);
  const [period, setPeriod] = useState('Week');
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [showAll, setShowAll] = useState(false);
  const week = weeks[weekIndex];
  const monthly = period === 'Month';
  const yearly = period === 'Year';
  const distance = monthly ? '112.6' : yearly ? '1,084' : week.distance;
  const chartValues = monthly ? [22.4, 24.8, 28.4, 37] : yearly ? [54, 68, 76, 82, 98, 104, 118, 122, 130, 112, 68, 52] : week.values;
  const chartLabels = monthly ? ['W1', 'W2', 'W3', 'W4'] : yearly ? ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'] : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  const maximum = Math.max(...chartValues);

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <View style={styles.wordmark}><View style={styles.brandMark}><View style={styles.brandSlash} /><View style={[styles.brandSlash, { height: 13 }]} /></View><Text style={styles.brand}>stride<Text style={{ color: '#f45d3b' }}>.</Text></Text></View>
          <View style={styles.avatar}><Text style={styles.avatarText}>JL</Text><View style={styles.online} /></View>
        </View>

        <View style={styles.titleRow}><Text style={styles.title}>Your progress</Text><View style={styles.liveBadge}><View style={styles.dot} /><Text style={styles.liveText}>KEEP GOING</Text></View></View>
        <Text style={styles.subtitle}>Small steps. Stronger you.</Text>

        <View style={styles.segment}>{['Week', 'Month', 'Year'].map(item => <Pressable key={item} onPress={() => { setPeriod(item); setSelectedDay(null); }} style={[styles.segmentItem, period === item && styles.segmentActive]}><Text style={[styles.segmentText, period === item && styles.segmentTextActive]}>{item}</Text></Pressable>)}</View>

        <View style={styles.dateRow}>
          <Pressable accessibilityLabel="Previous week" onPress={() => { setWeekIndex(0); setSelectedDay(null); }} hitSlop={12} style={styles.arrow}><Feather name="chevron-left" size={19} color="#6c6d66" /></Pressable>
          <Text style={styles.dateLabel}>{monthly ? 'OCTOBER 2026' : yearly ? '2026 · YOUR YEAR IN MOTION' : week.label}</Text>
          <Pressable accessibilityLabel="Next week" onPress={() => { setWeekIndex(1); setSelectedDay(null); }} hitSlop={12} style={styles.arrow}><Feather name="chevron-right" size={19} color="#6c6d66" /></Pressable>
        </View>

        <View style={styles.distanceRow}><Text style={styles.distance}>{selectedDay === null ? distance : chartValues[selectedDay].toFixed(1)}<Text style={styles.unit}> km</Text></Text><View style={styles.growth}><Feather name="trending-up" size={14} color="#56733d" /><Text style={styles.growthText}>{week.change}</Text></View></View>
        <View style={styles.distanceCaption}><Text style={styles.smallLabel}>{selectedDay === null ? 'TOTAL DISTANCE' : `${chartLabels[selectedDay]} · DISTANCE`}</Text><Text style={styles.compare}>vs. last {period.toLowerCase()}</Text></View>

        <View style={styles.chart}>
          <View style={styles.grid}><View style={styles.gridLine} /><View style={styles.gridLine} /><View style={styles.gridLine} /></View>
          <View style={styles.bars}>{chartValues.map((value, index) => <Pressable key={index} accessibilityLabel={`${chartLabels[index]}: ${value} kilometers`} onPress={() => setSelectedDay(selectedDay === index ? null : index)} style={styles.barColumn}>
            <View style={styles.barTrack}>{value === maximum && <Text style={styles.peakLabel}>{value.toFixed(1)}</Text>}<View style={[styles.bar, { height: value === 0 ? 5 : (value / maximum) * 106, backgroundColor: value === maximum || selectedDay === index ? '#ef6343' : '#dfdace', opacity: selectedDay !== null && selectedDay !== index ? 0.55 : 1 }]} /></View>
            <Text style={[styles.dayLabel, (value === maximum || selectedDay === index) && { color: '#df583a' }]}>{chartLabels[index]}</Text>
          </Pressable>)}</View>
        </View>

        <View style={styles.metrics}>
          <View style={styles.metric}><Feather name="clock" size={17} color="#777a6c" /><Text style={styles.metricValue}>{monthly ? '10h 48m' : yearly ? '103h 12m' : week.time}</Text><Text style={styles.metricLabel}>Time moving</Text></View>
          <View style={[styles.metric, styles.metricMiddle]}><Ionicons name="speedometer-outline" size={18} color="#777a6c" /><Text style={styles.metricValue}>{monthly ? '5:45' : yearly ? '5:43' : week.pace}<Text style={styles.metricUnit}> /km</Text></Text><Text style={styles.metricLabel}>Avg. pace</Text></View>
          <View style={styles.metric}><Feather name="activity" size={17} color="#777a6c" /><Text style={styles.metricValue}>{monthly ? '19' : yearly ? '186' : '5'}</Text><Text style={styles.metricLabel}>Total runs</Text></View>
        </View>

        <View style={styles.goalCard}>
          <View style={styles.goalIcon}><Feather name="flag" size={20} color="#526443" /></View>
          <View style={styles.goalBody}><View style={styles.goalTitleRow}><Text style={styles.goalTitle}>A little closer. Every run.</Text><Text style={styles.goalPercent}>{weekIndex === 1 ? '95%' : '83%'}</Text></View><Text style={styles.goalDescription}>{weekIndex === 1 ? '28.4' : '24.8'} of 30 km weekly goal</Text><View style={styles.progressTrack}><View style={[styles.progressFill, { width: weekIndex === 1 ? '95%' : '83%' }]} /></View></View>
        </View>

        <View style={styles.sectionHeading}><Text style={styles.sectionTitle}>This week’s runs<Text style={styles.runCount}>  5</Text></Text><Pressable hitSlop={12} onPress={() => setShowAll(!showAll)}><Text style={styles.viewAll}>{showAll ? 'Show less' : 'View all'} <Feather name="arrow-up-right" size={12} /></Text></Pressable></View>
        {(showAll ? [...runs, { ...runs[2], name: 'Midweek momentum', date: 'WED, OCT 14 · 7:10 AM', distance: '6.4', pace: '5:36', time: '35m 50s' }, { ...runs[0], name: 'Fresh start', date: 'MON, OCT 12 · 6:45 AM', distance: '5.2', pace: '5:43', time: '29m 44s' }] : runs).map((run, index) => <View key={`${run.name}-${index}`} style={styles.runRow}>
          <View style={styles.routeTile}><Svg width={58} height={56} viewBox="0 0 68 60"><Path d="M0 15 L68 15 M0 33 L68 33 M20 0 L20 60 M48 0 L48 60" stroke="#e5e6dc" strokeWidth="1" /><Path d={run.route} stroke="#738261" strokeWidth="2.5" fill="none" strokeLinecap="round" strokeLinejoin="round" /><Circle cx={index === 1 ? 7 : index === 2 ? 9 : 4} cy={index === 1 ? 43 : index === 2 ? 40 : 39} r="3" fill="#f16543" /></Svg></View>
          <View style={styles.runInfo}><Text style={styles.runDate}>{run.date}</Text><Text style={styles.runName}>{run.name}</Text><Text style={styles.runDetails}>{run.pace} /km<Text style={{ color: '#c7c7bf' }}>   ·   </Text>{run.time}</Text></View>
          <View style={styles.runDistance}><Text style={styles.runKilometers}>{run.distance}</Text><Text style={styles.runUnit}>km</Text></View>
        </View>)}
        <View style={styles.footer}><View style={styles.footerLine} /><Text style={styles.footerText}>EVERY STEP COUNTS.</Text><View style={styles.footerLine} /></View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#f9f8f3' },
  content: { paddingHorizontal: 25, paddingTop: 12, paddingBottom: 20, maxWidth: 600, width: '100%', alignSelf: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 30 },
  wordmark: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  brand: { fontSize: 27, fontWeight: '800', color: '#292e24', letterSpacing: -1.5 },
  brandMark: { flexDirection: 'row', alignItems: 'flex-end', gap: 3, transform: [{ skewX: '-19deg' }] },
  brandSlash: { width: 5, height: 22, backgroundColor: '#f06443', borderRadius: 1 },
  avatar: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#e9e9dd', alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: '#dedfd1' },
  avatarText: { fontSize: 12, fontWeight: '700', color: '#626951' },
  online: { position: 'absolute', right: -1, bottom: 0, width: 9, height: 9, borderRadius: 5, backgroundColor: '#83916d', borderWidth: 2, borderColor: '#f9f8f3' },
  titleRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 8 },
  title: { fontSize: 29, letterSpacing: -1.1, fontWeight: '700', color: '#292e24' },
  liveBadge: { flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: '#edefe3', borderRadius: 5, paddingHorizontal: 7, paddingVertical: 6 },
  dot: { width: 4, height: 4, borderRadius: 2, backgroundColor: '#748259' },
  liveText: { color: '#6b7655', fontSize: 8, fontWeight: '700', letterSpacing: 0.8 },
  subtitle: { color: '#919187', fontSize: 13, marginTop: 7 },
  segment: { flexDirection: 'row', backgroundColor: '#efeee7', borderRadius: 10, padding: 4, marginTop: 25, marginBottom: 22 },
  segmentItem: { flex: 1, paddingVertical: 9, borderRadius: 7, alignItems: 'center' },
  segmentActive: { backgroundColor: '#fffefa', shadowColor: '#3b3b26', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.08, shadowRadius: 3, elevation: 1 },
  segmentText: { fontSize: 12, fontWeight: '500', color: '#8a8b80' },
  segmentTextActive: { color: '#333a2b', fontWeight: '700' },
  dateRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 },
  arrow: { padding: 3 },
  dateLabel: { fontSize: 10, fontWeight: '600', letterSpacing: 1.3, color: '#707366' },
  distanceRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  distance: { fontSize: 64, fontWeight: '600', letterSpacing: -3.5, color: '#30372a', lineHeight: 74, fontVariant: ['tabular-nums'] },
  unit: { fontSize: 23, fontWeight: '400', letterSpacing: -0.5, color: '#9b9d90' },
  growth: { flexDirection: 'row', alignItems: 'center', gap: 5, backgroundColor: '#edf0e3', borderRadius: 6, paddingHorizontal: 8, paddingVertical: 5, marginTop: 18 },
  growthText: { color: '#5e7548', fontSize: 12, fontWeight: '700' },
  distanceCaption: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  smallLabel: { color: '#929487', fontSize: 9, letterSpacing: 1.5, fontWeight: '600' },
  compare: { color: '#9a9b90', fontSize: 10 },
  chart: { height: 161, marginTop: 12, marginBottom: 19 },
  grid: { position: 'absolute', top: 27, left: 0, right: 0, bottom: 28, justifyContent: 'space-between' },
  gridLine: { borderTopWidth: 1, borderColor: '#eae9e0', borderStyle: 'dashed' },
  bars: { flexDirection: 'row', height: '100%', gap: 12, paddingHorizontal: 8 },
  barColumn: { flex: 1, alignItems: 'center', justifyContent: 'flex-end' },
  barTrack: { height: 134, width: '100%', alignItems: 'center', justifyContent: 'flex-end' },
  bar: { width: '90%', maxWidth: 35, borderTopLeftRadius: 5, borderTopRightRadius: 5, minWidth: 6 },
  peakLabel: { fontSize: 10, fontWeight: '700', color: '#d85a3a', marginBottom: 7 },
  dayLabel: { marginTop: 12, fontSize: 10, color: '#96998b', fontWeight: '600' },
  metrics: { flexDirection: 'row', borderTopWidth: 1, borderBottomWidth: 1, borderColor: '#e5e5da', paddingVertical: 19 },
  metric: { flex: 1, alignItems: 'center', gap: 7 },
  metricMiddle: { borderLeftWidth: 1, borderRightWidth: 1, borderColor: '#e5e5da' },
  metricValue: { fontSize: 20, fontWeight: '600', letterSpacing: -0.7, color: '#363c2f' },
  metricUnit: { fontSize: 10, color: '#929586', fontWeight: '400', letterSpacing: 0 },
  metricLabel: { fontSize: 10, color: '#929487', marginTop: -2 },
  goalCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#eeefe5', padding: 14, borderRadius: 11, gap: 12, marginTop: 21, borderWidth: 1, borderColor: '#e6e8db' },
  goalIcon: { width: 34, height: 38, alignItems: 'center', justifyContent: 'center' },
  goalBody: { flex: 1 },
  goalTitleRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 5 },
  goalTitle: { fontSize: 11, fontWeight: '600', color: '#4d5941' },
  goalPercent: { fontSize: 11, fontWeight: '700', color: '#5f6d4e' },
  goalDescription: { fontSize: 10, color: '#939885', marginTop: 5 },
  progressTrack: { height: 4, borderRadius: 2, backgroundColor: '#dce0ce', marginTop: 11 },
  progressFill: { height: 4, borderRadius: 2, backgroundColor: '#7f8c66' },
  sectionHeading: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 28, marginBottom: 7 },
  sectionTitle: { fontSize: 17, fontWeight: '600', letterSpacing: -0.4, color: '#343a2d' },
  runCount: { fontSize: 12, color: '#9b9d90', fontWeight: '400' },
  viewAll: { fontSize: 10, color: '#878d77', fontWeight: '500' },
  runRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 14, borderBottomWidth: 1, borderBottomColor: '#e9e9df', gap: 12 },
  routeTile: { width: 58, height: 58, borderRadius: 9, backgroundColor: '#eeefe6', overflow: 'hidden', alignItems: 'center', justifyContent: 'center' },
  runInfo: { flex: 1, gap: 5 },
  runDate: { fontSize: 8, letterSpacing: 0.65, color: '#9b9d90', fontWeight: '500' },
  runName: { fontSize: 13, fontWeight: '600', color: '#434936', letterSpacing: -0.1 },
  runDetails: { fontSize: 10, color: '#95998a' },
  runDistance: { alignItems: 'flex-end', gap: 2 },
  runKilometers: { fontSize: 23, color: '#414834', fontWeight: '500', letterSpacing: -0.8 },
  runUnit: { fontSize: 9, color: '#a1a392' },
  footer: { flexDirection: 'row', alignItems: 'center', gap: 12, justifyContent: 'center', marginTop: 26, marginBottom: 4 },
  footerLine: { height: 1, width: 24, backgroundColor: '#dedfd2' },
  footerText: { fontSize: 8, letterSpacing: 2, color: '#a2a691', fontWeight: '500' },
});
