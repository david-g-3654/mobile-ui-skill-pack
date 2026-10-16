import React, { useState } from 'react';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import {
  QBadge,
  QBottomActionBar,
  QIconButton,
  QLargeTextFooter,
  QPrimaryButton,
  QScreen,
  QText,
  QTertiaryButton,
  useQLargeText,
} from '../../pack04/components';
import { metrics, radius, space, tabular, type, useQTheme } from '../../pack04/theme';

type Plan = 'monthly' | 'yearly';

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const plans = [
  { id: 'monthly' as const, name: 'Monthly', price: 5.99, period: '/ month', detail: 'Billed monthly' },
  { id: 'yearly' as const, name: 'Yearly', price: 39.99, period: '/ year', detail: `${currency.format(39.99 / 12)} / month` },
];
const benefits = [
  'Find your words with guided prompts',
  'Understand your mood over time',
  'Revisit your growth with reflections',
];

export default function Paywall() {
  const { c } = useQTheme();
  const router = useRouter();
  const largeText = useQLargeText();
  const [selected, setSelected] = useState<Plan>('yearly');
  const [dismissed, setDismissed] = useState(false);
  const annual = selected === 'yearly';

  const close = () => {
    if (router.canGoBack()) router.back();
    else setDismissed(true);
  };

  const showLegal = (kind: 'Terms' | 'Privacy') => {
    Alert.alert(
      kind === 'Terms' ? 'Subscription terms' : 'Your privacy',
      kind === 'Terms'
        ? 'Preview terms: yearly access is $39.99 after a 7-day free trial; monthly access is $5.99 with no trial. Subscriptions renew automatically unless canceled in your store subscription settings before renewal. This preview does not make purchases.'
        : 'This is a local interface preview. No journal entries or payment information are collected or sent by this screen. The published app must provide its full privacy policy before accepting subscriptions.',
      [{ text: 'Got it' }],
    );
  };

  const footer = (
    <View style={styles.footer}>
      <QText variant="footnote" color="ink2" style={styles.center}>
        {annual
          ? `7 days free, then ${currency.format(39.99)}/year. Auto-renews.`
          : `${currency.format(5.99)}/month. Auto-renews. No free trial.`}
        {'\n'}Cancel anytime in your store settings.
      </QText>
      <View style={styles.legalLinks}>
        {(['Terms', 'Privacy'] as const).map((kind) => (
          <Pressable
            key={kind}
            accessibilityRole="button"
            accessibilityLabel={kind === 'Terms' ? 'Read subscription terms' : 'Read privacy information'}
            onPress={() => showLegal(kind)}
            style={({ pressed }) => [styles.legalButton, pressed && { backgroundColor: c.surface2 }]}
          >
            <QText variant="footnote" color="ink2" style={styles.underlined}>{kind}</QText>
          </Pressable>
        ))}
      </View>
    </View>
  );

  return (
    <View style={[styles.root, { backgroundColor: c.canvas }]}>
      <StatusBar style="auto" />
      <Stack.Screen
        options={{
          title: dismissed ? 'Your journal' : '',
          headerShown: true,
          headerLargeTitle: false,
          headerShadowVisible: false,
          headerStyle: { backgroundColor: c.canvas },
          headerTintColor: c.ink,
          contentStyle: { backgroundColor: c.canvas },
          headerLeft: dismissed ? () => null : () => <QIconButton icon="close-outline" label="Close paywall" onPress={close} />,
          headerRight: dismissed ? () => null : () => (
            <QTertiaryButton
              title="Restore purchases"
              onPress={() => Alert.alert('Restore purchases', 'No store account is connected in this preview. In the published app, this restores a subscription bought with your current store account.', [{ text: 'Got it' }])}
            />
          ),
        }}
      />
      {dismissed ? (
        <QScreen contentContainerStyle={styles.dismissedContent}>
          <QText variant="largeTitle" role="header" style={styles.display}>A moment for you.</QText>
          <QText variant="subhead" color="ink2">Your free journal is always here. Come back to Plus whenever you’re ready.</QText>
          <View style={[styles.entry, { borderColor: c.hairline }]}>
            <QText variant="footnote" color="ink2">Today · A small thing I noticed</QText>
            <QText variant="subhead">I took the long way home today. For once, I wasn’t in a hurry to be anywhere else.</QText>
          </View>
          <QTertiaryButton title="Explore Still Plus" onPress={() => setDismissed(false)} />
        </QScreen>
      ) : (
        <>
          <QScreen contentContainerStyle={styles.content}>
            <View style={styles.hero}>
              <View style={styles.brand}>
                <View accessible={false} accessibilityElementsHidden importantForAccessibility="no-hide-descendants" style={[styles.bookMark, { backgroundColor: c.surface2 }]}>
                  <Ionicons name="book-outline" size={space.xl} color={c.ink} />
                </View>
                <QText variant="footnote" color="ink2" style={styles.semibold}>Still Plus</QText>
              </View>
              <QText variant="largeTitle" role="header" style={styles.display}>Make room{'\n'}for yourself.</QText>
              <QText variant="subhead" color="ink2">Turn a few quiet minutes into a deeper understanding of you.</QText>
            </View>

            <View style={styles.benefits}>
              {benefits.map((benefit) => (
                <View key={benefit} style={styles.benefit} accessible accessibilityLabel={benefit}>
                  <Ionicons name="checkmark-outline" size={space.lg} color={c.ink} accessible={false} />
                  <QText variant="subhead" style={styles.flexText}>{benefit}</QText>
                </View>
              ))}
            </View>

            <View style={styles.planSection}>
              <QText variant="footnote" color="ink2">A little commitment to yourself</QText>
              <View style={[styles.plans, largeText && styles.stacked]} accessibilityRole="radiogroup" accessibilityLabel="Subscription plans">
                {plans.map((plan) => {
                  const active = selected === plan.id;
                  return (
                    <Pressable
                      key={plan.id}
                      accessibilityRole="radio"
                      accessibilityState={{ selected: active }}
                      accessibilityLabel={`${plan.name}, ${currency.format(plan.price)} ${plan.period.replace('/ ', 'per ')}, ${plan.detail}${plan.id === 'yearly' ? ', 7-day free trial, save 44 percent compared with monthly billing' : ', no free trial'}`}
                      onPress={() => {
                        if (!active) {
                          void Haptics.selectionAsync().catch(() => undefined);
                          setSelected(plan.id);
                        }
                      }}
                      style={({ pressed }) => [
                        styles.plan,
                        { backgroundColor: pressed ? c.surface2 : active ? c.accentSoft : c.surface, borderColor: active ? c.accent : c.hairline },
                      ]}
                    >
                      <View style={styles.planHeading}>
                        <QText variant="headline">{plan.name}</QText>
                        <Ionicons name={active ? 'checkmark-circle-outline' : 'ellipse-outline'} size={space.xl} color={active ? c.accent : c.ink2} />
                      </View>
                      <View style={styles.price}>
                        <QText variant="title" style={tabular}>{currency.format(plan.price)}</QText>
                        <QText variant="footnote" color="ink2">{plan.period}</QText>
                      </View>
                      <QText variant="footnote" color="ink2">{plan.detail}</QText>
                      {plan.id === 'yearly' ? <QBadge text="Save 44%" /> : <QText variant="footnote" color="ink2">Flexible billing</QText>}
                    </Pressable>
                  );
                })}
              </View>
            </View>
            <QLargeTextFooter>{footer}</QLargeTextFooter>
          </QScreen>
          <QBottomActionBar footer={footer}>
            <QPrimaryButton
              title={annual ? 'Start 7-day free trial' : 'Subscribe monthly'}
              accessibilityHint={annual ? 'Review the yearly subscription preview' : 'Review the monthly subscription preview'}
              onPress={() => Alert.alert(
                'Subscription preview',
                `${annual ? `7 days free, then ${currency.format(39.99)} per year` : `${currency.format(5.99)} per month with no trial`}. This screen is a demo; no purchase has been made. Store billing must be connected before subscriptions can begin.`,
                [{ text: 'Got it' }],
              )}
            />
          </QBottomActionBar>
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  content: { paddingTop: space.sm, paddingBottom: space.md, gap: space.xl, maxWidth: 640, width: '100%', alignSelf: 'center' },
  hero: { gap: space.sm },
  brand: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
  bookMark: { width: space.xxxl, height: space.xxxl, borderRadius: radius.m, alignItems: 'center', justifyContent: 'center' },
  display: { fontWeight: type.title.fontWeight },
  semibold: { fontWeight: type.headline.fontWeight },
  benefits: { gap: space.sm },
  benefit: { flexDirection: 'row', alignItems: 'flex-start', gap: space.sm },
  flexText: { flex: 1 },
  planSection: { gap: space.sm },
  plans: { flexDirection: 'row', gap: space.sm, alignItems: 'stretch' },
  stacked: { flexDirection: 'column' },
  plan: { flex: 1, borderWidth: 2, borderRadius: radius.l, padding: space.md, gap: space.xs, minHeight: metrics.minTap },
  planHeading: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: space.xs },
  price: { flexDirection: 'row', alignItems: 'baseline', flexWrap: 'wrap', columnGap: space.xxs },
  footer: { gap: space.xxs },
  center: { textAlign: 'center' },
  legalLinks: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', gap: space.xs },
  legalButton: { minHeight: metrics.minTap, minWidth: metrics.minTap, paddingHorizontal: space.sm, justifyContent: 'center', borderRadius: radius.s },
  underlined: { textDecorationLine: 'underline' },
  dismissedContent: { paddingTop: space.xxl },
  entry: { borderTopWidth: StyleSheet.hairlineWidth, paddingTop: space.xl, gap: space.sm },
});
