// Auth entry for "Fernway", a trail journal app.
// Archetype: Auth. Job: get in with minimum typing. Focal: brand line + the platform provider button.
// Primary: Continue with Apple on iOS (Google on Android). Email branches into one-field steps
// (email → 6-digit code) so sign-in and sign-up share one flow. Cutting: password, "Forgot password?",
// extra social providers.

import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  BackHandler,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import Svg, { Path } from 'react-native-svg';
import { metrics, radius, space, type, useQTheme } from '../../pack04/theme';
import {
  QBottomActionBar,
  QLargeTextFooter,
  QPrimaryButton,
  QTertiaryButton,
  QText,
  QTextField,
  QToast,
} from '../../pack04/components';

type Step = 'entry' | 'email' | 'code';
type Provider = 'apple' | 'google' | 'email';

// Sample data: the code the "server" emailed, and the account it resolves to.
const SENT_CODE = '481207';
const RESEND_SECONDS = 30;
const KNOWN_EMAILS: Record<string, string> = {
  'amara.okafor@fastmail.com': 'Amara',
  'lucas.wei@icloud.com': 'Lucas',
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

// ── Google "G" mark — the official multicolor asset paths, unmodified ────────────
function GoogleMark({ size = 18 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 48 48" accessibilityElementsHidden importantForAccessibility="no">
      <Path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" /* mobile-ui: content-color */ />
      <Path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" /* mobile-ui: content-color */ />
      <Path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" /* mobile-ui: content-color */ />
      <Path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" /* mobile-ui: content-color */ />
    </Svg>
  );
}

// ── Provider button: 52-high capsule with the provider's mark ─────────────────────
function ProviderButton({
  provider,
  title,
  filled,
  busy,
  disabled,
  onPress,
}: {
  provider: Provider;
  title: string;
  filled: boolean;
  busy: boolean;
  disabled: boolean;
  onPress: () => void;
}) {
  const { c } = useQTheme();
  const fg = filled ? c.onPrimary : c.ink;
  const mark =
    provider === 'apple' ? (
      <Ionicons name="logo-apple" size={20} color={fg} />
    ) : provider === 'google' ? (
      <GoogleMark />
    ) : (
      <Ionicons name="mail-outline" size={20} color={fg} />
    );
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityState={{ disabled, busy }}
      style={({ pressed }) => [
        styles.provider,
        { backgroundColor: filled ? c.primaryFill : c.surface2, opacity: disabled && !busy ? 0.5 : 1 },
        pressed && styles.pressed,
      ]}
    >
      {busy ? (
        <ActivityIndicator color={fg} />
      ) : (
        <>
          {mark}
          <QText variant="headline" color={filled ? 'onPrimary' : 'ink'} style={styles.shrink}>
            {title}
          </QText>
        </>
      )}
    </Pressable>
  );
}

// ── Terms line (pinned at normal sizes, flows into the scroll at accessibility sizes) ──
function Terms({ onOpen }: { onOpen: (doc: string) => void }) {
  const { c } = useQTheme();
  const link = { color: c.ink, textDecorationLine: 'underline' as const };
  return (
    <QText variant="footnote" color="ink2">
      By continuing you agree to Fernway's{' '}
      <Text accessibilityRole="link" style={link} onPress={() => onOpen('Terms of Service')}>
        Terms
      </Text>{' '}
      and{' '}
      <Text accessibilityRole="link" style={link} onPress={() => onOpen('Privacy Policy')}>
        Privacy Policy
      </Text>
      .
    </QText>
  );
}

