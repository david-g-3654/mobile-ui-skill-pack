import React, { useState } from 'react';
import {
  Alert,
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  View,
  useWindowDimensions,
} from 'react-native';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import {
  QBottomActionBar,
  QChip,
  QEmptyState,
  QGroupedSection,
  QHeroMetric,
  QIconButton,
  QPrimaryButton,
  QProgressBar,
  QScreen,
  QSectionHeader,
  QText,
  QTextField,
} from '../../pack04/components';
import { metrics, radius, space, tabular, useQTheme } from '../../pack04/theme';

type Category = 'Groceries' | 'Eating out' | 'Transport';
type Expense = {
  id: string;
  merchant: string;
  amount: number;
  category: Category;
  date: string;
};

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const monthlyBudget = 4200;
const startingSpend = 2713.75;
const initialExpenses: Expense[] = [
  { id: '1', merchant: 'Trader Joe’s', amount: 64.82, category: 'Groceries', date: 'Today' },
  { id: '2', merchant: 'Maman', amount: 7.5, category: 'Eating out', date: 'Today' },
  { id: '3', merchant: 'Metropolitan Transportation Authority', amount: 2.9, category: 'Transport', date: 'Yesterday' },
  { id: '4', merchant: 'Sweetgreen', amount: 16.45, category: 'Eating out', date: 'Yesterday' },
];
const initialBudgets: { name: Category; spent: number; limit: number }[] = [
  { name: 'Groceries', spent: 342.68, limit: 550 },
  { name: 'Eating out', spent: 218.4, limit: 280 },
  { name: 'Transport', spent: 86.5, limit: 160 },
];

function splitMoney(amount: number) {
  const formatted = currency.format(amount);
  const firstDigit = formatted.search(/\d/);
  return { prefix: formatted.slice(0, firstDigit), value: formatted.slice(firstDigit) };
}

