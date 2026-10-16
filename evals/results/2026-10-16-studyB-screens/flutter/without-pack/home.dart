import 'package:flutter/material.dart';

class HomeEvalApp extends StatelessWidget {
  const HomeEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF34765B),
      brightness: brightness,
      surface: dark ? const Color(0xFF171E1B) : const Color(0xFFFAFAF6),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Roboto',
      dividerColor: dark ? const Color(0xFF303B35) : const Color(0xFFE7E9E1),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.4, color: scheme.onSurface),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: scheme.onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: scheme.onSurface),
        bodySmall: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: ThemeMode.system,
    home: const _HomeScreen(),
  );
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _selectedTab = 0;

  void _showDetails(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(children: [
                  Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(color: const Color(0xFFE7EBCF), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.spa_rounded, color: Color(0xFF3B6045), size: 27),
                  ),
                  const SizedBox(width: 11),
                  Expanded(child: Text('sprout', style: theme.textTheme.titleLarge?.copyWith(fontSize: 25, letterSpacing: -1))),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => _showDetails('You’re all caught up', 'Your budgets are up to date. We’ll let you know when you’re nearing a spending limit.'),
                    icon: Badge(smallSize: 6, backgroundColor: const Color(0xFFC17B50), child: Icon(Icons.notifications_none_rounded, color: muted)),
                  ),
                ]),
                const SizedBox(height: 30),
                Text('A little clarity, every day.', style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                const SizedBox(height: 6),
                Text('Hey, Alex 👋', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(child: Text('Your month at a glance', style: theme.textTheme.titleMedium)),
                  const SizedBox(width: 8),
                  Text('OCT 2026', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
                ]),
                const SizedBox(height: 14),
                const _BalanceCard(),
                const SizedBox(height: 12),
                const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _MoneyTile(label: 'Income', amount: '\$4,800', icon: Icons.south_west_rounded, positive: true)),
                  SizedBox(width: 12),
                  Expanded(child: _MoneyTile(label: 'Spent', amount: '\$2,350', icon: Icons.north_east_rounded, positive: false)),
                ]),
                const SizedBox(height: 28),
                _SectionHeading(title: 'Your budgets', action: 'View all', onTap: () => _showDetails('October budgets', 'Groceries: \$320 of \$500\nFood & drink: \$185 of \$250\nShopping: \$140 of \$300\n\nYou’re within all of your category budgets.')),
                const SizedBox(height: 14),
                const _BudgetRow(icon: Icons.shopping_basket_outlined, title: 'Groceries', spent: 320, limit: 500, color: Color(0xFF51806A)),
                const SizedBox(height: 19),
                const _BudgetRow(icon: Icons.local_cafe_outlined, title: 'Food & drink', spent: 185, limit: 250, color: Color(0xFFC18A52)),
                const SizedBox(height: 19),
                const _BudgetRow(icon: Icons.shopping_bag_outlined, title: 'Shopping', spent: 140, limit: 300, color: Color(0xFF8C82AA)),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(18)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.auto_awesome_outlined, size: 22, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Small steps. Real progress.', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('You’ve spent 12% less than this time last month. Keep it growing.', style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 26),
                _SectionHeading(title: 'Recent activity', action: 'See all', onTap: () => _showDetails('Recent activity', 'Today\nWhole Foods Market  −\$64.28\nBlue Bottle Coffee  −\$5.50\n\nYesterday\nMonthly paycheck  +\$2,400.00\nTarget  −\$38.40')),
                const SizedBox(height: 8),
                const _Transaction(icon: Icons.shopping_basket_outlined, name: 'Whole Foods Market', category: 'Groceries · Today', amount: '−\$64.28', color: Color(0xFF51806A)),
                const _Transaction(icon: Icons.coffee_outlined, name: 'Blue Bottle Coffee', category: 'Food & drink · Today', amount: '−\$5.50', color: Color(0xFFC18A52)),
                const _Transaction(icon: Icons.account_balance_outlined, name: 'Monthly paycheck', category: 'Income · Yesterday', amount: '+\$2,400.00', color: Color(0xFF51806A), income: true),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          if (index == 0) { setState(() => _selectedTab = 0); return; }
          final titles = ['Home', 'Budgets', 'Insights', 'Profile'];
          final messages = ['', 'You have \$405 left across your everyday budgets. All three categories are on track for October.', 'October spending is down 12% compared with the same point in September. Groceries are your largest everyday category.', 'Alex Morgan\nPersonal account\nCurrency: USD\nMonthly budget: \$4,000'];
          _showDetails(titles[index], messages[index]);
        },
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline_rounded), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: const Color(0xFF214F3D), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Left to spend', style: TextStyle(color: Color(0xFFD4E5D9), fontSize: 14))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF3D6650), borderRadius: BorderRadius.circular(20)), child: const Text('On track', style: TextStyle(color: Color(0xFFE0EDB5), fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 12),
      const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('\$1,650.00', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -1.6, color: Colors.white))),
      const SizedBox(height: 4),
      const Text('of your \$4,000 monthly budget', style: TextStyle(color: Color(0xFFD4E5D9), fontSize: 13)),
      const SizedBox(height: 24),
      const ClipRRect(borderRadius: BorderRadius.all(Radius.circular(8)), child: LinearProgressIndicator(value: 0.5875, minHeight: 7, color: Color(0xFFD3E7A5), backgroundColor: Color(0xFF49715C))),
      const SizedBox(height: 10),
      const Row(children: [Expanded(child: Text('59% spent', style: TextStyle(color: Color(0xFFD4E5D9), fontSize: 12))), SizedBox(width: 12), Flexible(child: Text('16 days to go', textAlign: TextAlign.end, style: TextStyle(color: Color(0xFFD4E5D9), fontSize: 12)))]),
    ]),
  );
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({required this.label, required this.amount, required this.icon, required this.positive});
  final String label;
  final String amount;
  final IconData icon;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 17, color: positive ? theme.colorScheme.primary : const Color(0xFFC18A52)), const SizedBox(width: 7), Expanded(child: Text(label, style: theme.textTheme.bodySmall))]),
        const SizedBox(height: 9),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(amount, style: theme.textTheme.titleLarge?.copyWith(fontSize: 23))),
      ]),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
    TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
  ]);
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.icon, required this.title, required this.spent, required this.limit, required this.color});
  final IconData icon;
  final String title;
  final int spent;
  final int limit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 23)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 4, spacing: 8, children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          Text.rich(TextSpan(children: [TextSpan(text: '\$$spent', style: const TextStyle(fontWeight: FontWeight.w600)), TextSpan(text: ' / \$$limit', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))]), style: theme.textTheme.bodySmall),
        ]),
        const SizedBox(height: 9),
        Semantics(label: '$title budget, $spent of $limit dollars spent', child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: spent / limit, minHeight: 5, color: color, backgroundColor: color.withValues(alpha: 0.12)))),
      ])),
    ]);
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction({required this.icon, required this.name, required this.category, required this.amount, required this.color, this.income = false});
  final IconData icon;
  final String name;
  final String category;
  final String amount;
  final Color color;
  final bool income;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 21)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(category, style: theme.textTheme.bodySmall),
        ])),
        const SizedBox(width: 8),
        Flexible(child: Text(amount, textAlign: TextAlign.end, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, color: income ? theme.colorScheme.primary : null))),
      ]),
    );
  }
}
