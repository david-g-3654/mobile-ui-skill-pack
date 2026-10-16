import React, { useState } from 'react';
import { Alert, Modal, Pressable, ScrollView, StyleSheet, Switch, Text, View, useColorScheme } from 'react-native';
import { Stack } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';

type IconName = React.ComponentProps<typeof Ionicons>['name'];
type Appearance = 'Light' | 'Dark' | 'System';

export default function SettingsScreen() {
  const [notifications, setNotifications] = useState(true);
  const [weeklyDigest, setWeeklyDigest] = useState(false);
  const [appearance, setAppearance] = useState<Appearance>('Light');
  const [appearanceOpen, setAppearanceOpen] = useState(false);
  const [planOpen, setPlanOpen] = useState(false);
  const [annual, setAnnual] = useState(true);
  const [signedOut, setSignedOut] = useState(false);
  const systemTheme = useColorScheme();
  const dark = appearance === 'Dark' || (appearance === 'System' && systemTheme === 'dark');
  const colors = dark
    ? { background: '#171C19', card: '#222923', text: '#F4F4EC', secondary: '#A5AEA6', line: '#343C35', soft: '#303B31' }
    : { background: '#F6F7F2', card: '#FFFFFF', text: '#25382C', secondary: '#858C83', line: '#EFF0EA', soft: '#EEF3E9' };

  function Row({ icon, title, subtitle, value, onPress, toggle, last = false }: { icon: IconName; title: string; subtitle?: string; value?: string; onPress?: () => void; toggle?: { value: boolean; change: (value: boolean) => void }; last?: boolean }) {
    return (
      <Pressable disabled={!onPress} onPress={onPress} style={({ pressed }) => [styles.row, { opacity: pressed ? 0.6 : 1 }]} accessibilityRole={onPress ? 'button' : undefined}>
        <View style={[styles.iconBox, { backgroundColor: colors.soft }]}><Ionicons name={icon} size={20} color={dark ? '#C0D1AD' : '#657A54'} /></View>
        <View style={[styles.rowBody, !last && { borderBottomColor: colors.line, borderBottomWidth: 1 }]}>
          <View style={styles.rowCopy}><Text style={[styles.rowTitle, { color: colors.text }]}>{title}</Text>{subtitle && <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{subtitle}</Text>}</View>
          {toggle ? <Switch accessibilityLabel={title} value={toggle.value} onValueChange={toggle.change} trackColor={{ false: dark ? '#4A514B' : '#DDE1D8', true: '#7A925C' }} thumbColor="#FFFFFF" ios_backgroundColor={dark ? '#4A514B' : '#DDE1D8'} /> : <View style={styles.rowEnd}>{value && <Text style={[styles.rowValue, { color: colors.secondary }]}>{value}</Text>}<Ionicons name="chevron-forward" size={17} color="#A6ADA0" /></View>}
        </View>
      </Pressable>
    );
  }

  function SectionLabel({ children }: { children: string }) {
    return <Text style={[styles.sectionLabel, { color: colors.secondary }]}>{children}</Text>;
  }

  return (
    <SafeAreaView style={[styles.screen, { backgroundColor: colors.background }]} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
        <View style={styles.topLine}><View style={styles.brand}><View style={styles.brandMark}><Ionicons name="leaf" size={17} color="#FFFFFF" /></View><Text style={[styles.brandName, { color: colors.text }]}>bloom</Text></View><View style={[styles.topBadge, { borderColor: dark ? '#48513E' : '#DCE2D2' }]}><View style={styles.onlineDot} /><Text style={[styles.topBadgeText, { color: colors.secondary }]}>YOUR SPACE</Text></View></View>
        <Text style={[styles.heading, { color: colors.text }]}>Settings</Text>
        <Text style={[styles.intro, { color: colors.secondary }]}>A little more you. A little more balance.</Text>

        <Pressable onPress={() => Alert.alert(signedOut ? 'Welcome back' : 'Your profile', signedOut ? 'Sign in to sync your preferences across devices.' : 'Alex Morgan\nalex.morgan@gmail.com\n\nYour personal space for a little daily growth.', signedOut ? [{ text: 'Cancel', style: 'cancel' }, { text: 'Sign in', onPress: () => setSignedOut(false) }] : [{ text: 'Done' }])} style={[styles.profile, { backgroundColor: colors.card }]} accessibilityRole="button" accessibilityLabel="View your profile">
          <View style={styles.avatar}><Text style={styles.avatarText}>{signedOut ? '?' : 'AM'}</Text><View style={[styles.avatarDot, { borderColor: colors.card }]}><Ionicons name="checkmark" size={9} color="white" /></View></View>
          <View style={styles.profileCopy}><Text style={[styles.profileName, { color: colors.text }]}>{signedOut ? 'Your space awaits' : 'Alex Morgan'}</Text><Text style={[styles.email, { color: colors.secondary }]}>{signedOut ? 'Sign in to keep growing' : 'alex.morgan@gmail.com'}</Text></View>
          <Ionicons name="chevron-forward" size={19} color="#A6ADA0" />
        </Pressable>

        <SectionLabel>MAKE IT YOURS</SectionLabel>
        <View style={[styles.card, { backgroundColor: colors.card }]}>
          <Row icon="notifications-outline" title="Push notifications" subtitle="A gentle nudge, when you need it" toggle={{ value: notifications, change: setNotifications }} />
          <Row icon="mail-outline" title="Weekly digest" subtitle="Your week, thoughtfully wrapped up" toggle={{ value: weeklyDigest, change: setWeeklyDigest }} />
          <Row icon="sunny-outline" title="Appearance" value={appearance} onPress={() => setAppearanceOpen(true)} last />
        </View>

        <SectionLabel>ROOM TO GROW</SectionLabel>
        <Pressable onPress={() => setPlanOpen(true)} style={styles.subscription} accessibilityRole="button" accessibilityLabel="Explore Bloom Plus subscription">
          <View style={styles.plusTop}><View style={styles.plusLabel}><Ionicons name="sparkles" size={17} color="#DCE8BD" /><Text style={styles.plusLabelText}>BLOOM PLUS</Text></View><View style={styles.planBadge}><Text style={styles.planBadgeText}>Free plan</Text></View></View>
          <Text style={styles.plusHeading}>Good things take a little space.</Text>
          <Text style={styles.plusSubtitle}>Unlock more ways to find your everyday calm.</Text>
          <View style={styles.plusBottom}><Text style={styles.exploreText}>Explore Plus</Text><View style={styles.arrowCircle}><Ionicons name="arrow-forward" size={17} color="#314531" /></View></View>
          <View pointerEvents="none" style={styles.decorCircle} /><View pointerEvents="none" style={styles.decorCircleSmall} />
        </Pressable>

        <SectionLabel>THE ESSENTIALS</SectionLabel>
        <View style={[styles.card, { backgroundColor: colors.card }]}>
          <Row icon="person-outline" title="Account & security" onPress={() => Alert.alert('Account & security', 'Your account is protected.\n\nEmail: alex.morgan@gmail.com\nPassword: Last updated September 24, 2026', [{ text: 'Close', style: 'cancel' }, { text: 'Reset password', onPress: () => Alert.alert('Check your inbox', 'A password reset link has been sent to alex.morgan@gmail.com.') }])} />
          <Row icon="help-circle-outline" title="Help & support" onPress={() => Alert.alert('A little help, whenever you need it', 'For questions about your account, daily practices, or subscriptions, reach us at hello@bloom.example.\n\nWe typically reply within 1–2 business days.')} />
          <Row icon="shield-checkmark-outline" title="Privacy & terms" onPress={() => Alert.alert('Your space stays yours', 'Your personal entries are private. We do not sell your personal information. You can request a copy or deletion of your data by contacting privacy@bloom.example.\n\nBloom is a wellbeing companion, not a substitute for professional care.')} last />
        </View>
        <Pressable onPress={() => signedOut ? setSignedOut(false) : Alert.alert('Sign out of Bloom?', 'Your preferences will stay right here for when you return.', [{ text: 'Stay here', style: 'cancel' }, { text: 'Sign out', style: 'destructive', onPress: () => setSignedOut(true) }])} style={styles.signOut} accessibilityRole="button"><Ionicons name={signedOut ? 'log-in-outline' : 'log-out-outline'} size={18} color="#8C746A" /><Text style={styles.signOutText}>{signedOut ? 'Sign in' : 'Sign out'}</Text></Pressable>
        <View style={styles.footer}><Ionicons name="leaf-outline" size={13} color="#9EA892" /><Text style={[styles.footerText, { color: colors.secondary }]}>Made for a slower, better everyday.</Text><Text style={styles.version}>VERSION 2.8.0 · WITH CARE</Text></View>
      </ScrollView>

      <Modal visible={appearanceOpen} transparent animationType="slide" onRequestClose={() => setAppearanceOpen(false)}><View style={styles.modalWrap}><Pressable style={styles.scrim} onPress={() => setAppearanceOpen(false)} accessibilityLabel="Close appearance settings" /><View style={[styles.sheet, { backgroundColor: colors.card }]}><View style={styles.handle} /><Text style={[styles.sheetTitle, { color: colors.text }]}>Your kind of light</Text><Text style={[styles.sheetDescription, { color: colors.secondary }]}>Choose how Bloom feels on your screen.</Text>{(['Light', 'Dark', 'System'] as Appearance[]).map(option => <Pressable key={option} onPress={() => { setAppearance(option); setAppearanceOpen(false); }} accessibilityRole="radio" accessibilityState={{ checked: appearance === option }} style={[styles.choice, { borderColor: colors.line }]}><Ionicons name={option === 'Light' ? 'sunny-outline' : option === 'Dark' ? 'moon-outline' : 'phone-portrait-outline'} size={21} color={colors.text} /><Text style={[styles.choiceText, { color: colors.text }]}>{option}</Text><Ionicons name={appearance === option ? 'radio-button-on' : 'radio-button-off'} size={23} color="#7A925C" /></Pressable>)}</View></View></Modal>
      <Modal visible={planOpen} transparent animationType="slide" onRequestClose={() => setPlanOpen(false)}><View style={styles.modalWrap}><Pressable style={styles.scrim} onPress={() => setPlanOpen(false)} accessibilityLabel="Close subscription details" /><View style={[styles.sheet, { backgroundColor: colors.card }]}><View style={styles.handle} /><View style={styles.sheetTitleRow}><Text style={[styles.sheetTitle, { color: colors.text }]}>A little more Bloom.</Text><Pressable accessibilityRole="button" accessibilityLabel="Close" onPress={() => setPlanOpen(false)}><Ionicons name="close" size={25} color={colors.text} /></Pressable></View><Text style={[styles.sheetDescription, { color: colors.secondary }]}>Unlimited guided practices, personal insights, and a little more room to grow.</Text>{[true, false].map(isAnnual => <Pressable key={String(isAnnual)} onPress={() => setAnnual(isAnnual)} style={[styles.choice, { borderColor: annual === isAnnual ? '#7A925C' : colors.line }]} accessibilityRole="radio" accessibilityState={{ checked: annual === isAnnual }}><View style={styles.rowCopy}><Text style={[styles.rowTitle, { color: colors.text }]}>{isAnnual ? 'Yearly · $39.99 / year' : 'Monthly · $5.99 / month'}</Text><Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{isAnnual ? 'A year of growth. Save 44%.' : 'A little space, one month at a time.'}</Text></View><Ionicons name={annual === isAnnual ? 'radio-button-on' : 'radio-button-off'} size={23} color="#7A925C" /></Pressable>)}<Pressable style={styles.subscribeButton} onPress={() => Alert.alert('You’re on the list', 'This preview does not process payments. Your free plan remains active and you have not been charged.')} accessibilityRole="button"><Text style={styles.subscribeText}>Continue with {annual ? 'yearly' : 'monthly'}</Text><Ionicons name="arrow-forward" size={19} color="white" /></Pressable><Text style={[styles.billingNote, { color: colors.secondary }]}>Renews automatically. Cancel anytime in your store settings.</Text></View></View></Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1 },
  content: { paddingHorizontal: 24, paddingTop: 18, paddingBottom: 16, maxWidth: 600, width: '100%', alignSelf: 'center' },
  topLine: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 30 },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  brandMark: { width: 27, height: 27, borderRadius: 10, backgroundColor: '#758A60', alignItems: 'center', justifyContent: 'center' },
  brandName: { fontSize: 23, fontWeight: '600', letterSpacing: -1 },
  topBadge: { flexDirection: 'row', alignItems: 'center', gap: 6, borderWidth: 1, borderRadius: 20, paddingHorizontal: 10, paddingVertical: 6 },
  onlineDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: '#8E9F71' },
  topBadgeText: { fontSize: 8, fontWeight: '600', letterSpacing: 1.4 },
  heading: { fontSize: 37, fontWeight: '600', letterSpacing: -1.5, lineHeight: 44 },
  intro: { fontSize: 13, marginTop: 6, lineHeight: 20 },
  profile: { flexDirection: 'row', alignItems: 'center', padding: 17, borderRadius: 18, marginTop: 24, gap: 13 },
  avatar: { width: 48, height: 48, borderRadius: 24, backgroundColor: '#ECE8DA', alignItems: 'center', justifyContent: 'center' },
  avatarText: { fontSize: 17, fontWeight: '500', color: '#7C8065', letterSpacing: -0.7 },
  avatarDot: { position: 'absolute', right: -1, bottom: 0, height: 16, width: 16, borderRadius: 8, borderWidth: 2, backgroundColor: '#8B9B71', alignItems: 'center', justifyContent: 'center' },
  profileCopy: { flex: 1, gap: 5 },
  profileName: { fontSize: 16, fontWeight: '600', letterSpacing: -0.3 },
  email: { fontSize: 11.5 },
  sectionLabel: { fontSize: 9, fontWeight: '600', letterSpacing: 1.8, marginTop: 25, marginBottom: 11, marginLeft: 3 },
  card: { borderRadius: 17, paddingHorizontal: 14, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, minHeight: 64 },
  iconBox: { width: 34, height: 34, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  rowBody: { flex: 1, minHeight: 64, flexDirection: 'row', alignItems: 'center', gap: 8, paddingVertical: 12 },
  rowCopy: { flex: 1 },
  rowTitle: { fontSize: 13, fontWeight: '500', letterSpacing: -0.2 },
  rowSubtitle: { fontSize: 9.5, marginTop: 5, lineHeight: 14 },
  rowEnd: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  rowValue: { fontSize: 11 },
  subscription: { backgroundColor: '#344B39', padding: 19, borderRadius: 18, overflow: 'hidden' },
  plusTop: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', zIndex: 1 },
  plusLabel: { flexDirection: 'row', gap: 7, alignItems: 'center' },
  plusLabelText: { color: '#DCE8BD', fontSize: 9, fontWeight: '600', letterSpacing: 1.6 },
  planBadge: { paddingVertical: 5, paddingHorizontal: 9, backgroundColor: '#4A6049', borderRadius: 20 },
  planBadgeText: { color: '#DEE5D3', fontSize: 9 },
  plusHeading: { color: '#F8F7E9', fontSize: 18, fontWeight: '500', letterSpacing: -0.6, marginTop: 17, zIndex: 1 },
  plusSubtitle: { color: '#B5C2AC', fontSize: 10.5, marginTop: 7, lineHeight: 17, zIndex: 1 },
  plusBottom: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 15, zIndex: 1 },
  exploreText: { color: '#E3ECCB', fontSize: 11, fontWeight: '600' },
  arrowCircle: { width: 27, height: 27, borderRadius: 14, backgroundColor: '#DDE8C3', alignItems: 'center', justifyContent: 'center' },
  decorCircle: { position: 'absolute', width: 175, height: 175, borderRadius: 88, borderWidth: 1, borderColor: '#53664A', right: -75, bottom: -90, transform: [{ scaleX: 1.7 }] },
  decorCircleSmall: { position: 'absolute', width: 175, height: 175, borderRadius: 88, borderWidth: 1, borderColor: '#53664A', right: -50, bottom: -110, transform: [{ scaleX: 1.7 }] },
  signOut: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 7, paddingVertical: 22 },
  signOutText: { fontSize: 12, fontWeight: '500', color: '#8C746A' },
  footer: { alignItems: 'center', gap: 7, paddingTop: 1, paddingBottom: 5 },
  footerText: { fontSize: 10 },
  version: { color: '#A9ADA2', fontSize: 7, letterSpacing: 1.5, marginTop: 3 },
  modalWrap: { flex: 1, justifyContent: 'flex-end' },
  scrim: { position: 'absolute', top: 0, bottom: 0, left: 0, right: 0, backgroundColor: '#15211780' },
  sheet: { borderTopLeftRadius: 28, borderTopRightRadius: 28, padding: 26, paddingBottom: 45 },
  handle: { width: 35, height: 4, borderRadius: 2, backgroundColor: '#CFD4C9', alignSelf: 'center', marginBottom: 25 },
  sheetTitle: { fontSize: 25, fontWeight: '600', letterSpacing: -0.8 },
  sheetTitleRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  sheetDescription: { fontSize: 13, lineHeight: 20, marginTop: 10, marginBottom: 21 },
  choice: { flexDirection: 'row', alignItems: 'center', gap: 13, borderWidth: 1, borderRadius: 14, padding: 17, marginBottom: 10 },
  choiceText: { flex: 1, fontSize: 15 },
  subscribeButton: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', backgroundColor: '#526D45', borderRadius: 14, padding: 18, marginTop: 10 },
  subscribeText: { color: '#FFFFFF', fontWeight: '600', fontSize: 14 },
  billingNote: { textAlign: 'center', fontSize: 10, lineHeight: 16, marginTop: 15 },
});
