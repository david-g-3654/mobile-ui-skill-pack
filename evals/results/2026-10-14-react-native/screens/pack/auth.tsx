// Auth — entry screen for "Tendril", a houseplant care app.
// Job: get the user in with minimum typing. Focal: the title + the platform's fastest provider.
// Primary: Continue with Apple (iOS) / Google (Android). Email is one field per step: email → 6-digit code.
// Cut: password field, "Forgot password?", separate sign-up flow (email branches after it's known).

import React, { useEffect, useState } from 'react';
import { BackHandler, KeyboardAvoidingView, Linking, Platform, StyleSheet, Text, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { Ionicons } from '@expo/vector-icons';
import { radius, space, useTheme } from '../../pack/theme';
import {
  BottomActionBar,
  LargeTextFooter,
  PrimaryButton,
  Screen,
  SecondaryButton,
  TertiaryButton,
  TextField,
  Toast,
  Txt,
} from '../../pack/components';

type Step = 'methods' | 'email' | 'code';
type Provider = 'apple' | 'google' | 'email';

const APP = {
  name: 'Tendril',
  headline: 'Keep every plant watered, fed and thriving',
  subhead: 'Reminders tuned to your light, your pots and your 23 plants.',
  termsUrl: 'https://example.com/terms',
  privacyUrl: 'https://example.com/privacy',
};

// Sample inline data: the code "sent" and the account it resolves to.
const SAMPLE = {
  prefillEmail: '',
  expiredCode: '000000',
  resendSeconds: 24,
  knownAccount: 'priya.raman@fastmail.com',
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

function formatCountdown(s: number) {
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
}

export default function AuthScreen() {
  const { c } = useTheme();
  const insets = useSafeAreaInsets();
  const [step, setStep] = useState<Step>('methods');
  const [busy, setBusy] = useState<Provider | 'verify' | null>(null);
  const [email, setEmail] = useState(SAMPLE.prefillEmail);
  const [emailError, setEmailError] = useState<string | undefined>();
  const [code, setCode] = useState('');
  const [codeError, setCodeError] = useState<string | undefined>();
  const [resendIn, setResendIn] = useState(SAMPLE.resendSeconds);
  const [toast, setToast] = useState<string | null>(null);

  // Provider order: the platform's own provider is the primary.
  const ios = Platform.OS === 'ios';

  // Android hardware back steps back through the email flow instead of leaving the app.
  useEffect(() => {
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      if (step === 'methods') return false;
      goBack();
      return true;
    });
    return () => sub.remove();
  }, [step]);

  // Resend countdown on the code step.
  useEffect(() => {
    if (step !== 'code' || resendIn <= 0) return;
    const id = setTimeout(() => setResendIn((s) => s - 1), 1000);
    return () => clearTimeout(id);
  }, [step, resendIn]);

  useEffect(() => {
    if (!toast) return;
    const id = setTimeout(() => setToast(null), 2600);
    return () => clearTimeout(id);
  }, [toast]);

  function goBack() {
    setBusy(null);
    if (step === 'code') {
      setCode('');
      setCodeError(undefined);
      setStep('email');
    } else {
      setEmailError(undefined);
      setStep('methods');
    }
  }

  function signedIn(who: string) {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setBusy(null);
    setToast(`Signed in as ${who}`);
  }

  function continueWith(provider: 'apple' | 'google') {
    // TODO: swap for the official buttons/flows — expo-apple-authentication's AppleAuthenticationButton
    // and Google's branded button — keeping height 52 and their marks.
    setBusy(provider);
    setTimeout(() => signedIn(provider === 'apple' ? 'Priya (Apple ID)' : SAMPLE.knownAccount), 900);
  }

  function sendCode() {
    const trimmed = email.trim();
    if (!trimmed) {
      setEmailError('Enter the email you want to sign in with.');
      return;
    }
    if (!EMAIL_RE.test(trimmed)) {
      setEmailError(`"${trimmed}" is missing part of the address — check for a typo after the @.`);
      return;
    }
    setEmailError(undefined);
    setBusy('email');
    setTimeout(() => {
      setBusy(null);
      setResendIn(SAMPLE.resendSeconds);
      setStep('code');
    }, 700);
  }

  function verify(value: string) {
    if (value.length < 6) {
      setCodeError('Enter all 6 digits from the email.');
      return;
    }
    setBusy('verify');
    setTimeout(() => {
      if (value === SAMPLE.expiredCode) {
        setBusy(null);
        setCode('');
        setResendIn(SAMPLE.resendSeconds);
        setCodeError('That code expired. We sent a new one.');
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
        return;
      }
      setCodeError(undefined);
      signedIn(email.trim());
    }, 700);
  }

  function onCodeChange(text: string) {
    const digits = text.replace(/\D/g, '').slice(0, 6);
    setCode(digits);
    if (codeError) setCodeError(undefined);
    if (digits.length === 6) verify(digits); // auto-submit, works with paste and OS autofill
  }

  const terms = (
    <Txt variant="footnote" color="ink2">
      By continuing you agree to {APP.name}’s{' '}
      <Text style={styles.link} accessibilityRole="link" onPress={() => Linking.openURL(APP.termsUrl)}>
        Terms
      </Text>{' '}
      and{' '}
      <Text style={styles.link} accessibilityRole="link" onPress={() => Linking.openURL(APP.privacyUrl)}>
        Privacy Policy
      </Text>
      .
    </Txt>
  );

  const appleButton = (
    <ProviderButton
      key="apple"
      primary={ios}
      title="Continue with Apple"
      loading={busy === 'apple'}
      disabled={busy !== null}
      onPress={() => continueWith('apple')}
    />
  );
  const googleButton = (
    <ProviderButton
      key="google"
      primary={!ios}
      title="Continue with Google"
      loading={busy === 'google'}
      disabled={busy !== null}
      onPress={() => continueWith('google')}
    />
  );

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: c.canvas }} behavior={ios ? 'padding' : undefined}>
      <Stack.Screen options={{ headerShown: false, contentStyle: { backgroundColor: c.canvas } }} />
      <StatusBar style="auto" />

      <Screen
        contentInsetAdjustmentBehavior="never"
        keyboardShouldPersistTaps="handled"
        contentContainerStyle={{ flexGrow: 1, paddingTop: insets.top + space.xxxl, gap: space.xl }}
      >
        {step === 'methods' && (
          <>
            <View
              style={[styles.mark, { backgroundColor: c.accentSoft }]}
              accessible
              accessibilityRole="image"
              accessibilityLabel={`${APP.name} logo`}
            >
              <Ionicons name="leaf-outline" size={36} color={c.accent} />
            </View>

            <View style={{ gap: space.xs }}>
              <Txt variant="largeTitle" role="header">
                {APP.headline}
              </Txt>
              <Txt variant="subhead" color="ink2">
                {APP.subhead}
              </Txt>
            </View>

            {/* Pushes the methods to the thumb zone; collapses when text is large and content scrolls. */}
            <View style={{ flexGrow: 1 }} />

            <View style={{ gap: space.sm }}>
              {ios ? [appleButton, googleButton] : [googleButton, appleButton]}
              <SecondaryButton
                title="Continue with email"
                disabled={busy !== null}
                onPress={() => {
                  Haptics.selectionAsync();
                  setStep('email');
                }}
              />
            </View>

            <View style={{ paddingBottom: insets.bottom }}>{terms}</View>
          </>
        )}

        {step === 'email' && (
          <>
            <View style={{ gap: space.xs }}>
              <Txt variant="largeTitle" role="header">
                What’s your email?
              </Txt>
              <Txt variant="subhead" color="ink2">
                We’ll send a 6-digit code. New to {APP.name}? The same code creates your account.
              </Txt>
            </View>
            <TextField
              label="Email"
              value={email}
              onChangeText={(t) => {
                setEmail(t);
                if (emailError) setEmailError(undefined);
              }}
              error={emailError}
              placeholder="you@example.com"
              autoFocus
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              textContentType="username"
              autoComplete="email"
              returnKeyType="go"
              onSubmitEditing={sendCode}
            />
            <View style={styles.alignStart}>
              <TertiaryButton title="Use Apple or Google instead" onPress={goBack} />
            </View>
            <LargeTextFooter>{terms}</LargeTextFooter>
          </>
        )}

        {step === 'code' && (
          <>
            <View style={{ gap: space.xs }}>
              <Txt variant="largeTitle" role="header">
                Check your inbox
              </Txt>
              <Txt variant="subhead" color="ink2">
                Enter the code we sent to {email.trim()}. It expires in 10 minutes.
              </Txt>
            </View>
            <TextField
              label="6-digit code"
              value={code}
              onChangeText={onCodeChange}
              error={codeError}
              placeholder="••••••"
              autoFocus
              keyboardType="number-pad"
              textContentType="oneTimeCode"
              autoComplete="one-time-code"
              maxLength={6}
              editable={busy !== 'verify'}
              style={styles.codeInput}
            />
            <View style={styles.row}>
              {resendIn > 0 ? (
                <Txt variant="subhead" color="ink2" style={styles.tabular}>
                  Resend code in {formatCountdown(resendIn)}
                </Txt>
              ) : (
                <TertiaryButton
                  title="Resend code"
                  color="ink"
                  onPress={() => {
                    setResendIn(SAMPLE.resendSeconds);
                    setToast(`New code sent to ${email.trim()}`);
                  }}
                />
              )}
              <TertiaryButton title="Change email" onPress={goBack} />
            </View>
          </>
        )}
      </Screen>

      {step === 'email' && (
        <BottomActionBar footer={terms}>
          <PrimaryButton title="Send sign-in code" loading={busy === 'email'} onPress={sendCode} />
        </BottomActionBar>
      )}
      {step === 'code' && (
        <BottomActionBar>
          <PrimaryButton
            title="Sign in"
            loading={busy === 'verify'}
            disabled={code.length < 6 && busy !== 'verify'}
            onPress={() => verify(code)}
          />
        </BottomActionBar>
      )}

      {toast && <Toast message={toast} />}
    </KeyboardAvoidingView>
  );
}

/** Provider button: primary (ink capsule) for the platform's own provider, tonal for the rest. */
function ProviderButton({
  title,
  primary,
  loading,
  disabled,
  onPress,
}: {
  title: string;
  primary: boolean;
  loading: boolean;
  disabled: boolean;
  onPress: () => void;
}) {
  if (primary) return <PrimaryButton title={title} loading={loading} onPress={onPress} />;
  return <SecondaryButton title={loading ? 'Connecting…' : title} disabled={disabled && !loading} onPress={onPress} />;
}

const styles = StyleSheet.create({
  mark: {
    width: 72,
    height: 72,
    borderRadius: radius.l,
    alignItems: 'center',
    justifyContent: 'center',
  },
  link: { textDecorationLine: 'underline' },
  alignStart: { alignItems: 'flex-start' },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: space.xs },
  codeInput: { letterSpacing: 8 },
  tabular: { fontVariant: ['tabular-nums'] },
});
