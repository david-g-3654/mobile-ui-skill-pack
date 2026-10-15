import React, { useCallback, useMemo, useState } from 'react';
import {
  Platform,
  Pressable,
  RefreshControl,
  ScrollView,
  SectionList,
  StyleSheet,
  Text,
  useColorScheme,
  useWindowDimensions,
  View,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type IconName = keyof typeof Ionicons.glyphMap;

type Category =
  | 'groceries'
  | 'dining'
  | 'transport'
  | 'shopping'
  | 'income'
  | 'transfer'
  | 'bills'
  | 'entertainment'
  | 'health';

type Transaction = {
  id: string;
  merchant: string;
  detail: string;
  amount: number; // negative = debit
  date: string; // ISO
  category: Category;
  pending?: boolean;
};

type Filter = 'all' | 'in' | 'out' | 'pending';

const CATEGORY_META: Record<Category, { icon: IconName; label: string; hue: string }> = {
  groceries: { icon: 'cart', label: 'Groceries', hue: '#30A46C' },
  dining: { icon: 'restaurant', label: 'Dining', hue: '#F76B15' },
  transport: { icon: 'car', label: 'Transport', hue: '#0090FF' },
  shopping: { icon: 'bag-handle', label: 'Shopping', hue: '#D6409F' },
  income: { icon: 'arrow-down', label: 'Income', hue: '#12A594' },
  transfer: { icon: 'swap-horizontal', label: 'Transfer', hue: '#6E56CF' },
  bills: { icon: 'flash', label: 'Bills & Utilities', hue: '#FFB224' },
  entertainment: { icon: 'film', label: 'Entertainment', hue: '#E54D2E' },
  health: { icon: 'medkit', label: 'Health', hue: '#3E63DD' },
};

const TRANSACTIONS: Transaction[] = [
  { id: 't1', merchant: 'Blue Bottle Coffee', detail: 'Card •• 4821', amount: -6.75, date: '2026-10-15T08:12:00', category: 'dining', pending: true },
  { id: 't2', merchant: 'Uber', detail: 'Trip to Mission District', amount: -18.4, date: '2026-10-15T07:41:00', category: 'transport', pending: true },
  { id: 't3', merchant: 'Acme Corp Payroll', detail: 'Direct deposit', amount: 3245.82, date: '2026-10-14T06:00:00', category: 'income' },
  { id: 't4', merchant: "Trader Joe's", detail: 'Card •• 4821', amount: -84.19, date: '2026-10-14T18:22:00', category: 'groceries' },
  { id: 't5', merchant: 'Spotify', detail: 'Premium Family · Monthly', amount: -16.99, date: '2026-10-14T03:00:00', category: 'entertainment' },
  { id: 't6', merchant: 'Maya Chen', detail: 'Zelle · Dinner split', amount: 42.5, date: '2026-10-13T21:05:00', category: 'transfer' },
  { id: 't7', merchant: 'PG&E', detail: 'Autopay · Electricity', amount: -112.37, date: '2026-10-13T09:00:00', category: 'bills' },
  { id: 't8', merchant: 'Apple Store', detail: 'MagSafe Charger', amount: -39.0, date: '2026-10-12T15:48:00', category: 'shopping' },
  { id: 't9', merchant: 'Tartine Bakery', detail: 'Card •• 4821', amount: -23.6, date: '2026-10-12T10:31:00', category: 'dining' },
  { id: 't10', merchant: 'Walgreens', detail: 'Pharmacy', amount: -14.29, date: '2026-10-11T17:10:00', category: 'health' },
  { id: 't11', merchant: 'Savings Account', detail: 'Transfer to •• 9034', amount: -500.0, date: '2026-10-11T08:00:00', category: 'transfer' },
  { id: 't12', merchant: 'Whole Foods Market', detail: 'Card •• 4821', amount: -127.45, date: '2026-10-10T19:02:00', category: 'groceries' },
  { id: 't13', merchant: 'BART', detail: 'Clipper reload', amount: -40.0, date: '2026-10-10T08:15:00', category: 'transport' },
  { id: 't14', merchant: 'Netflix', detail: 'Standard plan', amount: -15.49, date: '2026-10-09T02:00:00', category: 'entertainment' },
  { id: 't15', merchant: 'Amazon', detail: 'Refund · Order 112-4839', amount: 27.99, date: '2026-10-09T13:44:00', category: 'shopping' },
  { id: 't16', merchant: 'Comcast Xfinity', detail: 'Internet · Autopay', amount: -79.99, date: '2026-10-08T09:00:00', category: 'bills' },
  { id: 't17', merchant: 'Sweetgreen', detail: 'Card •• 4821', amount: -16.85, date: '2026-10-08T12:27:00', category: 'dining' },
];

const TODAY = new Date('2026-10-15T12:00:00');

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

function formatAmount(n: number) {
  const s = currency.format(Math.abs(n));
  return n > 0 ? `+${s}` : `−${s}`;
}

function dayKey(iso: string) {
  return iso.slice(0, 10);
}

function sectionTitle(key: string) {
  const d = new Date(`${key}T12:00:00`);
  const diff = Math.round((TODAY.getTime() - d.getTime()) / 86400000);
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Yesterday';
  return d.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });
}

