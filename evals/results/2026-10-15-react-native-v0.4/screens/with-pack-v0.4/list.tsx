// Transactions — Feed / list archetype.
// Job: scan recent account activity. Focal: month-to-date spend summary, then the first row.
// Primary action: none in content (search lives in the native header). Cutting: per-row chevrons,
// colored category circles, red on every debit (ink + minus sign; green only for money in).

import React, { useEffect, useMemo, useState } from 'react';
import { Platform, RefreshControl, ScrollView, SectionList, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { metrics, radius, space, tabular, useQTheme } from '../../pack04/theme';
import {
  QChip,
  QEmptyState,
  QHeroMetric,
  QSkeleton,
  QSkeletonRow,
  QTertiaryButton,
  QText,
  useQLargeText,
} from '../../pack04/components';

// ── Data ──────────────────────────────────────────────────────────────

type IconName = React.ComponentProps<typeof Ionicons>['name'];

type Txn = {
  id: string;
  merchant: string;
  category: string;
  icon: IconName;
  /** Signed amount in USD: negative = money out. */
  amount: number;
  daysAgo: number;
  time: string;
  pending?: boolean;
};

const TRANSACTIONS: Txn[] = [
  { id: 't01', merchant: 'Blue Bottle Coffee', category: 'Coffee', icon: 'cafe-outline', amount: -6.75, daysAgo: 0, time: '8:14 AM', pending: true },
  { id: 't02', merchant: 'Lyft', category: 'Transport', icon: 'car-outline', amount: -18.42, daysAgo: 0, time: '7:51 AM', pending: true },
  { id: 't03', merchant: 'Whole Foods Market', category: 'Groceries', icon: 'cart-outline', amount: -86.14, daysAgo: 1, time: '6:32 PM' },
  { id: 't04', merchant: 'Maya Fernández', category: 'Transfer in · Dinner split', icon: 'swap-horizontal-outline', amount: 42.5, daysAgo: 1, time: '9:05 PM' },
  { id: 't05', merchant: 'Spotify', category: 'Subscription', icon: 'repeat-outline', amount: -11.99, daysAgo: 1, time: '4:00 AM' },
  { id: 't06', merchant: 'Northwind Labs', category: 'Payroll', icon: 'briefcase-outline', amount: 3184.27, daysAgo: 2, time: '6:00 AM' },
  { id: 't07', merchant: 'Shell', category: 'Fuel', icon: 'car-outline', amount: -54.3, daysAgo: 2, time: '5:47 PM' },
  { id: 't08', merchant: 'Tartine Bakery', category: 'Dining', icon: 'restaurant-outline', amount: -23.8, daysAgo: 3, time: '12:18 PM' },
  { id: 't09', merchant: 'PG&E', category: 'Utilities', icon: 'flash-outline', amount: -132.06, daysAgo: 4, time: '9:00 AM' },
  { id: 't10', merchant: 'Uniqlo', category: 'Refund', icon: 'return-down-back-outline', amount: 39.9, daysAgo: 4, time: '2:26 PM' },
  { id: 't11', merchant: 'Trader Joe’s', category: 'Groceries', icon: 'cart-outline', amount: -61.23, daysAgo: 5, time: '7:12 PM' },
  { id: 't12', merchant: 'CVS Pharmacy', category: 'Health', icon: 'medkit-outline', amount: -14.89, daysAgo: 6, time: '11:40 AM' },
  { id: 't13', merchant: 'Mission Bay Apartments', category: 'Rent', icon: 'home-outline', amount: -2150, daysAgo: 8, time: '8:00 AM' },
  { id: 't14', merchant: 'Amazon', category: 'Shopping', icon: 'bag-handle-outline', amount: -47.62, daysAgo: 9, time: '3:55 PM' },
  { id: 't15', merchant: 'Sweetgreen', category: 'Dining', icon: 'restaurant-outline', amount: -16.45, daysAgo: 10, time: '1:07 PM' },
];

type Filter = 'all' | 'in' | 'out' | 'pending';

const FILTERS: { value: Filter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'in', label: 'Money in' },
  { value: 'out', label: 'Money out' },
  { value: 'pending', label: 'Pending' },
];

// One money format for the whole screen.
const usd = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const MINUS = '−';

function formatAmount(amount: number) {
  return amount < 0 ? `${MINUS}${usd.format(-amount)}` : `+${usd.format(amount)}`;
}

