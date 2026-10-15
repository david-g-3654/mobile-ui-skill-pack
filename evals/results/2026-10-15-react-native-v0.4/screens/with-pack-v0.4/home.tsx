// Home — personal budgeting.
// Archetype: Home / dashboard. Job: "how much can I still spend this month?"
// Focal: left-to-spend hero. Primary: "Log an expense" (pinned). Cut: charts (Stats tab), category tile grid.

import React, { useCallback, useEffect, useState } from 'react';
import { Platform, Pressable, RefreshControl, ScrollView, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { metrics, radius, space, useQTheme } from '../../pack04/theme';
import {
  QBottomActionBar,
  QGroupedSection,
  QHeroMetric,
  QListRow,
  QMetricRow,
  QPrimaryButton,
  QProgressBar,
  QSectionHeader,
  QSkeleton,
  QSkeletonRow,
  QText,
} from '../../pack04/components';

// ── Sample data (today: Thu, Oct 15) ─────────────────────────────────

const MONTH = 'October';
const BUDGET = 3200;
const SPENT = 1915.4;
const SAVED = 420;
const DAYS_LEFT = 16;

type Bill = { id: string; payee: string; due: string; amount: number; autopay: boolean };
const BILLS: Bill[] = [
  { id: 'b1', payee: 'Rent — Maple Court', due: 'Due Sat, Oct 17', amount: 1450, autopay: false },
  { id: 'b2', payee: 'Verizon Wireless', due: 'Oct 21 · Autopay', amount: 68.12, autopay: true },
  { id: 'b3', payee: 'Planet Fitness', due: 'Oct 24 · Autopay', amount: 24.99, autopay: true },
];

type Txn = { id: string; merchant: string; category: string; when: string; amount: number; icon: React.ComponentProps<typeof Ionicons>['name'] };
const RECENT: Txn[] = [
  { id: 't1', merchant: 'Trader Joe’s', category: 'Groceries', when: 'Today, 8:14 AM', amount: -47.83, icon: 'basket-outline' },
  { id: 't2', merchant: 'Blue Bottle Coffee', category: 'Dining out', when: 'Today, 7:32 AM', amount: -6.5, icon: 'cafe-outline' },
  { id: 't3', merchant: 'Lyft', category: 'Transport', when: 'Yesterday', amount: -18.24, icon: 'car-outline' },
  { id: 't4', merchant: 'Refund · REI Co-op', category: 'Shopping', when: 'Tue, Oct 13', amount: 89.95, icon: 'bag-handle-outline' },
];

// One money format for the whole screen.
const usd = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const money = (n: number) => usd.format(n);
const signed = (n: number) => (n < 0 ? `−${money(-n)}` : `+${money(n)}`);
const shortMoney = (n: number) => usd.format(Math.round(n)).replace(/\.00$/, '');

type Status = 'loading' | 'ready';

export default function BudgetHome() {
  const { c } = useQTheme();
  const [status, setStatus] = useState<Status>('loading');
  const [refreshing, setRefreshing] = useState(false);

  // Simulated fetch; the skeleton keeps the final layout.
  useEffect(() => {
    const id = setTimeout(() => setStatus('ready'), 700);
    return () => clearTimeout(id);
  }, []);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    setTimeout(() => {
      setRefreshing(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    }, 900);
  }, []);

  const left = BUDGET - SPENT;
  const [whole, cents] = money(left).slice(1).split('.');
  const symbol = money(0).charAt(0);
  const perDay = left / DAYS_LEFT;

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <StatusBar style="auto" />
      <Stack.Screen
        options={{
          title: MONTH,
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerLargeTitleShadowVisible: false,
          contentStyle: { backgroundColor: c.canvas },
          // iOS 26+: headerStyle hides the large title, so paint it on Android only.
          ...(Platform.OS === 'android' ? { headerStyle: { backgroundColor: c.canvas } } : null),
          headerRight: () => (
            <Pressable
              onPress={() => {
                /* push the month picker */
              }}
              accessibilityRole="button"
              accessibilityLabel="Change month"
              hitSlop={metrics.hitSlop}
              style={({ pressed }) => [{ minWidth: metrics.minTap, minHeight: metrics.minTap, alignItems: 'center', justifyContent: 'center' }, pressed && { opacity: 0.6 }]}
            >
              <Ionicons name="calendar-outline" size={22} color={c.ink} />
            </Pressable>
          ),
        }}
      />

      {/* QScreen-equivalent scroll so we can attach a native refresh control */}
      <ScrollArea refreshing={refreshing} onRefresh={onRefresh}>
        {status === 'loading' ? (
          <LoadingState />
        ) : (
          <>
            {/* Hero: the one number that is the screen */}
            <View style={{ gap: space.md }}>
              <QHeroMetric
                label="Left to spend"
                prefix={symbol}
                value={whole}
                suffix={`.${cents}`}
                context={`of ${shortMoney(BUDGET)} · ${DAYS_LEFT} days to go`}
              />
              <QProgressBar progress={SPENT / BUDGET} label={`${Math.round((SPENT / BUDGET) * 100)} percent of the ${MONTH} budget spent`} />
            </View>

            <QMetricRow
              items={[
                { value: money(perDay), label: 'per day to stay on track' },
                { value: shortMoney(SPENT), label: 'spent so far' },
                { value: shortMoney(SAVED), label: 'moved to savings' },
              ]}
            />

            {/* What needs attention: bills before they hit */}
            <View style={{ gap: space.sm }}>
              <QSectionHeader title="Coming up" action={{ title: 'All bills', onPress: () => {} }} />
              <QGroupedSection footer={`${money(BILLS.reduce((s, b) => s + b.amount, 0))} due in the next 10 days.`}>
                {BILLS.map((b) => (
                  <QListRow key={b.id} title={b.payee} subtitle={b.due} value={money(b.amount)} onPress={() => {}} />
                ))}
              </QGroupedSection>
            </View>

            {/* What just happened */}
            <View style={{ gap: space.sm }}>
              <QSectionHeader title="Recent" action={{ title: 'See all', onPress: () => {} }} />
              <QGroupedSection>
                {RECENT.length === 0 ? (
                  <QListRow title="No spending logged yet" subtitle="Purchases you log or sync show up here." />
                ) : (
                  RECENT.map((t) => (
                    <QListRow
                      key={t.id}
                      icon={t.icon}
                      title={t.merchant}
                      subtitle={`${t.category} · ${t.when}`}
                      value={signed(t.amount)}
                      onPress={() => {}}
                    />
                  ))
                )}
              </QGroupedSection>
            </View>
          </>
        )}
      </ScrollArea>

      <QBottomActionBar>
        <QPrimaryButton
          title="Log an expense"
          accessibilityHint="Opens a form to record a purchase"
          onPress={() => {
            /* present the add-expense form sheet */
          }}
        />
      </QBottomActionBar>
    </View>
  );
}

