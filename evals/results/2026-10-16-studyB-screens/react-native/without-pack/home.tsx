import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable, Modal, TextInput, Platform } from 'react-native';
import { Stack } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { StatusBar } from 'expo-status-bar';
import Svg, { Circle } from 'react-native-svg';

const colors = { background: '#F8F9F5', ink: '#203C32', muted: '#87918A', green: '#D7EDB1', line: '#E8EBE4' };
const initialTransactions = [
  { name: 'Whole Foods Market', category: 'Groceries', date: 'Today', amount: 64.28, icon: 'basket-outline' as const, color: '#EAF0DD' },
  { name: 'Blue Bottle Coffee', category: 'Food & drinks', date: 'Today', amount: 6.50, icon: 'cafe-outline' as const, color: '#F2E8DB' },
  { name: 'Spotify Premium', category: 'Subscriptions', date: 'Yesterday', amount: 10.99, icon: 'musical-notes-outline' as const, color: '#E3ECE6' },
];
const budgets = [
  { name: 'Groceries', spent: 284, total: 400, icon: 'basket-outline' as const, color: '#A7BE86' },
  { name: 'Food & drinks', spent: 168, total: 200, icon: 'restaurant-outline' as const, color: '#D7B18C' },
  { name: 'Shopping', spent: 95, total: 250, icon: 'bag-handle-outline' as const, color: '#AAAEC9' },
];

