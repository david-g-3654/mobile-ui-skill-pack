// Transactions (checking account) — Feed / list archetype.
// Job: scan what moved through the account. Focal: October spend so far, then the newest row.
// Primary action: none in content; search lives in the native header bar.
// Cutting: chevrons on rows, tinted icon circles, red on every debit (ink + minus; green + plus only for money in).

import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { NativeSyntheticEvent, Platform, RefreshControl, ScrollView, SectionList, StyleSheet, TextInputFocusEventData, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { radius, space, tabular, useQTheme } from '../../pack04/theme';
import { QChip, QEmptyState, QHeroMetric, QListRow, QSkeleton, QSkeletonRow, QText, QTertiaryButton } from '../../pack04/components';

type IconName = React.ComponentProps<typeof Ionicons>['name'];
type Filter = 'all' | 'in' | 'out' | 'pending';

type Txn = {
  id: string;
  merchant: string;
  detail: string;
  icon: IconName;
  /** Signed USD. Negative = money out. */
  amount: number;
  day: string;
  pending?: boolean;
};

// Today is Thu, Oct 15.
const TXNS: Txn[] = [
  { id: 't01', merchant: 'Blue Bottle Coffee', detail: 'Coffee · 8:12 AM', icon: 'cafe-outline', amount: -6.75, day: 'Today', pending: true },
  { id: 't02', merchant: 'Lyft', detail: 'Transport · 7:48 AM', icon: 'car-outline', amount: -18.42, day: 'Today', pending: true },
  { id: 't03', merchant: 'Trader Joe’s', detail: 'Groceries · 6:31 PM', icon: 'cart-outline', amount: -64.18, day: 'Yesterday' },
  { id: 't04', merchant: 'Refund from Uniqlo', detail: 'Shopping · 2:05 PM', icon: 'return-down-back-outline', amount: 29.9, day: 'Yesterday' },
  { id: 't05', merchant: 'Spotify', detail: 'Subscription · Monthly', icon: 'musical-notes-outline', amount: -11.99, day: 'Yesterday' },
  { id: 't06', merchant: 'Northwind Logistics payroll', detail: 'Direct deposit', icon: 'arrow-down-outline', amount: 2840.16, day: 'Tuesday' },
  { id: 't07', merchant: 'Transfer to Savings', detail: 'Rainy-day fund ••2207', icon: 'swap-horizontal-outline', amount: -400, day: 'Tuesday' },
  { id: 't08', merchant: 'Chipotle', detail: 'Dining · 12:40 PM', icon: 'restaurant-outline', amount: -14.35, day: 'Tuesday' },
  { id: 't09', merchant: 'PG&E', detail: 'Utilities · Autopay', icon: 'flash-outline', amount: -132.07, day: 'Monday' },
  { id: 't10', merchant: 'Sofía Ramírez-Castillo', detail: 'Sent with Zelle · “Tahoe cabin, my half”', icon: 'person-outline', amount: -215, day: 'Monday' },
  { id: 't11', merchant: 'Walgreens', detail: 'Pharmacy · 5:17 PM', icon: 'medkit-outline', amount: -23.61, day: 'Oct 10' },
  { id: 't12', merchant: 'Amtrak', detail: 'Travel · SF → Sacramento', icon: 'train-outline', amount: -48, day: 'Oct 10' },
  { id: 't13', merchant: 'Interest paid', detail: 'September', icon: 'trending-up-outline', amount: 0.83, day: 'Oct 9' },
];

const money = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const MINUS = '−';

function signed(n: number) {
  return n < 0 ? `${MINUS}${money.format(-n)}` : `+${money.format(n)}`;
}

function moneyParts(n: number) {
  const s = money.format(n);
  const first = s.search(/\d/);
  let last = s.length;
  while (last > first && !/\d/.test(s[last - 1])) last--;
  return { prefix: s.slice(0, first), value: s.slice(first, last), suffix: s.slice(last) };
}

const FILTERS: { value: Filter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'out', label: 'Money out' },
  { value: 'in', label: 'Money in' },
  { value: 'pending', label: 'Pending' },
];

const FILTER_NAMES: Record<Filter, string> = { all: '', in: 'money in', out: 'money out', pending: 'pending' };

// ── Screen ────────────────────────────────────────────────────────────

