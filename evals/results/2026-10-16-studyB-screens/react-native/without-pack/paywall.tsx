import React, { useState } from 'react';
import { Alert, Modal, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import * as Haptics from 'expo-haptics';
import Svg, { Path, Circle, Ellipse } from 'react-native-svg';

type Plan = 'yearly' | 'monthly';

function JournalIllustration() {
  return (
    <View style={styles.illustration}>
      <View style={styles.halo} />
      <Svg width={270} height={184} viewBox="0 0 270 184">
        <Ellipse cx="136" cy="166" rx="79" ry="9" fill="#DCDCCD" opacity={0.55} />
        <Path d="M60 31 Q60 24 68 25 L183 36 Q190 37 189 45 L178 159 Q177 166 169 165 L54 153 Q47 152 48 144Z" fill="#536C51" />
        <Path d="M69 24 L187 35 L176 155 L58 144Z" fill="#F7F0DC" />
        <Path d="M73 20 L191 31 L180 150 L62 139Z" fill="#FFF9E9" />
        <Path d="M82 23 L73 140" stroke="#DDD9C5" strokeWidth="1.3" />
        <Path d="M97 51 L165 58 M95 62 L171 69 M93 73 L155 79 M91 99 L162 106 M90 110 L151 116" stroke="#D7D5C0" strokeWidth="2" strokeLinecap="round" />
        <Path d="M148 30 L164 32 L160 70 L153 63 L144 69Z" fill="#C78662" />
        <Path d="M204 147 Q201 112 218 78" stroke="#7C8D64" strokeWidth="2" fill="none" />
        <Path d="M207 122 Q184 113 194 99 Q210 101 207 122 M212 105 Q231 103 229 88 Q212 88 212 105 M218 85 Q204 72 217 62 Q230 69 218 85" fill="#8B9B75" />
        <Path d="M44 71 L44 84 M38 77.5 L50 77.5 M218 38 L218 47 M213.5 42.5 L222.5 42.5" stroke="#B69C65" strokeWidth="1.5" strokeLinecap="round" />
        <Circle cx="199" cy="61" r="2.5" fill="#B69C65" />
        <Circle cx="43" cy="119" r="2" fill="#A8B294" />
      </Svg>
      <View style={styles.illustrationLabel}><Feather name="sun" size={11} color="#5B6F4C" /><Text style={styles.illustrationLabelText}>A LITTLE SPACE FOR YOU</Text></View>
    </View>
  );
}

export default function Paywall() {
  const insets = useSafeAreaInsets();
  const [plan, setPlan] = useState<Plan>('yearly');
  const [dismissed, setDismissed] = useState(false);
  const [legal, setLegal] = useState<'Terms' | 'Privacy' | null>(null);

  const selectPlan = (value: Plan) => {
    setPlan(value);
    void Haptics.selectionAsync();
  };

  return (
    <View style={styles.screen}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      {dismissed ? (
        <View style={[styles.freeScreen, { paddingTop: insets.top + 40 }]}>
          <View style={styles.brand}><Feather name="book-open" size={19} color="#53674D" /><Text style={styles.brandText}>still</Text></View>
          <Text style={styles.freeTitle}>Come as you are.</Text>
          <Text style={styles.freeDescription}>Your next chapter starts with a moment to yourself.</Text>
          <View style={styles.promptCard}><Text style={styles.eyebrow}>TODAY’S JOURNAL PROMPT</Text><Text style={styles.prompt}>What’s one small thing you’re grateful for today?</Text></View>
          <Pressable style={styles.primaryButton} onPress={() => setDismissed(false)}><Text style={styles.primaryButtonText}>Explore Still Plus</Text><Feather name="arrow-right" size={18} color="#FFFFFF" /></Pressable>
          <Text style={styles.freeNote}>You’re using the free version of Still.</Text>
        </View>
      ) : (
        <>
          <View style={[styles.header, { paddingTop: insets.top + 9 }]}>
            <View style={styles.brand}><Feather name="book-open" size={18} color="#53674D" /><Text style={styles.brandText}>still<Text style={styles.brandPlus}> plus</Text></Text></View>
            <Pressable accessibilityLabel="Close paywall" hitSlop={12} onPress={() => setDismissed(true)} style={styles.closeButton}><Feather name="x" size={19} color="#797D70" /></Pressable>
          </View>
          <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
            <JournalIllustration />
            <Text style={styles.eyebrow}>MAKE ROOM FOR YOURSELF</Text>
            <Text style={styles.title}>A little reflection.{'\n'}A deeper connection.</Text>
            <Text style={styles.subtitle}>Turn everyday moments into a more mindful life.{'\n'}Your space to grow, with Still Plus.</Text>
            <View style={styles.benefits}>
              <Benefit icon="edit-3" title="Your thoughts, without limits" detail="Unlimited journals, photos & little moments" />
              <Benefit icon="compass" title="Find the words to begin" detail="Thoughtful prompts for every kind of day" />
              <Benefit icon="bar-chart-2" title="See how far you’ve come" detail="Mood patterns & meaningful insights" />
            </View>
            <View style={styles.plans}>
              <Pressable accessibilityRole="radio" accessibilityState={{ checked: plan === 'yearly' }} accessibilityLabel="Yearly plan, 29 dollars 99 cents per year" onPress={() => selectPlan('yearly')} style={[styles.planCard, plan === 'yearly' && styles.selectedPlan]}>
                <View style={[styles.radio, plan === 'yearly' && styles.selectedRadio]}>{plan === 'yearly' && <View style={styles.radioDot} />}</View>
                <View style={styles.planDetails}><View style={styles.planTitleRow}><Text style={styles.planTitle}>Yearly</Text><View style={styles.savingsBadge}><Text style={styles.savingsText}>SAVE 50%</Text></View></View><Text style={styles.planDescription}>$29.99 billed once a year</Text></View>
                <View style={styles.planPrice}><Text style={styles.price}>$2.50</Text><Text style={styles.pricePeriod}>/ month</Text></View>
              </Pressable>
              <Pressable accessibilityRole="radio" accessibilityState={{ checked: plan === 'monthly' }} accessibilityLabel="Monthly plan, 4 dollars 99 cents per month" onPress={() => selectPlan('monthly')} style={[styles.planCard, plan === 'monthly' && styles.selectedPlan]}>
                <View style={[styles.radio, plan === 'monthly' && styles.selectedRadio]}>{plan === 'monthly' && <View style={styles.radioDot} />}</View>
                <View style={styles.planDetails}><Text style={styles.planTitle}>Monthly</Text><Text style={styles.planDescription}>A little space, month by month</Text></View>
                <View style={styles.planPrice}><Text style={styles.price}>$4.99</Text><Text style={styles.pricePeriod}>/ month</Text></View>
              </Pressable>
            </View>
            <View style={styles.reassurance}><Feather name="shield" size={12} color="#7B806E" /><Text style={styles.reassuranceText}>Just for you. Always private. Cancel anytime.</Text></View>
          </ScrollView>
          <View style={[styles.footer, { paddingBottom: Math.max(insets.bottom, 16) }]}>
            <Pressable accessibilityRole="button" style={({ pressed }) => [styles.primaryButton, pressed && styles.buttonPressed]} onPress={() => { void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); Alert.alert('Your space is waiting', `You selected Still Plus ${plan === 'yearly' ? 'Yearly at $29.99 per year' : 'Monthly at $4.99 per month'}. This preview does not process payments.`, [{ text: 'Got it' }]); }}><Text style={styles.primaryButtonText}>Make time for you</Text><Feather name="arrow-right" size={18} color="#FFFFFF" /></Pressable>
            <Text style={styles.billingNote}>{plan === 'yearly' ? '$29.99 / year' : '$4.99 / month'} · Auto-renews. Cancel anytime.</Text>
            <View style={styles.footerLinks}>
              <Pressable hitSlop={8} onPress={() => Alert.alert('Restore purchases', 'No existing subscription was found in this preview. No payment has been taken.')}><Text style={styles.footerLink}>Restore purchases</Text></Pressable><Text style={styles.linkDot}>·</Text>
              <Pressable hitSlop={8} onPress={() => setLegal('Terms')}><Text style={styles.footerLink}>Terms</Text></Pressable><Text style={styles.linkDot}>·</Text>
              <Pressable hitSlop={8} onPress={() => setLegal('Privacy')}><Text style={styles.footerLink}>Privacy</Text></Pressable>
            </View>
          </View>
        </>
      )}
      <Modal visible={legal !== null} transparent animationType="fade" onRequestClose={() => setLegal(null)}>
        <View style={styles.modalBackdrop}><View style={styles.modalCard}><Text style={styles.modalTitle}>{legal === 'Terms' ? 'A note on subscriptions' : 'Your words stay yours'}</Text><Text style={styles.modalText}>{legal === 'Terms' ? 'Still Plus includes unlimited journals, guided prompts, and mood insights. The selected plan renews automatically unless cancelled before the next billing period. Manage or cancel your subscription in your app store settings. This is a preview; purchases are not enabled.' : 'Your journal is personal. This preview stores no journal entries, collects no payment information, and does not send your plan selection to a server. A complete privacy policy will be available before purchases are enabled.'}</Text><Pressable style={styles.primaryButton} onPress={() => setLegal(null)}><Text style={styles.primaryButtonText}>Got it</Text></Pressable></View></View>
      </Modal>
    </View>
  );
}

