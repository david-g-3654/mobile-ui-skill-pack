import React, { useMemo, useState } from 'react';
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useColorScheme,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import Svg, { Circle } from 'react-native-svg';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type IoniconName = React.ComponentProps<typeof Ionicons>['name'];

type Category = {
  id: string;
  name: string;
  icon: IoniconName;
  color: string;
  spent: number;
  budget: number;
};

type Transaction = {
  id: string;
  merchant: string;
  category: string;
  icon: IoniconName;
  color: string;
  amount: number; // negative = expense
  date: string;
};

type Bill = {
  id: string;
  name: string;
  due: string;
  amount: number;
  icon: IoniconName;
  color: string;
};

const MONTH_LABEL = 'October';
const DAYS_LEFT = 16;
const INCOME = 5420;
const BUDGET_TOTAL = 3800;

const CATEGORIES: Category[] = [
  { id: 'groceries', name: 'Groceries', icon: 'cart', color: '#34C759', spent: 412.38, budget: 600 },
  { id: 'dining', name: 'Dining Out', icon: 'restaurant', color: '#FF9500', spent: 286.4, budget: 250 },
  { id: 'transport', name: 'Transport', icon: 'car', color: '#007AFF', spent: 138.75, budget: 220 },
  { id: 'shopping', name: 'Shopping', icon: 'bag-handle', color: '#AF52DE', spent: 174.99, budget: 300 },
  { id: 'fun', name: 'Entertainment', icon: 'film', color: '#FF2D55', spent: 64.0, budget: 150 },
];

const TRANSACTIONS: Transaction[] = [
  { id: 't1', merchant: 'Whole Foods Market', category: 'Groceries', icon: 'cart', color: '#34C759', amount: -84.12, date: 'Today' },
  { id: 't2', merchant: 'Blue Bottle Coffee', category: 'Dining Out', icon: 'cafe', color: '#FF9500', amount: -6.75, date: 'Today' },
  { id: 't3', merchant: 'Acme Corp Payroll', category: 'Income', icon: 'briefcase', color: '#30B0C7', amount: 2710.0, date: 'Yesterday' },
  { id: 't4', merchant: 'Lyft', category: 'Transport', icon: 'car', color: '#007AFF', amount: -18.4, date: 'Yesterday' },
  { id: 't5', merchant: 'Uniqlo', category: 'Shopping', icon: 'bag-handle', color: '#AF52DE', amount: -59.9, date: 'Oct 13' },
];

const BILLS: Bill[] = [
  { id: 'b1', name: 'Rent', due: 'Due Nov 1', amount: 1650, icon: 'home', color: '#5856D6' },
  { id: 'b2', name: 'Spotify', due: 'Due Oct 18', amount: 11.99, icon: 'musical-notes', color: '#34C759' },
  { id: 'b3', name: 'Electric', due: 'Due Oct 22', amount: 72.3, icon: 'flash', color: '#FFCC00' },
];

const currency = (n: number, opts?: { cents?: boolean; sign?: boolean }) => {
  const cents = opts?.cents ?? true;
  const abs = Math.abs(n);
  const formatted = abs.toLocaleString('en-US', {
    minimumFractionDigits: cents ? 2 : 0,
    maximumFractionDigits: cents ? 2 : 0,
  });
  const sign = opts?.sign ? (n < 0 ? '−' : '+') : n < 0 ? '−' : '';
  return `${sign}$${formatted}`;
};

function usePalette() {
  const dark = useColorScheme() === 'dark';
  return useMemo(
    () => ({
      dark,
      bg: dark ? '#000000' : '#F2F2F7',
      card: dark ? '#1C1C1E' : '#FFFFFF',
      text: dark ? '#FFFFFF' : '#000000',
      secondary: dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)',
      separator: dark ? 'rgba(84,84,88,0.65)' : 'rgba(60,60,67,0.18)',
      track: dark ? 'rgba(120,120,128,0.32)' : 'rgba(120,120,128,0.16)',
      tint: '#0A84FF',
      positive: dark ? '#30D158' : '#248A3D',
      negative: dark ? '#FF453A' : '#D70015',
    }),
    [dark]
  );
}

type Palette = ReturnType<typeof usePalette>;

