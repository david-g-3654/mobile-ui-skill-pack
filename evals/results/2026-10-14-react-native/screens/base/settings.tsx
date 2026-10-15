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
} from 'react-native';
import { Stack } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';
import { StatusBar } from 'expo-status-bar';

type IconName = React.ComponentProps<typeof Ionicons>['name'];
type ThemePref = 'system' | 'light' | 'dark';
type TextSize = 'Small' | 'Default' | 'Large';

const USER = {
  name: 'Maya Lindqvist',
  email: 'maya.lindqvist@fastmail.com',
  initials: 'ML',
  memberSince: 'March 2023',
};

const SUBSCRIPTION = {
  plan: 'Pro Annual',
  price: '$59.99 / year',
  renews: 'Renews Jan 18, 2027',
  storageUsedGb: 38.4,
  storageTotalGb: 100,
};

const ACCENTS = ['#4F46E5', '#0EA5E9', '#10B981', '#F59E0B', '#EF4444', '#EC4899'];

const light = {
  bg: '#F2F2F7',
  card: '#FFFFFF',
  text: '#111827',
  sub: '#6B7280',
  border: '#E5E7EB',
  muted: '#F3F4F6',
  danger: '#DC2626',
};
const dark = {
  bg: '#000000',
  card: '#1C1C1E',
  text: '#F9FAFB',
  sub: '#9CA3AF',
  border: '#2C2C2E',
  muted: '#2C2C2E',
  danger: '#F87171',
};
type Palette = typeof light;

function tap() {
  if (Platform.OS !== 'web') {
    Haptics.selectionAsync().catch(() => {});
  }
}