// ── Pieces ───────────────────────────────────────────────────────────

function ScrollArea({ children, refreshing, onRefresh }: { children: React.ReactNode; refreshing: boolean; onRefresh: () => void }) {
  const { c } = useQTheme();
  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: c.canvas }}
      contentInsetAdjustmentBehavior="automatic"
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={c.ink2} />}
      contentContainerStyle={{ paddingHorizontal: space.margin, paddingTop: space.xs, paddingBottom: space.xxl, gap: space.xxl }}
    >
      {children}
    </ScrollView>
  );
}

function LoadingState() {
  const { c } = useQTheme();
  return (
    <>
      <View style={{ gap: space.sm }}>
        <QSkeleton width={96} height={12} />
        <QSkeleton width="55%" height={56} />
        <QSkeleton width="70%" height={14} />
        <QSkeleton width="100%" height={6} />
      </View>
      <View style={{ flexDirection: 'row', gap: space.xl }}>
        <QSkeleton width={72} height={28} />
        <QSkeleton width={72} height={28} />
        <QSkeleton width={72} height={28} />
      </View>
      <View style={{ backgroundColor: c.surface, borderRadius: radius.l, overflow: 'hidden' }}>
        <QSkeletonRow />
        <QSkeletonRow />
        <QSkeletonRow />
      </View>
      <QText variant="footnote" color="ink2">
        Syncing your accounts…
      </QText>
    </>
  );
}