function Benefit({ icon, title, detail }: { icon: React.ComponentProps<typeof Feather>['name']; title: string; detail: string }) {
  return <View style={styles.benefit}><View style={styles.benefitIcon}><Feather name={icon} size={19} color="#657654" /></View><View style={styles.benefitCopy}><Text style={styles.benefitTitle}>{title}</Text><Text style={styles.benefitDetail}>{detail}</Text></View></View>;
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: '#FAF9F3' },
  header: { paddingHorizontal: 25, paddingBottom: 4, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  brandText: { fontFamily: 'Georgia', fontSize: 27, color: '#364632', letterSpacing: -1 },
  brandPlus: { fontFamily: undefined, fontSize: 12, fontWeight: '500', letterSpacing: 1, color: '#7B846C' },
  closeButton: { width: 32, height: 32, borderRadius: 16, backgroundColor: '#EFEEE6', alignItems: 'center', justifyContent: 'center' },
  content: { paddingHorizontal: 25, paddingBottom: 8, alignItems: 'center' },
  illustration: { height: 188, width: 280, alignItems: 'center', justifyContent: 'center', marginTop: 2, marginBottom: 8 },
  halo: { position: 'absolute', width: 181, height: 168, borderRadius: 90, backgroundColor: '#EDEEDF', top: 6 },
  illustrationLabel: { position: 'absolute', bottom: 2, flexDirection: 'row', gap: 5, alignItems: 'center', backgroundColor: '#F2F2E8', borderRadius: 14, paddingHorizontal: 11, paddingVertical: 6, transform: [{ rotate: '-4deg' }] },
  illustrationLabelText: { fontSize: 8, fontWeight: '600', letterSpacing: 1.2, color: '#687758' },
  eyebrow: { fontSize: 9, letterSpacing: 2.1, color: '#8A9278', fontWeight: '700', marginTop: 7 },
  title: { fontFamily: 'Georgia', fontSize: 32, lineHeight: 37, letterSpacing: -0.9, color: '#303C2D', textAlign: 'center', marginTop: 11 },
  subtitle: { fontSize: 12, lineHeight: 19, color: '#858579', textAlign: 'center', marginTop: 11 },
  benefits: { alignSelf: 'stretch', gap: 17, marginTop: 25, marginBottom: 25, paddingHorizontal: 8 },
  benefit: { flexDirection: 'row', alignItems: 'center', gap: 13 },
  benefitIcon: { width: 37, height: 37, borderRadius: 12, backgroundColor: '#EFF0E6', alignItems: 'center', justifyContent: 'center' },
  benefitCopy: { flex: 1, gap: 4 },
  benefitTitle: { fontSize: 13, fontWeight: '600', color: '#424A3A' },
  benefitDetail: { fontSize: 11, color: '#898A7E' },
  plans: { alignSelf: 'stretch', gap: 10 },
  planCard: { minHeight: 78, paddingHorizontal: 15, paddingVertical: 15, borderWidth: 1, borderColor: '#E2E2D8', borderRadius: 15, flexDirection: 'row', alignItems: 'center', backgroundColor: '#FDFCF8', gap: 12 },
  selectedPlan: { borderColor: '#71835C', backgroundColor: '#EFF2E7', borderWidth: 1.5, paddingHorizontal: 14.5, paddingVertical: 14.5 },
  radio: { width: 20, height: 20, borderRadius: 10, borderWidth: 1.3, borderColor: '#CFD0C3', alignItems: 'center', justifyContent: 'center' },
  selectedRadio: { borderColor: '#61784F', backgroundColor: '#61784F' },
  radioDot: { width: 7, height: 7, borderRadius: 4, backgroundColor: '#FFFFFF' },
  planDetails: { flex: 1, gap: 6 },
  planTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 9 },
  planTitle: { fontSize: 14, fontWeight: '600', color: '#3D4934' },
  savingsBadge: { backgroundColor: '#DDE5CE', paddingHorizontal: 7, paddingVertical: 4, borderRadius: 5 },
  savingsText: { fontSize: 8, fontWeight: '700', color: '#5B7049', letterSpacing: 0.5 },
  planDescription: { fontSize: 10, color: '#858877' },
  planPrice: { alignItems: 'flex-end', gap: 4 },
  price: { fontSize: 18, color: '#39472F', fontWeight: '600', letterSpacing: -0.5 },
  pricePeriod: { fontSize: 10, color: '#8C8E80' },
  reassurance: { flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 16, marginBottom: 5 },
  reassuranceText: { fontSize: 9, color: '#8B8D7F' },
  footer: { paddingHorizontal: 25, paddingTop: 10, backgroundColor: '#FAF9F3' },
  primaryButton: { minHeight: 53, borderRadius: 14, backgroundColor: '#536B45', alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 13, paddingHorizontal: 20 },
  primaryButtonText: { color: '#FFFFFF', fontSize: 14, fontWeight: '600', letterSpacing: 0.2 },
  buttonPressed: { opacity: 0.8 },
  billingNote: { fontSize: 9, color: '#8D8F81', textAlign: 'center', marginTop: 11 },
  footerLinks: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 13, marginTop: 14 },
  footerLink: { fontSize: 10, color: '#8B8D80' },
  linkDot: { fontSize: 10, color: '#B7B8AA' },
  freeScreen: { flex: 1, paddingHorizontal: 28, gap: 25 },
  freeTitle: { fontFamily: 'Georgia', fontSize: 38, color: '#303C2D', marginTop: 35 },
  freeDescription: { fontSize: 16, lineHeight: 25, color: '#858579' },
  promptCard: { padding: 23, backgroundColor: '#EFF2E7', borderRadius: 20, gap: 17, marginVertical: 15 },
  prompt: { fontFamily: 'Georgia', fontSize: 25, lineHeight: 34, color: '#424A3A' },
  freeNote: { fontSize: 12, textAlign: 'center', color: '#858579' },
  modalBackdrop: { flex: 1, justifyContent: 'center', padding: 25, backgroundColor: '#25301FCC' },
  modalCard: { borderRadius: 24, backgroundColor: '#FAF9F3', padding: 26, gap: 22 },
  modalTitle: { fontFamily: 'Georgia', fontSize: 27, color: '#303C2D' },
  modalText: { fontSize: 14, lineHeight: 23, color: '#777E6D' },
});
