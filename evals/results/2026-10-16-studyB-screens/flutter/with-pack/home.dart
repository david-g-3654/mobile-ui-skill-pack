import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class HomeEvalApp extends StatelessWidget {
  const HomeEvalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pocket · Your budget',
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const _HomeScreen(),
  );
}

String _money(double amount) {
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]},',
  );
  return '${amount < 0 ? '−' : ''}\$$whole.${parts.last}';
}

class _Expense {
  const _Expense(this.merchant, this.category, this.amount, this.when);

  final String merchant;
  final String category;
  final double amount;
  final String when;
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  double _spent = 2357.35;
  double _other = 0;
  final _expenses = <_Expense>[
    const _Expense('Trader Joe’s', 'Groceries', 64.28, 'Today'),
    const _Expense('Blue Bottle Coffee', 'Dining out', 5.75, 'Today'),
    const _Expense('City Transit', 'Transport', 2.90, 'Yesterday'),
  ];

  Future<void> _addExpense() async {
    final expense = await showModalBottomSheet<_Expense>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _ExpenseSheet(),
    );
    if (expense == null || !mounted) return;
    setState(() {
      _spent += expense.amount;
      _other += expense.amount;
      _expenses.insert(0, expense);
    });
    HapticFeedback.mediumImpact();
    showQToast(context, 'Expense added');
  }

  @override
  Widget build(BuildContext context) {
    final remaining = 4200 - _spent;
    final amount = _money(remaining.abs());
    final decimal = amount.lastIndexOf('.');
    return Scaffold(
      bottomNavigationBar: QBottomActionBar(
        children: [
          QPrimaryButton(label: 'Add expense', onPressed: _addExpense),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Your money'),
              actions: [
                IconButton(
                  tooltip: 'About this budget',
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () => showAdaptiveDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog.adaptive(
                      title: const Text('A little room to breathe'),
                      content: const Text(
                        'Your monthly spending plan is \$4,200.00, including bills and everyday purchases. Money left is your plan minus expenses recorded so far.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: QSpace.xs),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                QSpace.margin,
                QSpace.xs,
                QSpace.margin,
                QSpace.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: QSpace.md,
                          runSpacing: QSpace.xxs,
                          children: [
                            Text(
                              'October 2026',
                              style: context.qText.titleMedium,
                            ),
                            Text(
                              '15 days to go',
                              style: context.qText.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: QSpace.xl),
                        Semantics(
                          label: 'Money left this month, ${_money(remaining)}',
                          excludeSemantics: true,
                          child: QHeroMetric(
                            label: 'Left this month',
                            value: amount.substring(1, decimal),
                            prefix: remaining < 0 ? '−\$ ' : '\$ ',
                            suffix: amount.substring(decimal),
                          ),
                        ),
                        const SizedBox(height: QSpace.lg),
                        LinearProgressIndicator(
                          value: (_spent / 4200).clamp(0, 1),
                          minHeight: QSpace.sm,
                          borderRadius: BorderRadius.circular(QRadii.s),
                          color: context.q.accent,
                          backgroundColor: context.q.surface2,
                          semanticsLabel: 'Monthly budget used',
                          semanticsValue: '${(_spent / 42).round()} percent',
                        ),
                        const SizedBox(height: QSpace.md),
                        QMetricRow(
                          items: [
                            (_money(_spent), 'Spent so far'),
                            (_money(4200), 'Monthly plan'),
                          ],
                        ),
                        const SizedBox(height: QSpace.xxl),
                        const QSectionHeader(title: 'Everyday budgets'),
                        const SizedBox(height: QSpace.md),
                        const _BudgetRow(
                          name: 'Groceries',
                          spent: 386.42,
                          limit: 600,
                        ),
                        const _BudgetRow(
                          name: 'Dining out',
                          spent: 218.70,
                          limit: 300,
                        ),
                        const _BudgetRow(
                          name: 'Transport',
                          spent: 94.80,
                          limit: 180,
                        ),
                        if (_other > 0)
                          _BudgetRow(name: 'Other', spent: _other, limit: 250),
                        const SizedBox(height: QSpace.lg),
                        const QSectionHeader(title: 'Recent spending'),
                        const SizedBox(height: QSpace.sm),
                        QGroupedSection(
                          children: [
                            for (final expense in _expenses.take(4))
                              MergeSemantics(
                                child: QListRow(
                                  title: expense.merchant,
                                  subtitle:
                                      '${expense.category} · ${expense.when}',
                                  value: '−${_money(expense.amount)}',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: QSpace.md),
                        Text(
                          'Small purchases. A clearer picture.',
                          style: context.qText.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.name,
    required this.spent,
    required this.limit,
  });

  final String name;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.only(bottom: QSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: QSpace.sm,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: QSpace.md,
            runSpacing: QSpace.xxs,
            children: [
              Text(name, style: context.qText.titleMedium),
              Text(
                '${_money(spent)} / ${_money(limit)}',
                style: context.qText.bodyMedium,
              ),
            ],
          ),
          LinearProgressIndicator(
            value: (spent / limit).clamp(0, 1),
            minHeight: QSpace.xxs,
            borderRadius: BorderRadius.circular(QRadii.s),
            backgroundColor: context.q.surface2,
            color: context.q.ink2,
            semanticsLabel: '$name budget used',
            semanticsValue: '${(spent / limit * 100).round()} percent',
          ),
        ],
      ),
    ),
  );
}

class _ExpenseSheet extends StatefulWidget {
  const _ExpenseSheet();

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _merchant = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _Expense(
        _merchant.text.trim(),
        'Other',
        double.parse(_amount.text),
        'Today',
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(QSpace.margin),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: QSpace.md,
            children: [
              Semantics(
                header: true,
                child: Text('Add expense', style: context.qText.titleLarge),
              ),
              Text(
                'Record a purchase in your Other budget.',
                style: context.qText.bodyMedium,
              ),
              TextFormField(
                controller: _merchant,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Merchant'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a merchant or description.'
                    : null,
              ),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                onFieldSubmitted: (_) => _save(),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter an amount greater than zero.';
                  }
                  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!)) {
                    return 'Use up to two decimal places.';
                  }
                  return null;
                },
              ),
              QPrimaryButton(label: 'Save expense', onPressed: _save),
              QTertiaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
