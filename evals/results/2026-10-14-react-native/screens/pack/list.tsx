// Transactions — Feed / list archetype.
// Job: scan recent account activity. Focal: the newest rows. Primary action: none in content
// (search lives in the native header, filters are chips). Cutting: per-row cards, chevrons, colored red debits.

import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { Platform, RefreshControl, ScrollView, SectionList, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { metrics, space, tabular, useTheme } from '../../pack/theme';
import { Chip, EmptyState, SkeletonRow, Toast, Txt, useLargeText } from '../../pack/components';

// ── Data ─────────────────────────────────────────────────────────────

type Category = 'groceries' | 'dining' | 'transport' | 'shopping' | 'bills' | 'income' | 'transfer' | 'entertainment';
type Kind = 'card' | 'transfer' | 'income';

type Transaction = {
  id: string;
  merchant: string;
  category: Category;
  kind: Kind;
  /** Signed, in cents. Negative = money out. */
  cents: number;
  day: string;
  time: string;
  pending?: boolean;
  note?: string;
};

const CATEGORY: Record<Category, { label: string; icon: React.ComponentProps<typeof Ionicons>['name'] }> = {
  groceries: { label: 'Groceries', icon: 'basket-outline' },
  dining: { label: 'Eating out', icon: 'restaurant-outline' },
  transport: { label: 'Transport', icon: 'train-outline' },
  shopping: { label: 'Shopping', icon: 'bag-handle-outline' },
  bills: { label: 'Bills', icon: 'flash-outline' },
  income: { label: 'Salary', icon: 'briefcase-outline' },
  transfer: { label: 'Transfer', icon: 'swap-horizontal-outline' },
  entertainment: { label: 'Entertainment', icon: 'film-outline' },
};

const TRANSACTIONS: Transaction[] = [
  { id: 't01', merchant: 'Blue Bottle Coffee', category: 'dining', kind: 'card', cents: -675, day: 'Today', time: '8:42 AM', pending: true },
  { id: 't02', merchant: 'BART Clipper reload', category: 'transport', kind: 'card', cents: -4000, day: 'Today', time: '8:15 AM', pending: true },
  { id: 't03', merchant: 'Priya Raman', category: 'transfer', kind: 'transfer', cents: 3850, day: 'Today', time: '7:58 AM', note: 'Dinner split' },
  { id: 't04', merchant: 'Trader Joe’s', category: 'groceries', kind: 'card', cents: -8314, day: 'Yesterday', time: '6:31 PM' },
  { id: 't05', merchant: 'PG&E', category: 'bills', kind: 'card', cents: -11268, day: 'Yesterday', time: '9:00 AM', note: 'Autopay' },
  { id: 't06', merchant: 'Northwind Labs payroll', category: 'income', kind: 'income', cents: 412560, day: 'Mon, Oct 12', time: '5:02 AM' },
  { id: 't07', merchant: 'Tartine Bakery', category: 'dining', kind: 'card', cents: -2240, day: 'Mon, Oct 12', time: '12:47 PM' },
  { id: 't08', merchant: 'Savings · Rainy day', category: 'transfer', kind: 'transfer', cents: -50000, day: 'Mon, Oct 12', time: '5:30 AM', note: 'Scheduled' },
  { id: 't09', merchant: 'Alamo Drafthouse', category: 'entertainment', kind: 'card', cents: -3196, day: 'Sat, Oct 10', time: '8:20 PM' },
  { id: 't10', merchant: 'Uber', category: 'transport', kind: 'card', cents: -1873, day: 'Sat, Oct 10', time: '11:58 PM' },
  { id: 't11', merchant: 'Rainbow Grocery', category: 'groceries', kind: 'card', cents: -5627, day: 'Sat, Oct 10', time: '11:14 AM' },
  { id: 't12', merchant: 'Muji Union Square', category: 'shopping', kind: 'card', cents: -4950, day: 'Fri, Oct 9', time: '4:05 PM' },
  { id: 't13', merchant: 'Muji Union Square', category: 'shopping', kind: 'card', cents: 1490, day: 'Fri, Oct 9', time: '4:40 PM', note: 'Refund' },
  { id: 't14', merchant: 'Comcast Xfinity', category: 'bills', kind: 'card', cents: -7999, day: 'Fri, Oct 9', time: '7:00 AM', note: 'Autopay' },
  { id: 't15', merchant: 'Daniel Okoro', category: 'transfer', kind: 'transfer', cents: -12000, day: 'Thu, Oct 8', time: '7:12 PM', note: 'Concert tickets' },
  { id: 't16', merchant: 'Safeway', category: 'groceries', kind: 'card', cents: -3482, day: 'Thu, Oct 8', time: '6:03 PM' },
];

type Filter = 'all' | 'in' | 'out' | 'pending';
const FILTERS: { value: Filter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'in', label: 'Money in' },
  { value: 'out', label: 'Money out' },
  { value: 'pending', label: 'Pending' },
];