export default function SettingsScreen() {
  const system = useColorScheme();
  const insets = useSafeAreaInsets();

  const [themePref, setThemePref] = useState<ThemePref>('system');
  const [accent, setAccent] = useState(ACCENTS[0]);
  const [textSize, setTextSize] = useState<TextSize>('Default');
  const [reduceMotion, setReduceMotion] = useState(false);

  const [pushEnabled, setPushEnabled] = useState(true);
  const [notif, setNotif] = useState({
    messages: true,
    mentions: true,
    reminders: false,
    product: false,
  });
  const [emailDigest, setEmailDigest] = useState(true);
  const [quietHours, setQuietHours] = useState(true);

  const [biometrics, setBiometrics] = useState(true);

  const isDark = themePref === 'system' ? system === 'dark' : themePref === 'dark';
  const c: Palette = isDark ? dark : light;
  const s = useMemo(() => makeStyles(c), [c]);

  const storagePct = SUBSCRIPTION.storageUsedGb / SUBSCRIPTION.storageTotalGb;

  const confirmSignOut = () => {
    Alert.alert('Sign out?', 'You can sign back in any time with your email.', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign Out', style: 'destructive', onPress: () => tap() },
    ]);
  };

  const confirmDelete = () => {
    if (Platform.OS !== 'web') {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning).catch(() => {});
    }
    Alert.alert(
      'Delete account?',
      'This permanently removes your projects, files and subscription history. This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete Account', style: 'destructive' },
      ],
    );
  };

  const info = (title: string, msg: string) => () => {
    tap();
    Alert.alert(title, msg);
  };

  return (
    <View style={[s.root]}>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <Stack.Screen
        options={{
          title: 'Settings',
          headerLargeTitle: true,
          headerTransparent: Platform.OS === 'ios',
          headerBlurEffect: isDark ? 'systemChromeMaterialDark' : 'systemChromeMaterialLight',
          headerShadowVisible: false,
          headerStyle: Platform.OS === 'ios' ? undefined : { backgroundColor: c.bg },
          headerLargeStyle: { backgroundColor: c.bg },
          headerTintColor: accent,
          headerTitleStyle: { color: c.text },
          headerLargeTitleStyle: { color: c.text },
        }}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        contentContainerStyle={{ paddingBottom: insets.bottom + 32, paddingTop: 8 }}
      >
        {/* Profile */}
        <Pressable
          onPress={info('Edit profile', 'Profile editing would open here.')}
          style={({ pressed }) => [s.card, s.profile, pressed && s.pressed]}
          accessibilityRole="button"
          accessibilityLabel={`${USER.name}, edit profile`}
        >
          <View style={[s.avatar, { backgroundColor: accent }]}>
            <Text style={s.avatarText}>{USER.initials}</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={s.profileName}>{USER.name}</Text>
            <Text style={s.sub} numberOfLines={1}>
              {USER.email}
            </Text>
            <Text style={[s.sub, { fontSize: 12, marginTop: 2 }]}>
              Member since {USER.memberSince}
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={18} color={c.sub} />
        </Pressable>

        {/* Subscription */}
        <SectionHeader title="Subscription" s={s} />
        <View style={s.subWrap}>
          <LinearGradient
            colors={[accent, isDark ? '#1E1B4B' : '#7C3AED']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={s.subCard}
          >
            <View style={s.rowBetween}>
              <View style={s.badge}>
                <Ionicons name="sparkles" size={12} color="#fff" />
                <Text style={s.badgeText}>PRO</Text>
              </View>
              <Text style={s.subPrice}>{SUBSCRIPTION.price}</Text>
            </View>
            <Text style={s.subPlan}>{SUBSCRIPTION.plan}</Text>
            <Text style={s.subRenew}>{SUBSCRIPTION.renews}</Text>

            <View style={{ marginTop: 16 }}>
              <View style={s.rowBetween}>
                <Text style={s.subMeta}>Cloud storage</Text>
                <Text style={s.subMeta}>
                  {SUBSCRIPTION.storageUsedGb} of {SUBSCRIPTION.storageTotalGb} GB
                </Text>
              </View>
              <View style={s.track}>
                <View style={[s.fill, { width: `${Math.round(storagePct * 100)}%` }]} />
              </View>
            </View>

            <View style={s.subActions}>
              <Pressable
                onPress={info('Manage plan', 'Opens plan options and billing.')}
                style={({ pressed }) => [s.subBtnPrimary, pressed && { opacity: 0.85 }]}
                accessibilityRole="button"
              >
                <Text style={[s.subBtnPrimaryText, { color: accent }]}>Manage Plan</Text>
              </Pressable>
              <Pressable
                onPress={info('Restore purchases', 'Your purchases are up to date.')}
                style={({ pressed }) => [s.subBtnGhost, pressed && { opacity: 0.7 }]}
                accessibilityRole="button"
              >
                <Text style={s.subBtnGhostText}>Restore</Text>
              </Pressable>
            </View>
          </LinearGradient>
        </View>
        <Group s={s}>
          <Row
            s={s}
            c={c}
            icon="card"
            iconBg="#10B981"
            label="Payment Method"
            value="Visa •• 4021"
            onPress={info('Payment method', 'Update your card on file.')}
          />
          <Row
            s={s}
            c={c}
            icon="receipt"
            iconBg="#F59E0B"
            label="Billing History"
            value="4 invoices"
            onPress={info('Billing history', 'Last charge: $59.99 on Jan 18, 2026.')}
            last
          />
        </Group>

        {/* Notifications */}
        <SectionHeader title="Notifications" s={s} />
        <Group s={s}>
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="notifications"
            iconBg="#EF4444"
            label="Push Notifications"
            value={pushEnabled}
            onChange={setPushEnabled}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="chatbubble"
            iconBg="#0EA5E9"
            label="Direct Messages"
            value={pushEnabled && notif.messages}
            disabled={!pushEnabled}
            onChange={(v) => setNotif((n) => ({ ...n, messages: v }))}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="at"
            iconBg="#8B5CF6"
            label="Mentions & Replies"
            value={pushEnabled && notif.mentions}
            disabled={!pushEnabled}
            onChange={(v) => setNotif((n) => ({ ...n, mentions: v }))}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="alarm"
            iconBg="#F97316"
            label="Task Reminders"
            value={pushEnabled && notif.reminders}
            disabled={!pushEnabled}
            onChange={(v) => setNotif((n) => ({ ...n, reminders: v }))}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="megaphone"
            iconBg="#64748B"
            label="Product Updates"
            value={pushEnabled && notif.product}
            disabled={!pushEnabled}
            onChange={(v) => setNotif((n) => ({ ...n, product: v }))}
            last
          />
        </Group>
        <Group s={s} style={{ marginTop: 12 }}>
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="moon"
            iconBg="#4F46E5"
            label="Quiet Hours"
            sublabel="10:00 PM – 7:00 AM"
            value={quietHours}
            onChange={setQuietHours}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="mail"
            iconBg="#0284C7"
            label="Weekly Email Digest"
            sublabel="Sent Mondays at 9:00 AM"
            value={emailDigest}
            onChange={setEmailDigest}
            last
          />
        </Group>
        {!pushEnabled && (
          <Text style={s.footer}>
            Push notifications are off. You'll still see activity in your inbox.
          </Text>
        )}

        {/* Appearance */}
        <SectionHeader title="Appearance" s={s} />
        <Group s={s}>
          <View style={s.blockRow}>
            <Text style={s.label}>Theme</Text>
            <Segmented
              s={s}
              accent={accent}
              options={[
                { key: 'system', label: 'System', icon: 'phone-portrait-outline' },
                { key: 'light', label: 'Light', icon: 'sunny-outline' },
                { key: 'dark', label: 'Dark', icon: 'moon-outline' },
              ]}
              value={themePref}
              onChange={(v) => setThemePref(v as ThemePref)}
              c={c}
            />
          </View>
          <View style={s.divider} />
          <View style={s.blockRow}>
            <Text style={s.label}>Accent Color</Text>
            <View style={s.swatches}>
              {ACCENTS.map((col) => {
                const selected = col === accent;
                return (
                  <Pressable
                    key={col}
                    onPress={() => {
                      tap();
                      setAccent(col);
                    }}
                    hitSlop={6}
                    accessibilityRole="radio"
                    accessibilityState={{ selected }}
                    accessibilityLabel={`Accent color ${col}`}
                    style={[s.swatchRing, selected && { borderColor: col }]}
                  >
                    <View style={[s.swatch, { backgroundColor: col }]}>
                      {selected && <Ionicons name="checkmark" size={16} color="#fff" />}
                    </View>
                  </Pressable>
                );
              })}
            </View>
          </View>
          <View style={s.divider} />
          <View style={s.blockRow}>
            <Text style={s.label}>Text Size</Text>
            <Segmented
              s={s}
              accent={accent}
              options={[
                { key: 'Small', label: 'Small' },
                { key: 'Default', label: 'Default' },
                { key: 'Large', label: 'Large' },
              ]}
              value={textSize}
              onChange={(v) => setTextSize(v as TextSize)}
              c={c}
            />
            <Text
              style={[
                s.sub,
                { marginTop: 10, fontSize: textSize === 'Small' ? 13 : textSize === 'Large' ? 18 : 15 },
              ]}
            >
              The quick brown fox jumps over the lazy dog.
            </Text>
          </View>
          <View style={s.divider} />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="sparkles-outline"
            iconBg="#EC4899"
            label="Reduce Motion"
            value={reduceMotion}
            onChange={setReduceMotion}
            last
          />
        </Group>

        {/* Account */}
        <SectionHeader title="Account" s={s} />
        <Group s={s}>
          <Row
            s={s}
            c={c}
            icon="mail-outline"
            iconBg="#0EA5E9"
            label="Email"
            value={USER.email}
            onPress={info('Change email', 'A verification link will be sent to your new address.')}
          />
          <Row
            s={s}
            c={c}
            icon="key-outline"
            iconBg="#6366F1"
            label="Password"
            value="Changed 3 mo ago"
            onPress={info('Change password', 'Password change would open here.')}
          />
          <ToggleRow
            s={s}
            c={c}
            accent={accent}
            icon="finger-print"
            iconBg="#10B981"
            label={Platform.OS === 'ios' ? 'Unlock with Face ID' : 'Biometric Unlock'}
            value={biometrics}
            onChange={setBiometrics}
          />
          <Row
            s={s}
            c={c}
            icon="link-outline"
            iconBg="#64748B"
            label="Connected Accounts"
            value="Google, Apple"
            onPress={info('Connected accounts', 'Google and Apple are linked to this account.')}
          />
          <Row
            s={s}
            c={c}
            icon="download-outline"
            iconBg="#F59E0B"
            label="Export My Data"
            onPress={info('Export requested', "We'll email a download link within 24 hours.")}
            last
          />
        </Group>

        <Group s={s} style={{ marginTop: 24 }}>
          <Pressable
            onPress={confirmSignOut}
            style={({ pressed }) => [s.centerRow, pressed && s.pressed]}
            accessibilityRole="button"
          >
            <Text style={[s.centerText, { color: accent }]}>Sign Out</Text>
          </Pressable>
        </Group>
        <Group s={s} style={{ marginTop: 12 }}>
          <Pressable
            onPress={confirmDelete}
            style={({ pressed }) => [s.centerRow, pressed && s.pressed]}
            accessibilityRole="button"
          >
            <Text style={[s.centerText, { color: c.danger }]}>Delete Account</Text>
          </Pressable>
        </Group>

        <Text style={[s.footer, { textAlign: 'center', marginTop: 20 }]}>
          Version 4.12.0 (2081)
        </Text>
      </ScrollView>
    </View>
  );
}

