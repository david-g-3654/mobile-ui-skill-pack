// Budgeting home — Home/dashboard archetype (mobile-ui/references/screen-home.md).
// Job: "how much can I still spend this month". Focal: hero amount left + pace bar.
// Primary: none filled — "Add transaction" lives in the app bar. Cut: charts (Stats tab),
// account balances (Accounts tab), promo cards.

import 'package:flutter/material.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

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
      home: const _BudgetHome(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Budget {
  const _Budget(this.name, this.spent, this.limit);
  final String name;
  final int spent;
  final int limit;
}

class _Txn {
  const _Txn(this.merchant, this.meta, this.amount, this.icon);
  final String merchant;
  final String meta;
  final String amount;
  final IconData icon;
}

const _budgets = [
  _Budget('Groceries', 412, 550),
  _Budget('Dining out', 238, 200),
  _Budget('Transport', 96, 180),
  _Budget('Shopping', 145, 300),
];

const _recent = [
  _Txn("Trader Joe's", 'Groceries · Today', '−\$64.18', Icons.shopping_basket_rounded),
  _Txn('Shell', 'Transport · Yesterday', '−\$48.70', Icons.local_gas_station_rounded),
  _Txn('Northwind Labs payroll', 'Income · Oct 10', '+\$2,425.00', Icons.account_balance_rounded),
  _Txn('Sushi Ota', 'Dining out · Oct 9', '−\$57.30', Icons.restaurant_rounded),
];

// ── Screen ──────────────────────────────────────────────────────────

class _BudgetHome extends StatefulWidget {
  const _BudgetHome();

  @override
  State<_BudgetHome> createState() => _BudgetHomeState();
}

class _BudgetHomeState extends State<_BudgetHome> {
  int _tab = 0;

  // Flip to preview the loading / empty states.
  final bool _loading = false;
  final List<_Budget> _budgetList = _budgets;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('October'),
            actions: [
              IconButton(
                tooltip: 'Add transaction',
                icon: const Icon(Icons.add_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: Space.xs),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
            sliver: SliverList.list(
              children: [
                if (_loading) const _HeroSkeleton() else const _Overview(),
                const SizedBox(height: Space.xxl),
                SectionHeader(title: 'Budgets', actionLabel: 'See all', onAction: () {}),
                const SizedBox(height: Space.sm),
                if (_loading)
                  const GroupedSection(children: [SkeletonRow(), SkeletonRow(), SkeletonRow()])
                else if (_budgetList.isEmpty)
                  EmptyState(
                    icon: Icons.donut_large_rounded,
                    title: 'No budgets yet',
                    message: 'Set a monthly limit for groceries, rent, or anything else.',
                    actionLabel: 'Create a budget',
                    onAction: () {},
                  )
                else
                  GroupedSection(children: [
                    for (final b in _budgetList) _BudgetRow(budget: b),
                  ]),
                const SizedBox(height: Space.xxl),
                SectionHeader(title: 'Recent', actionLabel: 'See all', onAction: () {}),
                const SizedBox(height: Space.sm),
                if (_loading)
                  const GroupedSection(children: [SkeletonRow(), SkeletonRow(), SkeletonRow()])
                else
                  GroupedSection(children: [
                    for (final t in _recent)
                      ListRow(
                        icon: t.icon,
                        title: t.merchant,
                        subtitle: t.meta,
                        value: t.amount,
                        kind: RowKind.action,
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
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.pie_chart_rounded), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Accounts'),
        ],
      ),
    );
  }
}

// ── Hero: amount left + month pace ──────────────────────────────────

class _Overview extends StatelessWidget {
  const _Overview();

  static const double _budget = 3200;
  static const double _spent = 1883.58;
  static const int _day = 14;
  static const int _daysInMonth = 31;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final used = _spent / _budget;
    final elapsed = _day / _daysInMonth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HeroMetric(
          label: 'Safe to spend',
          prefix: '\$',
          value: '1,316',
          suffix: '.42',
          context: '\$77 a day for 17 days',
          delta: Delta('\$214 more than mid-September', up: true, upIsGood: false),
        ),
        const SizedBox(height: Space.md),
        Semantics(
          label: '${(used * 100).round()} percent of budget used, ${(elapsed * 100).round()} percent of month gone',
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.xs,
              children: [
                LinearProgressIndicator(
                  value: used,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(Radii.s),
                  color: q.accent,
                  backgroundColor: q.surface2,
                ),
                Text('${(used * 100).round()}% of \$3,200 used · ${(elapsed * 100).round()}% of the month gone',
                    style: context.t.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        const MetricRow(items: [
          ('\$1,884', 'spent'),
          ('\$4,850', 'income'),
          ('\$600', 'to savings'),
        ]),
      ],
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.sm,
      children: [
        Skeleton(width: 96, height: 12),
        Skeleton(width: 200, height: 56),
        Skeleton(width: 160, height: 16),
        Skeleton(height: 8),
      ],
    );
  }
}

// ── Budget row: name, spent of limit, thin bar ──────────────────────

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.budget});

  final _Budget budget;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final over = budget.spent > budget.limit;
    final amount = over
        ? '\$${budget.spent - budget.limit} over \$${budget.limit}'
        : '\$${budget.spent} of \$${budget.limit}';
    final amountText = Text(
      amount,
      style: context.t.bodyMedium?.copyWith(
        color: over ? q.negative : q.ink2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final title = Text(budget.name, style: context.t.bodyLarge);
    final stacked = isLargeText(context);

    return MergeSemantics(
      child: InkWell(
        onTap: () {},
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.xs,
              children: [
                if (stacked)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [title, amountText])
                else
                  Row(spacing: Space.sm, children: [Expanded(child: title), amountText]),
                ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: (budget.spent / budget.limit).clamp(0.0, 1.0),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(Radii.s),
                    color: over ? q.negative : q.ink,
                    backgroundColor: q.surface2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
