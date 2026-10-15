// Home / dashboard — personal budgeting app.
// Job: "see what's left this month". Focal: hero "left for October" amount.
// Primary: none on screen — "Add transaction" lives in the native header (one glyph).
// Cutting: category grid, charts (they belong on Stats), promo card.

import React, { useCallback, useState } from 'react';
import { Platform, RefreshControl, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import {
  GroupedSection,
  HeroMetric,
  IconButton,
  ListRow,
  MetricRow,
  ObjectCard,
  ProgressBar,
  Screen,
  SectionHeader,
  SkeletonRow,
  Txt,
} from '../../pack/components';
import { space, useTheme } from '../../pack/theme';

type IconName = React.ComponentProps<typeof Ionicons>['name'];

type Bill = { id: string; name: string; due: string; amount: string; icon: IconName };
type Transaction = { id: string; merchant: string; detail: string; amount: string; icon: IconName };

// Today: Wednesday, Oct 14 — 17 days left in October.
const UPCOMING_BILLS: Bill[] = [
  { id: 'car', name: 'Car insurance', due: 'Fri, Oct 16 · autopay', amount: '−$128.50', icon: 'car-outline' },
  { id: 'internet', name: 'Home internet', due: 'Tue, Oct 20', amount: '−$65.00', icon: 'wifi-outline' },
  { id: 'phone', name: 'Phone plan', due: 'Fri, Oct 23', amount: '−$45.00', icon: 'phone-portrait-outline' },
];

const RECENT: Transaction[] = [
  { id: 't1', merchant: "Trader Joe's", detail: 'Groceries · Today', amount: '−$64.18', icon: 'cart-outline' },
  { id: 't2', merchant: 'Thai Basil Kitchen', detail: 'Dining out · Yesterday', amount: '−$41.75', icon: 'restaurant-outline' },
  { id: 't3', merchant: 'Lyft', detail: 'Transport · Mon, Oct 12', amount: '−$18.20', icon: 'navigate-outline' },
  { id: 't4', merchant: 'Northwind Studio', detail: 'Paycheck · Fri, Oct 9', amount: '+$2,620.00', icon: 'briefcase-outline' },
];

export default function BudgetHome() {
  const { c } = useTheme();
  const [refreshing, setRefreshing] = useState(false);
  const bills = UPCOMING_BILLS;
  const recent = RECENT;

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    }, 900);
  }, []);

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Budget',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          // iOS: leave headerStyle unset so the large title stays visible; canvas paints behind it.
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          contentStyle: { backgroundColor: c.canvas },
          headerRight: () => <IconButton icon="add" label="Add transaction" onPress={() => {}} />,
        }}
      />
      <StatusBar style="auto" />
      <Screen refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={c.ink2} />}>
        {/* Status: the hero */}
        <View style={{ gap: space.xl }}>
          <HeroMetric
            label="Left for October"
            prefix="$"
            value="1,862"
            suffix=".40"
            delta={{ text: '$148 more', up: true, upIsGood: true }}
            context="than this point in September"
          />
          <MetricRow
            items={[
              { value: '$109', label: 'a day to stay on track' },
              { value: '17', label: 'days to go' },
              { value: '$2,317', label: 'spent so far' },
            ]}
          />
        </View>

        {/* Needs attention: the one category close to its limit */}
        <ObjectCard onPress={() => {}} accessibilityLabel="Dining out, $364 of $400 used, $36 left for 17 days. Opens the category.">
          <View style={{ gap: space.sm }}>
            <Txt variant="headline">Dining out is almost at its limit</Txt>
            <ProgressBar progress={364 / 400} label="Dining out budget used" />
            <Txt variant="subhead" color="ink2">
              $364 of $400 used · $36 left for the next 17 days
            </Txt>
          </View>
        </ObjectCard>

        {/* What's next */}
        <View style={{ gap: space.sm }}>
          <SectionHeader title="Coming up" action={{ title: 'All bills', onPress: () => {} }} />
          {bills.length === 0 ? (
            <GroupedSection>
              <ListRow icon="checkmark-circle-outline" title="No bills due before Oct 31" subtitle="Recurring bills show up here a week ahead." />
            </GroupedSection>
          ) : (
            <GroupedSection footer="$238.50 due in the next 10 days. Already counted in what's left.">
              {bills.map((b) => (
                <ListRow key={b.id} icon={b.icon} title={b.name} subtitle={b.due} value={b.amount} onPress={() => {}} />
              ))}
            </GroupedSection>
          )}
        </View>

        {/* Recent activity */}
        <View style={{ gap: space.sm }}>
          <SectionHeader title="Recent" action={{ title: 'See all', onPress: () => {} }} />
          {refreshing ? (
            <GroupedSection>
              <SkeletonRow />
              <SkeletonRow />
              <SkeletonRow />
              <SkeletonRow />
            </GroupedSection>
          ) : recent.length === 0 ? (
            <GroupedSection>
              <ListRow
                icon="receipt-outline"
                title="No spending yet this month"
                subtitle="Connect a bank account or tap + to log a purchase."
              />
            </GroupedSection>
          ) : (
            <GroupedSection>
              {recent.map((t) => (
                <ListRow key={t.id} icon={t.icon} title={t.merchant} subtitle={t.detail} value={t.amount} onPress={() => {}} />
              ))}
            </GroupedSection>
          )}
        </View>
      </Screen>
    </>
  );
}
