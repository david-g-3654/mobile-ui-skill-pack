import React, { useCallback, useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  Pressable,
  TextInput,
  ScrollView,
  RefreshControl,
  useColorScheme,
  Platform,
} from 'react-native';
import { Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { StatusBar } from 'expo-status-bar';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

type Category =
  | 'groceries'
  | 'dining'
  | 'transport'
  | 'shopping'
  | 'bills'
  | 'income'
  | 'transfer'
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

const CATEGORY_META: Record<Category, { icon: IconName; color: string; label: string }> = {
  groceries: { icon: 'cart', color: '#2E9E5B', label: 'Groceries' },
  dining: { icon: 'restaurant', color: '#E07A2E', label: 'Dining' },
  transport: { icon: 'car', color: '#3B7DDD', label: 'Transport' },
  shopping: { icon: 'bag-handle', color: '#B4498C', label: 'Shopping' },
  bills: { icon: 'flash', color: '#C9A227', label: 'Bills' },
  income: { icon: 'briefcase', color: '#1F8A70', label: 'Income' },
  transfer: { icon: 'swap-horizontal', color: '#6C63C7', label: 'Transfer' },
  entertainment: { icon: 'film', color: '#D14B4B', label: 'Entertainment' },
  health: { icon: 'medkit', color: '#2A9DB5', label: 'Health' },
};

const TRANSACTIONS: Transaction[] = [
  { id: 't1', merchant: 'Whole Foods Market', detail: 'Visa •• 4821', amount: -84.37, date: '2026-10-14T18:42:00', category: 'groceries', pending: true },
  { id: 't2', merchant: 'Uber', detail: 'Trip to SFO', amount: -46.2, date: '2026-10-14T07:15:00', category: 'transport', pending: true },
  { id: 't3', merchant: 'Blue Bottle Coffee', detail: 'Visa •• 4821', amount: -6.75, date: '2026-10-14T08:03:00', category: 'dining' },
  { id: 't4', merchant: 'Acme Corp Payroll', detail: 'Direct deposit', amount: 3842.16, date: '2026-10-13T06:00:00', category: 'income' },
  { id: 't5', merchant: 'Netflix', detail: 'Monthly subscription', amount: -15.49, date: '2026-10-13T03:12:00', category: 'entertainment' },
  { id: 't6', merchant: 'Sarah Chen', detail: 'Zelle · Dinner split', amount: 32.5, date: '2026-10-12T21:30:00', category: 'transfer' },
  { id: 't7', merchant: 'Trader Joe’s', detail: 'Visa •• 4821', amount: -52.18, date: '2026-10-12T17:20:00', category: 'groceries' },
  { id: 't8', merchant: 'Shell', detail: 'Fuel', amount: -58.9, date: '2026-10-12T11:05:00', category: 'transport' },
  { id: 't9', merchant: 'PG&E', detail: 'Autopay · Electricity', amount: -121.44, date: '2026-10-10T09:00:00', category: 'bills' },
  { id: 't10', merchant: 'Amazon', detail: 'Order #112-7734', amount: -67.99, date: '2026-10-10T14:48:00', category: 'shopping' },
  { id: 't11', merchant: 'CVS Pharmacy', detail: 'Visa •• 4821', amount: -18.23, date: '2026-10-09T19:10:00', category: 'health' },
  { id: 't12', merchant: 'Savings Account', detail: 'Transfer to •• 0193', amount: -500, date: '2026-10-08T08:00:00', category: 'transfer' },
  { id: 't13', merchant: 'Sweetgreen', detail: 'Visa •• 4821', amount: -16.85, date: '2026-10-08T12:31:00', category: 'dining' },
  { id: 't14', merchant: 'Comcast Xfinity', detail: 'Internet', amount: -79.99, date: '2026-10-07T10:00:00', category: 'bills' },
  { id: 't15', merchant: 'Amazon', detail: 'Refund · Order #112-6610', amount: 24.99, date: '2026-10-06T16:22:00', category: 'shopping' },
  { id: 't16', merchant: 'AMC Theatres', detail: 'Visa •• 4821', amount: -31.0, date: '2026-10-05T20:05:00', category: 'entertainment' },
  { id: 't17', merchant: 'Safeway', detail: 'Visa •• 4821', amount: -41.62, date: '2026-10-04T15:40:00', category: 'groceries' },
  { id: 't18', merchant: 'Chipotle', detail: 'Visa •• 4821', amount: -13.45, date: '2026-10-03T13:02:00', category: 'dining' },
];

const BALANCE = 8214.53;
const TODAY = new Date('2026-10-14T23:59:00');

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
  const todayKey = `${TODAY.getFullYear()}-${String(TODAY.getMonth() + 1).padStart(2, '0')}-${String(TODAY.getDate()).padStart(2, '0')}`;
  if (key === todayKey) return 'Today';
  const y = new Date(TODAY);
  y.setDate(y.getDate() - 1);
  const yKey = `${y.getFullYear()}-${String(y.getMonth() + 1).padStart(2, '0')}-${String(y.getDate()).padStart(2, '0')}`;
  if (key === yKey) return 'Yesterday';
  return d.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });
}

