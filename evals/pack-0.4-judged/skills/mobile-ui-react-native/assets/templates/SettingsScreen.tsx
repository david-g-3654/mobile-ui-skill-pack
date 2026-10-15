// SettingsScreen.tsx — Settings archetype (mobile-ui/references/screen-settings.md).
// Inset-grouped sections on canvas. Toggles apply immediately. Destructive actions last.
// Header (title + large title) is declared statically in app/_layout.tsx — see assets/templates/_layout.tsx.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import React, { useState } from 'react';
import { ActionSheetIOS, Alert, Linking, Platform, View } from 'react-native';
import { QAvatar, QGroupedSection, QListRow, QScreen, QToggleRow, QText } from '../components';
import { space } from '../theme';

export default function SettingsScreen() {
  const [dailyReminder, setDailyReminder] = useState(true);
  const [weeklyReport, setWeeklyReport] = useState(false);

  const confirmDelete = () => {
    const title = 'Delete your account?';
    const message = "Your journals and settings will be permanently removed. This can't be undone.";
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        { title, message, options: ['Delete account', 'Keep my account'], destructiveButtonIndex: 0, cancelButtonIndex: 1 },
        (i) => i === 0 && deleteAccount(),
      );
    } else {
      Alert.alert(title, message, [
        { text: 'Keep my account', style: 'cancel' },
        { text: 'Delete account', style: 'destructive', onPress: deleteAccount },
      ]);
    }
  };

  return (
    <>
      <QScreen>
        <QGroupedSection>
          <QListRow leading={<QAvatar name="Amara Okafor" size={48} />} title="Amara Okafor" subtitle="amara@hey.com" onPress={() => {}} />
        </QGroupedSection>

        <QGroupedSection header="Preferences" footer="Reminders arrive 10 minutes before your wake-up time.">
          <QListRow title="Appearance" value="System" onPress={() => {}} />
          <QListRow title="Wake up" value="8:00 AM" onPress={() => {}} />
          <QToggleRow title="Daily reminder" value={dailyReminder} onValueChange={setDailyReminder} />
        </QGroupedSection>

        <QGroupedSection header="Notifications">
          <QToggleRow title="Weekly report" subtitle="A summary every Sunday evening" value={weeklyReport} onValueChange={setWeeklyReport} />
        </QGroupedSection>

        <QGroupedSection header="Subscription">
          <QListRow title="Plan" value="Pro · renews Oct 3" />
          <QListRow title="Restore purchases" kind="action" onPress={() => {}} />
        </QGroupedSection>

        <QGroupedSection>
          <QListRow title="Privacy policy" kind="link" onPress={() => Linking.openURL('https://example.com/privacy')} />
        </QGroupedSection>

        <View style={{ gap: space.xl }}>
          <QGroupedSection>
            <QListRow title="Sign out" kind="action" onPress={() => {}} />
            <QListRow title="Delete account" kind="action" destructive onPress={confirmDelete} />
          </QGroupedSection>
          <QText variant="footnote" color="ink2" style={{ textAlign: 'center' }}>
            Quiet 4.2.0 (1182)
          </QText>
        </View>
      </QScreen>
    </>
  );
}

function deleteAccount() {
  // Call your API, then route to the signed-out flow.
}
