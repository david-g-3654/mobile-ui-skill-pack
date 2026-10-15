// Paywall — "Margin Plus" for a journaling app (mobile-ui paywall archetype).
// Job: pick a plan and start. Focal: headline + pre-selected yearly plan. Primary: one pinned CTA that states the deal.
// Cut: feature comparison table (behind "See everything in Plus"), hero illustration (serif headline carries the personality).

import React, { useState } from 'react';
import { Alert, Linking, Platform, ScrollView, View } from 'react-native';
import { router, Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import {
  BottomActionBar,
  IconButton,
  LargeTextFooter,
  PlanCard,
  PrimaryButton,
  TertiaryButton,
  Txt,
  useLargeText,
} from '../../pack/components';
import { space, useTheme } from '../../pack/theme';

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
    price: '$6.99',
    period: '/month',
    detail: 'Billed every month',
    trialDays: 0,
    cta: 'Subscribe for $6.99/month',
    terms: '$6.99 billed monthly. Cancel anytime in Settings.',
  },
  {
    id: 'yearly',
    name: 'Yearly',
    price: '$44.99',
    period: '/year',
    detail: 'Just $3.75 a month',
    badge: 'Save 46%',
    trialDays: 7,
    cta: 'Try Plus free for 7 days',
    terms: 'Free until Oct 21, then $44.99/year. Cancel anytime in Settings.',
  },
];

const BENEFITS = [
  'Unlimited entries with photos and voice notes',
  'A monthly recap written from your own words',
  'Lock your journal with Face ID or a passcode',
  'Export everything to PDF, whenever you like',
];

// Trial timeline: shown only when the selected plan has a free trial.
const TRIAL_STEPS = [
  { when: 'Today', what: 'Every Plus feature unlocks.' },
  { when: 'Oct 19', what: 'We send a reminder two days before you’re billed.' },
  { when: 'Oct 21', what: 'Your yearly plan starts. Cancel before then and pay nothing.' },
];

// One display face for personality, headline only.
const SERIF = Platform.select({ ios: 'Georgia', default: 'serif' });

export default function PaywallScreen() {
  const { c } = useTheme();
  const insets = useSafeAreaInsets();
  const large = useLargeText();
  const [planId, setPlanId] = useState<PlanId>('yearly');
  const [purchasing, setPurchasing] = useState(false);

  const plan = PLANS.find((p) => p.id === planId) ?? PLANS[1];

  const close = () => {
    if (router.canGoBack()) router.back();
  };

  const restore = () => {
    Alert.alert('Nothing to restore', 'We couldn’t find a Plus purchase on this Apple ID.');
  };

  const purchase = async () => {
    setPurchasing(true);
    await new Promise((resolve) => setTimeout(resolve, 900)); // stand-in for the store purchase call
    setPurchasing(false);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    Alert.alert('Welcome to Plus', 'Your recap for October arrives on Nov 1.');
  };

  const legal = (
    <>
      <Txt variant="footnote" color="ink2" style={{ textAlign: 'center' }}>
        {plan.terms}
      </Txt>
      <View style={{ flexDirection: 'row', justifyContent: 'center', gap: space.md }}>
        <TertiaryButton title="Terms" onPress={() => Linking.openURL('https://example.com/terms')} />
        <TertiaryButton title="Privacy" onPress={() => Linking.openURL('https://example.com/privacy')} />
      </View>
    </>
  );

  return (
    <View style={{ flex: 1, backgroundColor: c.canvas }}>
      <Stack.Screen options={{ headerShown: false, contentStyle: { backgroundColor: c.canvas } }} />
      <StatusBar style="auto" />

      {/* Close visible from the first frame; restore as quiet text. */}
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
          paddingHorizontal: space.margin,
          paddingTop: insets.top + space.xs,
        }}
      >
        <IconButton icon="close" label="Close" filled onPress={close} />
        <TertiaryButton title="Restore purchase" onPress={restore} />
      </View>

      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: space.margin,
          paddingTop: space.lg,
          paddingBottom: space.xl,
          gap: space.xl,
        }}
      >
        <View style={{ gap: space.xs }}>
          <Txt variant="subhead" color="ink2">
            You’ve written 38 entries since June.
          </Txt>
          <Txt variant="largeTitle" role="header" style={{ fontFamily: SERIF }}>
            {'Keep writing.\nNotice more.'}
          </Txt>
        </View>

        <View style={{ gap: space.sm }}>
          {BENEFITS.map((b) => (
            <View key={b} style={{ flexDirection: 'row', gap: space.sm, alignItems: 'flex-start' }}>
              <Ionicons name="checkmark" size={20} color={c.ink} style={{ marginTop: 1 }} />
              <Txt style={{ flex: 1 }}>{b}</Txt>
            </View>
          ))}
        </View>

        <View
          accessibilityRole="radiogroup"
          style={{ flexDirection: large ? 'column' : 'row', gap: space.sm }}
        >
          {PLANS.map((p) => (
            <PlanCard
              key={p.id}
              name={p.name}
              price={p.price}
              period={p.period}
              detail={p.detail}
              badge={p.badge}
              selected={planId === p.id}
              onPress={() => setPlanId(p.id)}
            />
          ))}
        </View>

        {plan.trialDays > 0 && (
          <View style={{ gap: space.md }}>
            <Txt variant="subhead" color="ink2">
              How your free week works
            </Txt>
            {TRIAL_STEPS.map((step, i) => (
              <View key={step.when} style={{ flexDirection: 'row', gap: space.sm }}>
                <View style={{ alignItems: 'center', width: space.md, paddingTop: space.xxs }}>
                  <View
                    style={{
                      width: space.sm,
                      height: space.sm,
                      borderRadius: space.xs,
                      backgroundColor: i === 0 ? c.accent : c.surface2,
                      borderWidth: i === 0 ? 0 : 2,
                      borderColor: c.hairline,
                    }}
                  />
                </View>
                <View style={{ flex: 1, gap: space.xxs }}>
                  <Txt variant="subhead" style={{ fontWeight: '600' }}>
                    {step.when}
                  </Txt>
                  <Txt variant="subhead" color="ink2">
                    {step.what}
                  </Txt>
                </View>
              </View>
            ))}
          </View>
        )}

        <View style={{ alignItems: 'flex-start' }}>
          <TertiaryButton
            title="See everything in Plus"
            onPress={() => Alert.alert('Margin Plus', 'Themes, templates, prompts, and unlimited history.')}
          />
        </View>

        {/* At accessibility sizes only the button stays pinned; terms move here. */}
        <LargeTextFooter>{legal}</LargeTextFooter>
      </ScrollView>

      <BottomActionBar footer={legal}>
        <PrimaryButton title={plan.cta} loading={purchasing} onPress={purchase} />
      </BottomActionBar>
    </View>
  );
}