/** "$1,234.56" with a true minus sign for debits and "+" for credits. */
function formatAmount(cents: number) {
  const abs = Math.abs(cents);
  const dollars = Math.floor(abs / 100)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const rest = (abs % 100).toString().padStart(2, '0');
  return `${cents < 0 ? '−' : '+'}$${dollars}.${rest}`;
}

// ── Screen ───────────────────────────────────────────────────────────

export default function TransactionsScreen() {
  const { c } = useTheme();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [toast, setToast] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');

  // Simulated first load: skeleton rows in the final layout, never a centered spinner.
  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 700);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 2200);
    return () => clearTimeout(t);
  }, [toast]);

  const refresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
      setToast('Up to date');
    }, 900);
  }, []);

  const sections = useMemo(() => {
    const q = query.trim().toLowerCase();
    const visible = TRANSACTIONS.filter((t) => {
      if (filter === 'in' && t.cents < 0) return false;
      if (filter === 'out' && t.cents > 0) return false;
      if (filter === 'pending' && !t.pending) return false;
      if (!q) return true;
      return [t.merchant, CATEGORY[t.category].label, t.note ?? ''].some((s) => s.toLowerCase().includes(q));
    });
    const byDay = new Map<string, Transaction[]>();
    for (const t of visible) byDay.set(t.day, [...(byDay.get(t.day) ?? []), t]);
    return Array.from(byDay, ([title, data]) => ({ title, data, net: data.reduce((sum, t) => sum + t.cents, 0) }));
  }, [filter, query]);

  const filtered = filter !== 'all' || query.trim().length > 0;
  const clearFilters = () => {
    setFilter('all');
    setQuery('');
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <StatusBar style="auto" />
      <Stack.Screen
        options={{
          title: 'Transactions',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          // iOS 26+: a header backgroundColor hides the large title — Android only.
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          contentStyle: { backgroundColor: c.canvas },
          headerSearchBarOptions: {
            placeholder: 'Search merchants, notes',
            hideWhenScrolling: true,
            onChangeText: (e) => setQuery(e.nativeEvent.text),
            onCancelButtonPress: () => setQuery(''),
          },
        }}
      />

      <SectionList
        sections={loading ? [] : sections}
        keyExtractor={(t) => t.id}
        contentInsetAdjustmentBehavior="automatic"
        style={{ backgroundColor: c.canvas }}
        contentContainerStyle={{ paddingBottom: space.xxl }}
        stickySectionHeadersEnabled
        keyboardDismissMode="on-drag"
        ListHeaderComponent={<Filters value={filter} onChange={setFilter} />}
        renderSectionHeader={({ section }) => <DayHeader title={section.title} net={section.net} />}
        renderItem={({ item }) => <TransactionRow t={item} />}
        ItemSeparatorComponent={Separator}
        ListEmptyComponent={
          loading ? (
            <View accessibilityLabel="Loading transactions">
              {Array.from({ length: 7 }, (_, i) => (
                <SkeletonRow key={i} />
              ))}
            </View>
          ) : filtered ? (
            <EmptyState
              icon="search-outline"
              title={query.trim() ? `No matches for “${query.trim()}”` : 'Nothing in this filter'}
              message="Try a different merchant name, or show all activity from the last 30 days."
              action={{ title: 'Clear filters', onPress: clearFilters }}
            />
          ) : (
            <EmptyState
              icon="card-outline"
              title="No transactions yet"
              message="Card payments and transfers show up here a few minutes after they happen."
            />
          )
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={refresh} tintColor={c.ink2} />}
      />

      {toast && <Toast message={toast} />}
    </View>
  );
}

