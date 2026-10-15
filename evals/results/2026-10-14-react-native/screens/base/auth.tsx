import React, { useMemo, useRef, useState } from 'react';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
  useColorScheme,
} from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { StatusBar } from 'expo-status-bar';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path, Circle } from 'react-native-svg';

type Provider = 'apple' | 'google' | 'email';
type Stage = 'choose' | 'sent';

const APP = {
  name: 'Fieldnote',
  tagline: 'Your notes, tasks and ideas — synced everywhere.',
  lastUsed: { provider: 'google' as Provider, email: 'maya.chen@gmail.com' },
  termsUrl: 'fieldnote.app/terms',
  privacyUrl: 'fieldnote.app/privacy',
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function palette(dark: boolean) {
  return dark
    ? {
        bg: '#0B0D12',
        gradTop: '#1C2340',
        text: '#F4F5F8',
        sub: '#A1A7B5',
        muted: '#6B7180',
        card: '#151821',
        border: '#2A2F3B',
        inputBg: '#12151D',
        accent: '#7C8CFF',
        accentText: '#0B0D12',
        error: '#FF6B6B',
        appleBg: '#FFFFFF',
        appleFg: '#000000',
        googleBg: '#1E222C',
        googleFg: '#F4F5F8',
      }
    : {
        bg: '#FFFFFF',
        gradTop: '#E8ECFF',
        text: '#11131A',
        sub: '#5B6170',
        muted: '#8A90A0',
        card: '#FFFFFF',
        border: '#E2E5EC',
        inputBg: '#F6F7FA',
        accent: '#4353FF',
        accentText: '#FFFFFF',
        error: '#D93B3B',
        appleBg: '#000000',
        appleFg: '#FFFFFF',
        googleBg: '#FFFFFF',
        googleFg: '#11131A',
      };
}

function GoogleLogo({ size = 18 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 48 48">
      <Path
        fill="#EA4335"
        d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"
      />
      <Path
        fill="#4285F4"
        d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"
      />
      <Path
        fill="#FBBC05"
        d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"
      />
      <Path
        fill="#34A853"
        d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"
      />
    </Svg>
  );
}

function BrandMark({ color }: { color: string }) {
  return (
    <Svg width={56} height={56} viewBox="0 0 56 56">
      <Circle cx={28} cy={28} r={28} fill={color} />
      <Path
        d="M19 17h18a2 2 0 0 1 2 2v3H21v6h14v4H21v7a2 2 0 0 1-2 2h-2V19a2 2 0 0 1 2-2z"
        fill="#FFFFFF"
      />
    </Svg>
  );
}

export default function AuthScreen() {
  const dark = useColorScheme() === 'dark';
  const c = useMemo(() => palette(dark), [dark]);

  const [stage, setStage] = useState<Stage>('choose');
  const [email, setEmail] = useState('');
  const [touched, setTouched] = useState(false);
  const [focused, setFocused] = useState(false);
  const [loading, setLoading] = useState<Provider | null>(null);
  const [banner, setBanner] = useState<string | null>(null);
  const inputRef = useRef<TextInput>(null);

  const emailValid = EMAIL_RE.test(email.trim());
  const showError = touched && email.length > 0 && !emailValid;
  const busy = loading !== null;

  const simulate = (provider: Provider, onDone: () => void) => {
    setLoading(provider);
    setBanner(null);
    setTimeout(() => {
      setLoading(null);
      onDone();
    }, 1200);
  };

  const handleSocial = (provider: 'apple' | 'google') => {
    if (busy) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    simulate(provider, () => {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setBanner(
        provider === 'apple'
          ? 'Signed in with Apple. Welcome back!'
          : `Signed in as ${APP.lastUsed.email}`,
      );
    });
  };

  const handleEmail = () => {
    setTouched(true);
    if (!emailValid) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      inputRef.current?.focus();
      return;
    }
    if (busy) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    simulate('email', () => {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      setStage('sent');
    });
  };

  const resetEmail = () => {
    Haptics.selectionAsync();
    setStage('choose');
    setTouched(false);
  };

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <LinearGradient
        colors={[c.gradTop, c.bg]}
        style={StyleSheet.absoluteFill}
        start={{ x: 0, y: 0 }}
        end={{ x: 0, y: 0.55 }}
      />
      <SafeAreaView style={styles.flex} edges={['top', 'bottom']}>
        <KeyboardAvoidingView
          style={styles.flex}
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
          <ScrollView
            contentContainerStyle={styles.scroll}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
          >
            <View style={styles.hero}>
              <BrandMark color={c.accent} />
              <Text style={[styles.title, { color: c.text }]} accessibilityRole="header">
                {stage === 'sent' ? 'Check your inbox' : `Sign in to ${APP.name}`}
              </Text>
              <Text style={[styles.subtitle, { color: c.sub }]}>
                {stage === 'sent'
                  ? `We sent a sign-in link to ${email.trim()}. It expires in 15 minutes.`
                  : APP.tagline}
              </Text>
            </View>

            {banner && (
              <View
                style={[styles.banner, { backgroundColor: c.card, borderColor: c.border }]}
                accessibilityLiveRegion="polite"
              >
                <Ionicons name="checkmark-circle" size={18} color="#2EB67D" />
                <Text style={[styles.bannerText, { color: c.text }]}>{banner}</Text>
              </View>
            )}

            {stage === 'choose' ? (
              <View style={styles.actions}>
                <Pressable
                  onPress={() => handleSocial('apple')}
                  disabled={busy}
                  accessibilityRole="button"
                  accessibilityLabel="Continue with Apple"
                  style={({ pressed }) => [
                    styles.btn,
                    { backgroundColor: c.appleBg, opacity: pressed ? 0.85 : busy && loading !== 'apple' ? 0.5 : 1 },
                  ]}
                >
                  {loading === 'apple' ? (
                    <ActivityIndicator color={c.appleFg} />
                  ) : (
                    <>
                      <Ionicons name="logo-apple" size={20} color={c.appleFg} style={styles.btnIcon} />
                      <Text style={[styles.btnText, { color: c.appleFg }]}>Continue with Apple</Text>
                    </>
                  )}
                </Pressable>

                <View>
                  <Pressable
                    onPress={() => handleSocial('google')}
                    disabled={busy}
                    accessibilityRole="button"
                    accessibilityLabel="Continue with Google"
                    accessibilityHint={`Last used with ${APP.lastUsed.email}`}
                    style={({ pressed }) => [
                      styles.btn,
                      styles.bordered,
                      {
                        backgroundColor: c.googleBg,
                        borderColor: c.border,
                        opacity: pressed ? 0.85 : busy && loading !== 'google' ? 0.5 : 1,
                      },
                    ]}
                  >
                    {loading === 'google' ? (
                      <ActivityIndicator color={c.googleFg} />
                    ) : (
                      <>
                        <View style={styles.btnIcon}>
                          <GoogleLogo />
                        </View>
                        <Text style={[styles.btnText, { color: c.googleFg }]}>Continue with Google</Text>
                      </>
                    )}
                  </Pressable>
                  {APP.lastUsed.provider === 'google' && (
                    <View style={[styles.lastUsed, { backgroundColor: c.accent }]}>
                      <Text style={[styles.lastUsedText, { color: c.accentText }]}>Last used</Text>
                    </View>
                  )}
                </View>

                <View style={styles.dividerRow}>
                  <View style={[styles.rule, { backgroundColor: c.border }]} />
                  <Text style={[styles.dividerText, { color: c.muted }]}>or</Text>
                  <View style={[styles.rule, { backgroundColor: c.border }]} />
                </View>

                <Text style={[styles.label, { color: c.text }]} nativeID="emailLabel">
                  Email
                </Text>
                <View
                  style={[
                    styles.inputWrap,
                    {
                      backgroundColor: c.inputBg,
                      borderColor: showError ? c.error : focused ? c.accent : c.border,
                    },
                  ]}
                >
                  <Ionicons name="mail-outline" size={18} color={c.muted} />
                  <TextInput
                    ref={inputRef}
                    value={email}
                    onChangeText={setEmail}
                    onFocus={() => setFocused(true)}
                    onBlur={() => {
                      setFocused(false);
                      setTouched(true);
                    }}
                    onSubmitEditing={handleEmail}
                    placeholder="you@example.com"
                    placeholderTextColor={c.muted}
                    keyboardType="email-address"
                    autoCapitalize="none"
                    autoCorrect={false}
                    autoComplete="email"
                    textContentType="emailAddress"
                    returnKeyType="go"
                    editable={!busy}
                    accessibilityLabelledBy="emailLabel"
                    accessibilityLabel="Email address"
                    style={[styles.input, { color: c.text }]}
                  />
                  {email.length > 0 && !busy && (
                    <Pressable
                      onPress={() => setEmail('')}
                      hitSlop={12}
                      accessibilityRole="button"
                      accessibilityLabel="Clear email"
                    >
                      <Ionicons name="close-circle" size={18} color={c.muted} />
                    </Pressable>
                  )}
                </View>
                {showError ? (
                  <Text style={[styles.helper, { color: c.error }]} accessibilityLiveRegion="polite">
                    Enter a valid email address, like name@company.com
                  </Text>
                ) : (
                  <Text style={[styles.helper, { color: c.muted }]}>
                    We'll email you a secure link — no password needed.
                  </Text>
                )}

                <Pressable
                  onPress={handleEmail}
                  disabled={busy}
                  accessibilityRole="button"
                  accessibilityLabel="Continue with email"
                  accessibilityState={{ disabled: busy, busy: loading === 'email' }}
                  style={({ pressed }) => [
                    styles.btn,
                    {
                      backgroundColor: c.accent,
                      opacity: pressed ? 0.85 : busy && loading !== 'email' ? 0.5 : 1,
                    },
                  ]}
                >
                  {loading === 'email' ? (
                    <ActivityIndicator color={c.accentText} />
                  ) : (
                    <Text style={[styles.btnText, { color: c.accentText }]}>Continue with email</Text>
                  )}
                </Pressable>
              </View>
            ) : (
              <View style={styles.actions}>
                <View style={[styles.sentCard, { backgroundColor: c.card, borderColor: c.border }]}>
                  <View style={[styles.sentIcon, { backgroundColor: c.inputBg }]}>
                    <Ionicons name="mail-open-outline" size={28} color={c.accent} />
                  </View>
                  <Text style={[styles.sentText, { color: c.sub }]}>
                    Tap the link in the email to finish signing in. Don't see it? Check your spam or
                    promotions folder.
                  </Text>
                </View>
                <Pressable
                  onPress={() => {
                    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
                    simulate('email', () => setBanner(`New link sent to ${email.trim()}`));
                  }}
                  disabled={busy}
                  accessibilityRole="button"
                  style={({ pressed }) => [
                    styles.btn,
                    styles.bordered,
                    { borderColor: c.border, backgroundColor: c.card, opacity: pressed ? 0.85 : 1 },
                  ]}
                >
                  {loading === 'email' ? (
                    <ActivityIndicator color={c.text} />
                  ) : (
                    <Text style={[styles.btnText, { color: c.text }]}>Resend link</Text>
                  )}
                </Pressable>
                <Pressable
                  onPress={resetEmail}
                  accessibilityRole="button"
                  style={styles.linkBtn}
                  hitSlop={8}
                >
                  <Text style={[styles.link, { color: c.accent }]}>Use a different email</Text>
                </Pressable>
              </View>
            )}

            <View style={styles.flex} />

            <Text style={[styles.legal, { color: c.muted }]}>
              By continuing, you agree to {APP.name}'s{' '}
              <Text style={[styles.legalLink, { color: c.sub }]} accessibilityRole="link">
                Terms of Service
              </Text>{' '}
              and{' '}
              <Text style={[styles.legalLink, { color: c.sub }]} accessibilityRole="link">
                Privacy Policy
              </Text>
              .
            </Text>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  flex: { flex: 1 },
  scroll: { flexGrow: 1, paddingHorizontal: 24, paddingTop: 48, paddingBottom: 16 },
  hero: { alignItems: 'center', marginBottom: 32 },
  title: { fontSize: 28, fontWeight: '700', letterSpacing: -0.5, marginTop: 20, textAlign: 'center' },
  subtitle: { fontSize: 15, lineHeight: 21, marginTop: 8, textAlign: 'center', maxWidth: 320 },
  banner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    marginBottom: 16,
  },
  bannerText: { fontSize: 14, flex: 1 },
  actions: { gap: 12 },
  btn: {
    height: 52,
    borderRadius: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  bordered: { borderWidth: 1 },
  btnIcon: { marginRight: 10 },
  btnText: { fontSize: 16, fontWeight: '600' },
  lastUsed: {
    position: 'absolute',
    top: -8,
    right: 14,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 8,
  },
  lastUsedText: { fontSize: 11, fontWeight: '700' },
  dividerRow: { flexDirection: 'row', alignItems: 'center', marginVertical: 8 },
  rule: { flex: 1, height: StyleSheet.hairlineWidth },
  dividerText: { marginHorizontal: 12, fontSize: 13, fontWeight: '500' },
  label: { fontSize: 14, fontWeight: '600', marginBottom: -4 },
  inputWrap: {
    height: 52,
    borderRadius: 14,
    borderWidth: 1.5,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    gap: 10,
  },
  input: { flex: 1, fontSize: 16, height: '100%' },
  helper: { fontSize: 13, marginTop: -4 },
  sentCard: {
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    gap: 12,
  },
  sentIcon: { width: 56, height: 56, borderRadius: 28, alignItems: 'center', justifyContent: 'center' },
  sentText: { fontSize: 14, lineHeight: 20, textAlign: 'center' },
  linkBtn: { alignSelf: 'center', paddingVertical: 8 },
  link: { fontSize: 15, fontWeight: '600' },
  legal: { fontSize: 12, lineHeight: 18, textAlign: 'center', marginTop: 24 },
  legalLink: { textDecorationLine: 'underline' },
});