type Styles = ReturnType<typeof makeStyles>;

function SectionHeader({ title, s }: { title: string; s: Styles }) {
  return (
    <Text style={s.sectionHeader} accessibilityRole="header">
      {title.toUpperCase()}
    </Text>
  );
}

function Group({
  children,
  s,
  style,
}: {
  children: React.ReactNode;
  s: Styles;
  style?: object;
}) {
  return <View style={[s.card, s.group, style]}>{children}</View>;
}

function IconTile({ name, bg }: { name: IconName; bg: string }) {
  return (
    <View style={[tileStyles.tile, { backgroundColor: bg }]}>
      <Ionicons name={name} size={17} color="#fff" />
    </View>
  );
}

function Row({
  s,
  c,
  icon,
  iconBg,
  label,
  value,
  onPress,
  last,
}: {
  s: Styles;
  c: Palette;
  icon: IconName;
  iconBg: string;
  label: string;
  value?: string;
  onPress: () => void;
  last?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [s.row, pressed && s.pressed]}
      accessibilityRole="button"
      accessibilityLabel={value ? `${label}, ${value}` : label}
    >
      <IconTile name={icon} bg={iconBg} />
      <View style={[s.rowBody, !last && s.rowBorder]}>
        <Text style={s.label} numberOfLines={1}>
          {label}
        </Text>
        <View style={s.rowRight}>
          {value ? (
            <Text style={s.value} numberOfLines={1}>
              {value}
            </Text>
          ) : null}
          <Ionicons name="chevron-forward" size={16} color={c.sub} />
        </View>
      </View>
    </Pressable>
  );
}