export default function Home() {
  const [tab, setTab] = useState('Home');
  const [month, setMonth] = useState('October');
  const [monthPicker, setMonthPicker] = useState(false);
  const [showAll, setShowAll] = useState(false);
  const [expenseOpen, setExpenseOpen] = useState(false);
  const [expenseName, setExpenseName] = useState('');
  const [expenseAmount, setExpenseAmount] = useState('');
  const [transactions, setTransactions] = useState(initialTransactions);
  const addedSpending = transactions.slice(0, Math.max(0, transactions.length - 3)).reduce((sum, item) => sum + item.amount, 0);
  const spent = 1248.50 + addedSpending;
  const remaining = 3200 - spent;
  const money = (value: number) => value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const addExpense = () => {
    const amount = Number(expenseAmount);
    if (!expenseName.trim() || !Number.isFinite(amount) || amount <= 0) return;
    setTransactions([{ name: expenseName.trim(), category: 'Shopping', date: 'Today', amount, icon: 'basket-outline', color: '#EAF0DD' }, ...transactions]);
    setExpenseName(''); setExpenseAmount(''); setExpenseOpen(false);
  };

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar style="dark" />
      <View style={styles.header}>
        <View style={styles.brand}><View style={styles.brandMark}><Ionicons name="leaf" size={21} color={colors.ink} /></View><Text style={styles.wordmark}>sprout<Text style={{ color: '#8BA66B' }}>.</Text></Text></View>
        <Pressable accessibilityLabel="Open profile" onPress={() => setTab('Profile')} style={styles.avatar}><Text style={styles.avatarText}>JL</Text><View style={styles.online} /></Pressable>
      </View>

      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
        {tab === 'Home' ? <>
          <View style={styles.greetingRow}><View><Text style={styles.eyebrow}>A LITTLE CLARITY, EVERY DAY</Text><Text style={styles.title}>Hey, Jamie <Text style={{ fontSize: 25 }}>✳</Text></Text></View></View>
          <View style={styles.sectionIntro}><Text style={styles.subtitle}>Let’s make room for what matters.</Text><Pressable accessibilityLabel="Select month" onPress={() => setMonthPicker(true)} style={styles.month}><Text style={styles.monthText}>{month}</Text><Ionicons name="chevron-down" size={12} color={colors.ink} /></Pressable></View>

          <View style={styles.balanceCard}>
            <View style={styles.balanceTop}><View style={styles.balanceLabel}><View style={styles.dot} /><Text style={styles.cardLabel}>LEFT TO SPEND</Text></View><Text style={styles.period}>{month.slice(0, 3).toUpperCase()} 1 – 31</Text></View>
            <View style={styles.balanceRow}><Text style={styles.balance}>${money(remaining).split('.')[0]}<Text style={styles.cents}>.{money(remaining).split('.')[1]}</Text></Text><View style={styles.circleArrow}><Ionicons name="arrow-forward" size={23} color={colors.ink} style={{ transform: [{ rotate: '-45deg' }] }} /></View></View>
            <Text style={styles.balanceHint}>A little mindful spending goes a long way.</Text>
            <View style={styles.track}><View style={[styles.trackFill, { width: `${Math.min(spent / 3200 * 100, 100)}%` }]} /></View>
            <View style={styles.cardBottom}><Text style={styles.spentText}>${money(spent)} <Text style={styles.cardMuted}>spent</Text></Text><Text style={styles.cardMuted}>of $3,200.00</Text></View>
          </View>

          <View style={styles.statsRow}>
            <View style={styles.statCard}><View style={styles.statLabel}><View style={styles.statIcon}><Ionicons name="arrow-down" size={13} color="#517B48" /></View><Text style={styles.statText}>Income</Text></View><Text style={styles.statAmount}>$4,850<Text style={styles.statDecimal}>.00</Text></Text><Text style={styles.statFoot}>All looking good <Text style={{ color: '#799365' }}>↗</Text></Text></View>
            <View style={styles.statCard}><View style={styles.statLabel}><View style={[styles.statIcon, { backgroundColor: '#F2E9DE' }]}><Ionicons name="sparkles-outline" size={13} color="#997752" /></View><Text style={styles.statText}>Set aside</Text></View><Text style={styles.statAmount}>$650<Text style={styles.statDecimal}>.00</Text></Text><Text style={styles.statFoot}>For your future self</Text></View>
          </View>

          <View style={styles.sectionHeading}><Text style={styles.sectionTitle}>Your budgets</Text><Pressable onPress={() => setTab('Budgets')} hitSlop={10}><Text style={styles.link}>See all <Text style={{ fontSize: 16 }}>↗</Text></Text></Pressable></View>
          <View style={styles.budgetsCard}>{budgets.map((budget, index) => <View key={budget.name} style={[styles.budgetRow, index !== 2 && styles.budgetDivider]}><View style={[styles.categoryIcon, { backgroundColor: `${budget.color}30` }]}><Ionicons name={budget.icon} size={20} color={colors.ink} /></View><View style={styles.budgetBody}><View style={styles.budgetInfo}><Text style={styles.budgetName}>{budget.name}</Text><Text style={styles.budgetAmount}>${budget.spent} <Text style={styles.budgetTotal}>/ ${budget.total}</Text></Text></View><View style={styles.budgetTrack}><View style={{ width: `${budget.spent / budget.total * 100}%`, backgroundColor: budget.color, height: 4, borderRadius: 3 }} /></View></View></View>)}</View>

          <View style={styles.sectionHeading}><Text style={styles.sectionTitle}>Recent activity</Text><Pressable onPress={() => { setShowAll(!showAll); }} hitSlop={10}><Text style={styles.link}>{showAll ? 'Show less' : 'View all'} <Text style={{ fontSize: 16 }}>↗</Text></Text></Pressable></View>
          <View>{(showAll ? [...transactions, { name: 'Sunday farmers market', category: 'Groceries', date: 'Oct 12', amount: 32, icon: 'leaf-outline' as const, color: '#EAF0DD' }] : transactions.slice(0, 3)).map((item, index) => <View style={styles.transaction} key={`${item.name}-${index}`}><View style={[styles.transactionIcon, { backgroundColor: item.color }]}><Ionicons name={item.icon} size={21} color={colors.ink} /></View><View style={styles.transactionBody}><Text style={styles.transactionName}>{item.name}</Text><Text style={styles.transactionMeta}>{item.category} <Text style={{ color: '#BCC1B8' }}> · </Text> {item.date}</Text></View><Text style={styles.transactionAmount}>−${money(item.amount)}</Text></View>)}</View>
          <View style={styles.note}><Ionicons name="leaf-outline" size={14} color="#8B9B7D" /><Text style={styles.noteText}>Small steps. A little more peace of mind.</Text></View>
        </> : tab === 'Budgets' ? <>
          <Text style={styles.eyebrow}>A PLAN THAT FEELS LIKE YOU</Text><Text style={styles.pageTitle}>Your budgets</Text><Text style={styles.pageSubtitle}>Give every dollar a little direction.</Text>
          {budgets.map(budget => <View key={budget.name} style={styles.detailCard}><View style={styles.budgetInfo}><Text style={styles.sectionTitle}>{budget.name}</Text><Ionicons name={budget.icon} size={22} color={colors.ink} /></View><Text style={styles.detailAmount}>${budget.total - budget.spent} <Text style={styles.statText}>left to spend</Text></Text><View style={styles.budgetTrack}><View style={{ width: `${budget.spent / budget.total * 100}%`, backgroundColor: budget.color, height: 4 }} /></View><Text style={styles.detailCaption}>${budget.spent} spent of ${budget.total} this month</Text></View>)}
        </> : tab === 'Insights' ? <>
          <Text style={styles.eyebrow}>THE BIGGER PICTURE</Text><Text style={styles.pageTitle}>Growing awareness.</Text><Text style={styles.pageSubtitle}>Here’s where your money is going this month.</Text>
          <View style={[styles.detailCard, { alignItems: 'center', paddingVertical: 30 }]}><View style={styles.chart}><Svg width={180} height={180} viewBox="0 0 180 180"><Circle cx="90" cy="90" r="76" fill="none" stroke="#E9EDE3" strokeWidth="15" /><Circle cx="90" cy="90" r="76" fill="none" stroke="#A7BE86" strokeWidth="15" strokeDasharray="290 478" rotation="-90" origin="90,90" strokeLinecap="round" /><Circle cx="90" cy="90" r="76" fill="none" stroke="#D7B18C" strokeWidth="15" strokeDasharray="100 478" strokeDashoffset="-300" rotation="-90" origin="90,90" strokeLinecap="round" /></Svg><View style={styles.chartCenter}><Text style={styles.statText}>Total spent</Text><Text style={styles.chartAmount}>${money(spent)}</Text></View></View><Text style={styles.detailCaption}>You’re keeping your spending in balance.</Text></View>
          {budgets.map(budget => <View key={budget.name} style={styles.insightRow}><View style={[styles.dot, { backgroundColor: budget.color }]} /><Text style={[styles.budgetName, { flex: 1 }]}>{budget.name}</Text><Text style={styles.budgetAmount}>${budget.spent}</Text></View>)}
        </> : <>
          <Text style={styles.eyebrow}>YOUR OWN LITTLE CORNER</Text><Text style={styles.pageTitle}>Hello, Jamie.</Text><View style={styles.detailCard}><View style={styles.profileAvatar}><Text style={styles.profileInitials}>JL</Text></View><Text style={[styles.sectionTitle, { textAlign: 'center', marginTop: 16 }]}>Jamie Lee</Text><Text style={[styles.pageSubtitle, { textAlign: 'center', marginTop: 6 }]}>jamie.lee@email.com</Text></View><View style={styles.detailCard}><Text style={styles.sectionTitle}>Your monthly plan</Text><Text style={styles.detailAmount}>$3,200<Text style={styles.statText}> / month</Text></Text><Text style={styles.detailCaption}>Currency: USD · Month starts on the 1st</Text></View>
        </>}
      </ScrollView>

      <View style={styles.navigation}>{['Home', 'Budgets', 'Add', 'Insights', 'Profile'].map((item, index) => item === 'Add' ? <Pressable key={item} accessibilityLabel="Add expense" onPress={() => setExpenseOpen(true)} style={styles.addButton}><Ionicons name="add" size={27} color="#F8F9F5" /></Pressable> : <Pressable key={item} accessibilityRole="tab" accessibilityState={{ selected: tab === item }} onPress={() => setTab(item)} style={styles.navItem}><Ionicons name={(['home-outline', 'wallet-outline', 'add', 'pie-chart-outline', 'person-outline'] as const)[index]} size={22} color={tab === item ? colors.ink : '#9AA298'} /><Text style={[styles.navLabel, tab === item && styles.navLabelActive]}>{item}</Text>{tab === item && <View style={styles.navDot} />}</Pressable>)}</View>

      <Modal visible={monthPicker} transparent animationType="fade" onRequestClose={() => setMonthPicker(false)}><Pressable style={styles.overlay} onPress={() => setMonthPicker(false)}><View style={styles.modalCard}><Text style={styles.sectionTitle}>Choose a month</Text>{['August', 'September', 'October'].map(item => <Pressable key={item} onPress={() => { setMonth(item); setMonthPicker(false); }} style={styles.monthOption}><Text style={styles.budgetName}>{item} 2026</Text><Ionicons name={month === item ? 'checkmark-circle' : 'ellipse-outline'} size={21} color={colors.ink} /></Pressable>)}</View></Pressable></Modal>
      <Modal visible={expenseOpen} transparent animationType="slide" onRequestClose={() => setExpenseOpen(false)}><View style={styles.overlay}><View style={styles.modalCard}><View style={styles.budgetInfo}><Text style={styles.sectionTitle}>A little expense</Text><Pressable accessibilityLabel="Close" hitSlop={15} onPress={() => setExpenseOpen(false)}><Ionicons name="close" size={24} color={colors.ink} /></Pressable></View><Text style={styles.inputLabel}>What was it for?</Text><TextInput value={expenseName} onChangeText={setExpenseName} placeholder="e.g. Lunch with a friend" placeholderTextColor="#9AA298" style={styles.input} /><Text style={styles.inputLabel}>Amount ($)</Text><TextInput value={expenseAmount} onChangeText={setExpenseAmount} placeholder="0.00" placeholderTextColor="#9AA298" keyboardType="decimal-pad" style={styles.input} /><Pressable onPress={addExpense} style={[styles.saveButton, (!expenseName.trim() || Number(expenseAmount) <= 0 || !Number.isFinite(Number(expenseAmount))) && { opacity: 0.5 }]}><Text style={styles.saveText}>Add expense</Text><Ionicons name="arrow-forward" size={18} color="#FFF" /></Pressable></View></View></Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.background },
  header: { paddingHorizontal: 25, paddingTop: 12, paddingBottom: 25, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  brand: { flexDirection: 'row', alignItems: 'center', gap: 7 }, brandMark: { transform: [{ rotate: '-20deg' }] }, wordmark: { fontSize: 28, fontWeight: '700', letterSpacing: -1.5, color: colors.ink },
  avatar: { width: 39, height: 39, borderRadius: 20, backgroundColor: '#E8EADD', alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: '#DCE0D1' }, avatarText: { fontSize: 12, fontWeight: '600', color: '#59664E' }, online: { width: 9, height: 9, borderRadius: 5, backgroundColor: '#8AA56A', position: 'absolute', bottom: 0, right: 0, borderWidth: 2, borderColor: colors.background },
  content: { paddingHorizontal: 24, paddingBottom: 14 }, greetingRow: { flexDirection: 'row', justifyContent: 'space-between' }, eyebrow: { fontSize: 9, letterSpacing: 1.8, color: '#8A9485', fontWeight: '600', marginBottom: 9 }, title: { fontSize: 32, letterSpacing: -1.3, color: colors.ink, fontWeight: '500' }, sectionIntro: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 8, marginBottom: 23, gap: 6 }, subtitle: { fontSize: 11, color: '#818B80', flexShrink: 1 }, month: { flexDirection: 'row', gap: 5, alignItems: 'center', paddingVertical: 6, paddingHorizontal: 9, borderWidth: 1, borderColor: '#E2E7DB', borderRadius: 7 }, monthText: { fontSize: 10, color: colors.ink, fontWeight: '500' },
  balanceCard: { backgroundColor: colors.green, borderRadius: 20, padding: 21 }, balanceTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }, balanceLabel: { flexDirection: 'row', alignItems: 'center', gap: 6 }, dot: { width: 5, height: 5, borderRadius: 5, backgroundColor: colors.ink }, cardLabel: { fontSize: 9, fontWeight: '600', color: '#4D6440', letterSpacing: 1.3 }, period: { fontSize: 8, color: '#627C4E', letterSpacing: 0.8 }, balanceRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 13 }, balance: { fontSize: 45, letterSpacing: -2, color: colors.ink, fontWeight: '500', fontVariant: ['tabular-nums'] }, cents: { color: '#6A8451', fontSize: 33, fontWeight: '400' }, circleArrow: { width: 35, height: 35, borderRadius: 18, backgroundColor: '#E5F3CB', alignItems: 'center', justifyContent: 'center' }, balanceHint: { fontSize: 10, color: '#607A4D', marginTop: 7, marginBottom: 23 }, track: { height: 5, borderRadius: 5, backgroundColor: '#BBD495', overflow: 'hidden' }, trackFill: { height: 5, borderRadius: 5, backgroundColor: '#405E36' }, cardBottom: { marginTop: 10, flexDirection: 'row', justifyContent: 'space-between' }, spentText: { fontSize: 10, color: colors.ink, fontWeight: '600' }, cardMuted: { fontSize: 10, fontWeight: '400', color: '#698153' },
  statsRow: { flexDirection: 'row', gap: 12, marginTop: 13 }, statCard: { flex: 1, backgroundColor: '#FFF', borderRadius: 15, borderWidth: 1, borderColor: colors.line, padding: 15 }, statLabel: { flexDirection: 'row', alignItems: 'center', gap: 6 }, statIcon: { width: 21, height: 21, borderRadius: 7, alignItems: 'center', justifyContent: 'center', backgroundColor: '#EDF2E5' }, statText: { fontSize: 11, color: '#7A8679', fontWeight: '400' }, statAmount: { fontSize: 24, letterSpacing: -0.8, color: colors.ink, marginTop: 10, fontWeight: '500' }, statDecimal: { fontSize: 18, color: '#85907C', fontWeight: '400' }, statFoot: { fontSize: 9, color: '#98A08F', marginTop: 5 },
  sectionHeading: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 26, marginBottom: 13 }, sectionTitle: { fontSize: 18, fontWeight: '500', letterSpacing: -0.5, color: colors.ink }, link: { fontSize: 10, color: '#718266', fontWeight: '500' }, budgetsCard: { backgroundColor: '#FFF', borderWidth: 1, borderColor: colors.line, borderRadius: 15, paddingHorizontal: 15 }, budgetRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 14 }, budgetDivider: { borderBottomWidth: 1, borderBottomColor: '#F0F1EB' }, categoryIcon: { width: 36, height: 36, borderRadius: 11, alignItems: 'center', justifyContent: 'center' }, budgetBody: { flex: 1 }, budgetInfo: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }, budgetName: { fontSize: 12, fontWeight: '500', color: colors.ink }, budgetAmount: { fontSize: 11, color: colors.ink, fontWeight: '500' }, budgetTotal: { fontWeight: '400', color: '#9AA391', fontSize: 10 }, budgetTrack: { height: 4, backgroundColor: '#F0F1EC', borderRadius: 3, marginTop: 10, overflow: 'hidden' },
  transaction: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, gap: 11 }, transactionIcon: { height: 38, width: 38, borderRadius: 12, alignItems: 'center', justifyContent: 'center' }, transactionBody: { flex: 1 }, transactionName: { color: colors.ink, fontSize: 12, fontWeight: '500' }, transactionMeta: { fontSize: 9, color: '#929B8C', marginTop: 5 }, transactionAmount: { fontSize: 12, fontWeight: '500', color: colors.ink }, note: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, marginVertical: 20 }, noteText: { color: '#99A08F', fontSize: 9 },
  navigation: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-around', paddingTop: 12, paddingHorizontal: 13, paddingBottom: Platform.OS === 'android' ? 10 : 2, borderTopWidth: 1, borderTopColor: '#E8EBE3', backgroundColor: colors.background }, navItem: { width: 55, alignItems: 'center', gap: 5, height: 49 }, navLabel: { fontSize: 9, color: '#9AA298' }, navLabelActive: { color: colors.ink, fontWeight: '600' }, navDot: { height: 3, width: 3, backgroundColor: colors.ink, borderRadius: 2 }, addButton: { height: 46, width: 46, borderRadius: 16, backgroundColor: colors.ink, alignItems: 'center', justifyContent: 'center', marginTop: -8 },
  pageTitle: { fontSize: 32, color: colors.ink, letterSpacing: -1, marginBottom: 10 }, pageSubtitle: { fontSize: 13, color: colors.muted, marginBottom: 25, lineHeight: 20 }, detailCard: { borderRadius: 18, padding: 22, backgroundColor: '#FFF', borderWidth: 1, borderColor: colors.line, marginBottom: 16 }, detailAmount: { fontSize: 30, color: colors.ink, marginTop: 25 }, detailCaption: { fontSize: 11, color: colors.muted, marginTop: 15, lineHeight: 18 }, chart: { width: 180, height: 180, justifyContent: 'center', alignItems: 'center' }, chartCenter: { position: 'absolute', alignItems: 'center', gap: 7 }, chartAmount: { color: colors.ink, fontSize: 23, fontWeight: '500' }, insightRow: { flexDirection: 'row', gap: 12, paddingVertical: 20, borderBottomWidth: 1, borderColor: colors.line, alignItems: 'center' }, profileAvatar: { width: 75, height: 75, borderRadius: 38, backgroundColor: colors.green, alignSelf: 'center', justifyContent: 'center', alignItems: 'center' }, profileInitials: { fontSize: 25, color: colors.ink },
  overlay: { flex: 1, backgroundColor: '#14291F66', justifyContent: 'center', padding: 25 }, modalCard: { borderRadius: 23, padding: 24, backgroundColor: colors.background }, monthOption: { paddingVertical: 20, borderBottomWidth: 1, borderBottomColor: colors.line, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }, inputLabel: { fontSize: 12, color: colors.ink, marginTop: 22, marginBottom: 10 }, input: { backgroundColor: '#FFF', borderWidth: 1, borderColor: colors.line, padding: 14, borderRadius: 12, fontSize: 15, color: colors.ink }, saveButton: { backgroundColor: colors.ink, padding: 17, marginTop: 25, borderRadius: 12, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }, saveText: { color: '#FFF', fontSize: 14, fontWeight: '500' },
});
