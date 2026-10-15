// Stats — weekly running summary.
// Job: "see how far I ran this week". Focal: hero kilometres for the selected week (or tapped day).
// Primary: none — the week stepper and day bars are the interaction.
// Cutting: per-day pace chart, heart-rate zones, elevation chart (one chart per view), badges.

import React, { useEffect, useMemo, useState } from 'react';
import { Platform, Pressable, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { GroupedSection, HeroMetric, ListRow, MetricRow, Screen, Skeleton, SkeletonRow, Txt } from '../../pack/components';
import { metrics, radius, space, tabular, useTheme } from '../../pack/theme';

// ── Sample data ──────────────────────────────────────────────────────
// Today: Wednesday, Oct 14. Weeks run Monday → Sunday.

type Run = { id: string; day: number; date: string; name: string; km: number; seconds: number };
type Week = { id: string; label: string; range: string; runs: Run[]; daysElapsed: number; note?: string };

const DAY_SHORT = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const DAY_LONG = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const WEEKLY_GOAL_KM = 32;
const CHART_MAX_KM = 16;
const CHART_HEIGHT = 160;

const WEEKS: Week[] = [
  {
    id: 'sep21',
    label: 'Week total',
    range: 'Sep 21–27',
    daysElapsed: 7,
    note: 'Rest week after the half marathon.',
    runs: [],
  },
  {
    id: 'sep28',
    label: 'Week total',
    range: 'Sep 28–Oct 4',
    daysElapsed: 7,
    runs: [
      { id: 'r1', day: 0, date: 'Mon, Sep 28', name: 'Easy run', km: 7.1, seconds: 2390 },
      { id: 'r2', day: 2, date: 'Wed, Sep 30', name: 'Hill repeats', km: 6.6, seconds: 2294 },
      { id: 'r3', day: 4, date: 'Fri, Oct 2', name: 'Easy run', km: 5.9, seconds: 1961 },
      { id: 'r4', day: 6, date: 'Sun, Oct 4', name: 'Long run, river loop', km: 10.6, seconds: 3622 },
    ],
  },
  {
    id: 'oct5',
    label: 'Last week',
    range: 'Oct 5–11',
    daysElapsed: 7,
    runs: [
      { id: 'r5', day: 1, date: 'Tue, Oct 6', name: 'Easy run', km: 6.4, seconds: 2200 },
      { id: 'r6', day: 2, date: 'Wed, Oct 7', name: 'Recovery jog', km: 5.3, seconds: 1872 },
      { id: 'r7', day: 3, date: 'Thu, Oct 8', name: 'Track intervals 6×800', km: 8.0, seconds: 2426 },
      { id: 'r8', day: 5, date: 'Sat, Oct 10', name: 'Long run', km: 14.8, seconds: 4897 },
    ],
  },
  {
    id: 'oct12',
    label: 'This week',
    range: 'Oct 12–18',
    daysElapsed: 3,
    runs: [
      { id: 'r9', day: 1, date: 'Tue, Oct 13', name: 'Tempo run', km: 8.2, seconds: 2538 },
      { id: 'r10', day: 2, date: 'Today', name: 'Easy run', km: 5.6, seconds: 1865 },
    ],
  },
];

// ── Formatting ───────────────────────────────────────────────────────

const sumKm = (runs: Run[]) => runs.reduce((s, r) => s + r.km, 0);
const sumSec = (runs: Run[]) => runs.reduce((s, r) => s + r.seconds, 0);
const km = (n: number) => n.toFixed(1);

function duration(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = sec % 60;
  const mm = h > 0 ? String(m).padStart(2, '0') : String(m);
  return `${h > 0 ? `${h}:` : ''}${mm}:${String(s).padStart(2, '0')}`;
}

function pace(sec: number, distance: number) {
  if (distance <= 0) return '–';
  const per = Math.round(sec / distance);
  return `${Math.floor(per / 60)}'${String(per % 60).padStart(2, '0')}"`;
}

function dailyKm(week: Week) {
  const days = Array<number>(7).fill(0);
  week.runs.forEach((r) => {
    days[r.day] += r.km;
  });
  return days;
}

// ── Screen ───────────────────────────────────────────────────────────

export default function WeeklyRunningStats() {
  const { c } = useTheme();
  const [weekIndex, setWeekIndex] = useState(WEEKS.length - 1);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 700);
    return () => clearTimeout(t);
  }, []);

  const week = WEEKS[weekIndex];
  const previous = weekIndex > 0 ? WEEKS[weekIndex - 1] : undefined;
  const isCurrent = weekIndex === WEEKS.length - 1;
  const days = useMemo(() => dailyKm(week), [week]);
  const total = sumKm(week.runs);
  const totalSec = sumSec(week.runs);

  const step = (dir: -1 | 1) => {
    const next = weekIndex + dir;
    if (next < 0 || next >= WEEKS.length) return;
    Haptics.selectionAsync();
    setSelectedDay(null);
    setWeekIndex(next);
  };

  const toggleDay = (d: number) => {
    Haptics.selectionAsync();
    setSelectedDay((cur) => (cur === d ? null : d));
  };

  // Hero: a tapped day, otherwise the week total.
  const dayRuns = selectedDay === null ? [] : week.runs.filter((r) => r.day === selectedDay);
  let hero: React.ComponentProps<typeof HeroMetric>;
  if (selectedDay !== null) {
    hero = {
      label: DAY_LONG[selectedDay],
      value: km(days[selectedDay]),
      suffix: 'km',
      context: dayRuns.length ? dayRuns.map((r) => `${r.name} · ${duration(r.seconds)}`).join(', ') : 'Rest day',
    };
  } else if (isCurrent && previous) {
    // Mid-week: compare against the same point last week, never the full week.
    const samePoint = sumKm(previous.runs.filter((r) => r.day < week.daysElapsed));
    const diff = total - samePoint;
    hero = {
      label: week.label,
      value: km(total),
      suffix: 'km',
      delta: { text: `${km(Math.abs(diff))} km`, up: diff >= 0 },
      context: `vs. this time last week · ${km(Math.max(WEEKLY_GOAL_KM - total, 0))} km to your ${WEEKLY_GOAL_KM} km goal`,
    };
  } else {
    const prevTotal = previous ? sumKm(previous.runs) : 0;
    const pct = prevTotal > 0 ? Math.round(((total - prevTotal) / prevTotal) * 100) : null;
    hero = {
      label: week.label,
      value: km(total),
      suffix: 'km',
      delta: pct !== null && total > 0 ? { text: `${Math.abs(pct)}%`, up: pct >= 0 } : undefined,
      context: pct !== null && total > 0 ? 'vs. the week before' : total >= WEEKLY_GOAL_KM ? 'Goal met' : week.note,
    };
  }

  const chartSummary =
    'Kilometres per day, ' +
    DAY_LONG.map((d, i) => (isCurrent && i >= week.daysElapsed ? `${d} upcoming` : `${d} ${km(days[i])}`)).join(', ');

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Running',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerLargeTitleShadowVisible: false,
          contentStyle: { backgroundColor: c.canvas },
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        }}
      />
      <StatusBar style="auto" />
      <Screen>
        {/* Week stepper */}
        <View style={styles.stepper}>
          <StepButton icon="chevron-back" label="Previous week" disabled={weekIndex === 0} onPress={() => step(-1)} />
          <Txt variant="subhead" color="ink2" style={styles.stepperLabel}>
            {week.range}
          </Txt>
          <StepButton icon="chevron-forward" label="Next week" disabled={isCurrent} onPress={() => step(1)} />
        </View>

        {loading ? (
          <LoadingState />
        ) : (
          <>
            <View style={{ gap: space.xl }}>
              <HeroMetric {...hero} />

              {/* Chart: one series, today/selected in accent, the rest in ink. */}
              <View style={{ gap: space.xs }}>
                <View style={[styles.chart, { borderBottomColor: c.hairline }]}>
                  {days.map((value, i) => {
                    const upcoming = isCurrent && i >= week.daysElapsed;
                    const highlighted = selectedDay !== null ? selectedDay === i : isCurrent && i === week.daysElapsed - 1;
                    const h = value > 0 ? Math.max((value / CHART_MAX_KM) * CHART_HEIGHT, space.xs) : space.xxs;
                    return (
                      <Pressable
                        key={i}
                        disabled={upcoming}
                        onPress={() => toggleDay(i)}
                        accessibilityRole="button"
                        accessibilityState={{ selected: selectedDay === i, disabled: upcoming }}
                        accessibilityLabel={upcoming ? `${DAY_LONG[i]}, upcoming` : `${DAY_LONG[i]}, ${km(value)} kilometres`}
                        style={styles.barSlot}
                      >
                        <View
                          style={[
                            styles.bar,
                            {
                              height: h,
                              backgroundColor: value === 0 ? c.surface2 : highlighted ? c.accent : c.ink,
                              opacity: value > 0 && !highlighted ? 0.85 : 1,
                            },
                          ]}
                        />
                      </Pressable>
                    );
                  })}
                  {total === 0 && (
                    <View pointerEvents="none" style={styles.chartEmpty}>
                      <Txt variant="subhead" color="ink2">
                        No runs this week
                      </Txt>
                    </View>
                  )}
                </View>
                <View style={styles.axis} accessible accessibilityLabel={chartSummary}>
                  {DAY_SHORT.map((d, i) => (
                    <Txt key={i} variant="footnote" color={isCurrent && i >= week.daysElapsed ? 'ink3' : 'ink2'} style={styles.axisLabel}>
                      {d}
                    </Txt>
                  ))}
                </View>
              </View>

              <MetricRow
                items={[
                  { value: total > 0 ? duration(totalSec) : '0:00', label: 'Time' },
                  { value: pace(totalSec, total), label: 'Avg pace /km' },
                  { value: String(week.runs.length), label: week.runs.length === 1 ? 'Run' : 'Runs' },
                ]}
              />
            </View>

            {week.runs.length > 0 ? (
              <GroupedSection header="Runs">
                {[...week.runs].reverse().map((r) => (
                  <ListRow
                    key={r.id}
                    title={r.name}
                    subtitle={`${r.date} · ${duration(r.seconds)} · ${pace(r.seconds, r.km)} /km`}
                    value={`${km(r.km)} km`}
                  />
                ))}
              </GroupedSection>
            ) : (
              <GroupedSection header="Runs" footer={week.note}>
                <ListRow title="No runs logged" subtitle="Runs you record or sync show up here." />
              </GroupedSection>
            )}
          </>
        )}
      </Screen>
    </>
  );
}

