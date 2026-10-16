import React, { useState } from 'react';
import {
  ActionSheetIOS,
  Alert,
  Appearance,
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  View,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { metrics, space, useQTheme } from '../../pack04/theme';
import {
  QAvatar,
  QBottomActionBar,
  QGroupedSection,
  QListRow,
  QPrimaryButton,
  QScreen,
  QText,
  QTextField,
  QTertiaryButton,
  QToggleRow,
} from '../../pack04/components';

type AppearanceChoice = 'System' | 'Light' | 'Dark';

export default function SettingsScreen() {
  const { c, dark } = useQTheme();
  const insets = useSafeAreaInsets();
  const [appearance, setAppearance] = useState<AppearanceChoice>('System');
  const [pushEnabled, setPushEnabled] = useState(true);
  const [weeklyEmail, setWeeklyEmail] = useState(false);
  const [renewing, setRenewing] = useState(true);
  const [signedIn, setSignedIn] = useState(true);
  const [deleted, setDeleted] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);
  const [name, setName] = useState('Maya Chen');
  const [email, setEmail] = useState('maya.chen@hey.com');
  const [draftName, setDraftName] = useState(name);
  const [draftEmail, setDraftEmail] = useState(email);
  const [formError, setFormError] = useState<string>();

  const selectAppearance = (choice: AppearanceChoice) => {
    setAppearance(choice);
    Appearance.setColorScheme(choice === 'System' ? 'unspecified' : choice === 'Dark' ? 'dark' : 'light');
    void Haptics.selectionAsync().catch(() => undefined);
  };

  const openAppearance = () => {
    const choices: AppearanceChoice[] = ['System', 'Light', 'Dark'];
    if (Platform.OS === 'ios') {
      ActionSheetIOS.showActionSheetWithOptions(
        {
          title: 'Appearance',
          message: 'System follows your device’s light and dark schedule.',
          options: [...choices.map(choice => choice === appearance ? `${choice} (selected)` : choice), 'Cancel'],
          cancelButtonIndex: choices.length,
          userInterfaceStyle: dark ? 'dark' : 'light',
        },
        index => {
          if (index < choices.length) selectAppearance(choices[index]);
        },
      );
    } else {
      Alert.alert('Appearance', 'Choose a theme. System follows your device.', choices.map(choice => ({
        text: choice === appearance ? `${choice} (selected)` : choice,
        onPress: () => selectAppearance(choice),
      })), { cancelable: true });
    }
  };

  const openProfile = () => {
    setDraftName(name);
    setDraftEmail(email);
    setFormError(undefined);
    setProfileOpen(true);
  };

  const saveProfile = () => {
    if (!draftName.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(draftEmail.trim())) {
      setFormError('Enter your name and a valid email address.');
      return;
    }
    setName(draftName.trim());
    setEmail(draftEmail.trim());
    setProfileOpen(false);
    void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => undefined);
  };

  const manageSubscription = () => {
    Alert.alert(
      'Still Plus · Annual',
      renewing
        ? '$39.99 per year. Your next renewal is November 16, 2026. This is a sample subscription; no billing changes are made.'
        : 'Renewal is off. Your sample Plus access continues until November 16, 2026.',
      [
        { text: 'Close', style: 'cancel' },
        {
          text: renewing ? 'Turn off renewal' : 'Turn on renewal',
          onPress: () => {
            setRenewing(!renewing);
            void Haptics.selectionAsync().catch(() => undefined);
          },
        },
      ],
    );
  };

  const signOut = () => Alert.alert('Sign out of Still?', 'Your preferences will stay here for this session.', [
    { text: 'Stay signed in', style: 'cancel' },
    { text: 'Sign out', onPress: () => setSignedIn(false) },
  ]);

  const deleteAccount = () => Alert.alert(
    'Delete your demo account?',
    'This removes the sample profile from this session. No real account or subscription will be affected.',
    [
      { text: 'Keep account', style: 'cancel' },
      {
        text: 'Delete account',
        style: 'destructive',
        onPress: () => {
          setSignedIn(false);
          setDeleted(true);
          setPushEnabled(false);
          setWeeklyEmail(false);
        },
      },
    ],
  );

  return (
    <View style={[styles.root, { backgroundColor: c.canvas }]}>
      <Stack.Screen options={{
        title: 'Settings',
        headerLargeTitle: true,
        headerShadowVisible: false,
        headerLargeTitleShadowVisible: false,
        headerTintColor: c.ink,
        headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        contentStyle: { backgroundColor: c.canvas },
      }} />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <QScreen contentContainerStyle={{ paddingBottom: insets.bottom + space.xxl }}>
        <QGroupedSection>
          <Pressable
            onPress={signedIn ? openProfile : () => {
              if (deleted) {
                setName('Maya Chen');
                setEmail('maya.chen@hey.com');
                setDeleted(false);
              }
              setSignedIn(true);
            }}
            accessibilityRole="button"
            accessibilityLabel={signedIn ? `${name}, ${email}. Edit profile` : 'Open demo account'}
            style={({ pressed }) => [styles.profile, pressed && { backgroundColor: c.surface2 }]}
          >
            <View accessible={false} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
              <QAvatar name={signedIn ? name : 'Still'} size={space.xxxl} />
            </View>
            <View style={styles.profileText}>
              <QText variant="headline">{signedIn ? name : 'Make yourself at home'}</QText>
              <QText variant="footnote" color="ink2">{signedIn ? email : 'Tap to open a demo account'}</QText>
            </View>
            <Ionicons name="chevron-forward" size={space.md} color={c.ink2} />
          </Pressable>
        </QGroupedSection>

        <QGroupedSection header="Appearance">
          <QListRow title="Color theme" value={appearance} kind="action" onPress={openAppearance} />
        </QGroupedSection>

        <QGroupedSection
          header="Notifications"
          footer="A little less noise. Choose what you hear from us."
        >
          <QToggleRow title="Push notifications" value={pushEnabled} onValueChange={setPushEnabled} />
          <QToggleRow title="Weekly email summary" value={weeklyEmail} onValueChange={setWeeklyEmail} />
        </QGroupedSection>

        {signedIn && (
          <QGroupedSection
            header="Subscription"
            footer={renewing ? '$39.99 / year · Renews Nov 16, 2026' : 'Renewal off · Access until Nov 16, 2026'}
          >
            <QListRow title="Manage plan" value="Plus · Annual" kind="action" onPress={manageSubscription} />
            <QListRow title="Restore purchases" kind="action" onPress={() => Alert.alert(
              'Your plan is up to date',
              'This demo already includes Still Plus. In the live app, this checks purchases linked to your store account.',
              [{ text: 'Got it' }],
            )} />
          </QGroupedSection>
        )}

        {signedIn && (
          <QGroupedSection header="Account">
            <QListRow title="Sign out" kind="action" onPress={signOut} />
            <QListRow title="Delete account" kind="action" destructive onPress={deleteAccount} />
          </QGroupedSection>
        )}

        <View style={styles.version}>
          <QText variant="footnote" color="ink2" style={styles.center}>Still · Version 2.8.1 (204)</QText>
          <QText variant="footnote" color="ink2" style={styles.center}>Demo settings reset when you reload.</QText>
        </View>
      </QScreen>

      <Modal visible={profileOpen} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setProfileOpen(false)}>
        <KeyboardAvoidingView style={[styles.root, { backgroundColor: c.canvas }]} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
          <View style={[styles.sheetHeader, { paddingTop: space.md + (Platform.OS === 'android' ? insets.top : 0) }]}>
            <QText variant="headline" role="header">Personal details</QText>
            <QTertiaryButton title="Cancel" onPress={() => setProfileOpen(false)} />
          </View>
          <QScreen keyboardShouldPersistTaps="handled" contentInsetAdjustmentBehavior="never">
            <QText variant="body" color="ink2">Keep your Still profile up to date.</QText>
            <QTextField label="Name" value={draftName} onChangeText={setDraftName} autoComplete="name" textContentType="name" autoCapitalize="words" />
            <QTextField label="Email address" value={draftEmail} onChangeText={setDraftEmail} keyboardType="email-address" autoComplete="email" textContentType="emailAddress" autoCapitalize="none" autoCorrect={false} onSubmitEditing={saveProfile} returnKeyType="done" />
            {formError && <QText variant="footnote" color="negative">{formError}</QText>}
          </QScreen>
          <QBottomActionBar>
            <QPrimaryButton title="Save changes" onPress={saveProfile} />
          </QBottomActionBar>
        </KeyboardAvoidingView>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  profile: {
    minHeight: metrics.rowMinHeight,
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
    padding: space.md,
  },
  profileText: { flex: 1, gap: space.xxs },
  version: { gap: space.xxs, paddingHorizontal: space.md },
  center: { textAlign: 'center' },
  sheetHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    flexWrap: 'wrap',
    gap: space.sm,
    paddingHorizontal: space.margin,
    paddingBottom: space.sm,
  },
});
