import React, { useMemo, useState } from 'react';
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  useColorScheme,
  useWindowDimensions,
  View,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';

type Run = {
  id: string;
  day: string;
  date: string;
  title: string;
  km: number;
  minutes: number;
  elevation: number;
  type: 'easy' | 'tempo' | 'intervals' | 'long';
};

type Week = {
  label: string;
  range: string;
  goalKm: number;
  daily: number[]; // Mon..Sun km
  runs: Run[];
  prevKm: number;
};

const DAYS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const DAY_NAMES = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const WEEKS: Week[] = [
  {
    label: 'This Week',
    range: 'Oct 13 – 19',
    goalKm: 40,
    prevKm: 31.6,
    daily: [6.2, 0, 8.4, 5.1, 0, 0, 0],
    runs: [
      { id: 'a3', day: 'Thu', date: 'Oct 16', title: 'Recovery Jog', km: 5.1, minutes: 31, elevation: 22, type: 'easy' },
      { id: 'a2', day: 'Wed', date: 'Oct 15', title: '6 × 800m Repeats', km: 8.4, minutes: 41, elevation: 35, type: 'intervals' },
      { id: 'a1', day: 'Mon', date: 'Oct 13', title: 'Morning Easy Run', km: 6.2, minutes: 36, elevation: 48, type: 'easy' },
    ],
  },
  {
    label: 'Last Week',
    range: 'Oct 6 – 12',
    goalKm: 40,
    prevKm: 28.3,
    daily: [5.0, 0, 7.2, 0, 6.4, 0, 13.0],
    runs: [
      { id: 'b4', day: 'Sun', date: 'Oct 12', title: 'Sunday Long Run', km: 13.0, minutes: 78, elevation: 142, type: 'long' },
      { id: 'b3', day: 'Fri', date: 'Oct 10', title: 'Tempo by the River', km: 6.4, minutes: 31, elevation: 18, type: 'tempo' },
      { id: 'b2', day: 'Wed', date: 'Oct 8', title: 'Hill Repeats', km: 7.2, minutes: 44, elevation: 121, type: 'intervals' },
      { id: 'b1', day: 'Mon', date: 'Oct 6', title: 'Shakeout', km: 5.0, minutes: 30, elevation: 26, type: 'easy' },
    ],
  },
];

const TYPE_META: Record<Run['type'], { label: string; icon: keyof typeof Ionicons.glyphMap; color: string }> = {
  easy: { label: 'Easy', icon: 'leaf', color: '#34C759' },
  tempo: { label: 'Tempo', icon: 'speedometer', color: '#FF9500' },
  intervals: { label: 'Intervals', icon: 'flash', color: '#FF2D55' },
  long: { label: 'Long', icon: 'trail-sign', color: '#5856D6' },
};

