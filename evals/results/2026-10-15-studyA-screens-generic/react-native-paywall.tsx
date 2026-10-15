import React, { useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useColorScheme,
} from 'react-native';
import { Stack, router } from 'expo-router';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { StatusBar } from 'expo-status-bar';

type PlanId = 'yearly' | 'monthly';

type Plan = {
  id: PlanId;
  title: string;
  price: string;
  period: string;
  detail: string;
  badge?: string;
  trial?: string;
};

const PLANS: Plan[] = [
  {
    id: 'yearly',
    title: 'Yearly',
    price: '$39.99',
    period: 'year',
    detail: 'Just $3.33/month, billed annually',
    badge: 'Save 44%',
    trial: '7-day free trial',
  },
  {
    id: 'monthly',
    title: 'Monthly',
    price: '$5.99',
    period: 'month',
    detail: 'Billed monthly, cancel anytime',
  },
];

const FEATURES: { icon: keyof typeof Ionicons.glyphMap; title: string; body: string }[] = [
  {
    icon: 'sparkles-outline',
    title: 'Guided prompts every day',
    body: '365+ reflective prompts that adapt to your mood and goals.',
  },
  {
    icon: 'lock-closed-outline',
    title: 'Private & encrypted',
    body: 'End-to-end encryption with Face ID lock for every entry.',
  },
  {
    icon: 'images-outline',
    title: 'Unlimited photos & audio',
    body: 'Attach memories, voice notes and places to any day.',
  },
  {
    icon: 'stats-chart-outline',
    title: 'Mood insights',
    body: 'See patterns in your sleep, energy and gratitude over time.',
  },
  {
    icon: 'cloud-done-outline',
    title: 'Sync across devices',
    body: 'Write on your phone, finish on your iPad. Always backed up.',
  },
];

function usePalette() {
  const dark = useColorScheme() === 'dark';
  return useMemo(
    () =>
      dark
        ? {
            dark,
            bg: '#121110',
            card: '#1E1C1A',
            text: '#F6F2EC',
            secondary: '#B3ACA3',
            tertiary: '#857E76',
            border: '#34302C',
            accent: '#E39A5B',
            accentText: '#1A120B',
            accentSoft: 'rgba(227,154,91,0.16)',
            heroFrom: '#3A2617',
            heroTo: '#121110',
          }
        : {
            dark,
            bg: '#FBF8F4',
            card: '#FFFFFF',
            text: '#1F1A15',
            secondary: '#6B635A',
            tertiary: '#968D83',
            border: '#E7E0D7',
            accent: '#C2652A',
            accentText: '#FFFFFF',
            accentSoft: 'rgba(194,101,42,0.10)',
            heroFrom: '#F7E3CF',
            heroTo: '#FBF8F4',
          },
    [dark]
  );
}