function ToggleRow({
  s,
  c,
  accent,
  icon,
  iconBg,
  label,
  sublabel,
  value,
  onChange,
  disabled,
  last,
}: {
  s: Styles;
  c: Palette;
  accent: string;
  icon: IconName;
  iconBg: string;
  label: string;
  sublabel?: string;
  value: boolean;
  onChange: (v: boolean) => void;
  disabled?: boolean;
  last?: boolean;
}) {
  return (
    <View style={[s.row, disabled && { opacity: 0.45 }]}>
      <IconTile name={icon} bg={iconBg} />
      <View style={[s.rowBody, !last && s.rowBorder]}>
        <View style={{ flex: 1, paddingRight: 8 }}>
          <Text style={s.label}>{label}</Text>
          {sublabel ? <Text style={[s.sub, { fontSize: 13, marginTop: 1 }]}>{sublabel}</Text> : null}
        </View>
        <Switch
          value={value}
          disabled={disabled}
          onValueChange={(v) => {
            tap();
            onChange(v);
          }}
          trackColor={{ true: accent, false: c.muted }}
          thumbColor={Platform.OS === 'android' ? '#fff' : undefined}
          ios_backgroundColor={c.muted}
          accessibilityLabel={label}
        />
      </View>
    </View>
  );
}