// ── Pieces ───────────────────────────────────────────────────────────

function StepButton({ icon, label, disabled, onPress }: { icon: 'chevron-back' | 'chevron-forward'; label: string; disabled: boolean; onPress: () => void }) {
  const { c } = useTheme();
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      hitSlop={metrics.hitSlop}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled }}
      style={({ pressed }) => [styles.stepButton, pressed && { backgroundColor: c.surface2 }]}
    >
      <Ionicons name={icon} size={20} color={disabled ? c.ink3 : c.ink} />
    </Pressable>
  );
}

function LoadingState() {
  return (
    <View style={{ gap: space.xl }} accessibilityLabel="Loading your week">
      <View style={{ gap: space.xs }}>
        <Skeleton width={96} height={12} />
        <Skeleton width="50%" height={56} radius={radius.m} />
        <Skeleton width="70%" height={16} />
      </View>
      <Skeleton width="100%" height={CHART_HEIGHT} radius={radius.m} />
      <View>
        <SkeletonRow />
        <SkeletonRow />
        <SkeletonRow />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  stepper: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  stepperLabel: { flex: 1, textAlign: 'center', ...tabular },
  stepButton: {
    width: metrics.minTap,
    height: metrics.minTap,
    borderRadius: radius.capsule,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chart: {
    height: CHART_HEIGHT,
    flexDirection: 'row',
    alignItems: 'flex-end',
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  barSlot: { flex: 1, height: '100%', justifyContent: 'flex-end', alignItems: 'center' },
  bar: { width: '56%', borderTopLeftRadius: space.xxs, borderTopRightRadius: space.xxs },
  chartEmpty: { position: 'absolute', top: 0, right: 0, bottom: 0, left: 0, alignItems: 'center', justifyContent: 'center' },
  axis: { flexDirection: 'row' },
  axisLabel: { flex: 1, textAlign: 'center' },
});
