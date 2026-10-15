// Stats archetype. Job: see how this week's running is going.
// Focal: weekly distance hero. Primary action: none — the week stepper and bar selection are the interaction.
// Cut: per-run maps, heart-rate charts, a 2×2 tile grid (secondary numbers live in one quiet metric row).

import React, { useEffect, useMemo, useState } from 'react';
import { Platform, Pressable, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { metrics, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QBar,
  QBarChart,
  QGroupedSection,
  QHeroMetric,
  QIconButton,
  QListRow,
  QMetricRow,
  QScreen,
  QSkeleton,
  QSkeletonRow,
  QText,
  useQLargeText,
} from '../../pack04/components';

// ── Sample data ──────────────────────────────────────────────────────
// Today is Thursday, Oct 15. Weeks run Monday → Sunday.

type Run = { day: number; name: string; miles: number; seconds: number };
type Week = { range: string; days: string[]; runs: Run[]; daysElapsed: number };

const DAY_LABELS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const DAY_SHORT = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

// Index 0 = this week; higher = further back.
const WEEKS: Week[] = [
  {
    range: 'Oct 12–18',
    days: ['Oct 12', 'Oct 13', 'Oct 14', 'Oct 15', 'Oct 16', 'Oct 17', 'Oct 18'],
    daysElapsed: 4,
    runs: [
      { day: 0, name: 'Recovery jog', miles: 3.1, seconds: 28 * 60 + 14 },
      { day: 2, name: 'Tempo, 3 × 1 mi', miles: 5.4, seconds: 43 * 60 + 52 },
      { day: 3, name: 'Easy run', miles: 4.1, seconds: 36 * 60 + 23 },
    ],
  },
  {
    range: 'Oct 5–11',
    days: ['Oct 5', 'Oct 6', 'Oct 7', 'Oct 8', 'Oct 9', 'Oct 10', 'Oct 11'],
    daysElapsed: 7,
    runs: [
      { day: 0, name: 'Easy run', miles: 3.2, seconds: 28 * 60 + 47 },
      { day: 2, name: 'Hill repeats', miles: 6.0, seconds: 53 * 60 + 9 },
      { day: 3, name: 'Easy run', miles: 4.4, seconds: 39 * 60 + 31 },
      { day: 5, name: 'Shakeout', miles: 2.6, seconds: 24 * 60 + 2 },
      { day: 6, name: 'Long run', miles: 9.3, seconds: 87 * 60 + 40 },
    ],
  },
  {
    range: 'Sep 28 – Oct 4',
    days: ['Sep 28', 'Sep 29', 'Sep 30', 'Oct 1', 'Oct 2', 'Oct 3', 'Oct 4'],
    daysElapsed: 7,
    runs: [
      { day: 1, name: 'Easy run', miles: 4.2, seconds: 38 * 60 + 5 },
      { day: 3, name: 'Intervals, 6 × 800 m', miles: 5.1, seconds: 41 * 60 + 36 },
      { day: 5, name: 'Easy run', miles: 3.5, seconds: 31 * 60 + 58 },
      { day: 6, name: 'Long run', miles: 8.0, seconds: 76 * 60 + 12 },
    ],
  },
  {
    range: 'Sep 21–27',
    days: ['Sep 21', 'Sep 22', 'Sep 23', 'Sep 24', 'Sep 25', 'Sep 26', 'Sep 27'],
    daysElapsed: 7,
    runs: [],
  },
];

// Last week's distance through the same weekday, for a like-for-like mid-week comparison.
function milesThrough(week: Week, daysElapsed: number) {
  return week.runs.filter((r) => r.day < daysElapsed).reduce((s, r) => s + r.miles, 0);
}

const sum = (runs: Run[], key: 'miles' | 'seconds') => runs.reduce((s, r) => s + r[key], 0);

function formatDuration(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.round(seconds % 60);
  if (h > 0) return `${h}h ${m}m`;
  return `${m}:${String(s).padStart(2, '0')}`;
}

function formatPace(seconds: number, miles: number) {
  if (miles <= 0) return '–';
  const per = seconds / miles;
  const m = Math.floor(per / 60);
  const s = Math.round(per % 60);
  return `${m}'${String(s).padStart(2, '0')}"`;
}

// ── Screen ───────────────────────────────────────────────────────────

export default function WeeklyRunningStats() {
  const { c, dark } = useQTheme();
  const [weekIndex, setWeekIndex] = useState(0);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  // Simulated fetch whenever the week changes; the skeleton keeps the final layout.
  useEffect(() => {
    setLoading(true);
    setSelectedDay(null);
    const t = setTimeout(() => setLoading(false), 450);
    return () => clearTimeout(t);
  }, [weekIndex]);

  const week = WEEKS[weekIndex];
  const isCurrent = weekIndex === 0;
  const today = isCurrent ? week.daysElapsed - 1 : undefined;

  const bars: QBar[] = useMemo(
    () =>
      DAY_LABELS.map((label, i) => {
        const miles = week.runs.filter((r) => r.day === i).reduce((s, r) => s + r.miles, 0);
        return { label, shortLabel: DAY_SHORT[i], value: miles, spokenValue: miles > 0 ? `${miles.toFixed(1)} miles` : 'no run' };
      }),
    [week],
  );

  const totalMiles = sum(week.runs, 'miles');
  const totalSeconds = sum(week.runs, 'seconds');
  const previous = WEEKS[weekIndex + 1];

  const delta = (() => {
    if (!previous || week.runs.length === 0) return undefined;
    const base = isCurrent ? milesThrough(previous, week.daysElapsed) : sum(previous.runs, 'miles');
    if (base <= 0) return undefined;
    const pct = Math.round(((totalMiles - base) / base) * 100);
    return { text: `${Math.abs(pct)}%`, up: pct >= 0 };
  })();

  const selectedRuns = selectedDay != null ? week.runs.filter((r) => r.day === selectedDay) : [];
  const selectDay = (i: number) => {
    Haptics.selectionAsync();
    setSelectedDay((d) => (d === i ? null : i));
  };

  const hero =
    selectedDay != null ? (
      <QHeroMetric
        label={`${DAY_LABELS[selectedDay]}, ${week.days[selectedDay]}`}
        value={sum(selectedRuns, 'miles').toFixed(1)}
        suffix="mi"
        context={
          selectedRuns.length > 0
            ? `${selectedRuns.map((r) => r.name).join(', ')} · ${formatDuration(sum(selectedRuns, 'seconds'))}`
            : isCurrent && selectedDay > (today ?? 6)
              ? 'Still ahead this week'
              : 'Rest day'
        }
      />
    ) : (
      <QHeroMetric
        label={isCurrent ? 'This week so far' : 'Total distance'}
        value={totalMiles.toFixed(1)}
        suffix="mi"
        delta={delta}
        context={
          delta
            ? isCurrent
              ? 'vs. this time last week'
              : 'vs. the week before'
            : week.runs.length === 0
              ? 'No runs logged'
              : undefined
        }
      />
    );

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Running',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          contentStyle: { backgroundColor: c.canvas },
          ...(Platform.OS === 'android' ? { headerStyle: { backgroundColor: c.canvas } } : null),
        }}
      />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <QScreen>
        <WeekStepper
          title={isCurrent ? `This week, ${week.range}` : week.range}
          onPrevious={weekIndex < WEEKS.length - 1 ? () => setWeekIndex((w) => w + 1) : undefined}
          onNext={weekIndex > 0 ? () => setWeekIndex((w) => w - 1) : undefined}
        />

        {loading ? (
          <LoadingState />
        ) : (
          <>
            <View style={{ gap: space.xl }}>
              {hero}
              <View>
                <QBarChart bars={bars} highlighted={selectedDay ?? today} height={176} />
                {/* Tap targets over each day column; the chart itself stays a single accessible summary. */}
                <View style={styles.barTargets}>
                  {bars.map((b, i) => (
                    <Pressable
                      key={b.label}
                      onPress={() => selectDay(i)}
                      accessibilityRole="button"
                      accessibilityState={{ selected: selectedDay === i }}
                      accessibilityLabel={`${b.label}, ${week.days[i]}, ${b.spokenValue}`}
                      accessibilityHint="Shows this day's distance"
                      style={styles.barTarget}
                    />
                  ))}
                </View>
                {week.runs.length === 0 && (
                  <View pointerEvents="none" style={styles.chartEmpty}>
                    <QText variant="subhead" color="ink2">
                      No runs this week
                    </QText>
                  </View>
                )}
              </View>
            </View>

            {week.runs.length > 0 && (
              <QMetricRow
                items={[
                  { value: formatDuration(totalSeconds), label: 'Time' },
                  { value: formatPace(totalSeconds, totalMiles), label: 'Avg pace /mi' },
                  { value: String(week.runs.length), label: week.runs.length === 1 ? 'Run' : 'Runs' },
                ]}
              />
            )}

            <QGroupedSection header="Runs" footer={week.runs.length > 0 ? 'Distances from your watch, rounded to 0.1 mi.' : undefined}>
              {week.runs.length > 0 ? (
                [...week.runs]
                  .sort((a, b) => b.day - a.day)
                  .map((r) => (
                    <QListRow
                      key={`${r.day}-${r.name}`}
                      title={`${DAY_LABELS[r.day]}, ${week.days[r.day]}`}
                      subtitle={`${r.name} · ${formatDuration(r.seconds)} · ${formatPace(r.seconds, r.miles)} /mi`}
                      value={`${r.miles.toFixed(1)} mi`}
                    />
                  ))
              ) : (
                <QListRow title="Nothing logged" subtitle="Runs synced from your watch appear here." />
              )}
            </QGroupedSection>
          </>
        )}
      </QScreen>
    </>
  );
}

