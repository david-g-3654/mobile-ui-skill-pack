import React, { useMemo, useState } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useColorScheme,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Circle, Defs, LinearGradient as SvgGradient, Path, Stop } from 'react-native-svg';

type Run = {
  id: string;
  title: string;
  type: 'Easy' | 'Tempo' | 'Intervals' | 'Long';
  km: number;
  durationSec: number;
  elevation: number;
  avgHr: number;
};

type Day = { label: string; date: string; runs: Run[] };

type Week = {
  range: string;
  goalKm: number;
  days: Day[];
};

const WEEKS: Week[] = [
  {
    range: 'Sep 29 – Oct 5',
    goalKm: 40,
    days: [
      { label: 'M', date: 'Mon, Sep 29', runs: [{ id: 'a1', title: 'Recovery jog', type: 'Easy', km: 5.2, durationSec: 1958, elevation: 22, avgHr: 138 }] },
      { label: 'T', date: 'Tue, Sep 30', runs: [] },
      { label: 'W', date: 'Wed, Oct 1', runs: [{ id: 'a2', title: '6 × 800m', type: 'Intervals', km: 8.4, durationSec: 2730, elevation: 31, avgHr: 161 }] },
      { label: 'T', date: 'Thu, Oct 2', runs: [{ id: 'a3', title: 'Lunch loop', type: 'Easy', km: 6.0, durationSec: 2232, elevation: 40, avgHr: 142 }] },
      { label: 'F', date: 'Fri, Oct 3', runs: [] },
      { label: 'S', date: 'Sat, Oct 4', runs: [{ id: 'a4', title: 'Riverside long run', type: 'Long', km: 16.1, durationSec: 5940, elevation: 118, avgHr: 148 }] },
      { label: 'S', date: 'Sun, Oct 5', runs: [{ id: 'a5', title: 'Shakeout', type: 'Easy', km: 4.0, durationSec: 1512, elevation: 12, avgHr: 135 }] },
    ],
  },
  {
    range: 'Oct 6 – Oct 12',
    goalKm: 42,
    days: [
      { label: 'M', date: 'Mon, Oct 6', runs: [{ id: 'b1', title: 'Easy miles', type: 'Easy', km: 6.3, durationSec: 2318, elevation: 28, avgHr: 140 }] },
      { label: 'T', date: 'Tue, Oct 7', runs: [{ id: 'b2', title: 'Tempo 3 × 2km', type: 'Tempo', km: 9.1, durationSec: 2794, elevation: 46, avgHr: 163 }] },
      { label: 'W', date: 'Wed, Oct 8', runs: [] },
      { label: 'T', date: 'Thu, Oct 9', runs: [{ id: 'b3', title: 'Hill repeats', type: 'Intervals', km: 7.5, durationSec: 2565, elevation: 164, avgHr: 158 }] },
      { label: 'F', date: 'Fri, Oct 10', runs: [{ id: 'b4', title: 'Morning easy', type: 'Easy', km: 5.0, durationSec: 1860, elevation: 18, avgHr: 137 }] },
      { label: 'S', date: 'Sat, Oct 11', runs: [] },
      { label: 'S', date: 'Sun, Oct 12', runs: [{ id: 'b5', title: 'Park loop long run', type: 'Long', km: 18.4, durationSec: 6698, elevation: 142, avgHr: 150 }] },
    ],
  },
  {
    range: 'Oct 13 – Oct 19',
    goalKm: 45,
    days: [
      { label: 'M', date: 'Mon, Oct 13', runs: [{ id: 'c1', title: 'Recovery jog', type: 'Easy', km: 6.1, durationSec: 2269, elevation: 24, avgHr: 136 }] },
      { label: 'T', date: 'Tue, Oct 14', runs: [{ id: 'c2', title: '5 × 1km @ 10K pace', type: 'Intervals', km: 9.8, durationSec: 3018, elevation: 35, avgHr: 164 }] },
      { label: 'W', date: 'Wed, Oct 15', runs: [] },
      { label: 'T', date: 'Thu, Oct 16', runs: [] },
      { label: 'F', date: 'Fri, Oct 17', runs: [] },
      { label: 'S', date: 'Sat, Oct 18', runs: [] },
      { label: 'S', date: 'Sun, Oct 19', runs: [] },
    ],
  },
];

