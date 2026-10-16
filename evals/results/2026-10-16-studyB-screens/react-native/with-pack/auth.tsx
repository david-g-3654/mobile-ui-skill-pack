import React, { useState } from 'react';
import {
  Alert,
  Keyboard,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  StyleSheet,
  View,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import {
  QBottomActionBar,
  QIconButton,
  QLargeTextFooter,
  QPrimaryButton,
  QScreen,
  QText,
  QTextField,
  useQLargeText,
} from '../../pack04/components';
import { metrics, radius, space, useQTheme } from '../../pack04/theme';

type AuthStep = 'welcome' | 'email' | 'preview';

export default function AuthScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const largeText = useQLargeText();
  const [step, setStep] = useState<AuthStep>('welcome');
  const [email, setEmail] = useState('');
  const [error, setError] = useState<string>();
  const [providerMessage, setProviderMessage] = useState<string>();
  const primaryProvider = Platform.OS === 'android' ? 'Google' : 'Apple';
  const secondaryProvider = primaryProvider === 'Apple' ? 'Google' : 'Apple';

  const openEmail = () => {
    setProviderMessage(undefined);
    setStep('email');
  };

  const submitEmail = () => {
    const normalizedEmail = email.trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
      setError('Enter a complete email address, like alex@icloud.com.');
      return;
    }
    Keyboard.dismiss();
    setEmail(normalizedEmail);
    setError(undefined);
    setStep('preview');
  };

  const providerButton = (provider: 'Apple' | 'Google', primary: boolean) => (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`Continue with ${provider}`}
      onPress={() => setProviderMessage(`${provider} sign-in isn’t connected in this preview. You can explore the email flow instead.`)}
      style={({ pressed }) => [
        styles.provider,
        {
          backgroundColor: primary ? c.primaryFill : c.surface,
          borderColor: primary ? c.primaryFill : c.hairline,
          opacity: pressed ? 0.75 : 1,
        },
      ]}
    >
      <View accessible={false} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
        <Ionicons
          name={provider === 'Apple' ? 'logo-apple' : 'logo-google'}
          size={space.xl}
          color={primary ? c.onPrimary : c.ink}
        />
      </View>
      <QText variant="headline" color={primary ? 'onPrimary' : 'ink'}>
        Continue with {provider}
      </QText>
    </Pressable>
  );

  const legal = (
    <View style={styles.legal}>
      <QText variant="footnote" color="ink2" style={styles.center}>
        By continuing, you agree to our
      </QText>
      <View style={styles.legalLinks}>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Read terms of service"
          onPress={() => Alert.alert('Terms of service', 'This is a Still sign-in preview. No account is created and no subscription or purchase is required.')}
          style={({ pressed }) => [styles.legalLink, { opacity: pressed ? 0.5 : 1 }]}
        >
          <QText variant="footnote" color="ink2" style={styles.underlined}>Terms of service</QText>
        </Pressable>
        <QText variant="footnote" color="ink2">and</QText>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Read privacy policy"
          onPress={() => Alert.alert('Privacy policy', 'This preview keeps your email only in memory. It does not send your details to a server or connect to Apple or Google.')}
          style={({ pressed }) => [styles.legalLink, { opacity: pressed ? 0.5 : 1 }]}
        >
          <QText variant="footnote" color="ink2" style={styles.underlined}>Privacy policy</QText>
        </Pressable>
      </View>
    </View>
  );

  const welcomeFooter = (
    <View style={styles.footer}>
      {providerButton(secondaryProvider, false)}
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Continue with email"
        onPress={openEmail}
        style={({ pressed }) => [styles.provider, { borderColor: c.hairline, backgroundColor: pressed ? c.surface2 : c.canvas }]}
      >
        <Ionicons name="mail-outline" size={space.xl} color={c.ink} />
        <QText variant="headline">Continue with email</QText>
      </Pressable>
      {legal}
    </View>
  );

  const isWelcome = step === 'welcome';

  return (
    <KeyboardAvoidingView
      style={[styles.screen, { backgroundColor: c.canvas }]}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <Stack.Screen
        options={{
          headerShown: !isWelcome,
          title: 'Sign in',
          headerShadowVisible: false,
          headerTintColor: c.ink,
          headerStyle: { backgroundColor: c.canvas },
          contentStyle: { backgroundColor: c.canvas },
          headerLeft: () => (
            <QIconButton icon="arrow-back" label="Back to sign-in options" onPress={() => {
              Keyboard.dismiss();
              setStep('welcome');
              setError(undefined);
            }} />
          ),
        }}
      />
      <StatusBar style="auto" />
      <QScreen
        keyboardShouldPersistTaps="handled"
        contentInsetAdjustmentBehavior={isWelcome ? 'never' : 'automatic'}
        contentContainerStyle={[
          styles.content,
          { paddingTop: isWelcome ? insets.top + space.xl : space.xxl },
        ]}
      >
        {isWelcome ? (
          <>
            <View style={styles.wordmark} accessible accessibilityLabel="Still">
              <View style={[styles.brandDot, { backgroundColor: c.accent }]} />
              <QText variant="headline">still</QText>
            </View>
            <View style={[styles.welcome, largeText && styles.largeWelcome]}>
              <View style={[styles.mark, { backgroundColor: c.surface2 }]} accessible={false} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
                <Ionicons name="book-outline" size={space.xxxl} color={c.ink} />
              </View>
              <View style={styles.introduction}>
                <QText variant="hero" role="header">Make room{'\n'}for yourself.</QText>
                <QText variant="subhead" color="ink2" style={styles.subtitle}>
                  Your thoughts, plans, and little moments.{'\n'}All in a place that’s yours.
                </QText>
              </View>
            </View>
            {providerMessage && (
              <View accessibilityLiveRegion="polite" style={styles.feedback}>
                <QText variant="footnote" color="ink2">{providerMessage}</QText>
              </View>
            )}
            <QLargeTextFooter>{welcomeFooter}</QLargeTextFooter>
          </>
        ) : step === 'email' ? (
          <View style={styles.emailContent}>
            <View style={styles.introduction}>
              <QText variant="hero" role="header">Start with{'\n'}your email.</QText>
              <QText variant="subhead" color="ink2">No password to remember. Just a secure link to your space.</QText>
            </View>
            <QTextField
              label="Email address"
              placeholder="alex@icloud.com"
              value={email}
              onChangeText={(value) => {
                setEmail(value);
                if (error) setError(undefined);
              }}
              error={error}
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              autoComplete="email"
              textContentType="emailAddress"
              returnKeyType="go"
              onSubmitEditing={submitEmail}
            />
            <QText variant="footnote" color="ink2">Preview only · No email will be sent.</QText>
            <QLargeTextFooter>{legal}</QLargeTextFooter>
          </View>
        ) : (
          <View style={styles.emailContent}>
            <Ionicons name="mail-open-outline" size={space.xxxl} color={c.ink} />
            <QText variant="hero" role="header">A small{'\n'}next step.</QText>
            <QText variant="subhead" color="ink2">In the connected app, a sign-in link would be sent to:</QText>
            <QText variant="headline">{email}</QText>
            <QText variant="footnote" color="ink2">This is a preview, so nothing has been sent and you haven’t been signed in.</QText>
          </View>
        )}
      </QScreen>
      {isWelcome ? (
        <QBottomActionBar footer={welcomeFooter}>
          {providerButton(primaryProvider, true)}
        </QBottomActionBar>
      ) : (
        <QBottomActionBar footer={step === 'email' ? legal : undefined}>
          <QPrimaryButton
            title={step === 'email' ? 'Preview email sign-in' : 'Use another email'}
            onPress={step === 'email' ? submitEmail : () => setStep('email')}
          />
        </QBottomActionBar>
      )}
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1 },
  content: { flexGrow: 1, gap: space.xxl, width: '100%', maxWidth: 640, alignSelf: 'center' },
  wordmark: { flexDirection: 'row', alignItems: 'center', gap: space.xs },
  brandDot: { width: space.sm, height: space.sm, borderRadius: radius.capsule },
  welcome: { flex: 1, justifyContent: 'center', gap: space.xxl, paddingVertical: space.xl },
  largeWelcome: { flex: 0 },
  mark: { width: space.xxxl + space.xxl, height: space.xxxl + space.xxl, borderRadius: radius.xl, alignItems: 'center', justifyContent: 'center' },
  introduction: { gap: space.md },
  subtitle: { paddingTop: space.xxs },
  footer: { gap: space.sm, width: '100%', maxWidth: 640, alignSelf: 'center' },
  provider: { minHeight: metrics.buttonHeight, paddingVertical: space.sm, paddingHorizontal: space.lg, borderRadius: radius.capsule, borderWidth: StyleSheet.hairlineWidth, flexDirection: 'row', gap: space.sm, alignItems: 'center', justifyContent: 'center', flexWrap: 'wrap', width: '100%', maxWidth: 640, alignSelf: 'center' },
  legal: { alignItems: 'center', paddingTop: space.md },
  legalLinks: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', flexWrap: 'wrap', gap: space.xs },
  legalLink: { minHeight: metrics.minTap, justifyContent: 'center' },
  center: { textAlign: 'center' },
  underlined: { textDecorationLine: 'underline' },
  feedback: { paddingBottom: space.xs },
  emailContent: { gap: space.xl },
});