// ── Pieces ───────────────────────────────────────────────────────────

function WeekStepper({ title, onPrevious, onNext }: { title: string; onPrevious?: () => void; onNext?: () => void }) {
  const large = useQLargeText();
  return (
    <View style={styles.stepper}>
      {onPrevious ? <QIconButton icon="chevron-back" label="Previous week" onPress={onPrevious} /> : <View style={styles.stepperSpacer} />}
      <QText variant="headline" style={[styles.stepperTitle, tabular]} numberOfLines={large ? undefined : 1}>
        {title}
      </QText>
      {onNext ? <QIconButton icon="chevron-forward" label="Next week" onPress={onNext} /> : <View style={styles.stepperSpacer} />}
    </View>
  );
}

function LoadingState() {
  return (
    <>
      <View style={{ gap: space.xl }}>
        <View style={{ gap: space.xs }}>
          <QSkeleton width={120} height={12} />
          <QSkeleton width="50%" height={56} />
          <QSkeleton width={180} height={16} />
        </View>
        <QSkeleton width="100%" height={200} />
      </View>
      <View>
        <QSkeletonRow />
        <QSkeletonRow />
        <QSkeletonRow />
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  stepper: { flexDirection: 'row', alignItems: 'center', gap: space.xs, marginTop: -space.xs },
  stepperTitle: { flex: 1, textAlign: 'center' },
  stepperSpacer: { width: metrics.minTap, height: metrics.minTap },
  barTargets: { position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, flexDirection: 'row' },
  barTarget: { flex: 1 },
  chartEmpty: { position: 'absolute', left: 0, right: 0, top: 0, height: 176, alignItems: 'center', justifyContent: 'center' },
});
