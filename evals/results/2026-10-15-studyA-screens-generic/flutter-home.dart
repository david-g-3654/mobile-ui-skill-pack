import 'package:flutter/material.dart';

class HomeEvalApp extends StatelessWidget {
  const HomeEvalApp({super.key});

  static const Color _seed = Color(0xFF1F7A5C);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
}

class _Txn {
  const _Txn(this.merchant, this.category, this.date, this.amount, this.icon,
      this.color);
  final String merchant;
  final String category;
  final String date;
  final double amount; // negative = expense
  final IconData icon;
  final Color color;
}

const double _monthlyBudget = 3200;
const double _income = 4850;
const int _daysLeft = 16;

const List<_Category> _categories = [
  _Category('Groceries', Icons.shopping_basket_outlined, Color(0xFF2E8B57), 412.36, 550),
  _Category('Dining out', Icons.restaurant_outlined, Color(0xFFE07A2E), 286.90, 250),
  _Category('Transport', Icons.directions_bus_outlined, Color(0xFF3A6FD8), 118.40, 200),
  _Category('Entertainment', Icons.movie_outlined, Color(0xFF9B51E0), 64.97, 120),
  _Category('Shopping', Icons.shopping_bag_outlined, Color(0xFFD64578), 189.25, 300),
];

const double _rentAndBills = 1146.12;

const List<_Txn> _transactions = [
  _Txn('Whole Foods Market', 'Groceries', 'Today', -84.17,
      Icons.shopping_basket_outlined, Color(0xFF2E8B57)),
  _Txn('Blue Bottle Coffee', 'Dining out', 'Today', -6.50,
      Icons.local_cafe_outlined, Color(0xFFE07A2E)),
  _Txn('Metro Transit', 'Transport', 'Yesterday', -32.00,
      Icons.directions_bus_outlined, Color(0xFF3A6FD8)),
  _Txn('Acme Corp Payroll', 'Income', 'Oct 13', 2425.00,
      Icons.account_balance_outlined, Color(0xFF1F7A5C)),
  _Txn('Netflix', 'Entertainment', 'Oct 12', -15.49, Icons.movie_outlined,
      Color(0xFF9B51E0)),
];

String _money(double v, {bool sign = false}) {
  final abs = v.abs();
  final whole = abs.truncate();
  final cents = ((abs - whole) * 100).round().toString().padLeft(2, '0');
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final prefix = v < 0 ? '−' : (sign ? '+' : '');
  return '$prefix\$$buf.$cents';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spent = _categories.fold<double>(0, (s, c) => s + c.spent) + _rentAndBills;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('October'),
            actions: [
              IconButton(
                tooltip: 'Search transactions',
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Notifications',
                icon: const Badge(
                  smallSize: 8,
                  child: Icon(Icons.notifications_outlined),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
            sliver: SliverList.list(
              children: [
                Text(
                  'Good morning, Maya',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _SummaryCard(spent: spent),
                const SizedBox(height: 16),
                const _StatRow(),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Budgets', action: 'Edit', onTap: () {}),
                const SizedBox(height: 8),
                const _BudgetsCard(),
                const SizedBox(height: 28),
                _SectionHeader(title: 'Recent activity', action: 'See all', onTap: () {}),
                const SizedBox(height: 8),
                const _TransactionsCard(),
              ],
            ),
          ),
        ],
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
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
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
    final cs = theme.colorScheme;
    final left = _monthlyBudget - spent;
    final progress = (spent / _monthlyBudget).clamp(0.0, 1.0);
    final perDay = left / _daysLeft;

    return Semantics(
      container: true,
      label:
          '${_money(left)} left to spend this month, ${_money(spent)} spent of ${_money(_monthlyBudget)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Left to spend',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _money(left),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: cs.primary,
                backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '${_money(spent)} of ${_money(_monthlyBudget)} spent',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onPrimaryContainer),
                ),
                Text(
                  '$_daysLeft days left · ${_money(perDay)}/day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    final tiles = [
      _StatTile(
        label: 'Income',
        value: _money(_income),
        icon: Icons.south_west,
        color: cs.primary,
      ),
      _StatTile(
        label: 'Bills & rent',
        value: _money(_rentAndBills),
        icon: Icons.event_repeat_outlined,
        color: cs.tertiary,
      ),
    ];
    if (large) {
      return Column(
        children: [tiles[0], const SizedBox(height: 12), tiles[1]],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tiles[0]),
          const SizedBox(width: 12),
          Expanded(child: tiles[1]),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _BudgetsCard extends StatelessWidget {
  const _BudgetsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < _categories.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 72),
            _BudgetRow(category: _categories[i]),
          ],
        ],
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
    final cs = theme.colorScheme;
    final over = category.spent > category.limit;
    final remaining = category.limit - category.spent;
    final barColor = over ? cs.error : category.color;
    final status = over
        ? '${_money(-remaining)} over'
        : '${_money(remaining)} left';

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon: category.icon, color: category.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(category.name, style: theme.textTheme.titleMedium),
                      Text(
                        status,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: over ? cs.error : cs.onSurfaceVariant,
                          fontWeight: over ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (category.spent / category.limit).clamp(0.0, 1.0),
                      minHeight: 6,
                      color: barColor,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_money(category.spent)} of ${_money(category.limit)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
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

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < _transactions.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 72),
            Builder(builder: (context) {
              final t = _transactions[i];
              final income = t.amount > 0;
              return ListTile(
                onTap: () {},
                leading: _IconBadge(icon: t.icon, color: t.color),
                title: Text(t.merchant, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${t.category} · ${t.date}'),
                trailing: Text(
                  _money(t.amount, sign: true),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: income ? cs.primary : cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            }),
          ],
        ],
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
        color: color.withValues(alpha: dark ? 0.24 : 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 22,
        color: dark ? Color.lerp(color, Colors.white, 0.35) : color,
      ),
    );
  }
}
