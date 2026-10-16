import React, { useState } from 'react';
import { Alert, KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import Svg, { Path } from 'react-native-svg';

const ink = '#252D28';
const green = '#3C5946';

function GoogleMark() {
  return <Svg width={21} height={21} viewBox="0 0 24 24"><Path fill="#4285F4" d="M21.8 12.2c0-.7-.1-1.4-.2-2.1H12v4h5.5a4.7 4.7 0 0 1-2.1 3.1v2.6h3.4c2-1.8 3-4.5 3-7.6Z" /><Path fill="#34A853" d="M12 22c2.8 0 5.1-.9 6.8-2.5l-3.4-2.6c-.9.6-2 1-3.4 1-2.7 0-4.9-1.8-5.7-4.2H2.8v2.7A10.2 10.2 0 0 0 12 22Z" /><Path fill="#FBBC05" d="M6.3 13.7a6 6 0 0 1 0-3.4V7.6H2.8a10 10 0 0 0 0 8.8l3.5-2.7Z" /><Path fill="#EA4335" d="M12 6.1c1.5 0 2.8.5 3.8 1.5l3-3A10 10 0 0 0 2.8 7.6l3.5 2.7C7.1 7.9 9.3 6.1 12 6.1Z" /></Svg>;
}

export default function AuthScreen() {
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState(false);
  const [sent, setSent] = useState(false);

  function continueWithEmail() {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      setEmailError(true);
      return;
    }
    setSent(true);
  }

  function socialSignIn(provider: string) {
    Alert.alert(`Continue with ${provider}`, `${provider} sign-in isn't connected in this preview. You can try the email flow instead.`);
  }

  return (
    <SafeAreaView style={styles.safe}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <ScrollView contentContainerStyle={styles.page} keyboardShouldPersistTaps="handled" showsVerticalScrollIndicator={false}>
          <View style={styles.brand}><View style={styles.brandIcon}><Ionicons name="leaf-outline" size={21} color={green} /></View><Text style={styles.brandName}>gather</Text></View>

          <View style={styles.hero}>
            <View style={styles.art} accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
              <View style={styles.orbit} />
              <View style={styles.orbitInner} />
              <View style={styles.sun} />
              <View style={styles.leafLeft} />
              <View style={styles.leafRight} />
              <View style={styles.stem} />
              <View style={styles.spark}><Ionicons name="sparkles" color={green} size={19} /></View>
              <View style={styles.smallDot} />
              <View style={styles.artLabel}><View style={styles.labelDot} /><Text style={styles.artLabelText}>A little more connected.</Text></View>
            </View>
            <Text style={styles.eyebrow}>GOOD THINGS START HERE</Text>
            <Text style={styles.title}>Your people.{'\n'}Your place.</Text>
            <Text style={styles.subtitle}>A space for the things you love,{ '\n'}and the people who get it.</Text>
          </View>

          <View style={styles.form}>
            {sent ? (
              <View style={styles.sentBox}>
                <Ionicons name="mail-open-outline" size={32} color={green} />
                <Text style={styles.sentTitle}>Check your inbox</Text>
                <Text style={styles.sentCopy}>Your next step is a sign-in link to {email.trim()}. This preview doesn’t send emails.</Text>
                <Pressable onPress={() => setSent(false)} accessibilityRole="button" style={styles.changeButton}><Text style={styles.changeText}>Use a different email</Text></Pressable>
              </View>
            ) : (
              <>
                <Pressable style={({ pressed }) => [styles.socialButton, styles.appleButton, pressed && styles.pressed]} onPress={() => socialSignIn('Apple')} accessibilityRole="button">
                  <Ionicons name="logo-apple" size={23} color="#FFF" /><Text style={styles.appleText}>Continue with Apple</Text>
                </Pressable>
                <Pressable style={({ pressed }) => [styles.socialButton, styles.googleButton, pressed && styles.pressed]} onPress={() => socialSignIn('Google')} accessibilityRole="button">
                  <GoogleMark /><Text style={styles.googleText}>Continue with Google</Text>
                </Pressable>
                <View style={styles.divider}><View style={styles.line} /><Text style={styles.dividerText}>or make yourself at home</Text><View style={styles.line} /></View>
                <Text style={styles.inputLabel}>Email address</Text>
                <View style={[styles.inputContainer, emailError && styles.inputError]}>
                  <Ionicons name="mail-outline" size={19} color="#8B9189" />
                  <TextInput style={styles.input} placeholder="you@example.com" placeholderTextColor="#9A9D95" keyboardType="email-address" autoCapitalize="none" autoCorrect={false} autoComplete="email" textContentType="emailAddress" accessibilityLabel="Email address" value={email} onChangeText={value => { setEmail(value); setEmailError(false); }} returnKeyType="go" onSubmitEditing={continueWithEmail} />
                </View>
                {emailError && <Text style={styles.errorText}>Enter a valid email address to continue.</Text>}
                <Pressable style={({ pressed }) => [styles.emailButton, pressed && styles.pressed]} onPress={continueWithEmail} accessibilityRole="button"><Text style={styles.emailButtonText}>Continue with email</Text><Ionicons name="arrow-forward" size={20} color="white" /></Pressable>
                <View style={styles.passwordless}><Ionicons name="lock-closed-outline" size={12} color="#858B81" /><Text style={styles.passwordlessText}>No passwords. Just a little inbox magic.</Text></View>
              </>
            )}
          </View>

          <View style={styles.footer}>
            <Text style={styles.terms}>By continuing, you agree to our <Text style={styles.legalLink} onPress={() => Alert.alert('Terms of Service', 'This is a demonstration of Gather. No account is created and no personal data is submitted.')} accessibilityRole="link">Terms of Service</Text>{'\n'}and <Text style={styles.legalLink} onPress={() => Alert.alert('Privacy Policy', 'Your email stays in this screen’s local state. This preview does not collect or share your information.')} accessibilityRole="link">Privacy Policy</Text>. Let’s keep this a good place.</Text>
            <View style={styles.footerNote}><Ionicons name="heart-outline" size={13} color="#848B7E" /><Text style={styles.footerNoteText}>A little less scrolling. A little more belonging.</Text></View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#F9F8F2' },
  flex: { flex: 1 },
  page: { flexGrow: 1, paddingHorizontal: 28, paddingTop: 14, paddingBottom: 19 },
  brand: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 7 },
  brandIcon: { width: 30, height: 30, borderRadius: 10, backgroundColor: '#E7EBDF', alignItems: 'center', justifyContent: 'center' },
  brandName: { color: green, fontSize: 27, fontWeight: '700', letterSpacing: -1.3 },
  hero: { alignItems: 'center', marginTop: 13, marginBottom: 27 },
  art: { width: 234, height: 177, alignItems: 'center', justifyContent: 'center' },
  orbit: { position: 'absolute', width: 165, height: 165, borderRadius: 90, borderWidth: 1, borderColor: '#E0E4D8', top: 0 },
  orbitInner: { position: 'absolute', width: 132, height: 132, borderRadius: 70, backgroundColor: '#EDF0E5', top: 17 },
  sun: { position: 'absolute', width: 49, height: 49, borderRadius: 25, backgroundColor: '#E9C374', left: 64, top: 28 },
  leafLeft: { position: 'absolute', width: 53, height: 83, borderTopLeftRadius: 55, borderBottomRightRadius: 55, backgroundColor: '#9BAE84', transform: [{ rotate: '-29deg' }], top: 55, left: 72 },
  leafRight: { position: 'absolute', width: 55, height: 90, borderTopRightRadius: 55, borderBottomLeftRadius: 55, backgroundColor: '#486A4E', transform: [{ rotate: '26deg' }], top: 31, left: 112 },
  stem: { position: 'absolute', width: 2, height: 68, backgroundColor: '#456348', top: 73, left: 117, transform: [{ rotate: '6deg' }] },
  spark: { position: 'absolute', top: 29, right: 23, transform: [{ rotate: '10deg' }] },
  smallDot: { position: 'absolute', width: 7, height: 7, borderRadius: 4, backgroundColor: '#BFCAAC', left: 24, top: 101 },
  artLabel: { position: 'absolute', bottom: 9, backgroundColor: '#FFFDF8', borderRadius: 20, paddingHorizontal: 13, paddingVertical: 9, flexDirection: 'row', alignItems: 'center', gap: 6, borderWidth: 1, borderColor: '#E5E7DC', transform: [{ rotate: '-5deg' }] },
  labelDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: '#789461' },
  artLabelText: { color: '#526347', fontSize: 10, fontWeight: '500' },
  eyebrow: { marginTop: 11, color: '#7A866F', fontSize: 9, fontWeight: '700', letterSpacing: 2 },
  title: { color: ink, fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif', fontSize: 43, lineHeight: 46, letterSpacing: -1.8, textAlign: 'center', marginTop: 12 },
  subtitle: { color: '#818479', fontSize: 14, lineHeight: 21, textAlign: 'center', marginTop: 13 },
  form: { width: '100%', maxWidth: 430, alignSelf: 'center' },
  socialButton: { height: 53, borderRadius: 13, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 10 },
  appleButton: { backgroundColor: ink },
  appleText: { color: '#FFF', fontSize: 14, fontWeight: '600' },
  googleButton: { backgroundColor: '#FFFDF9', borderWidth: 1, borderColor: '#DEDFD6', marginTop: 11 },
  googleText: { color: ink, fontSize: 14, fontWeight: '600' },
  divider: { flexDirection: 'row', alignItems: 'center', gap: 11, marginVertical: 22 },
  line: { flex: 1, height: 1, backgroundColor: '#E2E4DA' },
  dividerText: { fontSize: 10, color: '#969A8E' },
  inputLabel: { color: '#555F51', fontSize: 11, fontWeight: '600', marginBottom: 8 },
  inputContainer: { height: 51, borderWidth: 1, borderColor: '#DEDFD5', borderRadius: 12, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 14, gap: 11, backgroundColor: '#FDFCF7' },
  input: { flex: 1, height: '100%', color: ink, fontSize: 14 },
  inputError: { borderColor: '#AF604E' },
  errorText: { color: '#AF604E', fontSize: 11, marginTop: 7 },
  emailButton: { height: 52, backgroundColor: green, borderRadius: 12, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 13, marginTop: 12 },
  emailButtonText: { fontSize: 14, fontWeight: '600', color: '#FFF' },
  passwordless: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, marginTop: 12 },
  passwordlessText: { fontSize: 10, color: '#858B81' },
  footer: { marginTop: 'auto', paddingTop: 27, alignItems: 'center' },
  terms: { textAlign: 'center', color: '#92958B', fontSize: 10, lineHeight: 17 },
  legalLink: { textDecorationLine: 'underline', color: '#65705E' },
  footerNote: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, marginTop: 22 },
  footerNoteText: { fontSize: 9, color: '#848B7E', letterSpacing: 0.15 },
  pressed: { opacity: 0.75, transform: [{ scale: 0.99 }] },
  sentBox: { alignItems: 'center', paddingHorizontal: 20, paddingVertical: 32, backgroundColor: '#EDF0E5', borderRadius: 18, gap: 14 },
  sentTitle: { fontSize: 25, color: ink, fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif' },
  sentCopy: { fontSize: 14, color: '#6F7969', textAlign: 'center', lineHeight: 22 },
  changeButton: { padding: 10 },
  changeText: { color: green, fontWeight: '600', fontSize: 13, textDecorationLine: 'underline' },
});