const TYPE_COLOR: Record<Run['type'], string> = {
  Easy: '#34C38F',
  Tempo: '#FF9F43',
  Intervals: '#FF5C7A',
  Long: '#5B8CFF',
};

function fmtDuration(sec: number): string {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  return h > 0 ? `${h}h ${m.toString().padStart(2, '0')}m` : `${m}m`;
}

function fmtPace(sec: number, km: number): string {
  if (km <= 0) return '–';
  const p = sec / km;
  const m = Math.floor(p / 60);
  const s = Math.round(p % 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}

function summarize(week: Week) {
  const runs = week.days.flatMap((d) => d.runs);
  const km = runs.reduce((s, r) => s + r.km, 0);
  const sec = runs.reduce((s, r) => s + r.durationSec, 0);
  const elev = runs.reduce((s, r) => s + r.elevation, 0);
  const longest = runs.reduce((m, r) => Math.max(m, r.km), 0);
  return { runs, km, sec, elev, longest };
}

function useTheme() {
  const dark = useColorScheme() === 'dark';
  return {
    dark,
    bg: dark ? '#0B0D12' : '#F4F5F8',
    card: dark ? '#161A22' : '#FFFFFF',
    text: dark ? '#F3F5F9' : '#11141A',
    sub: dark ? '#8B93A4' : '#6B7280',
    line: dark ? '#252B36' : '#E7E9EE',
    track: dark ? '#232937' : '#EEF0F4',
    accent: '#FF6B35',
  };
}

type Theme = ReturnType<typeof useTheme>;

function GoalRing({ progress, t }: { progress: number; t: Theme }) {
  const size = 132;
  const stroke = 12;
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const p = Math.min(progress, 1);
  return (
    <Svg width={size} height={size}>
      <Defs>
        <SvgGradient id="ring" x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor="#FF8A3D" />
          <Stop offset="1" stopColor="#FF3D6E" />
        </SvgGradient>
      </Defs>
      <Circle cx={size / 2} cy={size / 2} r={r} stroke={t.track} strokeWidth={stroke} fill="none" />
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        stroke="url(#ring)"
        strokeWidth={stroke}
        fill="none"
        strokeLinecap="round"
        strokeDasharray={`${c} ${c}`}
        strokeDashoffset={c * (1 - p)}
        transform={`rotate(-90 ${size / 2} ${size / 2})`}
      />
    </Svg>
  );
}

function Sparkline({ values, color, width, height }: { values: number[]; color: string; width: number; height: number }) {
  if (values.length < 2) return null;
  const min = Math.min(...values);
  const max = Math.max(...values);
  const span = max - min || 1;
  const pts = values.map((v, i) => {
    const x = (i / (values.length - 1)) * width;
    const y = 4 + (1 - (v - min) / span) * (height - 8);
    return `${i === 0 ? 'M' : 'L'}${x.toFixed(1)},${y.toFixed(1)}`;
  });
  return (
    <Svg width={width} height={height}>
      <Path d={pts.join(' ')} stroke={color} strokeWidth={2} fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </Svg>
  );
}

export default function WeeklyStatsScreen() {
  const t = useTheme();
  const insets = useSafeAreaInsets();
  const [weekIdx, setWeekIdx] = useState(WEEKS.length - 2);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);

  const week = WEEKS[weekIdx];
  const stats = useMemo(() => summarize(week), [week]);
  const prev = weekIdx > 0 ? summarize(WEEKS[weekIdx - 1]) : null;
  const delta = prev && prev.km > 0 ? ((stats.km - prev.km) / prev.km) * 100 : null;
  const isCurrent = weekIdx === WEEKS.length - 1;

  const dayKm = week.days.map((d) => d.runs.reduce((s, r) => s + r.km, 0));
  const maxKm = Math.max(10, ...dayKm);
  const paceTrend = WEEKS.slice(0, weekIdx + 1).map((w) => {
    const s = summarize(w);
    return s.km > 0 ? s.sec / s.km : 0;
  });

  const listedDays = week.days
    .map((d, i) => ({ ...d, i }))
    .filter((d) => d.runs.length > 0 && (selectedDay === null || d.i === selectedDay));

  const changeWeek = (dir: -1 | 1) => {
    const next = weekIdx + dir;
    if (next < 0 || next >= WEEKS.length) return;
    Haptics.selectionAsync();
    setWeekIdx(next);
    setSelectedDay(null);
  };

  const pickDay = (i: number) => {
    Haptics.selectionAsync();
    setSelectedDay((cur) => (cur === i ? null : i));
  };

  return (
    <View style={[styles.flex, { backgroundColor: t.bg }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={t.dark ? 'light' : 'dark'} />
      <ScrollView
        contentContainerStyle={{ paddingTop: insets.top + 8, paddingBottom: insets.bottom + 32, paddingHorizontal: 16 }}
        showsVerticalScrollIndicator={false}
      >
        <Text style={[styles.title, { color: t.text }]} accessibilityRole="header">
          Weekly Stats
        </Text>

        <View style={[styles.weekNav, { backgroundColor: t.card, borderColor: t.line }]}>
          <Pressable
            onPress={() => changeWeek(-1)}
            disabled={weekIdx === 0}
            hitSlop={8}
            style={styles.navBtn}
            accessibilityRole="button"
            accessibilityLabel="Previous week"
          >
            <Ionicons name="chevron-back" size={20} color={weekIdx === 0 ? t.line : t.text} />
          </Pressable>
          <View style={styles.center}>
            <Text style={[styles.weekRange, { color: t.text }]}>{week.range}</Text>
            <Text style={[styles.small, { color: t.sub }]}>{isCurrent ? 'This week' : weekIdx === WEEKS.length - 2 ? 'Last week' : '2 weeks ago'}</Text>
          </View>
          <Pressable
            onPress={() => changeWeek(1)}
            disabled={isCurrent}
            hitSlop={8}
            style={styles.navBtn}
            accessibilityRole="button"
            accessibilityLabel="Next week"
          >
            <Ionicons name="chevron-forward" size={20} color={isCurrent ? t.line : t.text} />
          </Pressable>
        </View>

        {/* Hero */}
        <View style={[styles.card, styles.hero, { backgroundColor: t.card }]}>
          <View style={styles.ringWrap}>
            <GoalRing progress={stats.km / week.goalKm} t={t} />
            <View style={styles.ringLabel}>
              <Text style={[styles.ringPct, { color: t.text }]}>{Math.round((stats.km / week.goalKm) * 100)}%</Text>
              <Text style={[styles.small, { color: t.sub }]}>of goal</Text>
            </View>
          </View>
          <View style={styles.heroText}>
            <Text style={[styles.small, { color: t.sub }]}>Distance</Text>
            <Text style={[styles.bigNum, { color: t.text }]}>
              {stats.km.toFixed(1)}
              <Text style={[styles.unit, { color: t.sub }]}> km</Text>
            </Text>
            <Text style={[styles.small, { color: t.sub }]}>Goal {week.goalKm} km · {Math.max(0, week.goalKm - stats.km).toFixed(1)} km to go</Text>
            {delta !== null && (
              <View style={[styles.pill, { backgroundColor: delta >= 0 ? 'rgba(52,195,143,0.14)' : 'rgba(255,92,122,0.14)' }]}>
                <Ionicons name={delta >= 0 ? 'trending-up' : 'trending-down'} size={14} color={delta >= 0 ? '#34C38F' : '#FF5C7A'} />
                <Text style={[styles.pillText, { color: delta >= 0 ? '#34C38F' : '#FF5C7A' }]}>
                  {delta >= 0 ? '+' : ''}
                  {delta.toFixed(0)}% vs prior week
                </Text>
              </View>
            )}
          </View>
        </View>

        {/* Daily bars */}
        <View style={[styles.card, { backgroundColor: t.card }]}>
          <View style={styles.rowBetween}>
            <Text style={[styles.cardTitle, { color: t.text }]}>Daily distance</Text>
            {selectedDay !== null && (
              <Pressable onPress={() => pickDay(selectedDay)} hitSlop={8} accessibilityRole="button">
                <Text style={[styles.link, { color: t.accent }]}>Show all</Text>
              </Pressable>
            )}
          </View>
          <View style={styles.bars}>
            {week.days.map((d, i) => {
              const km = dayKm[i];
              const h = km > 0 ? Math.max(8, (km / maxKm) * 120) : 4;
              const active = selectedDay === null || selectedDay === i;
              const color = d.runs[0] ? TYPE_COLOR[d.runs[0].type] : t.track;
              return (
                <Pressable
                  key={d.date}
                  style={styles.barCol}
                  onPress={() => pickDay(i)}
                  accessibilityRole="button"
                  accessibilityLabel={`${d.date}, ${km > 0 ? `${km.toFixed(1)} kilometers` : 'rest day'}`}
                  accessibilityState={{ selected: selectedDay === i }}
                >
                  <Text style={[styles.barVal, { color: km > 0 ? t.text : 'transparent' }]}>{km > 0 ? km.toFixed(1) : '0'}</Text>
                  <View style={styles.barTrack}>
                    <View style={[styles.bar, { height: h, backgroundColor: color, opacity: active ? 1 : 0.3 }]} />
                  </View>
                  <Text style={[styles.barLabel, { color: selectedDay === i ? t.accent : t.sub }]}>{d.label}</Text>
                </Pressable>
              );
            })}
          </View>
          <View style={styles.legend}>
            {(Object.keys(TYPE_COLOR) as Run['type'][]).map((k) => (
              <View key={k} style={styles.legendItem}>
                <View style={[styles.dot, { backgroundColor: TYPE_COLOR[k] }]} />
                <Text style={[styles.small, { color: t.sub }]}>{k}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Stat grid */}
        <View style={styles.grid}>
          {[
            { icon: 'time-outline' as const, label: 'Time', value: fmtDuration(stats.sec) },
            { icon: 'speedometer-outline' as const, label: 'Avg pace', value: `${fmtPace(stats.sec, stats.km)} /km` },
            { icon: 'trending-up-outline' as const, label: 'Elevation', value: `${stats.elev} m` },
            { icon: 'footsteps-outline' as const, label: 'Runs', value: `${stats.runs.length}` },
            { icon: 'trophy-outline' as const, label: 'Longest', value: `${stats.longest.toFixed(1)} km` },
            { icon: 'flame-outline' as const, label: 'Calories', value: `${Math.round(stats.km * 68).toLocaleString()}` },
          ].map((s) => (
            <View key={s.label} style={[styles.tile, { backgroundColor: t.card }]}>
              <Ionicons name={s.icon} size={18} color={t.accent} />
              <Text style={[styles.tileVal, { color: t.text }]}>{s.value}</Text>
              <Text style={[styles.small, { color: t.sub }]}>{s.label}</Text>
            </View>
          ))}
        </View>

        {/* Pace trend */}
        {paceTrend.filter((p) => p > 0).length > 1 && (
          <View style={[styles.card, styles.rowBetween, { backgroundColor: t.card }]}>
            <View>
              <Text style={[styles.cardTitle, { color: t.text }]}>Pace trend</Text>
              <Text style={[styles.small, { color: t.sub }]}>Weekly average, lower is faster</Text>
            </View>
            <Sparkline values={paceTrend.filter((p) => p > 0).map((p) => -p)} color={t.accent} width={96} height={40} />
          </View>
        )}

        {/* Runs */}
        <Text style={[styles.section, { color: t.text }]}>
          {selectedDay !== null ? week.days[selectedDay].date : 'Runs this week'}
        </Text>
        {listedDays.length === 0 ? (
          <View style={[styles.card, styles.empty, { backgroundColor: t.card }]}>
            <Ionicons name="bed-outline" size={26} color={t.sub} />
            <Text style={[styles.cardTitle, { color: t.text }]}>Rest day</Text>
            <Text style={[styles.small, { color: t.sub }]}>No runs logged. Recovery counts too.</Text>
          </View>
        ) : (
          listedDays.flatMap((d) =>
            d.runs.map((r) => (
              <View key={r.id} style={[styles.runRow, { backgroundColor: t.card }]}>
                <View style={[styles.runBadge, { backgroundColor: TYPE_COLOR[r.type] + '22' }]}>
                  <Ionicons name="walk" size={18} color={TYPE_COLOR[r.type]} />
                </View>
                <View style={styles.flex}>
                  <Text style={[styles.runTitle, { color: t.text }]} numberOfLines={1}>{r.title}</Text>
                  <Text style={[styles.small, { color: t.sub }]}>
                    {d.date} · {r.type} · {r.avgHr} bpm
                  </Text>
                </View>
                <View style={styles.runRight}>
                  <Text style={[styles.runKm, { color: t.text }]}>{r.km.toFixed(1)} km</Text>
                  <Text style={[styles.small, { color: t.sub }]}>
                    {fmtPace(r.durationSec, r.km)} /km
                  </Text>
                </View>
              </View>
            )),
          )
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  center: { alignItems: 'center' },
  title: { fontSize: 32, fontWeight: '800', letterSpacing: -0.5, marginBottom: 14 },
  weekNav: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderRadius: 14,
    borderWidth: StyleSheet.hairlineWidth,
    paddingVertical: 8,
    paddingHorizontal: 6,
    marginBottom: 14,
  },
  navBtn: { width: 44, height: 44, alignItems: 'center', justifyContent: 'center' },
  weekRange: { fontSize: 16, fontWeight: '700' },
  small: { fontSize: 12.5 },
  card: { borderRadius: 18, padding: 16, marginBottom: 14 },
  hero: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  ringWrap: { width: 132, height: 132, alignItems: 'center', justifyContent: 'center' },
  ringLabel: { position: 'absolute', alignItems: 'center' },
  ringPct: { fontSize: 24, fontWeight: '800', fontVariant: ['tabular-nums'] },
  heroText: { flex: 1, gap: 4 },
  bigNum: { fontSize: 38, fontWeight: '800', letterSpacing: -1, fontVariant: ['tabular-nums'] },
  unit: { fontSize: 18, fontWeight: '600' },
  pill: { flexDirection: 'row', alignItems: 'center', gap: 4, alignSelf: 'flex-start', borderRadius: 999, paddingHorizontal: 8, paddingVertical: 4, marginTop: 6 },
  pillText: { fontSize: 12, fontWeight: '700' },
  rowBetween: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  cardTitle: { fontSize: 16, fontWeight: '700' },
  link: { fontSize: 14, fontWeight: '600' },
  bars: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 14 },
  barCol: { flex: 1, alignItems: 'center' },
  barVal: { fontSize: 11, fontWeight: '600', marginBottom: 4, fontVariant: ['tabular-nums'] },
  barTrack: { height: 120, justifyContent: 'flex-end' },
  bar: { width: 22, borderRadius: 7 },
  barLabel: { fontSize: 12, fontWeight: '700', marginTop: 8 },
  legend: { flexDirection: 'row', flexWrap: 'wrap', gap: 14, marginTop: 14 },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  dot: { width: 8, height: 8, borderRadius: 4 },
  grid: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', rowGap: 10, marginBottom: 14 },
  tile: { width: '31.5%', borderRadius: 16, padding: 12, gap: 6 },
  tileVal: { fontSize: 16, fontWeight: '800', fontVariant: ['tabular-nums'] },
  section: { fontSize: 20, fontWeight: '800', marginTop: 6, marginBottom: 10 },
  empty: { alignItems: 'center', gap: 6, paddingVertical: 28 },
  runRow: { flexDirection: 'row', alignItems: 'center', gap: 12, borderRadius: 16, padding: 14, marginBottom: 10 },
  runBadge: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  runTitle: { fontSize: 15.5, fontWeight: '700', marginBottom: 2 },
  runRight: { alignItems: 'flex-end' },
  runKm: { fontSize: 15.5, fontWeight: '800', fontVariant: ['tabular-nums'] },
});