export default function HomeScreen() {
  const { c, dark } = useQTheme();
  const insets = useSafeAreaInsets();
  const { fontScale } = useWindowDimensions();
  const stacked = fontScale >= 1.3;
  const [expenses, setExpenses] = useState(initialExpenses);
  const [budgets, setBudgets] = useState(initialBudgets);
  const [addedSpend, setAddedSpend] = useState(0);
  const [showAll, setShowAll] = useState(false);
  const [adding, setAdding] = useState(false);
  const [merchant, setMerchant] = useState('');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState<Category>('Groceries');
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  const spent = startingSpend + addedSpend;
  const remaining = monthlyBudget - spent;
  const hero = splitMoney(Math.abs(remaining));
  const visibleExpenses = expenses.slice(0, showAll ? 4 : 3);

  function openExpense() {
    setMerchant('');
    setAmount('');
    setCategory('Groceries');
    setError(null);
    setAdding(true);
  }

  function saveExpense() {
    const normalizedAmount = amount.trim();
    const parsedAmount = Number(normalizedAmount);
    if (!merchant.trim()) {
      setError('Add a merchant or a short description.');
      return;
    }
    if (!/^\d+(\.\d{1,2})?$/.test(normalizedAmount) || !Number.isFinite(parsedAmount) || parsedAmount <= 0 || parsedAmount > 999999) {
      setError('Enter an amount between 0.01 and 999,999, with up to 2 decimal places.');
      return;
    }
    const expense: Expense = {
      id: String(Date.now()),
      merchant: merchant.trim(),
      amount: parsedAmount,
      category,
      date: 'Today',
    };
    setExpenses(current => [expense, ...current]);
    setAddedSpend(current => Math.round((current + parsedAmount) * 100) / 100);
    setBudgets(current => current.map(budget => budget.name === category
      ? { ...budget, spent: Math.round((budget.spent + parsedAmount) * 100) / 100 }
      : budget));
    setAdding(false);
    setSaved(true);
    void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => undefined);
  }

  return (
    <View style={[styles.root, { backgroundColor: c.canvas }]}>
      <Stack.Screen options={{
        title: 'Overview',
        headerLargeTitle: true,
        headerShadowVisible: false,
        headerTintColor: c.ink,
        headerStyle: Platform.OS === 'android' ? { backgroundColor: c.canvas } : undefined,
        contentStyle: { backgroundColor: c.canvas },
        headerRight: () => (
          <QIconButton icon="person-circle-outline" label="View your profile" onPress={() =>
            Alert.alert('Sofia’s budget', 'Personal budget · USD\nThis demo keeps your changes in memory for this session.')} />
        ),
      }} />
      <StatusBar style={dark ? 'light' : 'dark'} />

      <QScreen contentContainerStyle={{ paddingTop: space.xl }}>
        <View style={{ gap: space.xl }}>
          <View style={styles.contextRow}>
            <QText variant="subhead" color="ink2">October 2026</QText>
            <View style={[styles.monthBadge, { backgroundColor: c.surface2 }]}>
              <QText variant="subhead" color="ink2">Monthly budget</QText>
            </View>
          </View>
          <QHeroMetric
            label={remaining >= 0 ? 'Left to spend' : 'Over your budget'}
            prefix={hero.prefix}
            value={hero.value}
            context="15 days left in October"
          />
          <View style={{ gap: space.sm }}>
            <QProgressBar progress={spent / monthlyBudget} label={`Monthly budget: ${currency.format(spent)} spent of ${currency.format(monthlyBudget)}`} />
            <View style={[styles.metrics, stacked && styles.stacked]}>
              <View style={{ gap: space.xxs }}>
                <QText variant="headline" style={tabular}>{currency.format(spent)}</QText>
                <QText variant="subhead" color="ink2">Spent so far</QText>
              </View>
              <View style={{ gap: space.xxs }}>
                <QText variant="headline" style={tabular}>{currency.format(monthlyBudget)}</QText>
                <QText variant="subhead" color="ink2">Monthly limit</QText>
              </View>
            </View>
          </View>
        </View>

        <View style={{ gap: space.md }}>
          <QSectionHeader title="Everyday budgets" />
          <View style={{ gap: space.lg }}>
            {budgets.map(budget => {
              const available = budget.limit - budget.spent;
              return (
                <Pressable
                  key={budget.name}
                  accessibilityRole="button"
                  accessibilityLabel={`${budget.name}, ${currency.format(budget.spent)} spent of ${currency.format(budget.limit)}. View budget details.`}
                  onPress={() => Alert.alert(budget.name,
                    `${currency.format(budget.spent)} spent of ${currency.format(budget.limit)} this month.\n${currency.format(Math.abs(available))} ${available >= 0 ? 'left to spend' : 'over budget'}.`)}
                  style={({ pressed }) => [{ gap: space.xs, minHeight: metrics.minTap, borderRadius: radius.s }, pressed && { backgroundColor: c.surface2 }]}
                >
                  <View style={[styles.budgetHeading, stacked && styles.stacked]}>
                    <QText variant="headline">{budget.name}</QText>
                    <QText variant="subhead" color={available < 0 ? 'negative' : 'ink2'} style={tabular}>
                      {currency.format(Math.abs(available))} {available >= 0 ? 'left' : 'over'}
                    </QText>
                  </View>
                  <View
                    accessible={false}
                    style={[styles.budgetTrack, { backgroundColor: c.surface2 }]}
                  >
                    <View style={[styles.budgetFill, {
                      width: `${Math.min(budget.spent / budget.limit, 1) * 100}%`,
                      backgroundColor: available < 0 ? c.negative : c.ink2,
                    }]} />
                  </View>
                </Pressable>
              );
            })}
          </View>
        </View>

        <View style={{ gap: space.sm }}>
          <QSectionHeader title="Recent activity" action={expenses.length > 3 ? {
            title: showAll ? 'Show less' : 'See more',
            onPress: () => setShowAll(current => !current),
          } : undefined} />
          {expenses.length === 0 ? (
            <QEmptyState title="Your spending starts here" message="Add your first expense to see where your money goes." />
          ) : (
            <QGroupedSection>
              {visibleExpenses.map(expense => (
                <Pressable
                  key={expense.id}
                  accessibilityRole="button"
                  accessibilityLabel={`${expense.merchant}, ${currency.format(expense.amount)}, ${expense.category}, ${expense.date}`}
                  onPress={() => Alert.alert(expense.merchant,
                    `${currency.format(expense.amount)}\n${expense.category} · ${expense.date}\nPaid from your monthly budget.`)}
                  style={({ pressed }) => [styles.transaction, stacked && styles.stacked,
                    { backgroundColor: pressed ? c.surface2 : c.surface }]}
                >
                  <View style={styles.transactionText}>
                    <QText variant="headline">{expense.merchant}</QText>
                    <QText variant="subhead" color="ink2">{expense.category} · {expense.date}</QText>
                  </View>
                  <QText variant="headline" style={tabular}>−{currency.format(expense.amount)}</QText>
                </Pressable>
              ))}
            </QGroupedSection>
          )}
          <View accessibilityLiveRegion="polite" style={{ paddingTop: space.xs }}>
            <QText variant="subhead" color="ink2">
              {saved ? 'Expense added · Your budget is up to date' : 'A little awareness goes a long way.'}
            </QText>
          </View>
        </View>
      </QScreen>

      <QBottomActionBar>
        <QPrimaryButton title="Add expense" onPress={openExpense} />
      </QBottomActionBar>

      <Modal visible={adding} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setAdding(false)}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          style={[styles.root, { backgroundColor: c.canvas, paddingTop: Platform.OS === 'android' ? insets.top : 0 }]}
        >
          <View style={[styles.modalHeading, { borderBottomColor: c.hairline }]}>
            <QText variant="title" role="header">Add expense</QText>
            <QIconButton icon="close-outline" label="Cancel adding expense" onPress={() => setAdding(false)} />
          </View>
          <QScreen keyboardShouldPersistTaps="handled" contentContainerStyle={{ paddingTop: space.xl }}>
            <QText variant="subhead" color="ink2">Small purchases count, too. Add one to your October budget.</QText>
            <QTextField label="Merchant or description" value={merchant} onChangeText={setMerchant} placeholder="e.g. Neighborhood bakery" autoCapitalize="sentences" maxLength={100} />
            <QTextField label="Amount (USD)" value={amount} onChangeText={setAmount} placeholder="0.00" keyboardType="decimal-pad" maxLength={12} />
            <View style={{ gap: space.sm }}>
              <QText variant="headline">Category</QText>
              <View style={styles.chips}>
                {initialBudgets.map(budget => (
                  <QChip key={budget.name} title={budget.name} selected={category === budget.name} onPress={() => setCategory(budget.name)} />
                ))}
              </View>
            </View>
            {error && <View accessibilityLiveRegion="assertive"><QText variant="subhead" color="negative">{error}</QText></View>}
            <QText variant="subhead" color="ink2">Demo mode · Expenses stay in this session only.</QText>
          </QScreen>
          <QBottomActionBar>
            <QPrimaryButton title="Save expense" onPress={saveExpense} />
          </QBottomActionBar>
        </KeyboardAvoidingView>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  contextRow: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: space.xs },
  monthBadge: { paddingHorizontal: space.sm, paddingVertical: space.xxs, borderRadius: radius.capsule },
  metrics: { flexDirection: 'row', gap: space.xxxl, paddingTop: space.xxs },
  stacked: { flexDirection: 'column', alignItems: 'flex-start', gap: space.xs },
  budgetHeading: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: space.sm },
  budgetTrack: { height: space.xxs, borderRadius: radius.capsule, overflow: 'hidden' },
  budgetFill: { height: '100%', borderRadius: radius.capsule },
  transaction: { flexDirection: 'row', alignItems: 'center', gap: space.sm, padding: space.md, minHeight: metrics.rowMinHeight },
  transactionText: { flex: 1, gap: space.xxs },
  modalHeading: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: space.md, padding: space.margin, borderBottomWidth: StyleSheet.hairlineWidth },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: space.xs },
});