function Segmented({
  s,
  c,
  accent,
  options,
  value,
  onChange,
}: {
  s: Styles;
  c: Palette;
  accent: string;
  options: { key: string; label: string; icon?: IconName }[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <View style={s.segment} accessibilityRole="radiogroup">
      {options.map((o) => {
        const active = o.key === value;
        return (
          <Pressable
            key={o.key}
            onPress={() => {
              tap();
              onChange(o.key);
            }}
            style={[s.segItem, active && s.segItemActive]}
            accessibilityRole="radio"
            accessibilityState={{ selected: active }}
          >
            {o.icon ? (
              <Ionicons name={o.icon} size={15} color={active ? accent : c.sub} />
            ) : null}
            <Text style={[s.segText, active && { color: c.text, fontWeight: '600' }]}>
              {o.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const tileStyles = StyleSheet.create({
  tile: {
    width: 30,
    height: 30,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
});

function makeStyles(c: Palette) {
  return StyleSheet.create({
    root: { flex: 1, backgroundColor: c.bg },
    card: {
      backgroundColor: c.card,
      borderRadius: 14,
      marginHorizontal: 16,
    },
    group: { overflow: 'hidden' },
    pressed: { opacity: 0.6 },
    profile: {
      flexDirection: 'row',
      alignItems: 'center',
      padding: 16,
      gap: 14,
    },
    avatar: {
      width: 58,
      height: 58,
      borderRadius: 29,
      alignItems: 'center',
      justifyContent: 'center',
    },
    avatarText: { color: '#fff', fontSize: 22, fontWeight: '700' },
    profileName: { color: c.text, fontSize: 19, fontWeight: '600', marginBottom: 2 },
    sub: { color: c.sub, fontSize: 14 },
    sectionHeader: {
      color: c.sub,
      fontSize: 13,
      fontWeight: '500',
      letterSpacing: 0.4,
      marginTop: 28,
      marginBottom: 8,
      marginHorizontal: 32,
    },
    subWrap: { marginHorizontal: 16, marginBottom: 12 },
    subCard: { borderRadius: 18, padding: 18 },
    rowBetween: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    badge: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: 4,
      backgroundColor: 'rgba(255,255,255,0.22)',
      paddingHorizontal: 8,
      paddingVertical: 3,
      borderRadius: 999,
    },
    badgeText: { color: '#fff', fontSize: 11, fontWeight: '800', letterSpacing: 1 },
    subPrice: { color: 'rgba(255,255,255,0.9)', fontSize: 13, fontWeight: '600' },
    subPlan: { color: '#fff', fontSize: 24, fontWeight: '700', marginTop: 12 },
    subRenew: { color: 'rgba(255,255,255,0.8)', fontSize: 14, marginTop: 2 },
    subMeta: { color: 'rgba(255,255,255,0.85)', fontSize: 12, fontWeight: '500' },
    track: {
      height: 6,
      borderRadius: 3,
      backgroundColor: 'rgba(255,255,255,0.25)',
      marginTop: 6,
      overflow: 'hidden',
    },
    fill: { height: 6, borderRadius: 3, backgroundColor: '#fff' },
    subActions: { flexDirection: 'row', gap: 10, marginTop: 18 },
    subBtnPrimary: {
      flex: 1,
      backgroundColor: '#fff',
      borderRadius: 12,
      paddingVertical: 12,
      alignItems: 'center',
    },
    subBtnPrimaryText: { fontSize: 15, fontWeight: '700' },
    subBtnGhost: {
      paddingHorizontal: 18,
      borderRadius: 12,
      paddingVertical: 12,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.5)',
    },
    subBtnGhostText: { color: '#fff', fontSize: 15, fontWeight: '600' },
    row: { flexDirection: 'row', alignItems: 'center', paddingLeft: 16, minHeight: 50 },
    rowBody: {
      flex: 1,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      paddingRight: 16,
      paddingVertical: 10,
      minHeight: 50,
    },
    rowBorder: { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: c.border },
    rowRight: { flexDirection: 'row', alignItems: 'center', gap: 4, flexShrink: 1, marginLeft: 12 },
    label: { color: c.text, fontSize: 16 },
    value: { color: c.sub, fontSize: 15, flexShrink: 1 },
    divider: { height: StyleSheet.hairlineWidth, backgroundColor: c.border, marginLeft: 16 },
    blockRow: { padding: 16, gap: 10 },
    segment: {
      flexDirection: 'row',
      backgroundColor: c.muted,
      borderRadius: 10,
      padding: 3,
    },
    segItem: {
      flex: 1,
      flexDirection: 'row',
      gap: 5,
      alignItems: 'center',
      justifyContent: 'center',
      paddingVertical: 8,
      borderRadius: 8,
    },
    segItemActive: {
      backgroundColor: c.card,
      shadowColor: '#000',
      shadowOpacity: 0.12,
      shadowRadius: 3,
      shadowOffset: { width: 0, height: 1 },
      elevation: 2,
    },
    segText: { color: c.sub, fontSize: 14, fontWeight: '500' },
    swatches: { flexDirection: 'row', gap: 10, flexWrap: 'wrap' },
    swatchRing: {
      padding: 3,
      borderRadius: 22,
      borderWidth: 2,
      borderColor: 'transparent',
    },
    swatch: {
      width: 32,
      height: 32,
      borderRadius: 16,
      alignItems: 'center',
      justifyContent: 'center',
    },
    centerRow: { paddingVertical: 15, alignItems: 'center' },
    centerText: { fontSize: 16, fontWeight: '600' },
    footer: { color: c.sub, fontSize: 13, marginHorizontal: 32, marginTop: 8 },
  });
}
