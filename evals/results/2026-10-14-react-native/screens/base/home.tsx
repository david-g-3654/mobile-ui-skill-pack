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
import Svg, { Circle } from 'react-native-svg';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

type Category = {
  id: string;
  name: string;
  icon: IconName;
  spent: number;
  budget: number;
  color: string;
};

type Bill = { id: string; name: string; amount: number; due: string; daysLeft: number; icon: IconName };

type Txn = {
  id: string;
  merchant: string;
  category: string;
  icon: IconName;
  amount: number; // negative = expense
  date: string;
};

// ---- Sample data (October 2026, day 14 of 31) ----
const MONTH_LABEL = 'October';
const DAY_OF_MONTH = 14;
const DAYS_IN_MONTH = 31;
const INCOME = 5420;
const MONTHLY_BUDGET = 3800;

const CATEGORIES: Category[] = [
  { id: 'groceries', name: 'Groceries', icon: 'cart-outline', spent: 312.48, budget: 550, color: '#2E9E6B' },
  { id: 'dining', name: 'Dining out', icon: 'restaurant-outline', spent: 241.9, budget: 250, color: '#E0803B' },
  { id: 'transport', name: 'Transport', icon: 'bus-outline', spent: 96.2, budget: 180, color: '#3D7BD9' },
  { id: 'shopping', name: 'Shopping', icon: 'bag-handle-outline', spent: 288.15, budget: 220, color: '#C2477A' },
  { id: 'fun', name: 'Entertainment', icon: 'film-outline', spent: 54.0, budget: 120, color: '#7B5CD6' },
];

const FIXED_SPENT = 1495; // rent + utilities + subscriptions already paid

const BILLS: Bill[] = [
  { id: 'b1', name: 'Phone plan', amount: 45, due: 'Oct 16', daysLeft: 2, icon: 'phone-portrait-outline' },
  { id: 'b2', name: 'Car insurance', amount: 128.4, due: 'Oct 20', daysLeft: 6, icon: 'car-outline' },
  { id: 'b3', name: 'Spotify Family', amount: 16.99, due: 'Oct 23', daysLeft: 9, icon: 'musical-notes-outline' },
];

const TRANSACTIONS: Txn[] = [
  { id: 't1', merchant: 'Trader Joe’s', category: 'Groceries', icon: 'cart-outline', amount: -64.37, date: 'Today' },
  { id: 't2', merchant: 'Blue Bottle Coffee', category: 'Dining out', icon: 'cafe-outline', amount: -6.75, date: 'Today' },
  { id: 't3', merchant: 'Acme Corp payroll', category: 'Income', icon: 'cash-outline', amount: 2710, date: 'Yesterday' },
  { id: 't4', merchant: 'Lyft', category: 'Transport', icon: 'car-sport-outline', amount: -18.4, date: 'Yesterday' },
  { id: 't5', merchant: 'Uniqlo', category: 'Shopping', icon: 'shirt-outline', amount: -79.9, date: 'Oct 12' },
];

// ---- Helpers ----
const fmt = (n: number, cents = true) =>
  '$' +
  Math.abs(n).toLocaleString('en-US', {
    minimumFractionDigits: cents ? 2 : 0,
    maximumFractionDigits: cents ? 2 : 0,
  });

const tap = () => {
  Haptics.selectionAsync().catch(() => {});
};

function usePalette() {
  const dark = useColorScheme() === 'dark';
  return dark
    ? {
        dark,
        bg: '#0E1110',
        card: '#181C1A',
        cardAlt: '#202522',
        text: '#F1F4F2',
        sub: '#9AA5A0',
        line: '#2A302D',
        track: '#2A302D',
        accent: '#4CC38A',
        accentInk: '#06140D',
        danger: '#F07A7A',
        warn: '#F0B35A',
      }
    : {
        dark,
        bg: '#F4F6F4',
        card: '#FFFFFF',
        cardAlt: '#EEF2EF',
        text: '#121614',
        sub: '#5F6B66',
        line: '#E3E8E5',
        track: '#E6EBE8',
        accent: '#1F8A5B',
        accentInk: '#FFFFFF',
        danger: '#C93C3C',
        warn: '#B9771A',
      };
}
type Palette = ReturnType<typeof usePalette>;

