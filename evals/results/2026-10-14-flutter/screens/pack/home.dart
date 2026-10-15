// Home / dashboard for a personal budgeting app (mobile-ui: screen-home.md, default Quiet skin).
// Job: "know what I can still spend this month". Focal: the safe-to-spend hero.
// Primary action: none on screen — "Add expense" lives in the app bar.
// Cut: account balances, charts and recent transactions (they live on the Activity / Accounts tabs).

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
      home: const _BudgetHomeScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

class _Category {
  const _Category(this.name, this.spent, this.limit);
  final String name;
  final double spent;
  final double limit;

  double get progress => limit == 0 ? 0 : spent / limit;
  bool get over => spent > limit;
}

class _Bill {
  const _Bill(this.name, this.when, this.amount, this.icon);
  final String name;
  final String when;
  final String amount;
  final IconData icon;
}

const _categories = [
  _Category('Groceries', 412.18, 550),
  _Category('Eating out', 263.75, 240),
  _Category('Transport', 96.40, 180),
  _Category('Fun money', 141.90, 200),
];

const _bills = [
  _Bill('Phone plan', 'Thursday, Oct 16', '−\$30.00', Icons.phone_iphone_rounded),
  _Bill('Car insurance', 'Monday, Oct 20', '−\$118.42', Icons.directions_car_rounded),
  _Bill('Home internet', 'Wednesday, Oct 22', '−\$64.99', Icons.wifi_rounded),
];

String _money(double v) {
  final whole = v.truncate();
  final cents = ((v - whole) * 100).round().toString().padLeft(2, '0');
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return cents == '00' ? '\$$buf' : '\$$buf.$cents';
}

// ── Screen ──────────────────────────────────────────────────────────

class _BudgetHomeScreen extends StatefulWidget {
  const _BudgetHomeScreen();

  @override
  State<_BudgetHomeScreen> createState() => _BudgetHomeScreenState();
}

class _BudgetHomeScreenState extends State<_BudgetHomeScreen> {
  int _tab = 0;

  // Flip to preview the loading state; bills can be emptied to preview the inline empty state.
  final bool _loading = false;
  final List<_Bill> _upcoming = _bills;

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
                icon: const Icon(Icons.add_rounded),
                onPressed: () => showToast(context, 'Expense form opens here'),
              ),
              const SizedBox(width: Space.xs),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
            sliver: SliverList.list(
              children: [
                if (_loading) const _HeroSkeleton() else const _Summary(),
                const SizedBox(height: Space.xxl),
                SectionHeader(title: 'Where it’s going', actionLabel: 'Budgets', onAction: () => setState(() => _tab = 2)),
                const SizedBox(height: Space.sm),
                if (_loading)
                  const GroupedSection(children: [SkeletonRow(), SkeletonRow(), SkeletonRow()])
                else
                  GroupedSection(
                    footer: 'Resets on Nov 1. Unspent fun money rolls into savings.',
                    children: [for (final c in _categories) _CategoryRow(category: c)],
                  ),
                const SizedBox(height: Space.xxl),
                SectionHeader(title: 'Due this week', actionLabel: 'All bills', onAction: () {}),
                const SizedBox(height: Space.sm),
                if (_loading)
                  const GroupedSection(children: [SkeletonRow(), SkeletonRow()])
                else if (_upcoming.isEmpty)
                  const GroupedSection(children: [
                    ListRow(
                      title: 'Nothing due before next week',
                      subtitle: 'Bills show up here 7 days before they’re charged.',
                    ),
                  ])
                else
                  GroupedSection(children: [
                    for (final b in _upcoming)
                      ListRow(icon: b.icon, title: b.name, subtitle: b.when, value: b.amount, onTap: () {}),
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
          NavigationDestination(icon: Icon(Icons.donut_large_rounded), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: 'Accounts'),
        ],
      ),
    );
  }
}

// ── Summary: hero + quiet metric row ────────────────────────────────

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Space.xl,
      children: [
        HeroMetric(
          label: 'Safe to spend',
          prefix: '\$',
          value: '1,862',
          suffix: '.37',
          delta: Delta('\$142 ahead of Sep 14', up: true),
          context: '17 days left this month',
        ),
        MetricRow(items: [
          ('\$109', 'a day to stay on track'),
          ('\$2,186', 'spent so far'),
          ('\$600', 'moved to savings'),
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
        Skeleton(width: 200, height: 56, radius: Radii.m),
        Skeleton(width: 160, height: 16),
      ],
    );
  }
}

// ── Category row: name, spent of limit, thin progress bar ──────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final c = category;
    final stacked = isLargeText(context);
    final remaining = c.limit - c.spent;
    final status = c.over ? '${_money(-remaining)} over' : '${_money(remaining)} left';

    final amount = Text.rich(
      TextSpan(children: [
        TextSpan(text: _money(c.spent), style: context.t.bodyLarge),
        TextSpan(text: ' of ${_money(c.limit)}', style: context.t.bodyMedium),
      ]),
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
    );

    return MergeSemantics(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Space.xs,
            children: [
              if (stacked) ...[
                Text(c.name, style: context.t.titleMedium),
                amount,
              ] else
                Row(
                  spacing: Space.sm,
                  children: [
                    Expanded(child: Text(c.name, style: context.t.titleMedium)),
                    amount,
                  ],
                ),
              ExcludeSemantics(
                child: LinearProgressIndicator(
                  value: c.progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(Space.xxs),
                  backgroundColor: q.surface2,
                  color: c.over ? q.negative : q.ink,
                ),
              ),
              Text(
                status,
                style: context.t.bodySmall?.copyWith(
                  color: c.over ? q.negative : q.ink2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
