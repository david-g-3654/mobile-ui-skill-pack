import React, { useMemo, useState } from 'react';
import {
  Alert,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
  useColorScheme,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';

type IconName = React.ComponentProps<typeof Ionicons>['name'];
type ThemePref = 'system' | 'light' | 'dark';

const USER = {
  name: 'Maya Lindqvist',
  email: 'maya.lindqvist@icloud.com',
  initials: 'ML',
  memberSince: 'March 2023',
};

const PLAN = {
  name: 'Pro Annual',
  price: '$59.99 / year',
  renews: 'Renews Feb 14, 2027',
  storageUsed: 38.4,
  storageTotal: 100,
};

const ACCENTS = ['#0A84FF', '#5E5CE6', '#FF375F', '#FF9F0A', '#30D158'] as const;

function palette(dark: boolean) {
  return dark
    ? {
        bg: '#000000',
        card: '#1C1C1E',
        text: '#FFFFFF',
        secondary: 'rgba(235,235,245,0.6)',
        tertiary: 'rgba(235,235,245,0.3)',
        separator: 'rgba(84,84,88,0.65)',
        pressed: '#2C2C2E',
        fill: 'rgba(118,118,128,0.24)',
        segment: '#636366',
        destructive: '#FF453A',
      }
    : {
        bg: '#F2F2F7',
        card: '#FFFFFF',
        text: '#000000',
        secondary: 'rgba(60,60,67,0.6)',
        tertiary: 'rgba(60,60,67,0.3)',
        separator: 'rgba(60,60,67,0.29)',
        pressed: '#E5E5EA',
        fill: 'rgba(118,118,128,0.12)',
        segment: '#FFFFFF',
        destructive: '#FF3B30',
      };
}

type Colors = ReturnType<typeof palette>;

function tap() {
  Haptics.selectionAsync().catch(() => {});
}

function Section({
  title,
  footer,
  colors,
  children,
}: {
  title?: string;
  footer?: string;
  colors: Colors;
  children: React.ReactNode;
}) {
  const items = React.Children.toArray(children).filter(Boolean);
  return (
    <View style={styles.section}>
      {title ? (
        <Text style={[styles.sectionTitle, { color: colors.secondary }]} accessibilityRole="header">
          {title}
        </Text>
      ) : null}
      <View style={[styles.card, { backgroundColor: colors.card }]}>
        {items.map((child, i) => (
          <View key={i}>
            {child}
            {i < items.length - 1 ? (
              <View
                style={[styles.separator, { backgroundColor: colors.separator }]}
              />
            ) : null}
          </View>
        ))}
      </View>
      {footer ? (
        <Text style={[styles.sectionFooter, { color: colors.secondary }]}>{footer}</Text>
      ) : null}
    </View>
  );
}

function IconTile({ name, color }: { name: IconName; color: string }) {
  return (
    <View style={[styles.iconTile, { backgroundColor: color }]}>
      <Ionicons name={name} size={18} color="#FFFFFF" />
    </View>
  );
}

function Row({
  icon,
  iconColor,
  label,
  subtitle,
  value,
  colors,
  stacked,
  onPress,
  right,
  destructive,
  accessibilityHint,
}: {
  icon?: IconName;
  iconColor?: string;
  label: string;
  subtitle?: string;
  value?: string;
  colors: Colors;
  stacked: boolean;
  onPress?: () => void;
  right?: React.ReactNode;
  destructive?: boolean;
  accessibilityHint?: string;
}) {
  const content = (pressed: boolean) => (
    <View
      style={[
        styles.row,
        { backgroundColor: pressed ? colors.pressed : 'transparent' },
      ]}
    >
      {icon && iconColor ? <IconTile name={icon} color={iconColor} /> : null}
      <View style={[styles.rowBody, stacked && styles.rowBodyStacked]}>
        <View style={styles.rowTextWrap}>
          <Text
            style={[
              styles.rowLabel,
              { color: destructive ? colors.destructive : colors.text },
            ]}
          >
            {label}
          </Text>
          {subtitle ? (
            <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{subtitle}</Text>
          ) : null}
          {stacked && value ? (
            <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{value}</Text>
          ) : null}
        </View>
        {!stacked && value ? (
          <Text
            style={[styles.rowValue, { color: colors.secondary }]}
            numberOfLines={1}
          >
            {value}
          </Text>
        ) : null}
      </View>
      {right}
      {onPress && !right ? (
        <Ionicons name="chevron-forward" size={18} color={colors.tertiary} />
      ) : null}
    </View>
  );

  if (!onPress) return content(false);
  return (
    <Pressable
      onPress={() => {
        tap();
        onPress();
      }}
      accessibilityRole="button"
      accessibilityLabel={value ? `${label}, ${value}` : label}
      accessibilityHint={accessibilityHint}
    >
      {({ pressed }) => content(pressed)}
    </Pressable>
  );
}

function ToggleRow({
  icon,
  iconColor,
  label,
  subtitle,
  value,
  onChange,
  colors,
  accent,
  disabled,
}: {
  icon: IconName;
  iconColor: string;
  label: string;
  subtitle?: string;
  value: boolean;
  onChange: (v: boolean) => void;
  colors: Colors;
  accent: string;
  disabled?: boolean;
}) {
  return (
    <View
      style={[styles.row, disabled && { opacity: 0.45 }]}
      accessible
      accessibilityRole="switch"
      accessibilityLabel={label}
      accessibilityHint={subtitle}
      accessibilityState={{ checked: value, disabled }}
      accessibilityActions={[{ name: 'activate' }]}
      onAccessibilityAction={() => !disabled && onChange(!value)}
    >
      <IconTile name={icon} color={iconColor} />
      <View style={styles.rowTextWrap}>
        <Text style={[styles.rowLabel, { color: colors.text }]}>{label}</Text>
        {subtitle ? (
          <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{subtitle}</Text>
        ) : null}
      </View>
      <Switch
        value={value}
        disabled={disabled}
        onValueChange={(v) => {
          tap();
          onChange(v);
        }}
        trackColor={{ true: Platform.OS === 'ios' ? '#34C759' : accent }}
        importantForAccessibility="no-hide-descendants"
      />
    </View>
  );
}

function Segmented({
  options,
  value,
  onChange,
  colors,
  stacked,
}: {
  options: { key: ThemePref; label: string; icon: IconName }[];
  value: ThemePref;
  onChange: (v: ThemePref) => void;
  colors: Colors;
  stacked: boolean;
}) {
  return (
    <View
      style={[
        styles.segmented,
        { backgroundColor: colors.fill, flexDirection: stacked ? 'column' : 'row' },
      ]}
      accessibilityRole="radiogroup"
    >
      {options.map((o) => {
        const selected = o.key === value;
        return (
          <Pressable
            key={o.key}
            onPress={() => {
              tap();
              onChange(o.key);
            }}
            accessibilityRole="radio"
            accessibilityState={{ selected }}
            accessibilityLabel={`${o.label} appearance`}
            style={[
              styles.segment,
              selected && [styles.segmentSelected, { backgroundColor: colors.segment }],
            ]}
          >
            <Ionicons name={o.icon} size={16} color={selected ? colors.text : colors.secondary} />
            <Text
              style={[
                styles.segmentLabel,
                { color: selected ? colors.text : colors.secondary },
                selected && { fontWeight: '600' },
              ]}
            >
              {o.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

export default function SettingsScreen() {
  const systemScheme = useColorScheme();
  const { fontScale } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const stacked = fontScale >= 1.35;

  const [themePref, setThemePref] = useState<ThemePref>('system');
  const [accent, setAccent] = useState<string>(ACCENTS[0]);
  const [notif, setNotif] = useState({
    push: true,
    mentions: true,
    reminders: true,
    weeklyDigest: false,
    productNews: false,
    sounds: true,
  });

  const dark = themePref === 'system' ? systemScheme === 'dark' : themePref === 'dark';
  const colors = useMemo(() => palette(dark), [dark]);
  const storagePct = PLAN.storageUsed / PLAN.storageTotal;

  const setN = (key: keyof typeof notif) => (v: boolean) =>
    setNotif((prev) => ({ ...prev, [key]: v }));

  const soon = (title: string) => Alert.alert(title, 'This would open the detail screen.');

  return (
    <>
      <Stack.Screen
        options={{
          title: 'Settings',
          headerLargeTitle: true,
          headerShadowVisible: false,
          headerLargeTitleShadowVisible: false,
          headerStyle: { backgroundColor: colors.bg },
          headerTitleStyle: { color: colors.text },
          headerLargeTitleStyle: { color: colors.text },
          headerTintColor: accent,
          contentStyle: { backgroundColor: colors.bg },
        }}
      />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <ScrollView
        style={{ flex: 1, backgroundColor: colors.bg }}
        contentInsetAdjustmentBehavior="automatic"
        contentContainerStyle={{ paddingBottom: insets.bottom + 32, paddingTop: 8 }}
      >
        {/* Profile */}
        <View style={styles.section}>
          <Pressable
            onPress={() => {
              tap();
              soon('Profile');
            }}
            accessibilityRole="button"
            accessibilityLabel={`${USER.name}, ${USER.email}. Edit profile`}
            style={({ pressed }) => [
              styles.card,
              styles.profile,
              { backgroundColor: pressed ? colors.pressed : colors.card },
            ]}
          >
            <LinearGradient
              colors={[accent, '#5E5CE6']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.avatar}
            >
              <Text style={styles.avatarText} maxFontSizeMultiplier={1.4}>
                {USER.initials}
              </Text>
            </LinearGradient>
            <View style={styles.rowTextWrap}>
              <Text style={[styles.profileName, { color: colors.text }]}>{USER.name}</Text>
              <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>{USER.email}</Text>
              <Text style={[styles.rowSubtitle, { color: colors.secondary }]}>
                Member since {USER.memberSince}
              </Text>
            </View>
            <Ionicons name="chevron-forward" size={18} color={colors.tertiary} />
          </Pressable>
        </View>

        {/* Subscription */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.secondary }]} accessibilityRole="header">
            Subscription
          </Text>
          <LinearGradient
            colors={dark ? ['#2A2560', '#1C1C1E'] : ['#5E5CE6', '#0A84FF']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={[styles.card, styles.planCard]}
          >
            <View style={styles.planHeader}>
              <View style={styles.planBadge}>
                <Ionicons name="sparkles" size={14} color="#FFFFFF" />
                <Text style={styles.planBadgeText} maxFontSizeMultiplier={1.6}>
                  ACTIVE
                </Text>
              </View>
            </View>
            <Text style={styles.planName} accessibilityRole="header">
              {PLAN.name}
            </Text>
            <Text style={styles.planMeta}>
              {PLAN.price} · {PLAN.renews}
            </Text>
            <View
              style={styles.storage}
              accessible
              accessibilityLabel={`Cloud storage: ${PLAN.storageUsed} of ${PLAN.storageTotal} gigabytes used`}
            >
              <View style={styles.storageLabels}>
                <Text style={styles.planMeta}>Cloud storage</Text>
                <Text style={styles.planMeta}>
                  {PLAN.storageUsed} GB of {PLAN.storageTotal} GB
                </Text>
              </View>
              <View style={styles.storageTrack}>
                <View style={[styles.storageFill, { width: `${storagePct * 100}%` }]} />
              </View>
            </View>
            <Pressable
              onPress={() => {
                tap();
                soon('Manage Subscription');
              }}
              accessibilityRole="button"
              style={({ pressed }) => [styles.planButton, pressed && { opacity: 0.8 }]}
            >
              <Text style={styles.planButtonText}>Manage Subscription</Text>
            </Pressable>
          </LinearGradient>
        </View>
        <Section colors={colors} footer="Purchases are billed through your App Store account.">
          <Row
            icon="card"
            iconColor="#30D158"
            label="Payment Method"
            value="Apple Pay"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Payment Method')}
          />
          <Row
            icon="receipt"
            iconColor="#8E8E93"
            label="Billing History"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Billing History')}
          />
          <Row
            icon="refresh"
            iconColor="#0A84FF"
            label="Restore Purchases"
            colors={colors}
            stacked={stacked}
            onPress={() => Alert.alert('Restore Purchases', 'Your purchases are up to date.')}
          />
        </Section>

        {/* Notifications */}
        <Section
          title="Notifications"
          colors={colors}
          footer="Quiet hours mute everything except reminders you mark as urgent."
        >
          <ToggleRow
            icon="notifications"
            iconColor="#FF3B30"
            label="Allow Notifications"
            value={notif.push}
            onChange={setN('push')}
            colors={colors}
            accent={accent}
          />
          <ToggleRow
            icon="at"
            iconColor="#0A84FF"
            label="Mentions & Replies"
            subtitle="When someone mentions you or replies to your note"
            value={notif.mentions}
            onChange={setN('mentions')}
            colors={colors}
            accent={accent}
            disabled={!notif.push}
          />
          <ToggleRow
            icon="alarm"
            iconColor="#FF9F0A"
            label="Reminders"
            value={notif.reminders}
            onChange={setN('reminders')}
            colors={colors}
            accent={accent}
            disabled={!notif.push}
          />
          <ToggleRow
            icon="newspaper"
            iconColor="#5E5CE6"
            label="Weekly Digest"
            subtitle="A Sunday summary of your activity"
            value={notif.weeklyDigest}
            onChange={setN('weeklyDigest')}
            colors={colors}
            accent={accent}
            disabled={!notif.push}
          />
          <ToggleRow
            icon="megaphone"
            iconColor="#FF2D55"
            label="Product Updates"
            value={notif.productNews}
            onChange={setN('productNews')}
            colors={colors}
            accent={accent}
            disabled={!notif.push}
          />
          <ToggleRow
            icon="volume-high"
            iconColor="#FF375F"
            label="Sounds & Haptics"
            value={notif.sounds}
            onChange={setN('sounds')}
            colors={colors}
            accent={accent}
            disabled={!notif.push}
          />
          <Row
            icon="moon"
            iconColor="#5856D6"
            label="Quiet Hours"
            value="10:00 PM – 7:00 AM"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Quiet Hours')}
          />
        </Section>

        {/* Appearance */}
        <Section title="Appearance" colors={colors}>
          <View style={styles.padded}>
            <Segmented
              options={[
                { key: 'system', label: 'System', icon: 'phone-portrait-outline' },
                { key: 'light', label: 'Light', icon: 'sunny-outline' },
                { key: 'dark', label: 'Dark', icon: 'moon-outline' },
              ]}
              value={themePref}
              onChange={setThemePref}
              colors={colors}
              stacked={stacked}
            />
          </View>
          <View style={styles.padded}>
            <Text style={[styles.rowLabel, { color: colors.text, marginBottom: 12 }]}>
              Accent Color
            </Text>
            <View style={styles.accentRow} accessibilityRole="radiogroup">
              {ACCENTS.map((c) => {
                const selected = c === accent;
                return (
                  <Pressable
                    key={c}
                    onPress={() => {
                      tap();
                      setAccent(c);
                    }}
                    accessibilityRole="radio"
                    accessibilityLabel={`Accent color ${c}`}
                    accessibilityState={{ selected }}
                    hitSlop={6}
                    style={[
                      styles.swatchRing,
                      { borderColor: selected ? c : 'transparent' },
                    ]}
                  >
                    <View style={[styles.swatch, { backgroundColor: c }]}>
                      {selected ? <Ionicons name="checkmark" size={18} color="#FFFFFF" /> : null}
                    </View>
                  </Pressable>
                );
              })}
            </View>
          </View>
          <Row
            icon="text"
            iconColor="#0A84FF"
            label="Text Size"
            value={`${Math.round(fontScale * 100)}%`}
            subtitle="Follows your system setting"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Text Size')}
          />
          <Row
            icon="apps"
            iconColor="#FF9F0A"
            label="App Icon"
            value="Classic"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('App Icon')}
          />
        </Section>

        {/* Account */}
        <Section title="Account" colors={colors}>
          <Row
            icon="mail"
            iconColor="#0A84FF"
            label="Email"
            value={USER.email}
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Email')}
          />
          <Row
            icon="key"
            iconColor="#8E8E93"
            label="Password & Security"
            value="2FA on"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Password & Security')}
          />
          <Row
            icon="laptop"
            iconColor="#34C759"
            label="Signed-In Devices"
            value="3"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Signed-In Devices')}
          />
          <Row
            icon="hand-left"
            iconColor="#5E5CE6"
            label="Privacy"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Privacy')}
          />
          <Row
            icon="download"
            iconColor="#30B0C7"
            label="Export My Data"
            colors={colors}
            stacked={stacked}
            onPress={() => soon('Export My Data')}
          />
        </Section>

        <Section colors={colors}>
          <Row
            label="Sign Out"
            colors={colors}
            stacked={stacked}
            destructive
            right={<View />}
            onPress={() =>
              Alert.alert('Sign out?', `You'll need to sign in again as ${USER.email}.`, [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Sign Out', style: 'destructive' },
              ])
            }
          />
          <Row
            label="Delete Account"
            colors={colors}
            stacked={stacked}
            destructive
            right={<View />}
            accessibilityHint="Permanently deletes your account and data"
            onPress={() => {
              Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning).catch(() => {});
              Alert.alert(
                'Delete account?',
                'This permanently removes your notes, files and subscription history. This cannot be undone.',
                [
                  { text: 'Cancel', style: 'cancel' },
                  { text: 'Delete', style: 'destructive' },
                ],
              );
            }}
          />
        </Section>

        <Text style={[styles.version, { color: colors.tertiary }]}>Version 4.2.1 (1187)</Text>
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  section: { marginHorizontal: 16, marginTop: 24 },
  sectionTitle: {
    fontSize: 13,
    textTransform: 'uppercase',
    letterSpacing: 0.3,
    marginLeft: 16,
    marginBottom: 7,
  },
  sectionFooter: { fontSize: 13, lineHeight: 18, marginTop: 7, marginHorizontal: 16 },
  card: { borderRadius: 12, overflow: 'hidden' },
  separator: { height: StyleSheet.hairlineWidth, marginLeft: 60 },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 48,
    paddingVertical: 10,
    paddingHorizontal: 16,
    gap: 12,
  },
  rowBody: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 8 },
  rowBodyStacked: { flexDirection: 'column', alignItems: 'flex-start' },
  rowTextWrap: { flex: 1 },
  rowLabel: { fontSize: 17 },
  rowSubtitle: { fontSize: 13, lineHeight: 18, marginTop: 2 },
  rowValue: { fontSize: 17, maxWidth: '55%', textAlign: 'right' },
  iconTile: {
    width: 30,
    height: 30,
    borderRadius: 7,
    alignItems: 'center',
    justifyContent: 'center',
  },
  padded: { paddingHorizontal: 16, paddingVertical: 14 },
  profile: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    gap: 14,
  },
  avatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: { color: '#FFFFFF', fontSize: 22, fontWeight: '600' },
  profileName: { fontSize: 20, fontWeight: '600' },
  planCard: { padding: 20, gap: 6 },
  planHeader: { flexDirection: 'row' },
  planBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: 'rgba(255,255,255,0.22)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 999,
  },
  planBadgeText: { color: '#FFFFFF', fontSize: 12, fontWeight: '700', letterSpacing: 0.6 },
  planName: { color: '#FFFFFF', fontSize: 26, fontWeight: '700', marginTop: 6 },
  planMeta: { color: 'rgba(255,255,255,0.85)', fontSize: 15 },
  storage: { marginTop: 10, gap: 8 },
  storageLabels: { flexDirection: 'row', justifyContent: 'space-between', flexWrap: 'wrap', gap: 4 },
  storageTrack: {
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(255,255,255,0.25)',
    overflow: 'hidden',
  },
  storageFill: { height: '100%', borderRadius: 3, backgroundColor: '#FFFFFF' },
  planButton: {
    marginTop: 14,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    minHeight: 48,
    paddingVertical: 12,
    paddingHorizontal: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  planButtonText: { color: '#3A36C9', fontSize: 17, fontWeight: '600', textAlign: 'center' },
  segmented: { borderRadius: 10, padding: 3, gap: 3 },
  segment: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    minHeight: 40,
    paddingVertical: 8,
    paddingHorizontal: 8,
    borderRadius: 8,
  },
  segmentSelected: {
    shadowColor: '#000000',
    shadowOpacity: 0.12,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  segmentLabel: { fontSize: 15 },
  accentRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 14 },
  swatchRing: { borderWidth: 2, borderRadius: 22, padding: 3 },
  swatch: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
  },
  version: { textAlign: 'center', fontSize: 13, marginTop: 28 },
});