function Ring({ progress, size = 92, stroke = 10 }: { progress: number; size?: number; stroke?: number }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const p = Math.min(Math.max(progress, 0), 1);
  return (
    <Svg width={size} height={size} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <Circle cx={size / 2} cy={size / 2} r={r} stroke="rgba(255,255,255,0.25)" strokeWidth={stroke} fill="none" />
      <Circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        stroke="#FFFFFF"
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
        <Pressable
          onPress={() => Haptics.selectionAsync()}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel={`${action} ${title}`}
          style={({ pressed }) => ({ opacity: pressed ? 0.5 : 1 })}
        >
          <Text style={[styles.sectionAction, { color: p.tint }]}>{action}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

function IconBadge({ icon, color, size = 36 }: { icon: IoniconName; color: string; size?: number }) {
  return (
    <View style={[styles.iconBadge, { backgroundColor: color, width: size, height: size, borderRadius: size * 0.28 }]}>
      <Ionicons name={icon} size={size * 0.52} color="#FFFFFF" />
    </View>
  );
}

export default function BudgetHomeScreen() {
  const p = usePalette();
  const insets = useSafeAreaInsets();
  const { fontScale } = useWindowDimensions();
  const large = fontScale >= 1.35;
  const [hideAmounts, setHideAmounts] = useState(false);

  const spent = CATEGORIES.reduce((s, c) => s + c.spent, 0);
  const left = BUDGET_TOTAL - spent;
  const progress = spent / BUDGET_TOTAL;
  const perDay = left / DAYS_LEFT;
  const mask = (s: string) => (hideAmounts ? '•••••' : s);

  const tap = () => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

  const actions: { label: string; icon: IoniconName }[] = [
    { label: 'Add Expense', icon: 'remove-circle' },
    { label: 'Add Income', icon: 'add-circle' },
    { label: 'Transfer', icon: 'swap-horizontal' },
    { label: 'Goals', icon: 'flag' },
  ];

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Budget',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerLargeTitleShadowVisible: false,
          headerStyle: { backgroundColor: p.bg },
          headerLargeStyle: { backgroundColor: p.bg },
          headerTintColor: p.tint,
          headerTitleStyle: { color: p.text },
          headerLargeTitleStyle: { color: p.text },
          headerRight: () => (
            <Pressable
              onPress={() => {
                Haptics.selectionAsync();
                setHideAmounts((v) => !v);
              }}
              hitSlop={10}
              accessibilityRole="button"
              accessibilityLabel={hideAmounts ? 'Show amounts' : 'Hide amounts'}
              style={({ pressed }) => ({ opacity: pressed ? 0.5 : 1, padding: 4 })}
            >
              <Ionicons name={hideAmounts ? 'eye-off-outline' : 'eye-outline'} size={24} color={p.tint} />
            </Pressable>
          ),
        }}
      />
      <StatusBar style={p.dark ? 'light' : 'dark'} />
      <ScrollView
        style={{ flex: 1, backgroundColor: p.bg }}
        contentInsetAdjustmentBehavior="automatic"
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: insets.bottom + 32, paddingTop: Platform.OS === 'android' ? 8 : 0 }}
      >
        {/* Hero summary */}
        <LinearGradient
          colors={p.dark ? ['#0A3D91', '#1E2A78'] : ['#0A84FF', '#3D5AFE']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.hero}
        >
          <View
            style={[styles.heroRow, large && { flexDirection: 'column', alignItems: 'flex-start' }]}
            accessible
            accessibilityLabel={`${currency(left)} left to spend in ${MONTH_LABEL}. ${Math.round(progress * 100)} percent of ${currency(BUDGET_TOTAL, { cents: false })} budget used. ${DAYS_LEFT} days left.`}
          >
            <View style={{ flex: large ? 0 : 1, gap: 4 }}>
              <Text style={styles.heroLabel}>Left to spend in {MONTH_LABEL}</Text>
              <Text style={styles.heroAmount} adjustsFontSizeToFit={!large} numberOfLines={large ? undefined : 1}>
                {mask(currency(left))}
              </Text>
              <Text style={styles.heroSub}>
                {mask(currency(spent))} of {mask(currency(BUDGET_TOTAL, { cents: false }))} spent
              </Text>
            </View>
            <View style={styles.ringWrap}>
              <Ring progress={progress} />
              <View style={styles.ringCenter}>
                <Text style={styles.ringPct}>{Math.round(progress * 100)}%</Text>
              </View>
            </View>
          </View>

          <View style={styles.heroDivider} />

          <View style={[styles.heroStats, large && { flexDirection: 'column', gap: 12 }]}>
            <View style={styles.heroStat}>
              <Text style={styles.heroStatLabel}>Safe per day</Text>
              <Text style={styles.heroStatValue}>{mask(currency(perDay))}</Text>
            </View>
            <View style={styles.heroStat}>
              <Text style={styles.heroStatLabel}>Days left</Text>
              <Text style={styles.heroStatValue}>{DAYS_LEFT}</Text>
            </View>
            <View style={styles.heroStat}>
              <Text style={styles.heroStatLabel}>Income</Text>
              <Text style={styles.heroStatValue}>{mask(currency(INCOME, { cents: false }))}</Text>
            </View>
          </View>
        </LinearGradient>

        {/* Quick actions */}
        <View style={styles.actions}>
          {actions.map((a) => (
            <Pressable
              key={a.label}
              onPress={tap}
              accessibilityRole="button"
              accessibilityLabel={a.label}
              style={({ pressed }) => [
                styles.action,
                { backgroundColor: p.card, opacity: pressed ? 0.7 : 1, minWidth: large ? '45%' : 72 },
              ]}
            >
              <Ionicons name={a.icon} size={26} color={p.tint} />
              <Text style={[styles.actionLabel, { color: p.text }]}>{a.label}</Text>
            </Pressable>
          ))}
        </View>

        {/* Budgets */}
        <SectionHeader title="Budgets" action="See All" p={p} />
        <View style={[styles.card, { backgroundColor: p.card }]}>
          {CATEGORIES.map((c, i) => {
            const ratio = c.spent / c.budget;
            const over = ratio > 1;
            const remaining = c.budget - c.spent;
            return (
              <Pressable
                key={c.id}
                onPress={() => Haptics.selectionAsync()}
                accessibilityRole="button"
                accessibilityLabel={`${c.name}. ${currency(c.spent)} of ${currency(c.budget, { cents: false })}. ${
                  over ? `${currency(-remaining)} over budget` : `${currency(remaining)} left`
                }`}
                style={({ pressed }) => [{ backgroundColor: pressed ? p.track : 'transparent' }]}
              >
                <View style={styles.budgetRow}>
                  <IconBadge icon={c.icon} color={c.color} />
                  <View style={{ flex: 1, gap: 8 }}>
                    <View style={[styles.budgetTop, large && { flexDirection: 'column', alignItems: 'flex-start' }]}>
                      <Text style={[styles.rowTitle, { color: p.text, flexShrink: 1 }]}>{c.name}</Text>
                      <Text style={[styles.rowMeta, { color: over ? p.negative : p.secondary }]}>
                        {over ? `${mask(currency(-remaining))} over` : `${mask(currency(remaining))} left`}
                      </Text>
                    </View>
                    <View style={[styles.track, { backgroundColor: p.track }]}>
                      <View
                        style={[
                          styles.fill,
                          { width: `${Math.min(ratio, 1) * 100}%`, backgroundColor: over ? p.negative : c.color },
                        ]}
                      />
                    </View>
                    <Text style={[styles.caption, { color: p.secondary }]}>
                      {mask(currency(c.spent))} of {mask(currency(c.budget, { cents: false }))}
                    </Text>
                  </View>
                </View>
                {i < CATEGORIES.length - 1 ? (
                  <View style={[styles.separator, { backgroundColor: p.separator, marginLeft: 64 }]} />
                ) : null}
              </Pressable>
            );
          })}
        </View>

        {/* Upcoming bills */}
        <SectionHeader title="Upcoming Bills" action="Manage" p={p} />
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{ gap: 12, paddingRight: 4 }}
          style={{ marginHorizontal: -16 }}
          contentInset={{ left: 16, right: 16 }}
          contentOffset={{ x: Platform.OS === 'ios' ? -16 : 0, y: 0 }}
        >
          {Platform.OS === 'android' ? <View style={{ width: 4 }} /> : null}
          {BILLS.map((b) => (
            <Pressable
              key={b.id}
              onPress={tap}
              accessibilityRole="button"
              accessibilityLabel={`${b.name}, ${currency(b.amount)}, ${b.due}`}
              style={({ pressed }) => [
                styles.billCard,
                { backgroundColor: p.card, opacity: pressed ? 0.7 : 1, width: large ? 220 : 156 },
              ]}
            >
              <IconBadge icon={b.icon} color={b.color} size={32} />
              <Text style={[styles.rowTitle, { color: p.text }]}>{b.name}</Text>
              <Text style={[styles.billAmount, { color: p.text }]}>{mask(currency(b.amount))}</Text>
              <Text style={[styles.caption, { color: p.secondary }]}>{b.due}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {/* Recent transactions */}
        <SectionHeader title="Recent Activity" action="See All" p={p} />
        <View style={[styles.card, { backgroundColor: p.card }]}>
          {TRANSACTIONS.map((t, i) => {
            const income = t.amount > 0;
            return (
              <Pressable
                key={t.id}
                onPress={() => Haptics.selectionAsync()}
                accessibilityRole="button"
                accessibilityLabel={`${t.merchant}, ${t.category}, ${t.date}, ${income ? 'received' : 'spent'} ${currency(
                  Math.abs(t.amount)
                )}`}
                style={({ pressed }) => [{ backgroundColor: pressed ? p.track : 'transparent' }]}
              >
                <View style={[styles.txRow, large && { alignItems: 'flex-start' }]}>
                  <IconBadge icon={t.icon} color={t.color} />
                  <View style={[styles.txBody, large && { flexDirection: 'column', alignItems: 'flex-start', gap: 4 }]}>
                    <View style={{ flex: large ? 0 : 1, gap: 2 }}>
                      <Text style={[styles.rowTitle, { color: p.text }]} numberOfLines={large ? undefined : 1}>
                        {t.merchant}
                      </Text>
                      <Text style={[styles.caption, { color: p.secondary }]}>
                        {t.category} · {t.date}
                      </Text>
                    </View>
                    <Text style={[styles.txAmount, { color: income ? p.positive : p.text }]}>
                      {mask(currency(t.amount, { sign: true }))}
                    </Text>
                  </View>
                </View>
                {i < TRANSACTIONS.length - 1 ? (
                  <View style={[styles.separator, { backgroundColor: p.separator, marginLeft: 64 }]} />
                ) : null}
              </Pressable>
            );
          })}
        </View>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  hero: {
    borderRadius: 22,
    padding: 20,
    marginTop: 8,
    gap: 16,
  },
  heroRow: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  heroLabel: { color: 'rgba(255,255,255,0.85)', fontSize: 15, fontWeight: '500' },
  heroAmount: { color: '#FFFFFF', fontSize: 40, fontWeight: '700', letterSpacing: -0.5, fontVariant: ['tabular-nums'] },
  heroSub: { color: 'rgba(255,255,255,0.85)', fontSize: 15 },
  ringWrap: { alignItems: 'center', justifyContent: 'center' },
  ringCenter: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, alignItems: 'center', justifyContent: 'center' },
  ringPct: { color: '#FFFFFF', fontSize: 17, fontWeight: '700', fontVariant: ['tabular-nums'] },
  heroDivider: { height: StyleSheet.hairlineWidth, backgroundColor: 'rgba(255,255,255,0.35)' },
  heroStats: { flexDirection: 'row', justifyContent: 'space-between', gap: 8 },
  heroStat: { flexShrink: 1, gap: 2 },
  heroStatLabel: { color: 'rgba(255,255,255,0.8)', fontSize: 13 },
  heroStatValue: { color: '#FFFFFF', fontSize: 17, fontWeight: '600', fontVariant: ['tabular-nums'] },
  actions: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 16 },
  action: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    paddingHorizontal: 6,
    borderRadius: 16,
    gap: 6,
    minHeight: 44,
  },
  actionLabel: { fontSize: 13, fontWeight: '500', textAlign: 'center' },
  sectionHeader: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    gap: 8,
    marginTop: 28,
    marginBottom: 10,
    paddingHorizontal: 4,
  },
  sectionTitle: { fontSize: 22, fontWeight: '700' },
  sectionAction: { fontSize: 17 },
  card: { borderRadius: 16, overflow: 'hidden' },
  budgetRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 12, paddingHorizontal: 16, paddingVertical: 14 },
  budgetTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline', gap: 8 },
  rowTitle: { fontSize: 17, fontWeight: '600' },
  rowMeta: { fontSize: 15, fontWeight: '500', fontVariant: ['tabular-nums'] },
  caption: { fontSize: 13, fontVariant: ['tabular-nums'] },
  track: { height: 8, borderRadius: 4, overflow: 'hidden' },
  fill: { height: '100%', borderRadius: 4 },
  separator: { height: StyleSheet.hairlineWidth },
  iconBadge: { alignItems: 'center', justifyContent: 'center' },
  billCard: { borderRadius: 16, padding: 14, gap: 6 },
  billAmount: { fontSize: 20, fontWeight: '700', fontVariant: ['tabular-nums'] },
  txRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 12, minHeight: 60 },
  txBody: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 12 },
  txAmount: { fontSize: 17, fontWeight: '600', fontVariant: ['tabular-nums'] },
});