function formatDuration(totalMin: number) {
  const h = Math.floor(totalMin / 60);
  const m = Math.round(totalMin % 60);
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

function formatPace(minutes: number, km: number) {
  if (km <= 0) return '–';
  const pace = minutes / km;
  const m = Math.floor(pace);
  const s = Math.round((pace - m) * 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}

function useTheme() {
  const dark = useColorScheme() === 'dark';
  return {
    dark,
    bg: dark ? '#000000' : '#F2F2F7',
    card: dark ? '#1C1C1E' : '#FFFFFF',
    text: dark ? '#FFFFFF' : '#000000',
    secondary: dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)',
    separator: dark ? 'rgba(84,84,88,0.6)' : 'rgba(60,60,67,0.18)',
    fill: dark ? 'rgba(120,120,128,0.32)' : 'rgba(120,120,128,0.12)',
    accent: '#FF5A1F',
    accentSoft: dark ? 'rgba(255,90,31,0.22)' : 'rgba(255,90,31,0.12)',
  };
}

type Theme = ReturnType<typeof useTheme>;

function GoalRing({ progress, theme, size = 96 }: { progress: number; theme: Theme; size?: number }) {
  const stroke = 10;
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const clamped = Math.min(progress, 1);
  return (
    <Svg width={size} height={size} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <Circle cx={size / 2} cy={size / 2} r={r} stroke={theme.accentSoft} strokeWidth={stroke} fill="none" />
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        stroke={theme.accent}
        strokeWidth={stroke}
        fill="none"
        strokeLinecap="round"
        strokeDasharray={`${c} ${c}`}
        strokeDashoffset={c * (1 - clamped)}
        transform={`rotate(-90 ${size / 2} ${size / 2})`}
      />
    </Svg>
  );
}

export default function WeeklyStatsScreen() {
  const theme = useTheme();
  const { fontScale } = useWindowDimensions();
  const largeText = fontScale >= 1.35;
  const [weekIndex, setWeekIndex] = useState(0);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const week = WEEKS[weekIndex];

  const totals = useMemo(() => {
    const km = week.runs.reduce((s, r) => s + r.km, 0);
    const minutes = week.runs.reduce((s, r) => s + r.minutes, 0);
    const elevation = week.runs.reduce((s, r) => s + r.elevation, 0);
    const longest = week.runs.reduce((m, r) => Math.max(m, r.km), 0);
    return { km, minutes, elevation, longest, count: week.runs.length };
  }, [week]);

  const maxDaily = Math.max(...week.daily, 1);
  const delta = totals.km - week.prevKm;
  const deltaPct = week.prevKm > 0 ? Math.round((delta / week.prevKm) * 100) : 0;
  const progress = totals.km / week.goalKm;

  const switchWeek = (i: number) => {
    if (i === weekIndex) return;
    Haptics.selectionAsync();
    setWeekIndex(i);
    setSelectedDay(null);
  };

  const stats: { label: string; value: string; unit?: string; icon: keyof typeof Ionicons.glyphMap }[] = [
    { label: 'Time', value: formatDuration(totals.minutes), icon: 'time-outline' },
    { label: 'Avg Pace', value: formatPace(totals.minutes, totals.km), unit: '/km', icon: 'speedometer-outline' },
    { label: 'Elevation', value: `${totals.elevation}`, unit: 'm', icon: 'trending-up-outline' },
    { label: 'Longest', value: totals.longest.toFixed(1), unit: 'km', icon: 'ribbon-outline' },
  ];

  const s = styles;

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Weekly Stats',
          headerLargeTitle: true,
          headerTransparent: Platform.OS === 'ios',
          headerBlurEffect: 'systemChromeMaterial',
          headerShadowVisible: false,
          headerLargeTitleShadowVisible: false,
          headerStyle: Platform.OS === 'ios' ? undefined : { backgroundColor: theme.bg },
          headerTintColor: theme.accent,
          headerTitleStyle: { color: theme.text },
          headerLargeTitleStyle: { color: theme.text },
          contentStyle: { backgroundColor: theme.bg },
        }}
      />
      <StatusBar style={theme.dark ? 'light' : 'dark'} />
      <ScrollView
        style={{ backgroundColor: theme.bg }}
        contentInsetAdjustmentBehavior="automatic"
        contentContainerStyle={s.content}
      >
        {/* Week selector */}
        <View style={[s.segment, { backgroundColor: theme.fill }]} accessibilityRole="tablist">
          {WEEKS.map((w, i) => {
            const active = i === weekIndex;
            return (
              <Pressable
                key={w.label}
                onPress={() => switchWeek(i)}
                accessibilityRole="tab"
                accessibilityState={{ selected: active }}
                accessibilityLabel={`${w.label}, ${w.range}`}
                style={[s.segmentItem, active && [s.segmentActive, { backgroundColor: theme.dark ? '#636366' : '#FFFFFF' }]]}
              >
                <Text style={[s.segmentText, { color: theme.text }, active && s.segmentTextActive]}>{w.label}</Text>
              </Pressable>
            );
          })}
        </View>

        {/* Hero */}
        <View style={[s.card, { backgroundColor: theme.card }]}>
          <View style={[s.heroRow, largeText && s.heroRowStacked]}>
            <View
              style={s.heroText}
              accessible
              accessibilityLabel={`${totals.km.toFixed(1)} kilometers of ${week.goalKm} kilometer goal, ${totals.count} runs`}
            >
              <Text style={[s.caption, { color: theme.secondary }]}>{week.range}</Text>
              <View style={s.bigNumberRow}>
                <Text style={[s.bigNumber, { color: theme.text }]}>{totals.km.toFixed(1)}</Text>
                <Text style={[s.bigUnit, { color: theme.secondary }]}> km</Text>
              </View>
              <Text style={[s.body, { color: theme.secondary }]}>
                of {week.goalKm} km goal · {totals.count} {totals.count === 1 ? 'run' : 'runs'}
              </Text>
            </View>
            <View style={s.ringWrap}>
              <GoalRing progress={progress} theme={theme} />
              <View style={s.ringLabel} pointerEvents="none">
                <Text style={[s.ringPct, { color: theme.text }]} maxFontSizeMultiplier={1.4}>
                  {Math.round(progress * 100)}%
                </Text>
              </View>
            </View>
          </View>

          <View style={[s.deltaPill, { backgroundColor: delta >= 0 ? 'rgba(52,199,89,0.15)' : 'rgba(255,59,48,0.15)' }]}>
            <Ionicons name={delta >= 0 ? 'arrow-up' : 'arrow-down'} size={14} color={delta >= 0 ? '#248A3D' : '#D70015'} />
            <Text style={[s.deltaText, { color: delta >= 0 ? (theme.dark ? '#30D158' : '#248A3D') : theme.dark ? '#FF453A' : '#D70015' }]}>
              {Math.abs(deltaPct)}% vs. previous week
            </Text>
          </View>
        </View>

        {/* Daily chart */}
        <Text style={[s.sectionTitle, { color: theme.text }]} accessibilityRole="header">
          Daily Distance
        </Text>
        <View style={[s.card, { backgroundColor: theme.card }]}>
          <Text style={[s.body, { color: theme.secondary }]}>
            {selectedDay === null
              ? 'Tap a day for details'
              : `${DAY_NAMES[selectedDay]}: ${week.daily[selectedDay] > 0 ? `${week.daily[selectedDay].toFixed(1)} km` : 'Rest day'}`}
          </Text>
          <View style={s.chart}>
            {week.daily.map((km, i) => {
              const h = km > 0 ? Math.max(8, (km / maxDaily) * 120) : 4;
              const selected = selectedDay === i;
              return (
                <Pressable
                  key={i}
                  style={s.barCol}
                  onPress={() => {
                    Haptics.selectionAsync();
                    setSelectedDay(selected ? null : i);
                  }}
                  accessibilityRole="button"
                  accessibilityLabel={`${DAY_NAMES[i]}, ${km > 0 ? `${km.toFixed(1)} kilometers` : 'rest day'}`}
                  accessibilityState={{ selected }}
                  hitSlop={4}
                >
                  <View style={s.barTrack}>
                    <View
                      style={[
                        s.bar,
                        {
                          height: h,
                          backgroundColor: km > 0 ? theme.accent : theme.fill,
                          opacity: selectedDay === null || selected ? 1 : 0.35,
                        },
                      ]}
                    />
                  </View>
                  <Text
                    style={[s.barLabel, { color: selected ? theme.accent : theme.secondary }]}
                    maxFontSizeMultiplier={1.6}
                  >
                    {DAYS[i]}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* Stat grid */}
        <Text style={[s.sectionTitle, { color: theme.text }]} accessibilityRole="header">
          Highlights
        </Text>
        <View style={s.grid}>
          {stats.map((st) => (
            <View
              key={st.label}
              style={[s.card, s.tile, { backgroundColor: theme.card }, largeText && s.tileFull]}
              accessible
              accessibilityLabel={`${st.label}: ${st.value}${st.unit ? ` ${st.unit === '/km' ? 'per kilometer' : st.unit === 'm' ? 'meters' : 'kilometers'}` : ''}`}
            >
              <View style={s.tileHeader}>
                <Ionicons name={st.icon} size={16} color={theme.accent} />
                <Text style={[s.caption, { color: theme.secondary, marginLeft: 6, flexShrink: 1 }]}>{st.label}</Text>
              </View>
              <Text style={[s.tileValue, { color: theme.text }]}>
                {st.value}
                {st.unit ? <Text style={[s.tileUnit, { color: theme.secondary }]}> {st.unit}</Text> : null}
              </Text>
            </View>
          ))}
        </View>

        {/* Runs list */}
        <Text style={[s.sectionTitle, { color: theme.text }]} accessibilityRole="header">
          Runs
        </Text>
        <View style={[s.card, s.listCard, { backgroundColor: theme.card }]}>
          {week.runs.map((run, idx) => {
            const meta = TYPE_META[run.type];
            return (
              <Pressable
                key={run.id}
                onPress={() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)}
                accessibilityRole="button"
                accessibilityLabel={`${run.title}, ${run.day} ${run.date}, ${run.km.toFixed(1)} kilometers in ${formatDuration(run.minutes)}, ${meta.label} run`}
                style={({ pressed }) => [s.row, pressed && { backgroundColor: theme.fill }]}
              >
                <View style={[s.rowIcon, { backgroundColor: meta.color + '22' }]}>
                  <Ionicons name={meta.icon} size={18} color={meta.color} />
                </View>
                <View style={[s.rowBody, idx > 0 && { borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: theme.separator }]}>
                  <View style={s.rowMain}>
                    <Text style={[s.rowTitle, { color: theme.text }]}>{run.title}</Text>
                    <Text style={[s.caption, { color: theme.secondary }]}>
                      {run.day}, {run.date} · {meta.label}
                    </Text>
                    <Text style={[s.caption, { color: theme.secondary }]}>
                      {formatDuration(run.minutes)} · {formatPace(run.minutes, run.km)} /km
                    </Text>
                  </View>
                  <Text style={[s.rowKm, { color: theme.text }]}>
                    {run.km.toFixed(1)}
                    <Text style={[s.caption, { color: theme.secondary }]}> km</Text>
                  </Text>
                  <Ionicons name="chevron-forward" size={16} color={theme.secondary} style={{ marginLeft: 6 }} />
                </View>
              </Pressable>
            );
          })}
        </View>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  content: { paddingHorizontal: 16, paddingBottom: 48, paddingTop: 8 },
  segment: { flexDirection: 'row', borderRadius: 9, padding: 2, marginBottom: 16 },
  segmentItem: { flex: 1, minHeight: 32, paddingVertical: 6, borderRadius: 7, alignItems: 'center', justifyContent: 'center' },
  segmentActive: {
    shadowColor: '#000',
    shadowOpacity: 0.12,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  segmentText: { fontSize: 13, fontWeight: '500', textAlign: 'center' },
  segmentTextActive: { fontWeight: '600' },
  card: { borderRadius: 16, padding: 16, borderCurve: 'continuous' },
  heroRow: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  heroRowStacked: { flexDirection: 'column-reverse', alignItems: 'flex-start' },
  heroText: { flex: 1, minWidth: 0 },
  bigNumberRow: { flexDirection: 'row', alignItems: 'baseline', flexWrap: 'wrap' },
  bigNumber: { fontSize: 48, fontWeight: '700', fontVariant: ['tabular-nums'], letterSpacing: -1 },
  bigUnit: { fontSize: 22, fontWeight: '600' },
  ringWrap: { width: 96, height: 96, alignItems: 'center', justifyContent: 'center' },
  ringLabel: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, alignItems: 'center', justifyContent: 'center' },
  ringPct: { fontSize: 17, fontWeight: '700', fontVariant: ['tabular-nums'] },
  deltaPill: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    gap: 4,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
    marginTop: 14,
    flexShrink: 1,
  },
  deltaText: { fontSize: 13, fontWeight: '600', flexShrink: 1 },
  caption: { fontSize: 13 },
  body: { fontSize: 15 },
  sectionTitle: { fontSize: 20, fontWeight: '700', marginTop: 28, marginBottom: 10, marginLeft: 4 },
  chart: { flexDirection: 'row', alignItems: 'flex-end', marginTop: 16, gap: 6 },
  barCol: { flex: 1, alignItems: 'center', minHeight: 44 },
  barTrack: { height: 124, width: '100%', justifyContent: 'flex-end', alignItems: 'center' },
  bar: { width: '70%', maxWidth: 28, borderRadius: 6 },
  barLabel: { fontSize: 13, fontWeight: '600', marginTop: 8 },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  tile: { flexGrow: 1, flexBasis: '45%', minWidth: 140 },
  tileFull: { flexBasis: '100%' },
  tileHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 6 },
  tileValue: { fontSize: 26, fontWeight: '700', fontVariant: ['tabular-nums'] },
  tileUnit: { fontSize: 15, fontWeight: '500' },
  listCard: { padding: 0, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', paddingLeft: 16, minHeight: 64 },
  rowIcon: { width: 34, height: 34, borderRadius: 9, alignItems: 'center', justifyContent: 'center', marginRight: 12 },
  rowBody: { flex: 1, flexDirection: 'row', alignItems: 'center', paddingVertical: 12, paddingRight: 16 },
  rowMain: { flex: 1, minWidth: 0, gap: 2 },
  rowTitle: { fontSize: 17, fontWeight: '600' },
  rowKm: { fontSize: 17, fontWeight: '700', fontVariant: ['tabular-nums'], marginLeft: 8 },
});