export default function AuthScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();

  const [step, setStep] = useState<Step>('entry');
  const [busy, setBusy] = useState<Provider | null>(null);
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | undefined>();
  const [code, setCode] = useState('');
  const [codeError, setCodeError] = useState<string | undefined>();
  const [verifying, setVerifying] = useState(false);
  const [resendIn, setResendIn] = useState(RESEND_SECONDS);
  const [toast, setToast] = useState<string | null>(null);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  const later = (fn: () => void, ms: number) => {
    timers.current.push(setTimeout(fn, ms));
  };
  useEffect(() => () => timers.current.forEach(clearTimeout), []);

  // Toast auto-dismiss
  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 2600);
    return () => clearTimeout(t);
  }, [toast]);

  // Resend countdown on the code step
  useEffect(() => {
    if (step !== 'code' || resendIn <= 0) return;
    const t = setTimeout(() => setResendIn((s) => s - 1), 1000);
    return () => clearTimeout(t);
  }, [step, resendIn]);

  // Android back walks the steps instead of leaving the app
  useEffect(() => {
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      if (step === 'entry') return false;
      goBack();
      return true;
    });
    return () => sub.remove();
  });

  const signedIn = (name: string) => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setToast(`Signed in. Welcome back, ${name}.`);
  };

  const startProvider = (p: 'apple' | 'google') => {
    setBusy(p);
    later(() => {
      setBusy(null);
      signedIn(p === 'apple' ? 'Amara' : 'Lucas');
    }, 1100);
  };

  const goBack = () => {
    if (step === 'code') {
      setCode('');
      setCodeError(undefined);
      setStep('email');
    } else {
      setEmailError(undefined);
      setStep('entry');
    }
  };

  const sendCode = () => {
    const trimmed = email.trim().toLowerCase();
    if (!EMAIL_RE.test(trimmed)) {
      setEmailError("That doesn't look like a full email address. Check the part after the @.");
      return;
    }
    setEmailError(undefined);
    setBusy('email');
    later(() => {
      setBusy(null);
      setEmail(trimmed);
      setResendIn(RESEND_SECONDS);
      setStep('code');
    }, 800);
  };

  const verify = (value: string) => {
    setVerifying(true);
    later(() => {
      setVerifying(false);
      if (value === SENT_CODE) {
        signedIn(KNOWN_EMAILS[email] ?? email.split('@')[0]);
      } else {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
        setCodeError("That code doesn't match. Use the newest email from Fernway.");
      }
    }, 700);
  };

  const onCodeChange = (raw: string) => {
    const digits = raw.replace(/\D/g, '').slice(0, 6);
    setCode(digits);
    setCodeError(undefined);
    if (digits.length === 6) verify(digits); // auto-submit, paste included
  };

  const resend = () => {
    setResendIn(RESEND_SECONDS);
    setCode('');
    setCodeError(undefined);
    setToast(`New code sent to ${email}`);
  };

  const openDoc = (doc: string) => setToast(`${doc} opens in your browser`);

  const primaryIsApple = Platform.OS === 'ios';
  const anyBusy = busy !== null;
  const clock = `0:${String(resendIn).padStart(2, '0')}`;

  // ── Step 1: provider entry ───────────────────────────────────────────────────
  if (step === 'entry') {
    const apple = (
      <ProviderButton key="apple" provider="apple" title="Continue with Apple" filled={primaryIsApple} busy={busy === 'apple'} disabled={anyBusy} onPress={() => startProvider('apple')} />
    );
    const google = (
      <ProviderButton key="google" provider="google" title="Continue with Google" filled={!primaryIsApple} busy={busy === 'google'} disabled={anyBusy} onPress={() => startProvider('google')} />
    );
    return (
      <View style={[styles.flex, { backgroundColor: c.canvas }]}>
        <Stack.Screen options={{ headerShown: false }} />
        <StatusBar style="auto" />
        <ScrollView
          style={styles.flex}
          contentContainerStyle={[
            styles.entryContent,
            { paddingTop: insets.top + space.xxxl, paddingBottom: Math.max(insets.bottom, space.md) + space.xs },
          ]}
        >
          <View style={styles.brand}>
            <View style={[styles.mark, { backgroundColor: c.surface }]} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
              <Ionicons name="trail-sign-outline" size={36} color={c.accent} />
            </View>
            <QText variant="largeTitle" role="header">
              Every trail you've walked, in one journal
            </QText>
            <QText variant="subhead" color="ink2">
              Sign in to sync your hikes, photos and maps across devices.
            </QText>
          </View>

          <View style={styles.methods}>
            {primaryIsApple ? [apple, google] : [google, apple]}
            <ProviderButton provider="email" title="Continue with email" filled={false} busy={false} disabled={anyBusy} onPress={() => setStep('email')} />
            <View style={styles.terms}>
              <Terms onOpen={openDoc} />
            </View>
          </View>
        </ScrollView>
        {toast && <QToast message={toast} />}
      </View>
    );
  }

  // ── Steps 2–3: one field per step under a native header ──────────────────────
  const isEmail = step === 'email';
  return (
    <KeyboardAvoidingView
      style={[styles.flex, { backgroundColor: c.canvas }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? insets.top + 44 : 0}
    >
      <Stack.Screen
        options={{
          headerShown: true,
          title: '',
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerStyle: { backgroundColor: c.canvas },
          contentStyle: { backgroundColor: c.canvas },
          headerLeft: () => <QTertiaryButton title={isEmail ? 'Cancel' : 'Change email'} color="ink" onPress={goBack} />,
        }}
      />
      <StatusBar style="auto" />
      <ScrollView
        style={styles.flex}
        contentInsetAdjustmentBehavior="automatic"
        keyboardShouldPersistTaps="handled"
        contentContainerStyle={styles.stepContent}
      >
        <View style={styles.stepTitle}>
          <QText variant="title" role="header">
            {isEmail ? "What's your email?" : 'Check your inbox'}
          </QText>
          <QText variant="subhead" color="ink2">
            {isEmail
              ? "We'll send a 6-digit code. New to Fernway? The same code creates your account."
              : `Enter the code we sent to ${email}. It expires in 10 minutes.`}
          </QText>
        </View>

        {isEmail ? (
          <QTextField
            key="email"
            label="Email"
            value={email}
            onChangeText={(v) => {
              setEmail(v);
              if (emailError) setEmailError(undefined);
            }}
            placeholder="name@example.com"
            autoFocus
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            autoComplete="email"
            textContentType="username"
            returnKeyType="go"
            onSubmitEditing={sendCode}
            error={emailError}
          />
        ) : (
          <View style={styles.codeBlock}>
            <QTextField
              key="code"
              label="6-digit code"
              value={code}
              onChangeText={onCodeChange}
              placeholder="000000"
              autoFocus
              keyboardType="number-pad"
              autoComplete="one-time-code"
              textContentType="oneTimeCode"
              maxLength={6}
              editable={!verifying}
              style={[type.title, styles.codeInput]}
              error={codeError}
            />
            {resendIn > 0 ? (
              <QText variant="subhead" color="ink2" style={styles.resendWait}>
                Resend code in {clock}
              </QText>
            ) : (
              <View style={styles.resendRow}>
                <QTertiaryButton title="Resend code" color="ink" onPress={resend} />
              </View>
            )}
          </View>
        )}

        <QLargeTextFooter>
          <Terms onOpen={openDoc} />
        </QLargeTextFooter>
      </ScrollView>

      <QBottomActionBar footer={<Terms onOpen={openDoc} />}>
        {isEmail ? (
          <QPrimaryButton title="Send code" onPress={sendCode} loading={busy === 'email'} disabled={email.trim().length === 0} />
        ) : (
          <QPrimaryButton title="Sign in" onPress={() => verify(code)} loading={verifying} disabled={code.length < 6} />
        )}
      </QBottomActionBar>
      {toast && <QToast message={toast} />}
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  entryContent: {
    flexGrow: 1,
    justifyContent: 'space-between',
    paddingHorizontal: space.margin,
    gap: space.xxl,
  },
  brand: { gap: space.sm },
  mark: {
    width: 72,
    height: 72,
    borderRadius: radius.l,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: space.sm,
  },
  methods: { gap: space.sm },
  provider: {
    minHeight: metrics.buttonHeight,
    borderRadius: radius.capsule,
    paddingHorizontal: space.xl,
    paddingVertical: space.sm,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: space.xs,
  },
  pressed: { opacity: 0.85, transform: [{ scale: 0.98 }] },
  shrink: { flexShrink: 1, textAlign: 'center' },
  terms: { paddingTop: space.xs },
  stepContent: { paddingHorizontal: space.margin, paddingTop: space.md, paddingBottom: space.xxl, gap: space.xl },
  stepTitle: { gap: space.xs },
  codeBlock: { gap: space.sm },
  codeInput: { letterSpacing: space.xs, textAlign: 'left' },
  resendWait: { minHeight: metrics.minTap, textAlignVertical: 'center', paddingTop: space.sm },
  resendRow: { alignItems: 'flex-start' },
});
