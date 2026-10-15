// Weekly running stats — Stats archetype.
// Job: see how far you ran this week and whether you're on track.
// Focal: the week's distance (hero). Primary action: none — the week stepper is the main interaction.
// States: loading (skeleton in final layout), empty week (axis + inline message), day selection.

import React, { useEffect, useMemo, useState } from 'react';
import { Platform, Pressable, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { metrics, radius, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QGroupedSection,
  QHeroMetric,
  QListRow,
  QMetricRow,
  QScreen,
  QSkeleton,
  QSkeletonRow,
  QText,
} from '../../pack04/components';

// ── Sample data (today: Wed, Oct 14) ─────────────────────────────────

type Run = { day: number; name: string; km: number; seconds: number };
type Week = { range: string; label: string; current?: boolean; todayIndex?: number; runs: Run[] };

const WEEKLY_GOAL_KM = 36;
const DAY_SHORT = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const DAY_LONG = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const CHART_MAX_KM = 20;
const CHART_HEIGHT = 176;

// Newest first. `dates` label each weekday for the hero and run rows.
const WEEKS: (Week & { dates: string[] })[] = [
  {
    range: 'Oct 12–18',
    label: 'This week',
    current: true,
    todayIndex: 2,
    dates: ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    runs: [
      { day: 0, name: 'Easy loop, Tempelhofer Feld', km: 6.2, seconds: 2046 },
      { day: 2, name: 'Canal tempo', km: 8.4, seconds: 2587 },
    ],
  },
  {
    range: 'Oct 5–11',
    label: 'Last week',
    dates: ['Oct 5', 'Oct 6', 'Oct 7', 'Oct 8', 'Oct 9', 'Oct 10', 'Oct 11'],
    runs: [
      { day: 0, name: 'Recovery jog', km: 5.1, seconds: 1744 },
      { day: 2, name: 'Track intervals, 6 × 800 m', km: 10.3, seconds: 3100 },
      { day: 4, name: 'Easy loop, Tempelhofer Feld', km: 6.0, seconds: 2130 },
      { day: 6, name: 'Long run, Grunewald', km: 16.8, seconds: 5645 },
    ],
  },
  {
    range: 'Sep 28–Oct 4',
    label: 'Sep 28–Oct 4',
    dates: ['Sep 28', 'Sep 29', 'Sep 30', 'Oct 1', 'Oct 2', 'Oct 3', 'Oct 4'],
    runs: [
      { day: 1, name: 'Easy loop, Tempelhofer Feld', km: 7.2, seconds: 2412 },
      { day: 3, name: 'Hill repeats, Viktoriapark', km: 8.0, seconds: 2560 },
      { day: 5, name: 'Long run, Spree path', km: 14.5, seconds: 4930 },
    ],
  },
  {
    range: 'Sep 21–27',
    label: 'Sep 21–27',
    dates: ['Sep 21', 'Sep 22', 'Sep 23', 'Sep 24', 'Sep 25', 'Sep 26', 'Sep 27'],
    runs: [],
  },
  {
    range: 'Sep 14–20',
    label: 'Sep 14–20',
    dates: ['Sep 14', 'Sep 15', 'Sep 16', 'Sep 17', 'Sep 18', 'Sep 19', 'Sep 20'],
    runs: [
      { day: 0, name: 'Shakeout', km: 5.0, seconds: 1690 },
      { day: 3, name: 'Progression run', km: 9.1, seconds: 2875 },
      { day: 6, name: 'Long run, Grunewald', km: 13.2, seconds: 4462 },
    ],
  },
];

// ── Formatting ───────────────────────────────────────────────────────

const km = (n: number) => n.toFixed(1);

function duration(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return h > 0 ? `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}` : `${m}:${String(s).padStart(2, '0')}`;
}

function pace(seconds: number, distance: number) {
  if (distance <= 0) return '–';
  const per = Math.round(seconds / distance);
  return `${Math.floor(per / 60)}'${String(per % 60).padStart(2, '0')}"`;
}

function totals(runs: Run[]) {
  return runs.reduce((acc, r) => ({ km: acc.km + r.km, seconds: acc.seconds + r.seconds }), { km: 0, seconds: 0 });
}

function dailyKm(runs: Run[]) {
  const days = [0, 0, 0, 0, 0, 0, 0];
  runs.forEach((r) => {
    days[r.day] += r.km;
  });
  return days;
}

// ── Screen ───────────────────────────────────────────────────────────

export default function WeeklyRunningStats() {
  const { c, dark } = useQTheme();
  const [loading, setLoading] = useState(true);
  const [weekIndex, setWeekIndex] = useState(0);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);

  // Simulated first sync from the watch.
  useEffect(() => {
    const id = setTimeout(() => setLoading(false), 700);
    return () => clearTimeout(id);
  }, []);

  const week = WEEKS[weekIndex];
  const previous = WEEKS[weekIndex + 1];
  const total = useMemo(() => totals(week.runs), [week]);
  const days = useMemo(() => dailyKm(week.runs), [week]);

  const changeWeek = (next: number) => {
    if (next < 0 || next >= WEEKS.length) return;
    Haptics.selectionAsync();
    setSelectedDay(null);
    setWeekIndex(next);
  };

  const toggleDay = (day: number) => {
    if (days[day] === 0) return;
    Haptics.selectionAsync();
    setSelectedDay((d) => (d === day ? null : day));
  };

  // Hero: the week total, or the selected day while a bar is held.
  const hero = (() => {
    if (selectedDay !== null) {
      const runs = week.runs.filter((r) => r.day === selectedDay);
      const t = totals(runs);
      return {
        label: `${DAY_LONG[selectedDay]}, ${week.dates[selectedDay]}`,
        value: km(t.km),
        context: `${duration(t.seconds)} · ${pace(t.seconds, t.km)} /km`,
        delta: undefined,
      };
    }
    if (week.current) {
      // Partial week: show progress toward the goal, not a delta against a full week.
      const left = Math.max(0, WEEKLY_GOAL_KM - total.km);
      return {
        label: 'Distance',
        value: km(total.km),
        context: left > 0 ? `${km(left)} km to your ${WEEKLY_GOAL_KM} km goal` : `${WEEKLY_GOAL_KM} km goal reached`,
        delta: undefined,
      };
    }
    const prevKm = previous ? totals(previous.runs).km : 0;
    const diff = total.km - prevKm;
    const goalNote = total.km >= WEEKLY_GOAL_KM ? 'Goal reached' : `Goal ${WEEKLY_GOAL_KM} km`;
    return {
      label: 'Distance',
      value: km(total.km),
      context: prevKm > 0 && total.km > 0 ? `vs week before · ${goalNote}` : goalNote,
      delta: prevKm > 0 && total.km > 0 ? { text: `${km(Math.abs(diff))} km`, up: diff >= 0 } : undefined,
    };
  })();

  const highlightDay = selectedDay ?? (week.current ? week.todayIndex ?? null : null);
  const longest = week.runs.reduce((m, r) => Math.max(m, r.km), 0);

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Running',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          contentStyle: { backgroundColor: c.canvas },
          // iOS: leave headerStyle unset so the large title stays visible.
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        }}
      />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <QScreen>
        <WeekStepper
          label={week.label === week.range ? week.range : `${week.label}, ${week.range}`}
          canGoBack={weekIndex < WEEKS.length - 1}
          canGoForward={weekIndex > 0}
          onBack={() => changeWeek(weekIndex + 1)}
          onForward={() => changeWeek(weekIndex - 1)}
        />

        {loading ? (
          <LoadingState />
        ) : (
          <>
            <View style={{ gap: space.lg }}>
              <QHeroMetric label={hero.label} value={hero.value} suffix="km" context={hero.context} delta={hero.delta} />
              <WeekChart days={days} highlight={highlightDay} selected={selectedDay} onSelect={toggleDay} empty={week.runs.length === 0} />
            </View>

            <QMetricRow
              items={[
                { value: week.runs.length > 0 ? duration(total.seconds) : '–', label: 'Time' },
                { value: pace(total.seconds, total.km), label: 'Avg pace /km' },
                { value: String(week.runs.length), label: week.runs.length === 1 ? 'Run' : 'Runs' },
              ]}
            />

            <QGroupedSection
              header="Runs"
              footer={week.runs.length > 0 ? `Longest run ${km(longest)} km. Tap a run to see it on the chart.` : undefined}
            >
              {week.runs.length === 0 ? (
                <QListRow title="No runs this week" subtitle="Runs synced from your watch show up here within a few minutes." />
              ) : (
                [...week.runs]
                  .sort((a, b) => b.day - a.day)
                  .map((r) => (
                    <QListRow
                      key={`${r.day}-${r.name}`}
                      title={r.name}
                      subtitle={`${DAY_LONG[r.day].slice(0, 3)}, ${week.dates[r.day]} · ${duration(r.seconds)} · ${pace(r.seconds, r.km)} /km`}
                      value={`${km(r.km)} km`}
                      kind="action"
                      onPress={() => toggleDay(r.day)}
                    />
                  ))
              )}
            </QGroupedSection>
          </>
        )}
      </QScreen>
    </>
  );
}