function formatTime(iso: string) {
  return new Date(iso).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
}

const FILTERS: { key: Filter; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'in', label: 'Money in' },
  { key: 'out', label: 'Money out' },
  { key: 'pending', label: 'Pending' },
];

function usePalette() {
  const dark = useColorScheme() === 'dark';
  return {
    dark,
    bg: dark ? '#000000' : '#F2F2F7',
    card: dark ? '#1C1C1E' : '#FFFFFF',
    text: dark ? '#FFFFFF' : '#111114',
    sub: dark ? '#9A9AA1' : '#6B6B73',
    sep: dark ? '#2C2C2E' : '#E5E5EA',
    field: dark ? '#1C1C1E' : '#E7E7EC',
    positive: dark ? '#34C77B' : '#1E8E4E',
    accent: dark ? '#4C8DFF' : '#0A5BD8',
    chip: dark ? '#2C2C2E' : '#FFFFFF',
  };
}

export default function TransactionsScreen() {
  const c = usePalette();
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
    }).sort((a, b) => b.date.localeCompare(a.date));
  }, [query, filter]);

  const sections = useMemo(() => {
    const map = new Map<string, Transaction[]>();
    for (const t of filtered) {
      const k = dayKey(t.date);
      const arr = map.get(k);
      if (arr) arr.push(t);
      else map.set(k, [t]);
    }
    return Array.from(map.entries()).map(([key, data]) => ({
      key,
      title: sectionTitle(key),
      total: data.reduce((s, t) => s + t.amount, 0),
      data,
    }));
  }, [filtered]);

  const monthIn = TRANSACTIONS.filter((t) => t.amount > 0).reduce((s, t) => s + t.amount, 0);
  const monthOut = TRANSACTIONS.filter((t) => t.amount < 0).reduce((s, t) => s + t.amount, 0);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 1000);
  }, []);

  const selectFilter = (f: Filter) => {
    if (f === filter) return;
    Haptics.selectionAsync().catch(() => {});
    setFilter(f);
  };

  const header = (
    <View>
      <View style={[styles.summary, { backgroundColor: c.card }]}>
        <Text style={[styles.summaryLabel, { color: c.sub }]}>Everyday Checking •• 7302</Text>
        <Text style={[styles.balance, { color: c.text }]} accessibilityLabel={`Available balance ${currency.format(BALANCE)}`}>
          {currency.format(BALANCE)}
        </Text>
        <Text style={[styles.summaryLabel, { color: c.sub }]}>Available balance</Text>
        <View style={[styles.summaryRow, { borderTopColor: c.sep }]}>
          <View style={styles.summaryCol}>
            <Text style={[styles.smallLabel, { color: c.sub }]}>In · October</Text>
            <Text style={[styles.smallValue, { color: c.positive }]}>{currency.format(monthIn)}</Text>
          </View>
          <View style={[styles.vSep, { backgroundColor: c.sep }]} />
          <View style={styles.summaryCol}>
            <Text style={[styles.smallLabel, { color: c.sub }]}>Out · October</Text>
            <Text style={[styles.smallValue, { color: c.text }]}>{currency.format(Math.abs(monthOut))}</Text>
          </View>
        </View>
      </View>

      <View style={[styles.search, { backgroundColor: c.field }]}>
        <Ionicons name="search" size={17} color={c.sub} />
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder="Search merchants or categories"
          placeholderTextColor={c.sub}
          style={[styles.searchInput, { color: c.text }]}
          returnKeyType="search"
          clearButtonMode="while-editing"
          autoCorrect={false}
          accessibilityLabel="Search transactions"
        />
        {Platform.OS !== 'ios' && query.length > 0 && (
          <Pressable onPress={() => setQuery('')} hitSlop={10} accessibilityLabel="Clear search">
            <Ionicons name="close-circle" size={17} color={c.sub} />
          </Pressable>
        )}
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chips}>
        {FILTERS.map((f) => {
          const active = f.key === filter;
          return (
            <Pressable
              key={f.key}
              onPress={() => selectFilter(f.key)}
              accessibilityRole="button"
              accessibilityState={{ selected: active }}
              style={[
                styles.chip,
                { backgroundColor: active ? c.accent : c.chip, borderColor: active ? c.accent : c.sep },
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
    <View style={[styles.flex, { backgroundColor: c.bg }]}>
      <StatusBar style={c.dark ? 'light' : 'dark'} />
      <Stack.Screen
        options={{
          title: 'Transactions',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerStyle: { backgroundColor: c.bg },
          headerTintColor: c.accent,
          headerTitleStyle: { color: c.text },
          headerLargeTitleStyle: { color: c.text },
          headerRight: () => (
            <Pressable hitSlop={10} accessibilityLabel="Download statement" onPress={() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {})}>
              <Ionicons name="download-outline" size={22} color={c.accent} />
            </Pressable>
          ),
        }}
      />
      <SectionList
        sections={sections}
        keyExtractor={(t) => t.id}
        contentInsetAdjustmentBehavior="automatic"
        keyboardDismissMode="on-drag"
        keyboardShouldPersistTaps="handled"
        stickySectionHeadersEnabled={false}
        ListHeaderComponent={header}
        contentContainerStyle={styles.content}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        renderSectionHeader={({ section }) => (
          <View style={styles.sectionHeader}>
            <Text style={[styles.sectionTitle, { color: c.sub }]}>{section.title.toUpperCase()}</Text>
            <Text style={[styles.sectionTotal, { color: c.sub }]}>{formatAmount(section.total)}</Text>
          </View>
        )}
        renderItem={({ item, index, section }) => {
          const meta = CATEGORY_META[item.category];
          const first = index === 0;
          const last = index === section.data.length - 1;
          const positive = item.amount > 0;
          return (
            <Pressable
              onPress={() => Haptics.selectionAsync().catch(() => {})}
              accessibilityRole="button"
              accessibilityLabel={`${item.merchant}, ${positive ? 'received' : 'spent'} ${currency.format(Math.abs(item.amount))}, ${item.pending ? 'pending, ' : ''}${formatTime(item.date)}`}
              style={({ pressed }) => [
                styles.row,
                {
                  backgroundColor: pressed ? c.sep : c.card,
                  borderTopLeftRadius: first ? 14 : 0,
                  borderTopRightRadius: first ? 14 : 0,
                  borderBottomLeftRadius: last ? 14 : 0,
                  borderBottomRightRadius: last ? 14 : 0,
                },
              ]}
            >
              <View style={[styles.icon, { backgroundColor: meta.color + (c.dark ? '33' : '1F') }]}>
                <Ionicons name={meta.icon} size={19} color={meta.color} />
              </View>
              <View style={[styles.rowBody, !last && { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: c.sep }]}>
                <View style={styles.rowText}>
                  <Text style={[styles.merchant, { color: c.text }]} numberOfLines={1}>
                    {item.merchant}
                  </Text>
                  <Text style={[styles.detail, { color: c.sub }]} numberOfLines={1}>
                    {item.detail} · {formatTime(item.date)}
                  </Text>
                </View>
                <View style={styles.amountCol}>
                  <Text style={[styles.amount, { color: positive ? c.positive : c.text }]}>{formatAmount(item.amount)}</Text>
                  {item.pending ? (
                    <View style={[styles.pending, { backgroundColor: c.field }]}>
                      <Text style={[styles.pendingText, { color: c.sub }]}>Pending</Text>
                    </View>
                  ) : (
                    <Text style={[styles.detail, { color: c.sub }]}>{meta.label}</Text>
                  )}
                </View>
              </View>
            </Pressable>
          );
        }}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="receipt-outline" size={40} color={c.sub} />
            <Text style={[styles.emptyTitle, { color: c.text }]}>No transactions found</Text>
            <Text style={[styles.emptyBody, { color: c.sub }]}>Try a different search or filter.</Text>
            {(query.length > 0 || filter !== 'all') && (
              <Pressable
                onPress={() => {
                  setQuery('');
                  setFilter('all');
                }}
                style={styles.emptyBtn}
                accessibilityRole="button"
              >
                <Text style={[styles.emptyBtnText, { color: c.accent }]}>Clear filters</Text>
              </Pressable>
            )}
          </View>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { paddingHorizontal: 16, paddingBottom: 40 },
  summary: { borderRadius: 16, paddingTop: 18, marginTop: 8, alignItems: 'center' },
  summaryLabel: { fontSize: 13 },
  balance: { fontSize: 34, fontWeight: '700', marginVertical: 4, fontVariant: ['tabular-nums'] },
  summaryRow: { flexDirection: 'row', marginTop: 16, borderTopWidth: StyleSheet.hairlineWidth, alignSelf: 'stretch' },
  summaryCol: { flex: 1, alignItems: 'center', paddingVertical: 12 },
  vSep: { width: StyleSheet.hairlineWidth, marginVertical: 10 },
  smallLabel: { fontSize: 12 },
  smallValue: { fontSize: 16, fontWeight: '600', marginTop: 2, fontVariant: ['tabular-nums'] },
  search: { flexDirection: 'row', alignItems: 'center', borderRadius: 10, paddingHorizontal: 10, height: 38, marginTop: 16, gap: 6 },
  searchInput: { flex: 1, fontSize: 16, paddingVertical: 0 },
  chips: { gap: 8, paddingVertical: 12 },
  chip: { paddingHorizontal: 14, height: 32, borderRadius: 16, justifyContent: 'center', borderWidth: StyleSheet.hairlineWidth },
  chipText: { fontSize: 14, fontWeight: '500' },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 4, paddingTop: 16, paddingBottom: 6 },
  sectionTitle: { fontSize: 12, fontWeight: '600', letterSpacing: 0.4 },
  sectionTotal: { fontSize: 12, fontVariant: ['tabular-nums'] },
  row: { flexDirection: 'row', alignItems: 'center', paddingLeft: 14, minHeight: 64 },
  icon: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  rowBody: { flex: 1, flexDirection: 'row', alignItems: 'center', marginLeft: 12, paddingRight: 14, paddingVertical: 11, alignSelf: 'stretch' },
  rowText: { flex: 1, marginRight: 10 },
  merchant: { fontSize: 16, fontWeight: '500' },
  detail: { fontSize: 13, marginTop: 2 },
  amountCol: { alignItems: 'flex-end' },
  amount: { fontSize: 16, fontWeight: '600', fontVariant: ['tabular-nums'] },
  pending: { borderRadius: 6, paddingHorizontal: 6, paddingVertical: 1, marginTop: 3 },
  pendingText: { fontSize: 11, fontWeight: '600' },
  empty: { alignItems: 'center', paddingTop: 48, gap: 6 },
  emptyTitle: { fontSize: 17, fontWeight: '600', marginTop: 6 },
  emptyBody: { fontSize: 14 },
  emptyBtn: { marginTop: 8, padding: 8 },
  emptyBtnText: { fontSize: 15, fontWeight: '600' },
});
