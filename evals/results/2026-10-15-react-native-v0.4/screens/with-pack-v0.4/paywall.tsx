// Paywall — "Margins Plus" for a journaling app (mobile-ui archetype: Paywall).
// Job: pick a plan and start. Focal: headline + pre-selected yearly plan. Primary: one pinned CTA that states the deal.
// Cut: feature comparison table (behind "Compare free and Plus"), hero illustration (the headline carries the screen).

import React, { useState } from 'react';
import { Alert, Linking, ScrollView, View } from 'react-native';
import { Stack, router } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import {
  QBottomActionBar,
  QIconButton,
  QLargeTextFooter,
  QPlanCard,
  QPrimaryButton,
  QTertiaryButton,
  QText,
  useQLargeText,
} from '../../pack04/components';
import { space, useQTheme } from '../../pack04/theme';

type PlanId = 'monthly' | 'yearly';

type Plan = {
  id: PlanId;
  name: string;
  price: string;
  period: string;
  detail: string;
  badge?: string;
  trialDays: number;
  cta: string;
  terms: string;
};

const PLANS: Plan[] = [
  {
    id: 'monthly',
    name: 'Monthly',
    price: '$5.99',
    period: '/month',
    detail: 'Billed every month',
    trialDays: 0,
    cta: 'Subscribe for $5.99/month',
    terms: '$5.99/month, renews automatically. Cancel anytime in Settings.',
  },
  {
    id: 'yearly',
    name: 'Yearly',
    price: '$39.99',
    period: '/year',
    detail: '$3.33/month',
    badge: 'Save 44%',
    trialDays: 7,
    cta: 'Start 7-day free trial',
    terms: '7 days free, then $39.99/year. Cancel anytime in Settings.',
  },
];

// Outcomes, not features. Four, one line each.
const BENEFITS = [
  'Write as much as you want, with photos and voice notes',
  'Gentle prompts when you don’t know where to start',
  'A monthly look back at what you wrote and felt',
  'Private by default, locked with Face ID',
];

// Trial timeline (builds trust): what happens and when. Dates relative to today.
function trialSteps() {
  const fmt = (offset: number) => {
    const d = new Date();
    d.setDate(d.getDate() + offset);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };
  return [
    { when: 'Today', what: 'Everything in Plus unlocks' },
    { when: fmt(5), what: 'We remind you before the trial ends' },
    { when: fmt(7), what: 'Billed $39.99 for the year' },
  ];
}

export default function JournalPaywall() {
  const { c } = useQTheme();
  const insets = useSafeAreaInsets();
  const large = useQLargeText();
  const [planId, setPlanId] = useState<PlanId>('yearly');
  const [purchasing, setPurchasing] = useState(false);

  const plan = PLANS.find((p) => p.id === planId) ?? PLANS[1];

  const close = () => {
    if (router.canGoBack()) router.back();
  };

  const purchase = async () => {
    setPurchasing(true);
    // Replace with the store call (RevenueCat / expo-iap): await purchase(plan.id)
    await new Promise((r) => setTimeout(r, 900));
    setPurchasing(false);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    Alert.alert('Welcome to Plus', plan.trialDays ? 'Your 7-day trial has started.' : 'Your subscription is active.');
  };

  const restore = () => {
    Alert.alert('Nothing to restore', 'We couldn’t find a previous Plus purchase on this Apple ID.');
  };

  const legal = (
    <>
      <QText variant="footnote" color="ink2" style={{ textAlign: 'center' }}>
        {plan.terms}
      </QText>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', columnGap: space.md }}>
        <QTertiaryButton title="Terms" onPress={() => Linking.openURL('https://margins.app/terms')} />
        <QTertiaryButton title="Privacy" onPress={() => Linking.openURL('https://margins.app/privacy')} />
      </View>
    </>
  );

  const steps = trialSteps();

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <Stack.Screen options={{ headerShown: false, contentStyle: { backgroundColor: c.canvas } }} />
      <StatusBar style="auto" />

      {/* Close visible from the first frame; Restore as a quiet text action. */}
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingHorizontal: space.md,
          paddingTop: insets.top + space.xs,
        }}
      >
        <QIconButton icon="close" label="Close" filled onPress={close} />
        <QTertiaryButton title="Restore purchases" onPress={restore} />
      </View>

      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={{ paddingHorizontal: space.margin, paddingTop: space.lg, paddingBottom: space.xl, gap: space.xl }}
      >
        <View style={{ gap: space.xs }}>
          <QText variant="overline" color="ink2">
            Margins Plus
          </QText>
          <QText variant="largeTitle" role="header">
            {'Keep the days\nyou’d otherwise forget.'}
          </QText>
        </View>

        <View style={{ gap: space.sm }}>
          {BENEFITS.map((b) => (
            <View key={b} style={{ flexDirection: 'row', gap: space.sm, alignItems: 'flex-start' }}>
              <Ionicons name="checkmark" size={20} color={c.ink} style={{ marginTop: 1 }} accessibilityElementsHidden importantForAccessibility="no" />
              <QText style={{ flex: 1 }}>{b}</QText>
            </View>
          ))}
        </View>

        <View
          accessibilityRole="radiogroup"
          accessibilityLabel="Choose a plan"
          style={{ flexDirection: large ? 'column' : 'row', gap: space.sm }}
        >
          {PLANS.map((p) => (
            <View key={p.id} style={{ flexDirection: 'row', flex: large ? undefined : 1 }}>
              <QPlanCard
                name={p.name}
                price={p.price}
                period={p.period}
                detail={p.detail}
                badge={p.badge}
                selected={planId === p.id}
                onPress={() => setPlanId(p.id)}
              />
            </View>
          ))}
        </View>

        {plan.trialDays > 0 ? (
          <View style={{ gap: space.sm }}>
            <QText variant="overline" color="ink2">
              How your trial works
            </QText>
            {steps.map((s, i) => (
              <View key={s.when} style={{ flexDirection: 'row', gap: space.sm }}>
                <View style={{ alignItems: 'center', width: space.sm, paddingTop: space.xs }}>
                  <View
                    style={{
                      width: space.xs,
                      height: space.xs,
                      borderRadius: space.xxs,
                      backgroundColor: i === 0 ? c.accent : c.ink3,
                    }}
                  />
                  {i < steps.length - 1 && (
                    <View style={{ flex: 1, width: 1, marginTop: space.xxs, backgroundColor: c.hairline }} />
                  )}
                </View>
                <View style={{ flex: 1, paddingBottom: i < steps.length - 1 ? space.xs : 0 }}>
                  <QText variant="subhead" color="ink2">
                    {s.when}
                  </QText>
                  <QText>{s.what}</QText>
                </View>
              </View>
            ))}
          </View>
        ) : (
          <QText variant="subhead" color="ink2">
            Billed today and every month after. No trial on the monthly plan.
          </QText>
        )}

        <QTertiaryButton
          title="Compare free and Plus"
          onPress={() => Alert.alert('Free vs Plus', 'Free: 3 entries a week, text only.\nPlus: unlimited entries, photos, voice notes, prompts and monthly recaps.')}
        />

        {/* At accessibility sizes only the CTA stays pinned; terms move here. */}
        <QLargeTextFooter>{legal}</QLargeTextFooter>
      </ScrollView>

      <QBottomActionBar footer={legal}>
        <QPrimaryButton title={plan.cta} loading={purchasing} onPress={purchase} />
      </QBottomActionBar>
    </View>
  );
}
