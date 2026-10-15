// Settings — archetype: Settings (mobile-ui/references/screen-settings.md).
// Job: change preferences and manage the account. Focal: the account header row.
// Primary action: none — toggles apply immediately; destructive actions sit in the last group.
// Cutting: per-row icon tiles, a Save button, and an upsell banner (Plus member already).

import React, { useState } from 'react';
import { ActionSheetIOS, Alert, Linking, Platform, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Avatar, GroupedSection, ListRow, Screen, ToggleRow, Txt } from '../../pack/components';
import { space, useTheme } from '../../pack/theme';

type Appearance = 'System' | 'Light' | 'Dark';
type Units = 'Metric' | 'US customary';

const ACCOUNT = {
  name: 'Priya Raman',
  email: 'priya.raman@fastmail.com',
};

const PLAN = {
  name: 'Pantry Plus',
  renews: 'Nov 12',
  price: '$4.99/mo',
};

function choose<T extends string>(title: string, options: readonly T[], onPick: (v: T) => void) {
  if (Platform.OS === 'ios') {
    ActionSheetIOS.showActionSheetWithOptions(
      { title, options: [...options, 'Cancel'], cancelButtonIndex: options.length },
      (i) => {
        if (i < options.length) {
          Haptics.selectionAsync();
          onPick(options[i]);
        }
      },
    );
  } else {
    Alert.alert(title, undefined, [
      ...options.map((o) => ({ text: o, onPress: () => onPick(o) })),
      { text: 'Cancel', style: 'cancel' as const },
    ]);
  }
}

export default function SettingsScreen() {
  const { c } = useTheme();

  const [mealReminders, setMealReminders] = useState(true);
  const [listUpdates, setListUpdates] = useState(true);
  const [weeklyPlan, setWeeklyPlan] = useState(false);
  const [appearance, setAppearance] = useState<Appearance>('System');
  const [units, setUnits] = useState<Units>('Metric');
  const [largeIngredients, setLargeIngredients] = useState(false);

  const confirmSignOut = () => {
    Alert.alert('Sign out of Pantry?', 'Your meal plans stay synced to your account.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign out', style: 'destructive', onPress: () => {} },
    ]);
  };

  const confirmDelete = () => {
    const title = 'Delete your account?';
    const message = '214 saved recipes and 9 weeks of meal plans will be erased. Your Plus subscription must be cancelled separately.';
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { title, message, options: ['Delete account', 'Keep account'], destructiveButtonIndex: 0, cancelButtonIndex: 1 },
        (i) => {
          if (i === 0) Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
        },
      );
    } else {
      Alert.alert(title, message, [
        { text: 'Keep account', style: 'cancel' },
        { text: 'Delete account', style: 'destructive', onPress: () => {} },
      ]);
    }
  };

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Settings',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          contentStyle: { backgroundColor: c.canvas },
          ...(Platform.OS === 'android' ? { headerStyle: { backgroundColor: c.canvas } } : {}),
        }}
      />
      <StatusBar style="auto" />
      <Screen>
        <GroupedSection>
          <ListRow
            leading={<Avatar name={ACCOUNT.name} size={48} />}
            title={ACCOUNT.name}
            subtitle={ACCOUNT.email}
            onPress={() => {}}
          />
        </GroupedSection>

        <GroupedSection header="Notifications" footer="Meal reminders arrive 45 minutes before the cook time on your plan.">
          <ToggleRow title="Meal reminders" value={mealReminders} onValueChange={setMealReminders} />
          <ToggleRow title="Shared list changes" subtitle="When Arjun adds or checks off items" value={listUpdates} onValueChange={setListUpdates} />
          <ToggleRow title="Weekly plan ready" value={weeklyPlan} onValueChange={setWeeklyPlan} />
          <ListRow title="Quiet hours" value="10:00 PM – 7:00 AM" onPress={() => {}} />
        </GroupedSection>

        <GroupedSection header="Appearance">
          <ListRow
            title="Theme"
            value={appearance}
            kind="action"
            onPress={() => choose<Appearance>('Theme', ['System', 'Light', 'Dark'], setAppearance)}
          />
          <ListRow
            title="Units"
            value={units}
            kind="action"
            onPress={() => choose<Units>('Measurement units', ['Metric', 'US customary'], setUnits)}
          />
          <ToggleRow
            title="Larger ingredient text"
            subtitle="Easier to read from the counter while cooking"
            value={largeIngredients}
            onValueChange={setLargeIngredients}
          />
        </GroupedSection>

        <GroupedSection header="Subscription" footer={`${PLAN.price}, billed through the App Store. Cancel any time before ${PLAN.renews}.`}>
          <ListRow title="Plan" value={`${PLAN.name} · renews ${PLAN.renews}`} />
          <ListRow title="Manage subscription" kind="link" onPress={() => Linking.openURL('https://apps.apple.com/account/subscriptions')} />
          <ListRow title="Restore purchases" kind="action" onPress={() => {}} />
        </GroupedSection>

        <GroupedSection header="Account">
          <ListRow title="Email" value={ACCOUNT.email} onPress={() => {}} />
          <ListRow title="Password" value="Changed 3 months ago" onPress={() => {}} />
          <ListRow title="Household members" value="2" onPress={() => {}} />
          <ListRow title="Export recipes" onPress={() => {}} />
        </GroupedSection>

        <View style={{ gap: space.xl }}>
          <GroupedSection>
            <ListRow title="Sign out" kind="action" onPress={confirmSignOut} />
            <ListRow title="Delete account" kind="action" destructive onPress={confirmDelete} />
          </GroupedSection>
          <Txt variant="footnote" color="ink2" style={{ textAlign: 'center' }}>
            Pantry 3.8.1 (2047)
          </Txt>
        </View>
      </Screen>
    </>
  );
}
