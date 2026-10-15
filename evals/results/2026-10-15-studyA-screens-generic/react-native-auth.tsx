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
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path } from 'react-native-svg';

type Provider = 'apple' | 'google' | 'email';

const APP = {
  name: 'Fieldnotes',
  tagline: 'Your journal, synced across every device.',
  lastUsedEmail: 'maya.chen@hey.com',
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function palette(dark: boolean) {
  return dark
    ? {
        bg: '#000000',
        surface: '#1C1C1E',
        field: '#1C1C1E',
        border: '#38383A',
        text: '#FFFFFF',
        secondary: 'rgba(235,235,245,0.62)',
        tertiary: 'rgba(235,235,245,0.36)',
        accent: '#0A84FF',
        accentText: '#FFFFFF',
        danger: '#FF453A',
        appleBg: '#FFFFFF',
        appleText: '#000000',
        googleBg: '#1C1C1E',
        googleText: '#FFFFFF',
        brandA: '#5E5CE6',
        brandB: '#0A84FF',
      }
    : {
        bg: '#F2F2F7',
        surface: '#FFFFFF',
        field: '#FFFFFF',
        border: '#D1D1D6',
        text: '#000000',
        secondary: 'rgba(60,60,67,0.66)',
        tertiary: 'rgba(60,60,67,0.36)',
        accent: '#007AFF',
        accentText: '#FFFFFF',
        danger: '#D70015',
        appleBg: '#000000',
        appleText: '#FFFFFF',
        googleBg: '#FFFFFF',
        googleText: '#1F1F1F',
        brandA: '#5856D6',
        brandB: '#007AFF',
      };
}

function GoogleLogo({ size = 18 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 48 48" accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <Path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" />
      <Path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" />
      <Path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" />
      <Path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" />
    </Svg>
  );
}

function AppMark({ a, b }: { a: string; b: string }) {
  return (
    <View style={[styles.mark, { backgroundColor: a }]} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <View style={[styles.markInner, { backgroundColor: b }]} />
      <Ionicons name="book" size={30} color="#FFFFFF" />
    </View>
  );
}

export default function AuthScreen() {
  const dark = useColorScheme() === 'dark';
  const c = useMemo(() => palette(dark), [dark]);
  const { fontScale } = useWindowDimensions();
  const large = fontScale >= 1.35;

  const [email, setEmail] = useState('');
  const [touched, setTouched] = useState(false);
  const [focused, setFocused] = useState(false);
  const [loading, setLoading] = useState<Provider | null>(null);
  const [sentTo, setSentTo] = useState<string | null>(null);
  const inputRef = useRef<TextInput>(null);

  const trimmed = email.trim();
  const valid = EMAIL_RE.test(trimmed);
  const showError = touched && trimmed.length > 0 && !valid;
  const busy = loading !== null;

  const start = (p: Provider) => {
    if (busy) return;
    if (p === 'email') {
      setTouched(true);
      if (!valid) {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
        inputRef.current?.focus();
        return;
      }
    }
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setLoading(p);
    setTimeout(() => {
      setLoading(null);
      if (p === 'email') {
        setSentTo(trimmed);
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      }
    }, 1200);
  };

  const providerButton = (
    p: Exclude<Provider, 'email'>,
    label: string,
    bg: string,
    fg: string,
    icon: React.ReactNode,
    bordered: boolean,
  ) => (
    <Pressable
      key={p}
      onPress={() => start(p)}
      disabled={busy}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityState={{ disabled: busy, busy: loading === p }}
      style={({ pressed }) => [
        styles.button,
        {
          backgroundColor: bg,
          borderColor: bordered ? c.border : bg,
          opacity: pressed ? 0.75 : busy && loading !== p ? 0.5 : 1,
        },
      ]}
    >
      {loading === p ? (
        <ActivityIndicator color={fg} />
      ) : (
        <View style={styles.buttonRow}>
          {icon}
          <Text style={[styles.buttonText, { color: fg }]} maxFontSizeMultiplier={2}>
            {label}
          </Text>
        </View>
      )}
    </Pressable>
  );

  return (
    <SafeAreaView style={[styles.flex, { backgroundColor: c.bg }]} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={dark ? 'light' : 'dark'} />
      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode="interactive"
          contentInsetAdjustmentBehavior="automatic"
        >
          <View style={[styles.hero, large && styles.heroCompact]}>
            {!large && <AppMark a={c.brandA} b={c.brandB} />}
            <Text style={[styles.title, { color: c.text }]} accessibilityRole="header" maxFontSizeMultiplier={1.8}>
              Welcome to {APP.name}
            </Text>
            <Text style={[styles.subtitle, { color: c.secondary }]} maxFontSizeMultiplier={2}>
              {APP.tagline}
            </Text>
          </View>

          {sentTo ? (
            <View style={[styles.card, { backgroundColor: c.surface }]} accessibilityLiveRegion="polite">
              <Ionicons name="mail-unread-outline" size={36} color={c.accent} />
              <Text style={[styles.cardTitle, { color: c.text }]} accessibilityRole="header">
                Check your inbox
              </Text>
              <Text style={[styles.cardBody, { color: c.secondary }]}>
                We sent a sign-in link to <Text style={{ color: c.text, fontWeight: '600' }}>{sentTo}</Text>. It expires in 15 minutes.
              </Text>
              <Pressable
                onPress={() => {
                  Haptics.selectionAsync();
                  setSentTo(null);
                }}
                accessibilityRole="button"
                hitSlop={8}
                style={({ pressed }) => [styles.link, { opacity: pressed ? 0.5 : 1 }]}
              >
                <Text style={[styles.linkText, { color: c.accent }]}>Use a different email</Text>
              </Pressable>
            </View>
          ) : (
            <View style={styles.actions}>
              {providerButton(
                'apple',
                'Continue with Apple',
                c.appleBg,
                c.appleText,
                <Ionicons name="logo-apple" size={20} color={c.appleText} />,
                false,
              )}
              {providerButton('google', 'Continue with Google', c.googleBg, c.googleText, <GoogleLogo />, true)}

              <View style={styles.dividerRow} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
                <View style={[styles.rule, { backgroundColor: c.border }]} />
                <Text style={[styles.dividerText, { color: c.tertiary }]}>or</Text>
                <View style={[styles.rule, { backgroundColor: c.border }]} />
              </View>

              <Text style={[styles.label, { color: c.secondary }]} nativeID="emailLabel">
                Email
              </Text>
              <TextInput
                ref={inputRef}
                value={email}
                onChangeText={setEmail}
                onFocus={() => setFocused(true)}
                onBlur={() => {
                  setFocused(false);
                  setTouched(true);
                }}
                onSubmitEditing={() => start('email')}
                placeholder={APP.lastUsedEmail}
                placeholderTextColor={c.tertiary}
                keyboardType="email-address"
                textContentType="emailAddress"
                autoComplete="email"
                autoCapitalize="none"
                autoCorrect={false}
                returnKeyType="go"
                editable={!busy}
                accessibilityLabel="Email address"
                accessibilityLabelledBy="emailLabel"
                accessibilityHint="We'll email you a sign-in link"
                maxFontSizeMultiplier={2}
                style={[
                  styles.input,
                  {
                    backgroundColor: c.field,
                    color: c.text,
                    borderColor: showError ? c.danger : focused ? c.accent : c.border,
                  },
                ]}
              />
              {showError && (
                <View style={styles.errorRow} accessibilityLiveRegion="polite">
                  <Ionicons name="alert-circle" size={16} color={c.danger} />
                  <Text style={[styles.errorText, { color: c.danger }]}>Enter a valid email, like name@example.com</Text>
                </View>
              )}

              <Pressable
                onPress={() => start('email')}
                disabled={busy}
                accessibilityRole="button"
                accessibilityLabel="Continue with email"
                accessibilityState={{ disabled: busy, busy: loading === 'email' }}
                style={({ pressed }) => [
                  styles.button,
                  styles.primary,
                  {
                    backgroundColor: c.accent,
                    borderColor: c.accent,
                    opacity: pressed ? 0.8 : busy && loading !== 'email' ? 0.5 : 1,
                  },
                ]}
              >
                {loading === 'email' ? (
                  <ActivityIndicator color={c.accentText} />
                ) : (
                  <Text style={[styles.buttonText, { color: c.accentText }]} maxFontSizeMultiplier={2}>
                    Continue with Email
                  </Text>
                )}
              </Pressable>
            </View>
          )}

          <View style={styles.spacer} />

          <Text style={[styles.legal, { color: c.tertiary }]} maxFontSizeMultiplier={2}>
            By continuing, you agree to our <Text style={{ color: c.secondary, fontWeight: '600' }}>Terms of Service</Text> and{' '}
            <Text style={{ color: c.secondary, fontWeight: '600' }}>Privacy Policy</Text>.
          </Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  scroll: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 24,
    paddingBottom: 16,
    width: '100%',
    maxWidth: 480,
    alignSelf: 'center',
  },
  hero: { alignItems: 'center', marginTop: 32, marginBottom: 36, gap: 10 },
  heroCompact: { marginTop: 8, marginBottom: 24, alignItems: 'flex-start' },
  mark: {
    width: 72,
    height: 72,
    borderRadius: 18,
    overflow: 'hidden',
    marginBottom: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  markInner: {
    position: 'absolute',
    width: 96,
    height: 96,
    borderRadius: 48,
    right: -44,
    bottom: -44,
    opacity: 0.85,
  },
  title: { fontSize: 30, fontWeight: '700', letterSpacing: 0.3, textAlign: 'center' },
  subtitle: { fontSize: 17, lineHeight: 22, textAlign: 'center' },
  actions: { gap: 12 },
  button: {
    minHeight: 52,
    borderRadius: 14,
    borderWidth: StyleSheet.hairlineWidth * 2,
    paddingHorizontal: 18,
    paddingVertical: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: { marginTop: 4 },
  buttonRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    flexWrap: 'wrap',
    gap: 10,
  },
  buttonText: { fontSize: 17, fontWeight: '600', textAlign: 'center' },
  dividerRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginVertical: 8 },
  rule: { flex: 1, height: StyleSheet.hairlineWidth },
  dividerText: { fontSize: 15 },
  label: { fontSize: 13, fontWeight: '600', textTransform: 'uppercase', letterSpacing: 0.4, marginLeft: 4, marginBottom: -4 },
  input: {
    minHeight: 52,
    borderRadius: 14,
    borderWidth: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 17,
  },
  errorRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 6, marginLeft: 4 },
  errorText: { fontSize: 14, flexShrink: 1 },
  card: { borderRadius: 18, padding: 24, alignItems: 'center', gap: 10 },
  cardTitle: { fontSize: 22, fontWeight: '700', textAlign: 'center' },
  cardBody: { fontSize: 16, lineHeight: 22, textAlign: 'center' },
  link: { minHeight: 44, justifyContent: 'center', paddingHorizontal: 8 },
  linkText: { fontSize: 17, fontWeight: '600' },
  spacer: { flexGrow: 1, minHeight: 24 },
  legal: { fontSize: 13, lineHeight: 18, textAlign: 'center' },
});