function dayLabel(daysAgo: number) {
  if (daysAgo === 0) return 'Today';
  if (daysAgo === 1) return 'Yesterday';
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  return d.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });
}

function matches(t: Txn, filter: Filter, query: string) {
  if (filter === 'in' && t.amount < 0) return false;
  if (filter === 'out' && t.amount > 0) return false;
  if (filter === 'pending' && !t.pending) return false;
  const q = query.trim().toLowerCase();
  return !q || t.merchant.toLowerCase().includes(q) || t.category.toLowerCase().includes(q);
}

// ── Row ───────────────────────────────────────────────────────────────

const LEADING = 40;

function TransactionRow({ txn, first, last }: { txn: Txn; first: boolean; last: boolean }) {
  const { c } = useQTheme();
  const stacked = useQLargeText();
  const income = txn.amount > 0;
  const meta = [txn.pending ? 'Pending' : null, txn.category, txn.time].filter(Boolean).join(' · ');
  const amount = (
    <QText variant="headline" color={income ? 'positive' : 'ink'} style={[tabular, !stacked && styles.amount]}>
      {formatAmount(txn.amount)}
    </QText>
  );
  return (
    <View
      accessible
      accessibilityLabel={`${txn.merchant}, ${meta}, ${income ? 'received' : 'spent'} ${usd.format(Math.abs(txn.amount))}`}
      style={[
        styles.rowWrap,
        { backgroundColor: c.surface },
        first && styles.firstRow,
        last && styles.lastRow,
      ]}
    >
      <View style={styles.row}>
        {!stacked && (
          <View style={[styles.glyph, { backgroundColor: c.surface2 }]}>
            <Ionicons name={txn.icon} size={20} color={c.ink2} />
          </View>
        )}
        <View style={styles.rowText}>
          <QText variant="headline" numberOfLines={stacked ? undefined : 1}>
            {txn.merchant}
          </QText>
          <QText variant="subhead" color="ink2" numberOfLines={stacked ? undefined : 1}>
            {meta}
          </QText>
          {stacked && amount}
        </View>
        {!stacked && amount}
      </View>
      {!last && <View style={[styles.separator, { backgroundColor: c.hairline, marginLeft: stacked ? space.md : space.md + LEADING + space.sm }]} />}
    </View>
  );
}

function LoadingRows() {
  const { c } = useQTheme();
  return (
    <View style={[styles.skeletonGroup, { backgroundColor: c.surface }]}>
      {Array.from({ length: 6 }, (_, i) => (
        <QSkeletonRow key={i} />
      ))}
    </View>
  );
}

// ── Screen ────────────────────────────────────────────────────────────