// ── Week stepper ─────────────────────────────────────────────────────

function WeekStepper({
  label,
  canGoBack,
  canGoForward,
  onBack,
  onForward,
}: {
  label: string;
  canGoBack: boolean;
  canGoForward: boolean;
  onBack: () => void;
  onForward: () => void;
}) {
  const { c } = useQTheme();
  const chevron = (icon: 'chevron-back' | 'chevron-forward', a11y: string, enabled: boolean, onPress: () => void) => (
    <Pressable
      onPress={onPress}
      disabled={!enabled}
      accessibilityRole="button"
      accessibilityLabel={a11y}
      accessibilityState={{ disabled: !enabled }}
      hitSlop={metrics.hitSlop}
      style={({ pressed }) => [styles.stepperButton, pressed && { backgroundColor: c.surface2 }]}
    >
      <Ionicons name={icon} size={20} color={enabled ? c.ink : c.ink3} />
    </Pressable>
  );
  return (
    <View style={styles.stepper}>
      {chevron('chevron-back', 'Show previous week', canGoBack, onBack)}
      <QText variant="headline" style={styles.stepperLabel} role="header">
        {label}
      </QText>
      {chevron('chevron-forward', 'Show next week', canGoForward, onForward)}
    </View>
  );
}

// ── Chart ────────────────────────────────────────────────────────────