function formatTime(iso: string) {
  return new Date(iso).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
}

function usePalette() {
  const dark = useColorScheme() === 'dark';
  return {
    dark,
    bg: dark ? '#000000' : '#F2F2F7',
    card: dark ? '#1C1C1E' : '#FFFFFF',
    text: dark ? '#FFFFFF' : '#000000',
    secondary: dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)',
    separator: dark ? 'rgba(84,84,88,0.6)' : 'rgba(60,60,67,0.18)',
    chip: dark ? '#2C2C2E' : '#E5E5EA',
    accent: dark ? '#0A84FF' : '#007AFF',
    positive: dark ? '#30D158' : '#1F8A3D',
    pendingBg: dark ? 'rgba(255,214,10,0.18)' : 'rgba(255,149,0,0.14)',
    pendingText: dark ? '#FFD60A' : '#B25000',
  };
}

const FILTERS: { key: Filter; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'in', label: 'Money in' },
  { key: 'out', label: 'Money out' },
  { key: 'pending', label: 'Pending' },
];

export default function TransactionsScreen() {
  const c = usePalette();
  const insets = useSafeAreaInsets();
  const { fontScale } = useWindowDimensions();
  const largeText = fontScale >= 1.35;

  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<Filter>('all');
  const [refreshing, setRefreshing] = useState(false);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return TRANSACTIONS.filter((t) => {
      if (filter === 'in' && t.amount <= 0) return false;
      if (filter === 'out' && t.amount >= 0) return false;
      if (filter === 'pending' && !t.pending) return false;
      if (!q) return true;
      return (
        t.merchant.toLowerCase().includes(q) ||
        t.detail.toLowerCase().includes(q) ||
        CATEGORY_META[t.category].label.toLowerCase().includes(q)
      );
    });
  }, [query, filter]);

  const sections = useMemo(() => {
    const map = new Map<string, Transaction[]>();
    [...filtered]
      .sort((a, b) => b.date.localeCompare(a.date))
      .forEach((t) => {
        const k = dayKey(t.date);
        const arr = map.get(k);
        if (arr) arr.push(t);
        else map.set(k, [t]);
      });
    return Array.from(map.entries()).map(([key, data]) => ({
      key,
      title: sectionTitle(key),
      net: data.reduce((s, t) => s + t.amount, 0),
      data,
    }));
  }, [filtered]);

  const totals = useMemo(() => {
    let inflow = 0;
    let outflow = 0;
    TRANSACTIONS.forEach((t) => {
      if (t.amount > 0) inflow += t.amount;
      else outflow += -t.amount;
    });
    return { inflow, outflow };
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 900);
  }, []);

  const selectFilter = (f: Filter) => {
    if (f === filter) return;
    Haptics.selectionAsync().catch(() => {});
    setFilter(f);
  };

  const header = (
    <View style={styles.headerWrap}>
      <View style={[styles.summaryCard, { backgroundColor: c.card }]}>
        <Text style={[styles.summaryLabel, { color: c.secondary }]}>Available balance · Checking •• 4821</Text>
        <Text
          style={[styles.balance, { color: c.text }]}
          accessibilityRole="header"
          adjustsFontSizeToFit={!largeText}
          numberOfLines={largeText ? undefined : 1}
        >
          {currency.format(8423.17)}
        </Text>
        <View style={[styles.flowRow, largeText && styles.flowRowStacked]}>
          <FlowStat
            icon="arrow-down-circle"
            label="In this month"
            value={currency.format(totals.inflow)}
            color={c.positive}
            textColor={c.text}
            secondary={c.secondary}
          />
          {!largeText && <View style={[styles.flowDivider, { backgroundColor: c.separator }]} />}
          <FlowStat
            icon="arrow-up-circle"
            label="Out this month"
            value={currency.format(totals.outflow)}
            color={c.text}
            textColor={c.text}
            secondary={c.secondary}
          />
        </View>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.chips}
        accessibilityRole="tablist"
      >
        {FILTERS.map((f) => {
          const active = f.key === filter;
          return (
            <Pressable
              key={f.key}
              onPress={() => selectFilter(f.key)}
              accessibilityRole="tab"
              accessibilityState={{ selected: active }}
              hitSlop={4}
              style={({ pressed }) => [
                styles.chip,
                { backgroundColor: active ? c.accent : c.chip, opacity: pressed ? 0.75 : 1 },
              ]}
            >
              <Text style={[styles.chipText, { color: active ? '#FFFFFF' : c.text }]}>{f.label}</Text>
            </Pressable>
          );
        })}
      </ScrollView>
    </View>
  );

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      <StatusBar style={c.dark ? 'light' : 'dark'} />
      <Stack.Screen
        options={{
          title: 'Transactions',
          headerLargeTitle: true,
          headerTransparent: Platform.OS === 'ios',
          headerBlurEffect: 'systemChromeMaterial',
          headerLargeStyle: { backgroundColor: c.bg },
          headerShadowVisible: false,
          headerStyle: Platform.OS === 'ios' ? undefined : { backgroundColor: c.bg },
          headerTintColor: c.accent,
          headerTitleStyle: { color: c.text },
          headerLargeTitleStyle: { color: c.text },
          headerSearchBarOptions: {
            placeholder: 'Search merchants or categories',
            hideWhenScrolling: true,
            onChangeText: (e) => setQuery(e.nativeEvent.text),
            onCancelButtonPress: () => setQuery(''),
          },
          headerRight: () => (
            <Pressable
              onPress={() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {})}
              accessibilityRole="button"
              accessibilityLabel="Download statement"
              hitSlop={10}
            >
              <Ionicons name="download-outline" size={24} color={c.accent} />
            </Pressable>
          ),
        }}
      />

      <SectionList
        sections={sections}
        keyExtractor={(t) => t.id}
        contentInsetAdjustmentBehavior="automatic"
        stickySectionHeadersEnabled={false}
        ListHeaderComponent={header}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        contentContainerStyle={{ paddingBottom: insets.bottom + 24 }}
        renderSectionHeader={({ section }) => (
          <View style={styles.sectionHeader} accessibilityRole="header">
            <Text style={[styles.sectionTitle, { color: c.text }]}>{section.title}</Text>
            <Text style={[styles.sectionNet, { color: c.secondary }]}>
              {section.net >= 0 ? '+' : '−'}
              {currency.format(Math.abs(section.net))}
            </Text>
          </View>
        )}
        renderItem={({ item, index, section }) => (
          <TransactionRow
            t={item}
            first={index === 0}
            last={index === section.data.length - 1}
            largeText={largeText}
            c={c}
          />
        )}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="search" size={40} color={c.secondary} />
            <Text style={[styles.emptyTitle, { color: c.text }]}>No transactions found</Text>
            <Text style={[styles.emptyBody, { color: c.secondary }]}>
              Try a different search or filter.
            </Text>
            <Pressable
              onPress={() => {
                setFilter('all');
                setQuery('');
              }}
              accessibilityRole="button"
              style={({ pressed }) => [styles.emptyBtn, { opacity: pressed ? 0.6 : 1 }]}
            >
              <Text style={[styles.emptyBtnText, { color: c.accent }]}>Clear filters</Text>
            </Pressable>
          </View>
        }
      />
    </View>
  );
}