export default function TransactionsScreen() {
  const { c } = useQTheme();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');

  useEffect(() => {
    const id = setTimeout(() => setLoading(false), 700);
    return () => clearTimeout(id);
  }, []);

  const today = new Date();
  const monthName = today.toLocaleDateString('en-US', { month: 'long' });
  const inThisMonth = (t: Txn) => t.daysAgo < today.getDate();

  const spent = TRANSACTIONS.filter((t) => t.amount < 0 && inThisMonth(t)).reduce((s, t) => s - t.amount, 0);
  const received = TRANSACTIONS.filter((t) => t.amount > 0 && inThisMonth(t)).reduce((s, t) => s + t.amount, 0);
  const pendingCount = TRANSACTIONS.filter((t) => t.pending).length;
  const spentParts = usd.formatToParts(spent);
  const spentSymbol = spentParts.find((p) => p.type === 'currency')?.value;
  const spentValue = spentParts.filter((p) => p.type !== 'currency').map((p) => p.value).join('');

  const sections = useMemo(() => {
    const groups = new Map<number, Txn[]>();
    for (const t of TRANSACTIONS) {
      if (!matches(t, filter, query)) continue;
      groups.set(t.daysAgo, [...(groups.get(t.daysAgo) ?? []), t]);
    }
    return [...groups.entries()].sort(([a], [b]) => a - b).map(([days, data]) => ({ title: dayLabel(days), data }));
  }, [filter, query]);

  const selectFilter = (f: Filter) => {
    if (f === filter) return;
    Haptics.selectionAsync();
    setFilter(f);
  };

  const clearFilters = () => {
    setFilter('all');
    setQuery('');
  };

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 900);
  };

  const filterLabel = FILTERS.find((f) => f.value === filter)?.label.toLowerCase();

  const header = (
    <View style={styles.header}>
      {loading ? (
        <View style={styles.heroSkeleton}>
          <QSkeleton width="40%" height={12} />
          <QSkeleton width="55%" height={56} radius={radius.m} />
          <QSkeleton width="70%" height={14} />
        </View>
      ) : (
        <QHeroMetric
          label={`Spent in ${monthName}`}
          prefix={spentSymbol}
          value={spentValue}
          context={`${usd.format(received)} in · ${pendingCount} pending`}
        />
      )}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips} style={styles.chipScroller}>
        {FILTERS.map((f) => (
          <QChip key={f.value} title={f.label} selected={filter === f.value} onPress={() => selectFilter(f.value)} />
        ))}
      </ScrollView>
    </View>
  );

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Transactions',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerLargeTitleShadowVisible: false,
          headerTintColor: c.ink,
          headerTitleStyle: { color: c.ink },
          contentStyle: { backgroundColor: c.canvas },
          // iOS 26+: headerStyle hides the large title, so only Android gets a painted header.
          ...(Platform.OS === 'android' ? { headerStyle: { backgroundColor: c.canvas } } : {}),
          headerSearchBarOptions: {
            placeholder: 'Search merchants or categories',
            onChangeText: (e) => setQuery(e.nativeEvent.text),
            onCancelButtonPress: () => setQuery(''),
            hideWhenScrolling: true,
          },
        }}
      />
      <StatusBar style="auto" />
      <SectionList
        style={{ flex: 1, backgroundColor: c.canvas }}
        contentInsetAdjustmentBehavior="automatic"
        keyboardDismissMode="on-drag"
        sections={loading ? [] : sections}
        keyExtractor={(t) => t.id}
        stickySectionHeadersEnabled
        ListHeaderComponent={header}
        renderSectionHeader={({ section }) => (
          <View style={[styles.sectionHeader, { backgroundColor: c.canvas }]}>
            <QText variant="overline" color="ink2" role="header">
              {section.title}
            </QText>
          </View>
        )}
        renderItem={({ item, index, section }) => (
          <TransactionRow txn={item} first={index === 0} last={index === section.data.length - 1} />
        )}
        ListEmptyComponent={
          loading ? (
            <LoadingRows />
          ) : (
            <View>
              <QEmptyState
                icon="search-outline"
                title={query.trim() ? `No matches for “${query.trim()}”` : `No ${filterLabel} transactions`}
                message={
                  query.trim()
                    ? 'Try a merchant name like “Whole Foods”, or a category like “Dining”.'
                    : 'Nothing in the last two weeks matches this filter.'
                }
              />
              <View style={styles.clear}>
                <QTertiaryButton title="Clear filters" onPress={clearFilters} />
              </View>
            </View>
          )
        }
        ListFooterComponent={
          !loading && sections.length > 0 ? (
            <QText variant="footnote" color="ink2" style={styles.footer}>
              Showing the last 14 days. Pending charges can change before they post.
            </QText>
          ) : null
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={c.ink2} />}
        contentContainerStyle={styles.content}
      />
    </>
  );
}

const styles = StyleSheet.create({
  content: { paddingBottom: space.xxl },
  header: { paddingHorizontal: space.margin, paddingTop: space.xs, gap: space.xl, paddingBottom: space.xs },
  heroSkeleton: { gap: space.sm },
  chipScroller: { marginHorizontal: -space.margin },
  chips: { paddingHorizontal: space.margin, gap: space.xs },
  sectionHeader: { paddingHorizontal: space.margin + space.md, paddingTop: space.xl, paddingBottom: space.xs },
  rowWrap: { marginHorizontal: space.margin, overflow: 'hidden' },
  firstRow: { borderTopLeftRadius: radius.l, borderTopRightRadius: radius.l },
  lastRow: { borderBottomLeftRadius: radius.l, borderBottomRightRadius: radius.l },
  row: {
    minHeight: metrics.rowMinHeight + space.sm,
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
    paddingHorizontal: space.md,
    paddingVertical: space.sm,
  },
  glyph: { width: LEADING, height: LEADING, borderRadius: LEADING / 2, alignItems: 'center', justifyContent: 'center' },
  rowText: { flex: 1, gap: 2 },
  amount: { textAlign: 'right' },
  separator: { height: StyleSheet.hairlineWidth },
  skeletonGroup: { marginHorizontal: space.margin, marginTop: space.xl, borderRadius: radius.l, overflow: 'hidden' },
  clear: { alignItems: 'center' },
  footer: { paddingHorizontal: space.margin + space.md, paddingTop: space.xl },
});
