import React, { useState } from 'react';
import { Platform, Pressable, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { metrics, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QBarChart,
  QHeroMetric,
  QMetricRow,
  QScreen,
  QSegmented,
  QText,
} from '../../pack04/components';

type Measure = 'distance' | 'time';
type Run = { day: number; name: string; km: number; minutes: number };
type Week = { start: number; runs: Run[] };

const weeks: Week[] = [
  { start: 21, runs: [] },
  {
    start: 28,
    runs: [
      { day: 1, name: 'Neighborhood loop', km: 5.6, minutes: 34 },
      { day: 3, name: 'Hill repeats', km: 7.2, minutes: 43 },
      { day: 5, name: 'Saturday long run', km: 11.4, minutes: 69 },
    ],
  },
  {
    start: 5,
    runs: [
      { day: 0, name: 'An easy start', km: 5.1, minutes: 31 },
      { day: 2, name: 'Riverside tempo', km: 7.6, minutes: 39 },
      { day: 4, name: 'Lunch break loop', km: 4.8, minutes: 28 },
      { day: 6, name: 'Long way home', km: 12.2, minutes: 73 },
    ],
  },
  {
    start: 12,
    runs: [
      { day: 0, name: 'Monday shakeout', km: 5.2, minutes: 32 },
      { day: 1, name: 'Riverside tempo', km: 8.0, minutes: 41 },
      { day: 3, name: 'Easy miles through the park', km: 6.4, minutes: 39 },
      { day: 4, name: 'Friday long run', km: 12.8, minutes: 70 },
    ],
  },
];

const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const measures: { value: Measure; label: string }[] = [
  { value: 'distance', label: 'Distance' },
  { value: 'time', label: 'Time' },
];

function duration(minutes: number) {
  const hours = Math.floor(minutes / 60);
  const remainder = Math.round(minutes % 60);
  return hours ? `${hours}h ${remainder.toString().padStart(2, '0')}m` : `${remainder}m`;
}

function pace(minutes: number, km: number) {
  if (!km) return '—';
  const seconds = Math.round((minutes * 60) / km);
  return `${Math.floor(seconds / 60)}′${(seconds % 60).toString().padStart(2, '0')}″`;
}

function dateFor(week: Week, day: number) {
  return new Date(2026, week.start >= 21 ? 8 : 9, week.start + day);
}

function periodLabel(week: Week) {
  const first = dateFor(week, 0);
  const last = dateFor(week, 6);
  const firstMonth = first.toLocaleDateString('en-US', { month: 'short' });
  const lastMonth = last.toLocaleDateString('en-US', { month: 'short' });
  return `${firstMonth} ${first.getDate()}–${firstMonth === lastMonth ? '' : `${lastMonth} `}${last.getDate()}`;
}

export default function RunningStatsScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const [weekIndex, setWeekIndex] = useState(weeks.length - 1);
  const [measure, setMeasure] = useState<Measure>('distance');
  const week = weeks[weekIndex];
  const current = weekIndex === weeks.length - 1;
  const distance = week.runs.reduce((total, run) => total + run.km, 0);
  const minutes = week.runs.reduce((total, run) => total + run.minutes, 0);
  const empty = week.runs.length === 0;
  const bars = days.map((day, index) => {
    const run = week.runs.find((item) => item.day === index);
    const value = measure === 'distance' ? (run?.km ?? 0) : (run?.minutes ?? 0);
    return {
      label: day,
      shortLabel: day.slice(0, 1),
      value,
      spokenValue: current && index > 4
        ? 'upcoming'
        : run
          ? `${value} ${measure === 'distance' ? 'kilometers' : 'minutes'}`
          : 'rest day',
    };
  });

  function changeWeek(direction: number) {
    const next = weekIndex + direction;
    if (next < 0 || next >= weeks.length) return;
    setWeekIndex(next);
    void Haptics.selectionAsync().catch(() => undefined);
  }

  return (
    <View style={[styles.root, { backgroundColor: c.canvas }]}>
      <Stack.Screen
        options={{
          title: 'Running',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          contentStyle: { backgroundColor: c.canvas },
        }}
      />
      <StatusBar style="auto" />
      <QScreen contentContainerStyle={{ paddingBottom: insets.bottom + space.xxl }}>
        <View style={styles.controls}>
          <QSegmented options={measures} value={measure} onChange={setMeasure} />
          <View style={styles.period}>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Previous week"
              accessibilityState={{ disabled: weekIndex === 0 }}
              disabled={weekIndex === 0}
              onPress={() => changeWeek(-1)}
              style={({ pressed }) => [styles.arrow, { opacity: pressed ? 0.5 : 1 }]}
            >
              <Ionicons name="chevron-back-outline" size={space.lg} color={weekIndex === 0 ? c.ink3 : c.ink} />
            </Pressable>
            <View style={styles.periodText} accessible accessibilityLabel={`${current ? 'This week' : 'Week of'} ${periodLabel(week)}, 2026`}>
              <QText variant="subhead" style={styles.semibold}>{current ? 'This week' : 'Weekly summary'}</QText>
              <QText variant="footnote" color="ink2">{periodLabel(week)}, 2026</QText>
            </View>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Next week"
              accessibilityState={{ disabled: current }}
              disabled={current}
              onPress={() => changeWeek(1)}
              style={({ pressed }) => [styles.arrow, { opacity: pressed ? 0.5 : 1 }]}
            >
              <Ionicons name="chevron-forward-outline" size={space.lg} color={current ? c.ink3 : c.ink} />
            </Pressable>
          </View>
        </View>

        <View style={styles.overview}>
          <QHeroMetric
            label={measure === 'distance' ? 'Distance this week' : 'Time on your feet'}
            value={measure === 'distance' ? distance.toFixed(1) : duration(minutes)}
            suffix={measure === 'distance' ? 'km' : undefined}
            context={empty ? 'A fresh week starts here.' : current ? '7.6 km to your 40 km weekly goal' : `${week.runs.length} runs in the books`}
          />
          <View>
            {empty && (
              <View style={styles.emptyChart} pointerEvents="none">
                <QText variant="subhead" color="ink2">No runs this week</QText>
              </View>
            )}
            <QBarChart bars={bars} highlighted={current ? 4 : undefined} />
          </View>
          <View style={styles.chartCaption}>
            <QText variant="footnote" color="ink2">{measure === 'distance' ? 'Kilometers per day' : 'Minutes per day'}</QText>
            <QText variant="footnote" color="ink2">{current ? 'Through Friday' : 'Full week'}</QText>
          </View>
        </View>

        <View style={[styles.summary, { borderColor: c.hairline }]}>
          <QMetricRow items={[
            { value: duration(minutes), label: 'Moving time' },
            { value: pace(minutes, distance), label: 'Avg pace /km' },
            { value: String(week.runs.length), label: 'Runs' },
          ]} />
        </View>

        <View style={styles.history}>
          <View style={styles.sectionHeading}>
            <QText variant="title" role="header">Your runs</QText>
            <QText variant="footnote" color="ink2">{week.runs.length} this week</QText>
          </View>
          {empty ? (
            <View style={styles.emptyHistory}>
              <QText variant="subhead" color="ink2">Your recorded runs will appear here, with distance, time, and pace.</QText>
            </View>
          ) : [...week.runs].reverse().map((run) => (
            <View
              key={run.day}
              accessible
              accessibilityLabel={`${run.name}, ${dateFor(week, run.day).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}, ${run.km.toFixed(1)} kilometers, ${duration(run.minutes)}, pace ${pace(run.minutes, run.km)} per kilometer`}
              style={[styles.run, { borderBottomColor: c.hairline }]}
            >
              <View style={styles.runInfo}>
                <QText variant="footnote" color="ink2">{days[run.day]} · {dateFor(week, run.day).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</QText>
                <QText variant="subhead" style={styles.semibold}>{run.name}</QText>
                <QText variant="footnote" color="ink2">{duration(run.minutes)} · {pace(run.minutes, run.km)} /km</QText>
              </View>
              <QText variant="subhead" style={[tabular, styles.semibold]}>{run.km.toFixed(1)} km</QText>
            </View>
          ))}
          {current && !empty && (
            <QText variant="footnote" color="ink2" style={styles.closing}>Four runs down. Let the weekend find its own pace.</QText>
          )}
        </View>
      </QScreen>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  controls: { gap: space.sm },
  period: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  periodText: { flex: 1, alignItems: 'center', gap: space.xxs },
  arrow: { minWidth: metrics.minTap, minHeight: metrics.minTap, alignItems: 'center', justifyContent: 'center' },
  semibold: { fontWeight: '600' },
  overview: { gap: space.md },
  chartCaption: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', gap: space.xs },
  summary: { borderTopWidth: StyleSheet.hairlineWidth, borderBottomWidth: StyleSheet.hairlineWidth, paddingVertical: space.xl },
  history: { gap: space.xxs },
  sectionHeading: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'baseline', gap: space.xs, marginBottom: space.xs },
  run: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', columnGap: space.md, rowGap: space.xs, paddingVertical: space.md, borderBottomWidth: StyleSheet.hairlineWidth },
  runInfo: { flex: 1, minWidth: '65%', gap: space.xxs },
  closing: { marginTop: space.md },
  emptyChart: { position: 'absolute', inset: 0, alignItems: 'center', justifyContent: 'center' },
  emptyHistory: { paddingVertical: space.md },
});