// ---- Components ----
function Ring({ progress, size, stroke, color, track }: { progress: number; size: number; stroke: number; color: string; track: string }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const p = Math.max(0, Math.min(1, progress));
  return (
    <Svg width={size} height={size}>
      <Circle cx={size / 2} cy={size / 2} r={r} stroke={track} strokeWidth={stroke} fill="none" />
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        stroke={color}
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

function SectionHeader({ title, action, p }: { title: string; action?: string; p: Palette }) {
  return (
    <View style={styles.sectionHeader}>
      <Text style={[styles.sectionTitle, { color: p.text }]} accessibilityRole="header">
        {title}
      </Text>
      {action ? (
        <Pressable onPress={tap} hitSlop={12} accessibilityRole="button">
          <Text style={[styles.sectionAction, { color: p.accent }]}>{action}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

function CategoryRow({ c, p, paceRatio }: { c: Category; p: Palette; paceRatio: number }) {
  const ratio = c.spent / c.budget;
  const over = ratio > 1;
  const ahead = !over && ratio > paceRatio + 0.15;
  const left = c.budget - c.spent;
  const barColor = over ? p.danger : c.color;
  return (
    <Pressable
      onPress={tap}
      accessibilityRole="button"
      accessibilityLabel={`${c.name}, ${fmt(c.spent)} of ${fmt(c.budget, false)} spent, ${over ? `${fmt(-left)} over` : `${fmt(left)} left`}`}
      style={({ pressed }) => [styles.catRow, pressed && { opacity: 0.6 }]}
    >
      <View style={[styles.catIcon, { backgroundColor: c.color + '22' }]}>
        <Ionicons name={c.icon} size={18} color={c.color} />
      </View>
      <View style={{ flex: 1 }}>
        <View style={styles.rowBetween}>
          <Text style={[styles.catName, { color: p.text }]}>{c.name}</Text>
          <Text style={[styles.catLeft, { color: over ? p.danger : p.text }]}>
            {over ? `${fmt(-left)} over` : `${fmt(left)} left`}
          </Text>
        </View>
        <View style={[styles.barTrack, { backgroundColor: p.track }]}>
          <View style={[styles.barFill, { width: `${Math.min(ratio, 1) * 100}%`, backgroundColor: barColor }]} />
          <View style={[styles.paceTick, { left: `${paceRatio * 100}%`, backgroundColor: p.sub }]} />
        </View>
        <View style={styles.rowBetween}>
          <Text style={[styles.catMeta, { color: p.sub }]}>
            {fmt(c.spent)} of {fmt(c.budget, false)}
          </Text>
          {ahead ? <Text style={[styles.catMeta, { color: p.warn }]}>Spending fast</Text> : null}
        </View>
      </View>
    </Pressable>
  );
}

export default function HomeScreen() {
  const p = usePalette();
  const insets = useSafeAreaInsets();
  const [hidden, setHidden] = useState(false);

  const stats = useMemo(() => {
    const variableSpent = CATEGORIES.reduce((s, c) => s + c.spent, 0);
    const spent = variableSpent + FIXED_SPENT;
    const left = MONTHLY_BUDGET - spent;
    const daysLeft = DAYS_IN_MONTH - DAY_OF_MONTH + 1;
    const upcoming = BILLS.reduce((s, b) => s + b.amount, 0);
    const perDay = Math.max(0, (left - upcoming) / daysLeft);
    return { spent, left, daysLeft, upcoming, perDay };
  }, []);

  const paceRatio = DAY_OF_MONTH / DAYS_IN_MONTH;
  const usedRatio = stats.spent / MONTHLY_BUDGET;
  const money = (n: number, cents = true) => (hidden ? '$•••' : fmt(n, cents));

  return (
    <View style={[styles.root, { backgroundColor: p.bg }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={p.dark ? 'light' : 'dark'} />

      <ScrollView
        contentContainerStyle={{ paddingTop: insets.top + 8, paddingBottom: insets.bottom + 96, paddingHorizontal: 20 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Top bar */}
        <View style={[styles.rowBetween, { marginBottom: 20 }]}>
          <View>
            <Text style={[styles.overline, { color: p.sub }]}>Tuesday, Oct 14</Text>
            <Text style={[styles.greeting, { color: p.text }]}>Hi, Maya</Text>
          </View>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Pressable
              onPress={() => {
                tap();
                setHidden((h) => !h);
              }}
              accessibilityRole="button"
              accessibilityLabel={hidden ? 'Show amounts' : 'Hide amounts'}
              style={[styles.iconBtn, { backgroundColor: p.card, borderColor: p.line }]}
            >
              <Ionicons name={hidden ? 'eye-off-outline' : 'eye-outline'} size={20} color={p.text} />
            </Pressable>
            <Pressable
              onPress={tap}
              accessibilityRole="button"
              accessibilityLabel="Notifications, 1 new"
              style={[styles.iconBtn, { backgroundColor: p.card, borderColor: p.line }]}
            >
              <Ionicons name="notifications-outline" size={20} color={p.text} />
              <View style={[styles.dot, { backgroundColor: p.danger, borderColor: p.card }]} />
            </Pressable>
          </View>
        </View>

        {/* Hero: left to spend */}
        <View style={[styles.hero, { backgroundColor: p.card, borderColor: p.line }]}>
          <View style={{ flex: 1, paddingRight: 12 }}>
            <Text style={[styles.overline, { color: p.sub }]}>Left to spend in {MONTH_LABEL}</Text>
            <Text
              style={[styles.heroAmount, { color: stats.left < 0 ? p.danger : p.text }]}
              adjustsFontSizeToFit
              numberOfLines={1}
            >
              {money(stats.left)}
            </Text>
            <Text style={[styles.heroSub, { color: p.sub }]}>
              {money(stats.spent, false)} of {money(MONTHLY_BUDGET, false)} spent
            </Text>
            <View style={[styles.pill, { backgroundColor: p.cardAlt }]}>
              <Ionicons name="sunny-outline" size={14} color={p.accent} />
              <Text style={[styles.pillText, { color: p.text }]}>
                {money(stats.perDay)}/day for {stats.daysLeft} days
              </Text>
            </View>
          </View>
          <View style={styles.ringWrap}>
            <Ring
              progress={usedRatio}
              size={104}
              stroke={10}
              color={usedRatio > paceRatio + 0.1 ? p.warn : p.accent}
              track={p.track}
            />
            <View style={styles.ringLabel}>
              <Text style={[styles.ringPct, { color: p.text }]}>{Math.round(usedRatio * 100)}%</Text>
              <Text style={[styles.ringCaption, { color: p.sub }]}>used</Text>
            </View>
          </View>
        </View>
        <Text style={[styles.footnote, { color: p.sub }]}>
          Daily amount sets aside {money(stats.upcoming)} for upcoming bills. Income this month: {money(INCOME, false)}.
        </Text>

        {/* Budgets */}
        <SectionHeader title="Budgets" action="Edit" p={p} />
        <View style={[styles.card, { backgroundColor: p.card, borderColor: p.line }]}>
          {CATEGORIES.map((c, i) => (
            <View key={c.id}>
              {i > 0 ? <View style={[styles.divider, { backgroundColor: p.line }]} /> : null}
              <CategoryRow c={c} p={p} paceRatio={paceRatio} />
            </View>
          ))}
          <View style={[styles.legend, { borderTopColor: p.line }]}>
            <View style={[styles.legendTick, { backgroundColor: p.sub }]} />
            <Text style={[styles.catMeta, { color: p.sub }]}>Marker shows where you’d be at an even pace</Text>
          </View>
        </View>

        {/* Upcoming bills */}
        <SectionHeader title="Upcoming bills" action="See all" p={p} />
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 12, paddingRight: 20 }} style={{ marginHorizontal: -20, paddingLeft: 20 }}>
          {BILLS.map((b) => (
            <Pressable
              key={b.id}
              onPress={tap}
              accessibilityRole="button"
              accessibilityLabel={`${b.name}, ${fmt(b.amount)}, due ${b.due}`}
              style={({ pressed }) => [styles.billCard, { backgroundColor: p.card, borderColor: p.line }, pressed && { opacity: 0.7 }]}
            >
              <View style={styles.rowBetween}>
                <Ionicons name={b.icon} size={20} color={p.text} />
                <Text style={[styles.billDue, { color: b.daysLeft <= 3 ? p.warn : p.sub }]}>
                  {b.daysLeft <= 3 ? `In ${b.daysLeft} days` : b.due}
                </Text>
              </View>
              <Text style={[styles.billName, { color: p.sub }]} numberOfLines={1}>
                {b.name}
              </Text>
              <Text style={[styles.billAmount, { color: p.text }]}>{money(b.amount)}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {/* Recent transactions */}
        <SectionHeader title="Recent activity" action="See all" p={p} />
        <View style={[styles.card, { backgroundColor: p.card, borderColor: p.line }]}>
          {TRANSACTIONS.map((t, i) => {
            const income = t.amount > 0;
            return (
              <View key={t.id}>
                {i > 0 ? <View style={[styles.divider, { backgroundColor: p.line, marginLeft: 52 }]} /> : null}
                <Pressable
                  onPress={tap}
                  accessibilityRole="button"
                  accessibilityLabel={`${t.merchant}, ${income ? 'received' : 'spent'} ${fmt(t.amount)}, ${t.date}`}
                  style={({ pressed }) => [styles.txnRow, pressed && { opacity: 0.6 }]}
                >
                  <View style={[styles.catIcon, { backgroundColor: p.cardAlt }]}>
                    <Ionicons name={t.icon} size={18} color={income ? p.accent : p.text} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={[styles.catName, { color: p.text }]} numberOfLines={1}>
                      {t.merchant}
                    </Text>
                    <Text style={[styles.catMeta, { color: p.sub, marginTop: 2 }]}>
                      {t.category} · {t.date}
                    </Text>
                  </View>
                  <Text style={[styles.txnAmount, { color: income ? p.accent : p.text }]}>
                    {income ? '+' : '−'}
                    {hidden ? '$•••' : fmt(t.amount)}
                  </Text>
                </Pressable>
              </View>
            );
          })}
        </View>
      </ScrollView>

      {/* Primary action */}
      <Pressable
        onPress={() => {
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {});
        }}
        accessibilityRole="button"
        accessibilityLabel="Add transaction"
        style={({ pressed }) => [
          styles.fab,
          { backgroundColor: p.accent, bottom: insets.bottom + 16 },
          pressed && { transform: [{ scale: 0.97 }] },
        ]}
      >
        <Ionicons name="add" size={22} color={p.accentInk} />
        <Text style={[styles.fabText, { color: p.accentInk }]}>Add expense</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  rowBetween: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  overline: { fontSize: 13, fontWeight: '500' },
  greeting: { fontSize: 28, fontWeight: '700', letterSpacing: -0.5, marginTop: 2 },
  iconBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: StyleSheet.hairlineWidth,
  },
  dot: { position: 'absolute', top: 10, right: 11, width: 9, height: 9, borderRadius: 5, borderWidth: 2 },
  hero: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    borderRadius: 20,
    borderWidth: StyleSheet.hairlineWidth,
  },
  heroAmount: { fontSize: 38, fontWeight: '700', letterSpacing: -1, marginTop: 6, fontVariant: ['tabular-nums'] },
  heroSub: { fontSize: 14, marginTop: 2, fontVariant: ['tabular-nums'] },
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    alignSelf: 'flex-start',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    marginTop: 14,
  },
  pillText: { fontSize: 13, fontWeight: '600', fontVariant: ['tabular-nums'] },
  ringWrap: { width: 104, height: 104, alignItems: 'center', justifyContent: 'center' },
  ringLabel: { position: 'absolute', alignItems: 'center' },
  ringPct: { fontSize: 22, fontWeight: '700', fontVariant: ['tabular-nums'] },
  ringCaption: { fontSize: 12 },
  footnote: { fontSize: 12, lineHeight: 17, marginTop: 10, paddingHorizontal: 4 },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    marginTop: 28,
    marginBottom: 10,
  },
  sectionTitle: { fontSize: 20, fontWeight: '700', letterSpacing: -0.3 },
  sectionAction: { fontSize: 15, fontWeight: '600' },
  card: { borderRadius: 18, borderWidth: StyleSheet.hairlineWidth, paddingHorizontal: 16, overflow: 'hidden' },
  divider: { height: StyleSheet.hairlineWidth },
  catRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 14 },
  catIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  catName: { fontSize: 16, fontWeight: '600' },
  catLeft: { fontSize: 15, fontWeight: '600', fontVariant: ['tabular-nums'] },
  catMeta: { fontSize: 13, fontVariant: ['tabular-nums'] },
  barTrack: { height: 6, borderRadius: 3, marginVertical: 8, overflow: 'visible' },
  barFill: { height: 6, borderRadius: 3 },
  paceTick: { position: 'absolute', top: -3, width: 2, height: 12, borderRadius: 1, marginLeft: -1 },
  legend: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 12,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  legendTick: { width: 2, height: 12, borderRadius: 1 },
  billCard: { width: 150, padding: 14, borderRadius: 16, borderWidth: StyleSheet.hairlineWidth },
  billDue: { fontSize: 12, fontWeight: '600' },
  billName: { fontSize: 13, marginTop: 14 },
  billAmount: { fontSize: 18, fontWeight: '700', marginTop: 2, fontVariant: ['tabular-nums'] },
  txnRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 12 },
  txnAmount: { fontSize: 16, fontWeight: '600', fontVariant: ['tabular-nums'] },
  fab: {
    position: 'absolute',
    alignSelf: 'center',
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    height: 52,
    paddingHorizontal: 22,
    borderRadius: 26,
    shadowColor: '#000',
    shadowOpacity: 0.18,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 6,
  },
  fabText: { fontSize: 16, fontWeight: '700' },
});
