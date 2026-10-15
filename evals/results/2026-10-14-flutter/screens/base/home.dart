import 'package:flutter/material.dart';

class HomeEvalApp extends StatelessWidget {
  const HomeEvalApp({super.key});

  static const Color _seed = Color(0xFF1F7A5C);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF6F7F4)
          : scheme.surface,
    );
    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _Category {
  const _Category(this.name, this.icon, this.color, this.spent, this.limit);
  final String name;
  final IconData icon;
  final Color color;
  final double spent;
  final double limit;

  double get ratio => limit == 0 ? 0 : spent / limit;
}

class _Txn {
  const _Txn(this.merchant, this.category, this.icon, this.color, this.amount,
      this.when);
  final String merchant;
  final String category;
  final IconData icon;
  final Color color;
  final double amount; // negative = expense
  final String when;
}

const _monthlyIncome = 4850.00;
const _monthlyBudget = 3200.00;
const _daysLeft = 17;

const _categories = <_Category>[
  _Category('Groceries', Icons.shopping_basket_outlined, Color(0xFF2E9E6B),
      312.48, 500),
  _Category('Dining out', Icons.restaurant_outlined, Color(0xFFE07A3F), 236.10,
      250),
  _Category('Transport', Icons.directions_bus_outlined, Color(0xFF3F7FD9),
      84.20, 160),
  _Category('Shopping', Icons.local_mall_outlined, Color(0xFFB0509E), 291.75,
      240),
  _Category('Entertainment', Icons.movie_outlined, Color(0xFF7A62D6), 42.99,
      120),
];

const _transactions = <_Txn>[
  _Txn('Trader Joe’s', 'Groceries', Icons.shopping_basket_outlined,
      Color(0xFF2E9E6B), -64.32, 'Today, 6:12 PM'),
  _Txn('Blue Bottle Coffee', 'Dining out', Icons.local_cafe_outlined,
      Color(0xFFE07A3F), -6.75, 'Today, 8:41 AM'),
  _Txn('Acme Corp payroll', 'Income', Icons.account_balance_outlined,
      Color(0xFF1F7A5C), 2425.00, 'Yesterday'),
  _Txn('Metro transit', 'Transport', Icons.directions_bus_outlined,
      Color(0xFF3F7FD9), -2.90, 'Yesterday'),
  _Txn('Netflix', 'Entertainment', Icons.movie_outlined, Color(0xFF7A62D6),
      -15.49, 'Oct 12'),
];

String _money(double v, {bool signed = false}) {
  final neg = v < 0;
  final abs = v.abs();
  final whole = abs.truncate();
  final cents = ((abs - whole) * 100).round().toString().padLeft(2, '0');
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final body = '\$$buf.$cents';
  if (signed) return neg ? '−$body' : '+$body';
  return neg ? '−$body' : body;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final spent = _categories.fold<double>(0, (s, c) => s + c.spent) + 412.30;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(
                children: [
                  _SummaryCard(spent: spent),
                  const SizedBox(height: 16),
                  const _QuickActions(),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Budgets', action: 'Manage'),
                  const SizedBox(height: 8),
                  const _BudgetsCard(),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Recent activity', action: 'See all'),
                  const SizedBox(height: 8),
                  const _TransactionsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart_outline), label: 'Budgets'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Activity'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primaryContainer,
            child: Text('MR',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: scheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good evening, Maya',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('October 2026',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.spent});
  final double spent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final left = _monthlyBudget - spent;
    final ratio = (spent / _monthlyBudget).clamp(0.0, 1.0);
    final perDay = left / _daysLeft;
    final onCard = scheme.onPrimary;
    final muted = onCard.withValues(alpha: 0.78);

    return Semantics(
      container: true,
      label:
          'Left to spend ${_money(left)} of ${_money(_monthlyBudget)} monthly budget',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Left to spend this month',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(_money(left),
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(color: onCard, fontSize: 36)),
            ),
            const SizedBox(height: 4),
            Text(
              '${_money(perDay)}/day for the next $_daysLeft days',
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: onCard.withValues(alpha: 0.22),
                valueColor: AlwaysStoppedAnimation(onCard),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text('${_money(spent)} spent',
                    style: theme.textTheme.labelLarge?.copyWith(color: onCard)),
                Text('of ${_money(_monthlyBudget)}',
                    style: theme.textTheme.labelLarge?.copyWith(color: muted)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: onCard.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _MiniStat(
                  icon: Icons.south_west,
                  label: 'Income',
                  value: _money(_monthlyIncome),
                  color: onCard,
                  muted: muted,
                ),
                _MiniStat(
                  icon: Icons.savings_outlined,
                  label: 'Saved',
                  value: _money(650),
                  color: onCard,
                  muted: muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.muted,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.labelMedium?.copyWith(color: muted)),
            Text(value,
                style: t.titleSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    const actions = [
      (Icons.swap_horiz, 'Transfer'),
      (Icons.flag_outlined, 'Goals'),
      (Icons.event_repeat_outlined, 'Bills'),
      (Icons.insights_outlined, 'Reports'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in actions)
          ActionChip(
            avatar: Icon(a.$1, size: 18),
            label: Text(a.$2),
            onPressed: () {},
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        TextButton(onPressed: () {}, child: Text(action)),
      ],
    );
  }
}

class _BudgetsCard extends StatelessWidget {
  const _BudgetsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < _categories.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 68),
              _BudgetRow(category: _categories[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.category});
  final _Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = category;
    final over = c.spent > c.limit;
    final near = !over && c.ratio >= 0.85;
    final remaining = c.limit - c.spent;
    final statusColor = over
        ? scheme.error
        : near
            ? (theme.brightness == Brightness.light
                ? const Color(0xFFA66300)
                : const Color(0xFFFFB95C))
            : scheme.onSurfaceVariant;
    final status = over
        ? '${_money(-remaining).replaceFirst('−', '')} over'
        : '${_money(remaining)} left';

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: c.icon, color: c.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      Text(c.name, style: theme.textTheme.titleSmall),
                      Text(
                        '${_money(c.spent)} / ${_money(c.limit)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: c.ratio.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation(over ? scheme.error : c.color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (over || near) ...[
                        Icon(
                          over
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          status,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight:
                                over || near ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon,
          size: 22, color: dark ? Color.lerp(color, Colors.white, 0.35) : color),
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final income = theme.brightness == Brightness.light
        ? const Color(0xFF1B7A4F)
        : const Color(0xFF7FDBAA);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < _transactions.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 68),
              Builder(builder: (context) {
                final t = _transactions[i];
                final positive = t.amount > 0;
                return ListTile(
                  onTap: () {},
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: _IconBadge(icon: t.icon, color: t.color),
                  title: Text(t.merchant,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${t.category} · ${t.when}',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    _money(t.amount, signed: true),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: positive ? income : scheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
