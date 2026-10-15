import React, { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { Stack, router } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';

type PlanId = 'monthly' | 'yearly';

type Plan = {
  id: PlanId;
  title: string;
  price: string;
  period: string;
  subline: string;
  badge?: string;
};

const PLANS: Plan[] = [
  {
    id: 'yearly',
    title: 'Yearly',
    price: '$39.99',
    period: '/year',
    subline: 'Just $3.33/month · 7-day free trial',
    badge: 'Save 44%',
  },
  {
    id: 'monthly',
    title: 'Monthly',
    price: '$5.99',
    period: '/month',
    subline: 'Billed monthly · Cancel anytime',
  },
];

type Feature = {
  icon: React.ComponentProps<typeof Ionicons>['name'];
  title: string;
  body: string;
};

const FEATURES: Feature[] = [
  {
    icon: 'sparkles-outline',
    title: 'Guided prompts every day',
    body: '400+ reflection prompts for gratitude, mood and goals.',
  },
  {
    icon: 'lock-closed-outline',
    title: 'Private, encrypted entries',
    body: 'Face ID lock and end-to-end encrypted sync.',
  },
  {
    icon: 'analytics-outline',
    title: 'Mood insights',
    body: 'See patterns in how you feel across weeks and months.',
  },
  {
    icon: 'images-outline',
    title: 'Unlimited photos & voice notes',
    body: 'Capture moments however they come to you.',
  },
  {
    icon: 'cloud-download-outline',
    title: 'Export to PDF',
    body: 'Keep a beautiful printed copy of your year.',
  },
];

const COLORS = {
  bg: '#FBF7F2',
  ink: '#2B2420',
  muted: '#7A6E66',
  accent: '#C2603D',
  accentSoft: '#F6E3D9',
  card: '#FFFFFF',
  border: '#E8DFD6',
};

export default function PaywallScreen() {
  const [selected, setSelected] = useState<PlanId>('yearly');
  const [loading, setLoading] = useState(false);
  const plan = PLANS.find((p) => p.id === selected)!;

  const choose = (id: PlanId) => {
    if (id !== selected) Haptics.selectionAsync();
    setSelected(id);
  };

  const close = () => {
    if (router.canGoBack()) router.back();
  };

  const purchase = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      Alert.alert(
        'Welcome to Quill Premium',
        selected === 'yearly'
          ? 'Your 7-day free trial has started. You won’t be charged until Oct 21.'
          : 'Your monthly subscription is now active.',
      );
    }, 1200);
  };

  const restore = () => {
    Alert.alert('Restore purchases', 'No previous purchases were found for this Apple ID.');
  };

  return (
    <View style={styles.root}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <LinearGradient
        colors={['#F3D9C9', COLORS.bg]}
        style={StyleSheet.absoluteFill}
        end={{ x: 0.5, y: 0.45 }}
      />
      <SafeAreaView style={styles.flex} edges={['top', 'bottom']}>
        <View style={styles.topBar}>
          <Pressable
            onPress={restore}
            hitSlop={12}
            accessibilityRole="button"
          >
            <Text style={styles.topLink}>Restore</Text>
          </Pressable>
          <Pressable
            onPress={close}
            hitSlop={12}
            style={styles.closeBtn}
            accessibilityRole="button"
            accessibilityLabel="Close"
          >
            <Ionicons name="close" size={20} color={COLORS.ink} />
          </Pressable>
        </View>

        <ScrollView
          contentContainerStyle={styles.scroll}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.hero}>
            <View style={styles.heroIcon}>
              <Ionicons name="book" size={34} color="#fff" />
            </View>
            <Text style={styles.eyebrow}>QUILL PREMIUM</Text>
            <Text style={styles.title}>Make journaling a habit you keep</Text>
            <Text style={styles.subtitle}>
              Join 120,000+ writers reflecting a little every day.
            </Text>
          </View>

          <View style={styles.features}>
            {FEATURES.map((f) => (
              <View key={f.title} style={styles.featureRow}>
                <View style={styles.featureIcon}>
                  <Ionicons name={f.icon} size={18} color={COLORS.accent} />
                </View>
                <View style={styles.flex}>
                  <Text style={styles.featureTitle}>{f.title}</Text>
                  <Text style={styles.featureBody}>{f.body}</Text>
                </View>
              </View>
            ))}
          </View>

          <View style={styles.plans} accessibilityRole="radiogroup">
            {PLANS.map((p) => {
              const active = p.id === selected;
              return (
                <Pressable
                  key={p.id}
                  onPress={() => choose(p.id)}
                  accessibilityRole="radio"
                  accessibilityState={{ checked: active }}
                  accessibilityLabel={`${p.title}, ${p.price} ${p.period}. ${p.subline}`}
                  style={[styles.planCard, active && styles.planCardActive]}
                >
                  {p.badge ? (
                    <View style={styles.badge}>
                      <Text style={styles.badgeText}>{p.badge}</Text>
                    </View>
                  ) : null}
                  <View style={[styles.radio, active && styles.radioActive]}>
                    {active ? <View style={styles.radioDot} /> : null}
                  </View>
                  <View style={styles.flex}>
                    <Text style={styles.planTitle}>{p.title}</Text>
                    <Text style={styles.planSub}>{p.subline}</Text>
                  </View>
                  <Text style={styles.planPrice}>
                    {p.price}
                    <Text style={styles.planPeriod}>{p.period}</Text>
                  </Text>
                </Pressable>
              );
            })}
          </View>

          <View style={styles.quote}>
            <Text style={styles.quoteText}>
              “The mood insights showed me I write best on Sunday mornings. I haven’t
              missed a week since.”
            </Text>
            <View style={styles.quoteMeta}>
              {[0, 1, 2, 3, 4].map((i) => (
                <Ionicons key={i} name="star" size={12} color="#E0A33A" />
              ))}
              <Text style={styles.quoteAuthor}>  Priya M., journaling 214 days</Text>
            </View>
          </View>
        </ScrollView>

        <View style={styles.footer}>
          <Pressable
            onPress={purchase}
            disabled={loading}
            accessibilityRole="button"
            style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85 }]}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.ctaText}>
                {selected === 'yearly' ? 'Start 7-day free trial' : 'Subscribe for $5.99/month'}
              </Text>
            )}
          </Pressable>
          <Text style={styles.legal}>
            {selected === 'yearly'
              ? `Free for 7 days, then ${plan.price}${plan.period}. `
              : `${plan.price}${plan.period}, renews automatically. `}
            Cancel anytime in Settings.
          </Text>
          <View style={styles.legalLinks}>
            <Text style={styles.legalLink}>Terms of Use</Text>
            <Text style={styles.legal}> · </Text>
            <Text style={styles.legalLink}>Privacy Policy</Text>
          </View>
        </View>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: COLORS.bg },
  flex: { flex: 1 },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 4,
    height: 44,
  },
  topLink: { color: COLORS.muted, fontSize: 15, fontWeight: '500' },
  closeBtn: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.7)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  scroll: { paddingHorizontal: 20, paddingBottom: 24 },
  hero: { alignItems: 'center', marginTop: 8, marginBottom: 24 },
  heroIcon: {
    width: 68,
    height: 68,
    borderRadius: 20,
    backgroundColor: COLORS.accent,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    shadowColor: COLORS.accent,
    shadowOpacity: 0.35,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 6 },
    elevation: 6,
  },
  eyebrow: {
    fontSize: 12,
    letterSpacing: 1.6,
    fontWeight: '700',
    color: COLORS.accent,
    marginBottom: 8,
  },
  title: {
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '700',
    color: COLORS.ink,
    textAlign: 'center',
    fontFamily: 'Georgia',
  },
  subtitle: {
    fontSize: 15,
    color: COLORS.muted,
    textAlign: 'center',
    marginTop: 8,
  },
  features: { gap: 14, marginBottom: 24 },
  featureRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 12 },
  featureIcon: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: COLORS.accentSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  featureTitle: { fontSize: 15, fontWeight: '600', color: COLORS.ink },
  featureBody: { fontSize: 13, color: COLORS.muted, marginTop: 2, lineHeight: 18 },
  plans: { gap: 12, marginBottom: 20 },
  planCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.card,
    borderWidth: 1.5,
    borderColor: COLORS.border,
  },
  planCardActive: { borderColor: COLORS.accent, backgroundColor: '#FFFBF8' },
  badge: {
    position: 'absolute',
    top: -10,
    right: 16,
    backgroundColor: COLORS.accent,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
  },
  badgeText: { color: '#fff', fontSize: 11, fontWeight: '700' },
  radio: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 2,
    borderColor: COLORS.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  radioActive: { borderColor: COLORS.accent },
  radioDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: COLORS.accent },
  planTitle: { fontSize: 16, fontWeight: '600', color: COLORS.ink },
  planSub: { fontSize: 12.5, color: COLORS.muted, marginTop: 2 },
  planPrice: { fontSize: 17, fontWeight: '700', color: COLORS.ink },
  planPeriod: { fontSize: 12, fontWeight: '500', color: COLORS.muted },
  quote: {
    backgroundColor: COLORS.card,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  quoteText: {
    fontSize: 14,
    lineHeight: 20,
    color: COLORS.ink,
    fontStyle: 'italic',
    fontFamily: 'Georgia',
  },
  quoteMeta: { flexDirection: 'row', alignItems: 'center', marginTop: 10 },
  quoteAuthor: { fontSize: 12, color: COLORS.muted },
  footer: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: COLORS.border,
    backgroundColor: COLORS.bg,
  },
  cta: {
    height: 54,
    borderRadius: 16,
    backgroundColor: COLORS.ink,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ctaText: { color: '#fff', fontSize: 17, fontWeight: '600' },
  legal: { fontSize: 11.5, color: COLORS.muted, textAlign: 'center', marginTop: 8 },
  legalLinks: { flexDirection: 'row', justifyContent: 'center', alignItems: 'baseline' },
  legalLink: { fontSize: 11.5, color: COLORS.ink, textDecorationLine: 'underline', marginTop: 8 },
});
