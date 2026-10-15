// PaywallScreen.tsx — Paywall archetype (mobile-ui/references/screen-paywall.md).
// Present full-screen (Expo Router: <Stack.Screen name="paywall" options={{ presentation: 'fullScreenModal', headerShown: false }} />).
// A page-sheet 'modal' would double the top inset: the sheet already sits below the status bar.
// Close visible from frame one. Recommended plan pre-selected. CTA states the deal. Terms beside CTA.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import React, { useState } from 'react';
import { Linking, Platform, ScrollView, View } from 'react-native';
import { router } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import { QBottomActionBar, QIconButton, QLargeTextFooter, QPlanCard, QPrimaryButton, QTertiaryButton, QText } from '../components';
import { space, useQTheme } from '../theme';

type Plan = 'monthly' | 'yearly';

const BENEFITS = [
  'Unlimited journals and entries',
  'Weekly insights on your mood patterns',
  'Sync across all your devices',
  'Lock sensitive entries with your face or fingerprint',
];

// Editorial personality: a serif display face for the headline only.
const SERIF = Platform.select({ ios: 'Georgia', default: 'serif' });

export default function PaywallScreen() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const [plan, setPlan] = useState<Plan>('yearly');
  const [purchasing, setPurchasing] = useState(false);

  const cta = plan === 'yearly' ? 'Start 7-day free trial' : 'Subscribe for $7.99/month';
  const terms =
    plan === 'yearly' ? '7 days free, then $49.99/year. Cancel anytime in Settings.' : '$7.99/month. Cancel anytime in Settings.';

  const purchase = async () => {
    setPurchasing(true);
    // await purchasePackage(...)
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setPurchasing(false);
  };

  // Plain-language terms + links: pinned under the CTA, or in the scroll content at large text sizes.
  const legal = (
    <>
      <QText variant="footnote" color="ink2" style={{ textAlign: 'center' }}>
        {terms}
      </QText>
      <View style={{ flexDirection: 'row', justifyContent: 'center', gap: space.md }}>
        <QTertiaryButton title="Terms" onPress={() => Linking.openURL('https://example.com/terms')} />
        <QTertiaryButton title="Privacy" onPress={() => Linking.openURL('https://example.com/privacy')} />
      </View>
    </>
  );

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: space.md, paddingTop: insets.top + space.xs }}>
        <QIconButton icon="close" label="Close" filled onPress={() => router.back()} />
        <QTertiaryButton title="Restore" onPress={() => {}} />
      </View>

      <ScrollView contentContainerStyle={{ paddingHorizontal: space.margin, paddingTop: space.xl, paddingBottom: space.xl, gap: space.xl }}>
        <QText variant="largeTitle" style={{ fontFamily: SERIF }}>
          {'Write it down.\nSee the pattern.'}
        </QText>

        <View style={{ gap: space.sm }}>
          {BENEFITS.map((b) => (
            <View key={b} style={{ flexDirection: 'row', gap: space.sm, alignItems: 'flex-start' }}>
              <Ionicons name="checkmark" size={20} color={c.accent} style={{ marginTop: 1 }} />
              <QText style={{ flex: 1 }}>{b}</QText>
            </View>
          ))}
        </View>

        <View accessibilityRole="radiogroup" style={{ flexDirection: 'row', gap: space.sm }}>
          <QPlanCard name="Monthly" price="$7.99" period="/mo" detail="Billed monthly" selected={plan === 'monthly'} onPress={() => setPlan('monthly')} />
          <QPlanCard name="Yearly" price="$49.99" period="/yr" detail="$4.17/mo" badge="Save 48%" selected={plan === 'yearly'} onPress={() => setPlan('yearly')} />
        </View>

        {/* At accessibility sizes the bar pins only the button; the terms move here. */}
        <QLargeTextFooter>{legal}</QLargeTextFooter>
      </ScrollView>

      <QBottomActionBar footer={legal}>
        <QPrimaryButton title={cta} loading={purchasing} onPress={purchase} />
      </QBottomActionBar>
    </View>
  );
}
