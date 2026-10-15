// HomeScreen.tsx — Home/dashboard archetype (mobile-ui/references/screen-home.md).
// Job: "see what's left to spend". Focal: hero balance. Primary: none (add lives in the header).
// Expo Router: place at app/index.tsx (or app/(tabs)/index.tsx). Declare the static header options
// (title, headerLargeTitle) in app/_layout.tsx — see assets/templates/_layout.tsx. Only dynamic options
// (headerRight) are set here. React Navigation: set the same options on the navigator.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import React from 'react';
import { View } from 'react-native';
import { Stack } from 'expo-router';
import {
  QEmptyState,
  QGroupedSection,
  QHeroMetric,
  QIconButton,
  QListRow,
  QMetricRow,
  QScreen,
  QSectionHeader,
  QSkeletonRow,
} from '../components';
import { space } from '../theme';

type Bill = { id: string; name: string; due: string; amount: string; icon: 'home-outline' | 'musical-notes-outline' | 'cafe-outline' };

const SAMPLE_BILLS: Bill[] = [
  { id: 'rent', name: 'Rent', due: 'Due Thursday', amount: '−$1,450.00', icon: 'home-outline' },
  { id: 'spotify', name: 'Spotify Family', due: 'Sep 18', amount: '−$16.99', icon: 'musical-notes-outline' },
  { id: 'coffee', name: 'Blue Bottle Coffee subscription', due: 'Sep 21', amount: '−$38.40', icon: 'cafe-outline' },
];

export default function HomeScreen({ loading = false, bills = SAMPLE_BILLS }: { loading?: boolean; bills?: Bill[] }) {
  return (
    <>
      <Stack.Screen options={{ headerRight: () => <QIconButton icon="add" label="Add expense" onPress={() => {}} /> }} />
      <QScreen>
        <View style={{ gap: space.xl }}>
          <QHeroMetric
            label="Left to spend"
            prefix="$"
            value="2,140"
            suffix=".50"
            context="12 days to go"
            delta={{ text: '$86 under', up: false, upIsGood: false }}
          />
          <QMetricRow
            items={[
              { value: '$1,284', label: 'spent' },
              { value: '$107', label: 'per day' },
              { value: '62%', label: 'of budget' },
            ]}
          />
        </View>

        <View style={{ gap: space.sm }}>
          <QSectionHeader title="Up next" action={{ title: 'See all', onPress: () => {} }} />
          {loading ? (
            <QGroupedSection>
              <QSkeletonRow />
              <QSkeletonRow />
              <QSkeletonRow />
            </QGroupedSection>
          ) : bills.length === 0 ? (
            <QEmptyState icon="calendar-outline" title="Nothing due" message="Bills you add show up here a week before they're due." />
          ) : (
            <QGroupedSection>
              {bills.map((b) => (
                <QListRow key={b.id} icon={b.icon} title={b.name} subtitle={b.due} value={b.amount} />
              ))}
            </QGroupedSection>
          )}
        </View>
      </QScreen>
    </>
  );
}
