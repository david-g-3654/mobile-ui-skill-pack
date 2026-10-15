// Home / dashboard for a personal budgeting app.
// Job: "is this month on track?". Focal: hero "left to spend" amount.
// Primary: none on screen — "Add expense" lives in the app bar. Cut: charts (Stats tab), account list.

import 'package:flutter/material.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class HomeEvalApp extends StatelessWidget {
  const HomeEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _BudgetHomeScreen(loading: false, transactions: _recent),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Budget {
  const _Budget(this.name, this.spent, this.limit);
  final String name;
  final double spent;
  final double limit;
}

class _Txn {
  const _Txn(this.merchant, this.detail, this.amount, this.icon);
  final String merchant;
  final String detail;
  final String amount;
  final IconData icon;
}

const _budgets = [
  _Budget('Groceries', 412, 550),
  _Budget('Dining out', 238, 200),
  _Budget('Transport', 96, 180),
];

const _recent = [
  _Txn("Trader Joe's", 'Groceries · Today', '−\$64.18', Icons.shopping_basket_outlined),
  _Txn('Lyft', 'Transport · Yesterday', '−\$17.40', Icons.directions_car_outlined),
  _Txn('Northwind Payroll', 'Income · Oct 13', '+\$2,430.00', Icons.account_balance_outlined),
  _Txn('Tartine Bakery', 'Dining out · Oct 12', '−\$23.75', Icons.restaurant_outlined),
];

String _money(double v) {
  final whole = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return '\$$buf';
}

// ── Screen ──────────────────────────────────────────────────────────

class _BudgetHomeScreen extends StatefulWidget {
  const _BudgetHomeScreen({this.loading = false, this.transactions = _recent});

  final bool loading;
  final List<_Txn> transactions;

  @override
  State<_BudgetHomeScreen> createState() => _BudgetHomeScreenState();
}

class _BudgetHomeScreenState extends State<_BudgetHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('October'),
            actions: [
              IconButton(
                tooltip: 'Add expense',
                icon: const Icon(Icons.add_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: QSpace.xs),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                if (widget.loading)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: QSpace.sm,
                    children: [
                      QSkeleton(width: 120, height: 12),
                      FractionallySizedBox(widthFactor: 0.55, child: QSkeleton(height: 56)),
                      QSkeleton(width: 200, height: 14),
                    ],
                  )
                else
                  const QHeroMetric(
                    label: 'Left to spend this month',
                    prefix: '\$',
                    value: '1,312',
                    suffix: '.75',
                    context: '16 days left · about \$82 a day',
                  ),
                const SizedBox(height: QSpace.xl),
                const QMetricRow(items: [
                  ('\$4,860', 'income'),
                  ('\$2,947', 'spent'),
                  ('\$600', 'set aside'),
                ]),
                const SizedBox(height: QSpace.xxl),
                QSectionHeader(title: 'Budgets', actionLabel: 'See all', onAction: () {}),
                const SizedBox(height: QSpace.sm),
                QGroupedSection(children: [
                  for (final b in _budgets) _BudgetRow(budget: b, onTap: () {}),
                ]),
                const SizedBox(height: QSpace.xxl),
                QSectionHeader(title: 'Recent activity', actionLabel: 'See all', onAction: () {}),
                const SizedBox(height: QSpace.sm),
                if (widget.loading)
                  const QGroupedSection(children: [QSkeletonRow(), QSkeletonRow(), QSkeletonRow()])
                else if (widget.transactions.isEmpty)
                  const QEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No spending yet',
                    message: 'Purchases from your linked accounts land here within a few minutes.',
                  )
                else
                  QGroupedSection(children: [
                    for (final t in widget.transactions)
                      QListRow(
                        icon: t.icon,
                        title: t.merchant,
                        subtitle: t.detail,
                        value: t.amount,
                        onTap: () {},
                      ),
                  ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Accounts'),
        ],
      ),
    );
  }
}

// ── Budget row: name, "spent of limit", thin progress bar ───────────

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.budget, required this.onTap});

  final _Budget budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final over = budget.spent > budget.limit;
    final status = over
        ? '${_money(budget.spent - budget.limit)} over'
        : '${_money(budget.limit - budget.spent)} left';
    final amounts = Text(
      '${_money(budget.spent)} of ${_money(budget.limit)}',
      style: context.qText.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
    final title = Text(budget.name, style: context.qText.bodyLarge);
    final stacked = qIsLargeText(context);

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: QMetrics.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: QSpace.xs,
              children: [
                if (stacked) ...[title, amounts] else Row(
                  spacing: QSpace.sm,
                  children: [Expanded(child: title), amounts],
                ),
                ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: (budget.spent / budget.limit).clamp(0.0, 1.0),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    backgroundColor: q.surface2,
                    color: over ? q.negative : q.ink,
                  ),
                ),
                Text(
                  status,
                  style: context.qText.bodySmall?.copyWith(color: over ? q.negative : q.ink2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
