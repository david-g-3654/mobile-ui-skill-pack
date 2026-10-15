// Settings — Fieldnote (journaling app). Archetype: settings.
// Job: change preferences and manage the account. Focal: account header row. Primary: none (toggles apply immediately).
import React, { useState } from 'react';
import { ActionSheetIOS, Alert, Linking, Platform, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { space, useQTheme } from '../../pack04/theme';
import { QAvatar, QGroupedSection, QListRow, QScreen, QText, QToggleRow } from '../../pack04/components';

type ThemeChoice = 'System' | 'Light' | 'Dark';
type ReminderTime = '7:00 AM' | '12:30 PM' | '8:30 PM' | '10:00 PM';

const ACCOUNT = { name: 'Priya Raman', email: 'priya.raman@fastmail.com' };
const PLAN = { name: 'Fieldnote Plus', renews: 'Nov 3', price: '$39.99/year' };
const THEMES: ThemeChoice[] = ['System', 'Light', 'Dark'];
const REMINDER_TIMES: ReminderTime[] = ['7:00 AM', '12:30 PM', '8:30 PM', '10:00 PM'];

/** Native picker: action sheet on iOS, alert with buttons on Android. */
function pickOption<T extends string>(title: string, options: T[], onPick: (v: T) => void) {
  if (Platform.OS === 'ios') {
    ActionSheetIOS.showActionSheetWithOptions({ title, options: [...options, 'Cancel'], cancelButtonIndex: options.length }, (i) => {
      if (i < options.length) {
        Haptics.selectionAsync();
        onPick(options[i]);
      }
    });
    return;
  }
  Alert.alert(title, undefined, [
    ...options.map((o) => ({ text: o, onPress: () => onPick(o) })),
    { text: 'Cancel', style: 'cancel' as const },
  ]);
}

export default function SettingsScreen() {
  const { c } = useQTheme();

  const [dailyReminder, setDailyReminder] = useState(true);
  const [reminderTime, setReminderTime] = useState<ReminderTime>('8:30 PM');
  const [weeklyRecap, setWeeklyRecap] = useState(true);
  const [sharedComments, setSharedComments] = useState(false);
  const [theme, setTheme] = useState<ThemeChoice>('System');
  const [showWordCount, setShowWordCount] = useState(true);

  const confirmSignOut = () =>
    Alert.alert('Sign out of Fieldnote?', 'Your entries stay synced and will be here when you sign back in.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign out', style: 'destructive', onPress: () => {} },
    ]);

  const confirmDelete = () =>
    Alert.alert(
      'Delete your account?',
      'This permanently removes all 214 entries and cancels Fieldnote Plus. Export them first if you want a copy.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete account', style: 'destructive', onPress: () => {} },
      ],
    );

  const restorePurchases = () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    Alert.alert('Purchases restored', `${PLAN.name} is active on this device.`);
  };

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Settings',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
          contentStyle: { backgroundColor: c.canvas },
        }}
      />
      <StatusBar style="auto" />
      <QScreen>
        <QGroupedSection>
          <QListRow
            leading={<QAvatar name={ACCOUNT.name} size={48} />}
            title={ACCOUNT.name}
            subtitle={ACCOUNT.email}
            onPress={() => {}}
          />
        </QGroupedSection>

        <QGroupedSection
          header="Notifications"
          footer={
            dailyReminder
              ? `We'll nudge you at ${reminderTime} if you haven't written yet that day.`
              : 'Turn on a daily reminder to keep your writing streak going.'
          }
        >
          <QToggleRow title="Daily writing reminder" value={dailyReminder} onValueChange={setDailyReminder} />
          {dailyReminder && (
            <QListRow
              title="Reminder time"
              value={reminderTime}
              onPress={() => pickOption('Remind me at', REMINDER_TIMES, setReminderTime)}
            />
          )}
          <QToggleRow title="Weekly recap" subtitle="Sunday morning summary of what you wrote" value={weeklyRecap} onValueChange={setWeeklyRecap} />
          <QToggleRow title="Comments on shared entries" value={sharedComments} onValueChange={setSharedComments} />
        </QGroupedSection>

        <QGroupedSection header="Appearance">
          <QListRow title="Theme" value={theme} onPress={() => pickOption('Theme', THEMES, setTheme)} />
          <QListRow title="Editor font" value="New York" onPress={() => {}} />
          <QToggleRow title="Show word count" value={showWordCount} onValueChange={setShowWordCount} />
        </QGroupedSection>

        <QGroupedSection header="Subscription" footer={`${PLAN.price}, billed through the App Store. Cancel anytime in Manage subscription.`}>
          <QListRow title={PLAN.name} value={`Renews ${PLAN.renews}`} onPress={() => {}} />
          <QListRow title="Manage subscription" kind="link" onPress={() => Linking.openURL('https://apps.apple.com/account/subscriptions')} />
          <QListRow title="Restore purchases" kind="action" onPress={restorePurchases} />
        </QGroupedSection>

        <QGroupedSection header="Account">
          <QListRow title="Sign-in & security" onPress={() => {}} />
          <QListRow title="Synced devices" value="3" onPress={() => {}} />
          <QListRow title="Export entries" subtitle="214 entries as Markdown" onPress={() => {}} />
        </QGroupedSection>

        <QGroupedSection>
          <QListRow title="Sign out" kind="action" onPress={confirmSignOut} />
          <QListRow title="Delete account" kind="action" destructive onPress={confirmDelete} />
        </QGroupedSection>

        <View style={{ alignItems: 'center', gap: space.xxs }}>
          <QText variant="footnote" color="ink2">
            Fieldnote 3.8.1 (2417)
          </QText>
          <QText variant="footnote" color="ink2">
            Made in Lisbon
          </QText>
        </View>
      </QScreen>
    </>
  );
}
