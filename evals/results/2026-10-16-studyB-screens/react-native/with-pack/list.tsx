import React, { useMemo, useState } from 'react';
import { ActionSheetIOS, Alert, Platform, Pressable, SectionList, StyleSheet, View } from 'react-native';
import { Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { metrics, radius, space, tabular, useQTheme } from '../../pack04/theme';
import { QEmptyState, QIconButton, QText, QTextField, QTertiaryButton, useQLargeText } from '../../pack04/components';

type Transaction = {
  id: string;
  merchant: string;
  category: string;
  amount: number;
  date: Date;
  icon: React.ComponentProps<typeof Ionicons>['name'];
  pending?: boolean;
};
type Filter = 'All' | 'Money out' | 'Money in';
type Period = 'This month' | 'Last month' | 'All activity';

const money = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const today = new Date();
const filters: Filter[] = ['All', 'Money out', 'Money in'];
const periods: Period[] = ['This month', 'Last month', 'All activity'];

function daysAgo(days: number) {
  return new Date(today.getFullYear(), today.getMonth(), today.getDate() - days, 12);
}

const transactions: Transaction[] = [
  { id: 'TX-8041', merchant: 'Whole Foods Market', category: 'Groceries', amount: -86.42, date: daysAgo(0), icon: 'basket-outline', pending: true },
  { id: 'TX-8040', merchant: 'Blue Bottle Coffee', category: 'Food & drink', amount: -5.8, date: daysAgo(0), icon: 'cafe-outline' },
  { id: 'TX-8039', merchant: 'Amara Okafor', category: 'Dinner split · Transfer', amount: 38.5, date: daysAgo(0), icon: 'arrow-down-outline' },
  { id: 'TX-8038', merchant: 'Spotify', category: 'Subscriptions', amount: -11.99, date: daysAgo(1), icon: 'musical-notes-outline' },
  { id: 'TX-8037', merchant: 'San Francisco Municipal Railway', category: 'Transport', amount: -2.75, date: daysAgo(1), icon: 'train-outline' },
  { id: 'TX-8036', merchant: 'Tartine Bakery', category: 'Food & drink', amount: -24.6, date: daysAgo(1), icon: 'restaurant-outline' },
  { id: 'TX-8035', merchant: 'Northstar Studio', category: 'Salary', amount: 3250.75, date: daysAgo(3), icon: 'arrow-down-outline' },
  { id: 'TX-8034', merchant: 'Green Apple Books', category: 'Shopping', amount: -32.5, date: daysAgo(3), icon: 'book-outline' },
  { id: 'TX-8033', merchant: 'Savings account', category: 'Transfer', amount: -450, date: daysAgo(5), icon: 'swap-horizontal-outline' },
  { id: 'TX-8032', merchant: 'Nopa', category: 'Food & drink', amount: -67.2, date: daysAgo(6), icon: 'restaurant-outline' },
  { id: 'TX-8031', merchant: 'October rent', category: 'Home', amount: -1450, date: new Date(today.getFullYear(), today.getMonth(), 1, 12), icon: 'home-outline' },
  { id: 'TX-8029', merchant: 'Patagonia', category: 'Refund · Shopping', amount: 89.4, date: new Date(today.getFullYear(), today.getMonth() - 1, 28, 12), icon: 'return-down-back-outline' },
  { id: 'TX-8028', merchant: 'Rainbow Grocery', category: 'Groceries', amount: -72.16, date: new Date(today.getFullYear(), today.getMonth() - 1, 27, 12), icon: 'basket-outline' },
];

function dateLabel(date: Date) {
  if (date.toDateString() === today.toDateString()) return 'Today';
  if (date.toDateString() === daysAgo(1).toDateString()) return 'Yesterday';
  return date.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
}

function signedAmount(amount: number) {
  return `${amount < 0 ? '−' : '+'}${money.format(Math.abs(amount))}`;
}

export default function TransactionsScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const largeText = useQLargeText();
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState<Filter>('All');
  const [period, setPeriod] = useState<Period>('This month');
  const [expanded, setExpanded] = useState<string | null>(null);

  const periodTransactions = useMemo(() => transactions.filter((transaction) => {
    if (period === 'All activity') return true;
    const month = new Date(today.getFullYear(), today.getMonth() - (period === 'Last month' ? 1 : 0), 1);
    return transaction.date.getMonth() === month.getMonth() && transaction.date.getFullYear() === month.getFullYear();
  }), [period]);

  const visible = useMemo(() => periodTransactions.filter((transaction) => {
    const matchesDirection = filter === 'All' || (filter === 'Money out' ? transaction.amount < 0 : transaction.amount > 0);
    const matchesQuery = `${transaction.merchant} ${transaction.category}`.toLowerCase().includes(query.trim().toLowerCase());
    return matchesDirection && matchesQuery;
  }).sort((first, second) => second.date.getTime() - first.date.getTime()), [periodTransactions, query, filter]);

  const sections = useMemo(() => {
    const groups: { title: string; data: Transaction[] }[] = [];
    for (const transaction of visible) {
      const title = dateLabel(transaction.date);
      const previous = groups[groups.length - 1];
      if (previous?.title === title) previous.data.push(transaction);
      else groups.push({ title, data: [transaction] });
    }
    return groups;
  }, [visible]);

  const spent = Math.abs(periodTransactions.reduce((total, transaction) => total + Math.min(0, transaction.amount), 0));
  const formattedSpent = money.format(spent);
  const numberStart = formattedSpent.search(/\d/);
  const monthName = new Date(today.getFullYear(), today.getMonth() - (period === 'Last month' ? 1 : 0), 1)
    .toLocaleDateString('en-US', { month: 'long' });

  function choosePeriod() {
    const select = (next: Period) => {
      setPeriod(next);
      setExpanded(null);
      void Haptics.selectionAsync().catch(() => undefined);
    };
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions({ title: 'Show transactions', options: [...periods, 'Cancel'], cancelButtonIndex: periods.length }, (index) => {
        if (index < periods.length) select(periods[index]);
      });
    } else {
      Alert.alert('Show transactions', undefined, periods.map((value) => ({ text: value, onPress: () => select(value) })), { cancelable: true });
    }
  }

  const header = (
    <View style={styles.headerContent}>
      <View style={styles.summary}>
        <View style={styles.periodLine}>
          <QText variant="overline" color="ink2">Everyday account · •• 4829</QText>
        </View>
        <View accessible accessibilityLabel={`${period === 'All activity' ? 'Total money out' : `Spent in ${monthName}`}, ${formattedSpent}`}>
          <QText variant="subhead" color="ink2">{period === 'All activity' ? 'Total money out' : `Spent in ${monthName}`}</QText>
          <View style={styles.heroLine}>
            <QText variant="headline" color="ink2">{formattedSpent.slice(0, numberStart)}</QText>
            <QText variant="hero" fit style={styles.heroValue}>{formattedSpent.slice(numberStart)}</QText>
          </View>
        </View>
        <QText variant="subhead" color="ink2">{period === 'All activity' ? 'All activity' : period} · Includes pending payments</QText>
      </View>

      <View style={styles.searchGroup}>
        <QTextField
          label="Find a transaction"
          placeholder="Merchant or category"
          value={query}
          onChangeText={setQuery}
          autoCapitalize="none"
          autoCorrect={false}
          returnKeyType="search"
          clearButtonMode="while-editing"
        />
        <View style={styles.filters}>
          {filters.map((value) => (
            <Pressable
              key={value}
              onPress={() => {
                setFilter(value);
                setExpanded(null);
                void Haptics.selectionAsync().catch(() => undefined);
              }}
              accessibilityRole="button"
              accessibilityState={{ selected: filter === value }}
              style={({ pressed }) => [styles.filter, { backgroundColor: filter === value ? c.accentSoft : c.surface2, borderColor: filter === value ? c.accent : c.surface2 }, pressed && styles.pressed]}
            >
              <QText variant="subhead" color={filter === value ? 'accent' : 'ink2'}>{value}</QText>
            </Pressable>
          ))}
        </View>
      </View>
    </View>
  );

  function renderTransaction({ item }: { item: Transaction }) {
    const isExpanded = expanded === item.id;
    return (
      <View style={{ backgroundColor: c.surface }}>
        <Pressable
          onPress={() => setExpanded(isExpanded ? null : item.id)}
          accessibilityRole="button"
          accessibilityState={{ expanded: isExpanded }}
          accessibilityLabel={`${item.merchant}, ${signedAmount(item.amount)}, ${item.category}${item.pending ? ', pending' : ''}`}
          accessibilityHint={isExpanded ? 'Hide payment details' : 'Show payment details'}
          style={({ pressed }) => [styles.transaction, { backgroundColor: pressed ? c.surface2 : c.surface }]}
        >
          <View style={[styles.rowContent, largeText && styles.stacked]}>
            <View style={styles.identity}>
              <View style={styles.glyph} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
                <Ionicons name={item.icon} size={space.xl} color={c.ink2} />
              </View>
              <View style={styles.description}>
                <QText variant="body">{item.merchant}</QText>
                <QText variant="subhead" color="ink2">{item.category}</QText>
              </View>
            </View>
            <View style={[styles.amount, largeText && styles.stackedAmount]}>
              <QText variant="body" color={item.amount > 0 ? 'positive' : 'ink'} style={tabular}>{signedAmount(item.amount)}</QText>
              {item.pending && <QText variant="subhead" color="ink2">Pending</QText>}
            </View>
          </View>
        </Pressable>
        {isExpanded && (
          <View style={[styles.details, { backgroundColor: c.surface2 }]}>
            <QText variant="subhead" color="ink2">{item.date.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}</QText>
            <QText variant="subhead">{item.pending ? 'Awaiting merchant confirmation' : 'Completed'} · Everyday •• 4829</QText>
            <QText variant="subhead" color="ink2">Reference {item.id}</QText>
            {item.pending && <QText variant="subhead" color="ink2">The final amount may change when the merchant completes this payment.</QText>}
          </View>
        )}
      </View>
    );
  }

  return (
    <View style={[styles.screen, { backgroundColor: c.canvas }]}>
      <Stack.Screen options={{
        title: 'Transactions',
        headerLargeTitle: true,
        headerShadowVisible: false,
        headerLargeTitleShadowVisible: false,
        headerTintColor: c.ink,
        headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        contentStyle: { backgroundColor: c.canvas },
        headerRight: () => <QIconButton icon="calendar-outline" label="Change date range" onPress={choosePeriod} />,
      }} />
      <StatusBar style="auto" />
      <SectionList
        style={styles.screen}
        sections={sections}
        keyExtractor={(item) => item.id}
        renderItem={renderTransaction}
        stickySectionHeadersEnabled
        contentInsetAdjustmentBehavior="automatic"
        keyboardDismissMode="on-drag"
        keyboardShouldPersistTaps="handled"
        contentContainerStyle={[styles.listContent, { paddingBottom: insets.bottom + space.xxl }]}
        ListHeaderComponent={header}
        renderSectionHeader={({ section }) => (
          <View style={[styles.sectionHeader, { backgroundColor: c.canvas }]}>
            <QText variant="overline" color="ink2" role="header">{section.title}</QText>
          </View>
        )}
        ItemSeparatorComponent={() => <View style={[styles.separator, { backgroundColor: c.hairline }]} />}
        ListEmptyComponent={
          <QEmptyState
            icon="search-outline"
            title={query.trim() ? 'No matching transactions' : 'Nothing in this view'}
            message={query.trim() ? `No results for “${query.trim()}”. Try another merchant or category.` : 'Try another filter or choose a different date range.'}
            action={{ title: 'Reset filters', onPress: () => { setQuery(''); setFilter('All'); setPeriod('This month'); } }}
          />
        }
        ListFooterComponent={visible.length ? (
          <View style={styles.footer}>
            <QText variant="subhead" color="ink2">{visible.length} transactions · All amounts in USD</QText>
            {(query || filter !== 'All') ? <QTertiaryButton title="Clear filters" onPress={() => { setQuery(''); setFilter('All'); }} /> : null}
          </View>
        ) : null}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1 },
  listContent: { flexGrow: 1 },
  headerContent: { paddingHorizontal: space.margin, paddingTop: space.xl, paddingBottom: space.sm, gap: space.xxl },
  summary: { gap: space.sm },
  periodLine: { flexDirection: 'row', flexWrap: 'wrap' },
  heroLine: { flexDirection: 'row', alignItems: 'baseline', gap: space.xxs, marginTop: space.xxs },
  heroValue: { flexShrink: 1 },
  searchGroup: { gap: space.md },
  filters: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
  filter: { minHeight: metrics.minTap, paddingHorizontal: space.md, paddingVertical: space.xs, justifyContent: 'center', borderRadius: radius.capsule, borderWidth: 1 },
  pressed: { opacity: 0.7 },
  sectionHeader: { paddingHorizontal: space.margin, paddingTop: space.lg, paddingBottom: space.sm },
  transaction: { minHeight: metrics.rowMinHeight, paddingHorizontal: space.margin, paddingVertical: space.md },
  rowContent: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
  identity: { flexDirection: 'row', alignItems: 'center', gap: space.sm, flex: 1 },
  glyph: { width: space.xxl, alignItems: 'center', justifyContent: 'center' },
  description: { flex: 1, gap: space.xxs },
  amount: { alignItems: 'flex-end', gap: space.xxs, flexShrink: 0 },
  stacked: { flexDirection: 'column', alignItems: 'stretch' },
  stackedAmount: { alignItems: 'flex-start', paddingLeft: space.xxl + space.sm },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: space.margin + space.xxl + space.sm },
  details: { marginHorizontal: space.margin, marginBottom: space.md, padding: space.md, borderRadius: radius.m, gap: space.xs },
  footer: { padding: space.xxl, alignItems: 'center', gap: space.xs },
});