// ── Pieces ───────────────────────────────────────────────────────────

function Filters({ value, onChange }: { value: Filter; onChange: (f: Filter) => void }) {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={styles.filters}
      accessibilityRole="tablist"
    >
      {FILTERS.map((f) => (
        <Chip
          key={f.value}
          title={f.label}
          selected={value === f.value}
          onPress={() => {
            if (value !== f.value) Haptics.selectionAsync();
            onChange(f.value);
          }}
        />
      ))}
    </ScrollView>
  );
}

function DayHeader({ title, net }: { title: string; net: number }) {
  const { c } = useTheme();
  return (
    <View style={[styles.dayHeader, { backgroundColor: c.canvas }]} accessibilityRole="header">
      <Txt variant="overline" color="ink2">
        {title}
      </Txt>
      <Txt variant="overline" color="ink2" style={tabular}>
        {formatAmount(net)}
      </Txt>
    </View>
  );
}

function TransactionRow({ t }: { t: Transaction }) {
  const { c } = useTheme();
  const stacked = useLargeText();
  const cat = CATEGORY[t.category];
  const credit = t.cents > 0;
  const meta = [t.pending ? 'Pending' : t.time, t.note ?? cat.label].join(' · ');
  const amount = formatAmount(t.cents);

  const amountText = (
    // Debits stay ink with a minus sign; only money in gets color (and a "+").
    <Txt color={credit ? 'positive' : 'ink'} style={[tabular, !stacked && styles.amount]}>
      {amount}
    </Txt>
  );

  return (
    <View
      accessible
      accessibilityLabel={`${t.merchant}, ${credit ? 'received' : 'spent'} ${amount.slice(1)}, ${meta}`}
      style={styles.row}
    >
      {!stacked && (
        <View style={[styles.glyph, { backgroundColor: c.surface }]}>
          <Ionicons name={cat.icon} size={20} color={c.ink2} />
        </View>
      )}
      <View style={styles.rowText}>
        <Txt variant="headline" numberOfLines={stacked ? undefined : 1}>
          {t.merchant}
        </Txt>
        <Txt variant="subhead" color="ink2" numberOfLines={stacked ? undefined : 1}>
          {meta}
        </Txt>
        {stacked && amountText}
      </View>
      {!stacked && amountText}
    </View>
  );
}

function Separator() {
  const { c } = useTheme();
  return <View style={[styles.separator, { backgroundColor: c.hairline }]} />;
}

const GLYPH = 40;

const styles = StyleSheet.create({
  filters: {
    gap: space.xs,
    paddingHorizontal: space.margin,
    paddingTop: space.xs,
    paddingBottom: space.md,
  },
  dayHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: space.margin,
    paddingTop: space.xl,
    paddingBottom: space.xs,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
    minHeight: 64,
    paddingHorizontal: space.margin,
    paddingVertical: space.sm,
  },
  glyph: {
    width: GLYPH,
    height: GLYPH,
    borderRadius: GLYPH / 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowText: { flex: 1, gap: 2 },
  amount: { textAlign: 'right', minWidth: metrics.minTap },
  separator: {
    height: StyleSheet.hairlineWidth,
    marginLeft: space.margin + GLYPH + space.sm,
  },
});