function FlowStat(props: {
  icon: IconName;
  label: string;
  value: string;
  color: string;
  textColor: string;
  secondary: string;
}) {
  return (
    <View style={styles.flowStat} accessible accessibilityLabel={`${props.label}, ${props.value}`}>
      <Ionicons name={props.icon} size={22} color={props.color} />
      <View style={styles.flowText}>
        <Text style={[styles.flowLabel, { color: props.secondary }]}>{props.label}</Text>
        <Text style={[styles.flowValue, { color: props.textColor }]}>{props.value}</Text>
      </View>
    </View>
  );
}

function TransactionRow({
  t,
  first,
  last,
  largeText,
  c,
}: {
  t: Transaction;
  first: boolean;
  last: boolean;
  largeText: boolean;
  c: ReturnType<typeof usePalette>;
}) {
  const meta = CATEGORY_META[t.category];
  const positive = t.amount > 0;
  const amountText = formatAmount(t.amount);
  const a11y = `${t.merchant}, ${positive ? 'received' : 'spent'} ${currency.format(
    Math.abs(t.amount),
  )}, ${meta.label}, ${formatTime(t.date)}${t.pending ? ', pending' : ''}`;

  const amount = (
    <Text
      style={[
        styles.amount,
        { color: positive ? c.positive : c.text },
        largeText && styles.amountStacked,
      ]}
    >
      {amountText}
    </Text>
  );

  return (
    <Pressable
      onPress={() => Haptics.selectionAsync().catch(() => {})}
      accessibilityRole="button"
      accessibilityLabel={a11y}
      accessibilityHint="Opens transaction details"
      style={({ pressed }) => [
        styles.row,
        {
          backgroundColor: pressed ? c.chip : c.card,
          borderTopLeftRadius: first ? 14 : 0,
          borderTopRightRadius: first ? 14 : 0,
          borderBottomLeftRadius: last ? 14 : 0,
          borderBottomRightRadius: last ? 14 : 0,
        },
      ]}
    >
      <View style={[styles.rowInner, largeText && styles.rowInnerStacked]}>
        <View style={[styles.iconBadge, { backgroundColor: meta.hue + (c.dark ? '33' : '1F') }]}>
          <Ionicons name={meta.icon} size={20} color={meta.hue} />
        </View>
        <View
          style={[
            styles.rowBody,
            !last && { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: c.separator },
            largeText && styles.rowBodyStacked,
          ]}
        >
          <View style={styles.rowText}>
            <Text style={[styles.merchant, { color: c.text }]} numberOfLines={largeText ? undefined : 1}>
              {t.merchant}
            </Text>
            <Text style={[styles.detail, { color: c.secondary }]} numberOfLines={largeText ? undefined : 1}>
              {t.detail} · {formatTime(t.date)}
            </Text>
            {largeText && amount}
            {t.pending && (
              <View style={[styles.pending, { backgroundColor: c.pendingBg }]}>
                <Text style={[styles.pendingText, { color: c.pendingText }]}>Pending</Text>
              </View>
            )}
          </View>
          {!largeText && (
            <View style={styles.trailing}>
              {amount}
              <Ionicons name="chevron-forward" size={16} color={c.secondary} />
            </View>
          )}
        </View>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  headerWrap: { paddingTop: 8 },
  summaryCard: {
    marginHorizontal: 16,
    borderRadius: 16,
    padding: 18,
    gap: 6,
  },
  summaryLabel: { fontSize: 13, fontWeight: '500' },
  balance: {
    fontSize: 34,
    fontWeight: '700',
    letterSpacing: 0.3,
    fontVariant: ['tabular-nums'],
  },
  flowRow: { flexDirection: 'row', alignItems: 'stretch', marginTop: 10, gap: 14 },
  flowRowStacked: { flexDirection: 'column', gap: 12 },
  flowDivider: { width: StyleSheet.hairlineWidth },
  flowStat: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 10 },
  flowText: { flexShrink: 1 },
  flowLabel: { fontSize: 13 },
  flowValue: { fontSize: 17, fontWeight: '600', fontVariant: ['tabular-nums'] },
  chips: { paddingHorizontal: 16, paddingVertical: 16, gap: 8 },
  chip: {
    minHeight: 36,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 18,
    justifyContent: 'center',
  },
  chipText: { fontSize: 15, fontWeight: '600' },
  sectionHeader: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    columnGap: 12,
    paddingHorizontal: 20,
    paddingTop: 18,
    paddingBottom: 8,
  },
  sectionTitle: { fontSize: 20, fontWeight: '700', flexShrink: 1 },
  sectionNet: { fontSize: 15, fontVariant: ['tabular-nums'] },
  row: { marginHorizontal: 16, overflow: 'hidden' },
  rowInner: { flexDirection: 'row', alignItems: 'center', paddingLeft: 14 },
  rowInnerStacked: { alignItems: 'flex-start', paddingTop: 12 },
  iconBadge: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowBody: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: 12,
    paddingVertical: 12,
    paddingRight: 14,
    minHeight: 64,
    gap: 10,
  },
  rowBodyStacked: { paddingTop: 0 },
  rowText: { flex: 1, gap: 2, alignItems: 'flex-start' },
  merchant: { fontSize: 17, fontWeight: '600', alignSelf: 'stretch' },
  detail: { fontSize: 14, alignSelf: 'stretch' },
  trailing: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  amount: { fontSize: 17, fontWeight: '600', fontVariant: ['tabular-nums'] },
  amountStacked: { marginTop: 4 },
  pending: { marginTop: 4, paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6 },
  pendingText: { fontSize: 12, fontWeight: '700', letterSpacing: 0.3 },
  empty: { alignItems: 'center', paddingHorizontal: 32, paddingVertical: 48, gap: 8 },
  emptyTitle: { fontSize: 20, fontWeight: '600', textAlign: 'center' },
  emptyBody: { fontSize: 15, textAlign: 'center' },
  emptyBtn: { marginTop: 8, minHeight: 44, justifyContent: 'center', paddingHorizontal: 12 },
  emptyBtnText: { fontSize: 17, fontWeight: '600' },
});