function WeekChart({
  days,
  highlight,
  selected,
  onSelect,
  empty,
}: {
  days: number[];
  highlight: number | null;
  selected: number | null;
  onSelect: (day: number) => void;
  empty: boolean;
}) {
  const { c } = useQTheme();
  const summary = empty
    ? 'Kilometres per day: no runs this week'
    : `Kilometres per day: ${days.map((d, i) => `${DAY_LONG[i]} ${km(d)}`).join(', ')}`;

  return (
    <View accessible={empty} accessibilityLabel={summary} style={{ gap: space.xs }}>
      <View style={[styles.plot, { height: CHART_HEIGHT }]}>
        {/* One hairline guide at the midpoint for scale. */}
        <View style={[styles.guide, { bottom: CHART_HEIGHT / 2, borderColor: c.hairline }]} />
        <QText variant="footnote" color="ink2" style={[styles.guideLabel, { bottom: CHART_HEIGHT / 2 + space.xxs }, tabular]}>
          {CHART_MAX_KM / 2} km
        </QText>
        <View style={[styles.baseline, { backgroundColor: c.hairline }]} />

        {empty ? (
          <View style={styles.emptyChart}>
            <QText color="ink2">No runs this week</QText>
          </View>
        ) : (
          <View style={styles.bars}>
            {days.map((d, i) => {
              const isHighlight = highlight === i;
              const h = d > 0 ? Math.max(space.xxs, (d / CHART_MAX_KM) * CHART_HEIGHT) : 2;
              return (
                <Pressable
                  key={i}
                  onPress={() => onSelect(i)}
                  disabled={d === 0}
                  accessibilityRole="button"
                  accessibilityLabel={d > 0 ? `${DAY_LONG[i]}, ${km(d)} kilometres` : `${DAY_LONG[i]}, rest day`}
                  accessibilityState={{ selected: selected === i, disabled: d === 0 }}
                  style={styles.barColumn}
                >
                  <View
                    style={[
                      styles.bar,
                      {
                        height: h,
                        backgroundColor: d === 0 ? c.hairline : isHighlight ? c.accent : c.ink,
                        opacity: d === 0 || isHighlight ? 1 : 0.85,
                      },
                    ]}
                  />
                </Pressable>
              );
            })}
          </View>
        )}
      </View>
      <View style={styles.axis} importantForAccessibility="no-hide-descendants" accessibilityElementsHidden>
        {DAY_SHORT.map((d, i) => (
          <QText
            key={i}
            variant="footnote"
            color={highlight === i && !empty ? 'ink' : 'ink2'}
            style={styles.axisLabel}
            numberOfLines={1}
          >
            {d}
          </QText>
        ))}
      </View>
    </View>
  );
}

// ── Loading ──────────────────────────────────────────────────────────

function LoadingState() {
  return (
    <>
      <View style={{ gap: space.lg }}>
        <View style={{ gap: space.xs }}>
          <QSkeleton width="40%" height={space.sm} />
          <QSkeleton width="50%" height={56} radius={radius.s} />
          <QSkeleton width="60%" height={space.md} />
        </View>
        <QSkeleton width="100%" height={CHART_HEIGHT} radius={radius.m} />
      </View>
      <View style={{ gap: space.xs }}>
        <QSkeletonRow />
        <QSkeletonRow />
        <QSkeletonRow />
      </View>
    </>
  );
}

// ── Styles ───────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  stepper: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  stepperButton: {
    width: metrics.minTap,
    height: metrics.minTap,
    borderRadius: radius.capsule,
    alignItems: 'center',
    justifyContent: 'center',
  },
  stepperLabel: { flex: 1, textAlign: 'center' },
  plot: { justifyContent: 'flex-end' },
  guide: { position: 'absolute', left: 0, right: 0, borderTopWidth: StyleSheet.hairlineWidth, borderStyle: 'dashed' },
  guideLabel: { position: 'absolute', right: 0 },
  baseline: { height: StyleSheet.hairlineWidth },
  bars: { position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, flexDirection: 'row', alignItems: 'flex-end' },
  barColumn: { flex: 1, height: '100%', alignItems: 'center', justifyContent: 'flex-end' },
  bar: { width: '56%', borderTopLeftRadius: space.xxs, borderTopRightRadius: space.xxs },
  emptyChart: { position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, alignItems: 'center', justifyContent: 'center' },
  axis: { flexDirection: 'row' },
  axisLabel: { flex: 1, textAlign: 'center' },
});