export default function TransactionsScreen() {
  const { c } = useQTheme();
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    const id = setTimeout(() => setLoading(false), 700);
    return () => clearTimeout(id);
  }, []);

  const refresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    }, 900);
  }, []);

  const spent = useMemo(() => TXNS.filter((t) => t.amount < 0 && !t.merchant.startsWith('Transfer')).reduce((s, t) => s - t.amount, 0), []);
  const spentParts = moneyParts(spent);

  const sections = useMemo(() => {
    const q = query.trim().toLowerCase();
    const rows = TXNS.filter((t) => {
      if (filter === 'in' && t.amount < 0) return false;
      if (filter === 'out' && t.amount > 0) return false;
      if (filter === 'pending' && !t.pending) return false;
      return !q || t.merchant.toLowerCase().includes(q) || t.detail.toLowerCase().includes(q);
    });
    const order: string[] = [];
    const byDay: Record<string, Txn[]> = {};
    for (const t of rows) {
      if (!byDay[t.day]) {
        byDay[t.day] = [];
        order.push(t.day);
      }
      byDay[t.day].push(t);
    }
    return order.map((day) => ({ title: day, data: byDay[day] }));
  }, [filter, query]);

  const onSearch = (e: NativeSyntheticEvent<TextInputFocusEventData>) => setQuery(e.nativeEvent.text);
  const clear = () => {
    setFilter('all');
    setQuery('');
  };

  const header = (
    <View style={styles.header}>
      {loading ? (
        <View style={{ gap: space.xs }}>
          <QSkeleton width={120} height={12} />
          <QSkeleton width="50%" height={56} />
        </View>
      ) : (
        <QHeroMetric
          label="Spent in October"
          prefix={spentParts.prefix}
          value={spentParts.value}
          suffix={spentParts.suffix}
          context="Oct 1 – 15 · excludes transfers"
        />
      )}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips} style={styles.chipScroller}>
        {FILTERS.map((f) => (
          <QChip
            key={f.value}
            title={f.label}
            selected={filter === f.value}
            onPress={() => {
              if (filter !== f.value) Haptics.selectionAsync();
              setFilter(f.value);
            }}
          />
        ))}
      </ScrollView>
    </View>
  );

  const filtered = filter !== 'all' || query.trim().length > 0;
  const emptyMessage = query.trim()
    ? `Nothing matches “${query.trim()}”${filter !== 'all' ? ` in ${FILTER_NAMES[filter]}` : ''}. Try a merchant name like “Lyft”.`
    : `No ${FILTER_NAMES[filter]} transactions this month.`;

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Transactions',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          contentStyle: { backgroundColor: c.canvas },
          headerSearchBarOptions: {
            placeholder: 'Search merchants',
            onChangeText: onSearch,
            onCancelButtonPress: () => setQuery(''),
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
        contentContainerStyle={styles.content}
        renderSectionHeader={({ section }) => (
          <View style={[styles.sectionHeader, { backgroundColor: c.canvas }]}>
            <QText variant="overline" color="ink2" role="header">
              {section.title}
            </QText>
          </View>
        )}
        renderItem={({ item, index, section }) => {
          const first = index === 0;
          const last = index === section.data.length - 1;
          const credit = item.amount > 0;
          return (
            <View
              style={[
                styles.rowWrap,
                { backgroundColor: c.surface },
                first && styles.rowFirst,
                last && styles.rowLast,
              ]}
            >
              <QListRow
                icon={item.icon}
                title={item.merchant}
                subtitle={item.pending ? `Pending · ${item.detail}` : item.detail}
                value={credit ? undefined : signed(item.amount)}
                trailing={
                  credit ? (
                    <QText color="positive" style={tabular}>
                      {signed(item.amount)}
                    </QText>
                  ) : undefined
                }
                kind="action"
                // Opens the transaction detail screen once that route exists.
                onPress={() => {}}
              />
              {!last && <View style={[styles.hairline, { backgroundColor: c.hairline }]} />}
            </View>
          );
        }}
        ListEmptyComponent={
          loading ? (
            <View style={[styles.skeletonGroup, { backgroundColor: c.surface }]}>
              {Array.from({ length: 7 }, (_, i) => (
                <QSkeletonRow key={i} />
              ))}
            </View>
          ) : filtered ? (
            <View>
              <QEmptyState icon="search-outline" title="No matches" message={emptyMessage} />
              <View style={styles.center}>
                <QTertiaryButton title="Clear filters" onPress={clear} />
              </View>
            </View>
          ) : (
            <QEmptyState
              icon="receipt-outline"
              title="No transactions yet"
              message="Card payments and transfers show up here a few minutes after they happen."
            />
          )
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={refresh} tintColor={c.ink2} />}
      />
    </>
  );
}

const styles = StyleSheet.create({
  content: { paddingHorizontal: space.margin, paddingBottom: space.xxl },
  header: { gap: space.xl, paddingTop: space.xs, paddingBottom: space.xs },
  chipScroller: { marginHorizontal: -space.margin },
  chips: { gap: space.xs, paddingHorizontal: space.margin },
  sectionHeader: { paddingTop: space.xl, paddingBottom: space.xs, paddingHorizontal: space.md },
  rowWrap: { overflow: 'hidden' },
  rowFirst: { borderTopLeftRadius: radius.l, borderTopRightRadius: radius.l },
  rowLast: { borderBottomLeftRadius: radius.l, borderBottomRightRadius: radius.l },
  // Inset to the text start: row padding 16 + icon 28 + gap 12.
  hairline: { height: StyleSheet.hairlineWidth, marginLeft: space.md + 28 + space.sm },
  skeletonGroup: { marginTop: space.xl, borderRadius: radius.l, overflow: 'hidden' },
  center: { alignItems: 'center' },
});