export default function PaywallScreen() {
  const c = usePalette();
  const insets = useSafeAreaInsets();
  const [selected, setSelected] = useState<PlanId>('yearly');
  const [purchasing, setPurchasing] = useState(false);

  const plan = PLANS.find((p) => p.id === selected)!;

  const selectPlan = (id: PlanId) => {
    if (id !== selected) {
      Haptics.selectionAsync().catch(() => {});
      setSelected(id);
    }
  };

  const close = () => {
    if (router.canGoBack()) router.back();
  };

  const subscribe = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {});
    setPurchasing(true);
    await new Promise((r) => setTimeout(r, 1200));
    setPurchasing(false);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {});
    Alert.alert('Welcome to Inkwell Plus', `Your ${plan.title.toLowerCase()} plan is active. Happy writing!`);
  };

  const restore = () => {
    Alert.alert('Restore Purchases', 'No previous purchases were found for this Apple ID.');
  };

  const ctaLabel = plan.trial ? 'Start Free Trial' : 'Subscribe';
  const ctaFootnote = plan.trial
    ? `${plan.trial}, then ${plan.price}/${plan.period}. Cancel anytime.`
    : `${plan.price}/${plan.period}. Cancel anytime.`;

  return (
    <View style={[styles.root, { backgroundColor: c.bg }]}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style={c.dark ? 'light' : 'dark'} />

      <LinearGradient
        colors={[c.heroFrom, c.heroTo]}
        style={[styles.heroGradient, { height: 340 + insets.top }]}
        pointerEvents="none"
      />

      <SafeAreaView edges={['top']} style={styles.topBar}>
        <Pressable
          onPress={close}
          hitSlop={12}
          accessibilityRole="button"
          accessibilityLabel="Close"
          style={({ pressed }) => [
            styles.closeButton,
            { backgroundColor: c.dark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.06)', opacity: pressed ? 0.6 : 1 },
          ]}
        >
          <Ionicons name="close" size={20} color={c.secondary} />
        </Pressable>
      </SafeAreaView>

      <ScrollView
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 56 }]}
        showsVerticalScrollIndicator={false}
        contentInsetAdjustmentBehavior="never"
      >
        <View style={styles.hero}>
          <View style={[styles.appIcon, { backgroundColor: c.accent }]}>
            <Ionicons name="book" size={36} color={c.accentText} />
          </View>
          <Text style={[styles.eyebrow, { color: c.accent }]} accessibilityRole="text">
            INKWELL PLUS
          </Text>
          <Text style={[styles.title, { color: c.text }]} accessibilityRole="header">
            Make writing a habit you love
          </Text>
          <Text style={[styles.subtitle, { color: c.secondary }]}>
            Join 120,000+ people who journal with Inkwell to feel calmer, clearer and more grateful.
          </Text>
        </View>

        <View style={[styles.featureCard, { backgroundColor: c.card, borderColor: c.border }]}>
          {FEATURES.map((f, i) => (
            <View
              key={f.title}
              style={[
                styles.featureRow,
                i < FEATURES.length - 1 && { borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: c.border },
              ]}
              accessible
              accessibilityLabel={`${f.title}. ${f.body}`}
            >
              <View style={[styles.featureIcon, { backgroundColor: c.accentSoft }]}>
                <Ionicons name={f.icon} size={20} color={c.accent} />
              </View>
              <View style={styles.featureText}>
                <Text style={[styles.featureTitle, { color: c.text }]}>{f.title}</Text>
                <Text style={[styles.featureBody, { color: c.secondary }]}>{f.body}</Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.testimonial} accessible accessibilityLabel="Rated 4.8 out of 5. Review: I've journaled more in three months than in the last five years. — Maya R.">
          <View style={styles.stars}>
            {[0, 1, 2, 3, 4].map((s) => (
              <Ionicons key={s} name="star" size={14} color={c.accent} />
            ))}
            <Text style={[styles.rating, { color: c.secondary }]}>4.8 · 18K ratings</Text>
          </View>
          <Text style={[styles.quote, { color: c.text }]}>
            “I’ve journaled more in three months than in the last five years.”
          </Text>
          <Text style={[styles.quoteAuthor, { color: c.tertiary }]}>Maya R.</Text>
        </View>

        <Text style={[styles.sectionTitle, { color: c.text }]} accessibilityRole="header">
          Choose your plan
        </Text>

        <View accessibilityRole="radiogroup" style={styles.plans}>
          {PLANS.map((p) => {
            const active = p.id === selected;
            return (
              <Pressable
                key={p.id}
                onPress={() => selectPlan(p.id)}
                accessibilityRole="radio"
                accessibilityState={{ checked: active }}
                accessibilityLabel={`${p.title}, ${p.price} per ${p.period}. ${p.detail}.${p.trial ? ` Includes ${p.trial}.` : ''}${p.badge ? ` ${p.badge}.` : ''}`}
                style={({ pressed }) => [
                  styles.planCard,
                  {
                    backgroundColor: active ? c.accentSoft : c.card,
                    borderColor: active ? c.accent : c.border,
                    opacity: pressed ? 0.85 : 1,
                  },
                ]}
              >
                <View style={[styles.radio, { borderColor: active ? c.accent : c.tertiary }]}>
                  {active && <View style={[styles.radioDot, { backgroundColor: c.accent }]} />}
                </View>
                <View style={styles.planInfo}>
                  <View style={styles.planTitleRow}>
                    <Text style={[styles.planTitle, { color: c.text }]}>{p.title}</Text>
                    {p.badge && (
                      <View style={[styles.badge, { backgroundColor: c.accent }]}>
                        <Text style={[styles.badgeText, { color: c.accentText }]}>{p.badge}</Text>
                      </View>
                    )}
                  </View>
                  <Text style={[styles.planDetail, { color: c.secondary }]}>{p.detail}</Text>
                  {p.trial && <Text style={[styles.planTrial, { color: c.accent }]}>{p.trial}</Text>}
                </View>
                <View style={styles.planPrice}>
                  <Text style={[styles.price, { color: c.text }]}>{p.price}</Text>
                  <Text style={[styles.period, { color: c.tertiary }]}>/{p.period}</Text>
                </View>
              </Pressable>
            );
          })}
        </View>

        <View style={styles.links}>
          <Pressable onPress={restore} accessibilityRole="button" hitSlop={8}>
            <Text style={[styles.link, { color: c.secondary }]}>Restore Purchases</Text>
          </Pressable>
          <Text style={[styles.link, { color: c.tertiary }]}>·</Text>
          <Pressable onPress={() => {}} accessibilityRole="link" hitSlop={8}>
            <Text style={[styles.link, { color: c.secondary }]}>Terms</Text>
          </Pressable>
          <Text style={[styles.link, { color: c.tertiary }]}>·</Text>
          <Pressable onPress={() => {}} accessibilityRole="link" hitSlop={8}>
            <Text style={[styles.link, { color: c.secondary }]}>Privacy</Text>
          </Pressable>
        </View>

        <Text style={[styles.legal, { color: c.tertiary }]}>
          Payment is charged to your {Platform.OS === 'ios' ? 'Apple ID' : 'Google Play'} account at confirmation.
          Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.
          Manage or cancel anytime in your account settings.
        </Text>
      </ScrollView>

      <View
        style={[
          styles.footer,
          {
            backgroundColor: c.bg,
            borderTopColor: c.border,
            paddingBottom: Math.max(insets.bottom, 16),
          },
        ]}
      >
        <Pressable
          onPress={subscribe}
          disabled={purchasing}
          accessibilityRole="button"
          accessibilityLabel={`${ctaLabel}. ${ctaFootnote}`}
          accessibilityState={{ disabled: purchasing, busy: purchasing }}
          style={({ pressed }) => [
            styles.cta,
            { backgroundColor: c.accent, opacity: pressed || purchasing ? 0.85 : 1 },
          ]}
        >
          {purchasing ? (
            <ActivityIndicator color={c.accentText} />
          ) : (
            <Text style={[styles.ctaText, { color: c.accentText }]}>{ctaLabel}</Text>
          )}
        </Pressable>
        <Text style={[styles.ctaFootnote, { color: c.secondary }]}>{ctaFootnote}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  heroGradient: { position: 'absolute', top: 0, left: 0, right: 0 },
  topBar: {
    position: 'absolute',
    top: 0,
    right: 0,
    zIndex: 10,
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  closeButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 8,
  },
  scroll: { paddingHorizontal: 20, paddingBottom: 32 },
  hero: { alignItems: 'center', marginBottom: 28 },
  appIcon: {
    width: 76,
    height: 76,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 18,
    shadowColor: '#7A3A12',
    shadowOpacity: 0.25,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 6,
  },
  eyebrow: { fontSize: 13, fontWeight: '700', letterSpacing: 1.2, marginBottom: 8 },
  title: {
    fontSize: 30,
    lineHeight: 36,
    fontWeight: '700',
    textAlign: 'center',
    letterSpacing: -0.4,
    fontFamily: Platform.select({ ios: 'Georgia', android: 'serif' }),
  },
  subtitle: { fontSize: 16, lineHeight: 22, textAlign: 'center', marginTop: 10, paddingHorizontal: 8 },
  featureCard: { borderRadius: 18, borderWidth: StyleSheet.hairlineWidth, paddingHorizontal: 16 },
  featureRow: { flexDirection: 'row', alignItems: 'flex-start', paddingVertical: 14, gap: 14 },
  featureIcon: { width: 36, height: 36, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  featureText: { flex: 1, flexShrink: 1 },
  featureTitle: { fontSize: 16, fontWeight: '600', lineHeight: 21 },
  featureBody: { fontSize: 14, lineHeight: 19, marginTop: 2 },
  testimonial: { alignItems: 'center', marginTop: 24, marginBottom: 8, paddingHorizontal: 12 },
  stars: { flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', justifyContent: 'center', gap: 2 },
  rating: { fontSize: 13, marginLeft: 6 },
  quote: {
    fontSize: 17,
    lineHeight: 24,
    textAlign: 'center',
    fontStyle: 'italic',
    marginTop: 8,
    fontFamily: Platform.select({ ios: 'Georgia', android: 'serif' }),
  },
  quoteAuthor: { fontSize: 13, marginTop: 6 },
  sectionTitle: { fontSize: 20, fontWeight: '700', marginTop: 24, marginBottom: 12 },
  plans: { gap: 12 },
  planCard: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderRadius: 16,
    paddingVertical: 16,
    paddingHorizontal: 16,
    gap: 14,
    minHeight: 72,
  },
  radio: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  radioDot: { width: 12, height: 12, borderRadius: 6 },
  planInfo: { flex: 1, flexShrink: 1 },
  planTitleRow: { flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap', gap: 8 },
  planTitle: { fontSize: 17, fontWeight: '600' },
  badge: { borderRadius: 999, paddingHorizontal: 8, paddingVertical: 3 },
  badgeText: { fontSize: 12, fontWeight: '700' },
  planDetail: { fontSize: 14, lineHeight: 19, marginTop: 4 },
  planTrial: { fontSize: 13, fontWeight: '600', marginTop: 4 },
  planPrice: { alignItems: 'flex-end', flexShrink: 0, maxWidth: '40%' },
  price: { fontSize: 20, fontWeight: '700', fontVariant: ['tabular-nums'] },
  period: { fontSize: 13 },
  links: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 10,
    marginTop: 24,
  },
  link: { fontSize: 14, paddingVertical: 6 },
  legal: { fontSize: 12, lineHeight: 17, textAlign: 'center', marginTop: 12 },
  footer: {
    paddingHorizontal: 20,
    paddingTop: 12,
    borderTopWidth: StyleSheet.hairlineWidth,
  },
  cta: {
    minHeight: 54,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    paddingHorizontal: 20,
  },
  ctaText: { fontSize: 17, fontWeight: '700', textAlign: 'center' },
  ctaFootnote: { fontSize: 13, lineHeight: 18, textAlign: 'center', marginTop: 8 },
});
