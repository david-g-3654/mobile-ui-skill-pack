import 'package:flutter/material.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF255844),
      brightness: brightness,
      surface: dark ? const Color(0xFF141C18) : const Color(0xFFFAFBF8),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'sans-serif',
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: ThemeMode.system,
    home: const _TransactionsScreen(),
  );
}

class _Transaction {
  const _Transaction(this.name, this.detail, this.amount, this.icon,
      this.color, {this.income = false, this.pending = false});

  final String name;
  final String detail;
  final String amount;
  final IconData icon;
  final Color color;
  final bool income;
  final bool pending;
}

const _today = [
  _Transaction('Whole Foods Market', 'Groceries · 12:42 PM', '−\$64.28',
      Icons.shopping_bag_outlined, Color(0xFF527A48)),
  _Transaction('Blue Bottle Coffee', 'Food & drink · 9:15 AM', '−\$6.50',
      Icons.coffee_outlined, Color(0xFFA67546), pending: true),
];
const _yesterday = [
  _Transaction('Acme Studio', 'Salary · Direct deposit', '+\$3,850.00',
      Icons.south_west_rounded, Color(0xFF34745B), income: true),
  _Transaction('Spotify', 'Subscriptions · Monthly', '−\$11.99',
      Icons.graphic_eq_rounded, Color(0xFF4E805C)),
  _Transaction('Uber', 'Transport · 6:38 PM', '−\$18.40',
      Icons.directions_car_outlined, Color(0xFF69707B)),
];
const _earlier = [
  _Transaction('Ava Thompson', 'Transfer · Dinner on Friday', '+\$32.00',
      Icons.person_outline_rounded, Color(0xFF81709B), income: true),
  _Transaction('MUJI', 'Shopping · Debit card', '−\$48.90',
      Icons.storefront_outlined, Color(0xFFB26B5F)),
];

class _TransactionsScreen extends StatefulWidget {
  const _TransactionsScreen();

  @override
  State<_TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<_TransactionsScreen> {
  int _filter = 0;
  String _query = '';

  void _showTransaction(_Transaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(transaction.amount,
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              Text(transaction.detail),
              const SizedBox(height: 8),
              Text(transaction.pending ? 'Pending · Final amount may change' : 'Completed'),
              const SizedBox(height: 8),
              const Text('Everyday account •• 4821'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(String title, String date, List<_Transaction> transactions) {
    final visible = transactions.where((transaction) {
      final matchesFilter = _filter == 0 ||
          (_filter == 1 && !transaction.income) ||
          (_filter == 2 && transaction.income);
      return matchesFilter &&
          '${transaction.name} ${transaction.detail}'
              .toLowerCase().contains(_query.toLowerCase());
    }).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700)),
                Text(date, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final transaction in visible)
            _TransactionTile(
              transaction: transaction,
              onTap: () => _showTransaction(transaction),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final all = [..._today, ..._yesterday, ..._earlier];
    final hasResults = all.any((transaction) =>
        (_filter == 0 || (_filter == 1 && !transaction.income) ||
            (_filter == 2 && transaction.income)) &&
        '${transaction.name} ${transaction.detail}'
            .toLowerCase().contains(_query.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blur_on_rounded, color: scheme.primary, size: 29),
            const SizedBox(width: 8),
            const Text('folio', style: TextStyle(
                fontWeight: FontWeight.w800, letterSpacing: -1, fontSize: 26)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Semantics(
              label: 'Profile: Alex Morgan',
              child: CircleAvatar(
                radius: 19,
                backgroundColor: scheme.secondaryContainer,
                child: Text('AM', style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transactions', style: theme.textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.3)),
                        const SizedBox(height: 6),
                        Text('A little clarity for your everyday.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 25),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF243E31) : const Color(0xFFE8EEDF),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    size: 18, color: scheme.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Everyday account',
                                    style: theme.textTheme.labelLarge)),
                                Text('•• 4821', style: theme.textTheme.labelMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant)),
                              ]),
                              const SizedBox(height: 20),
                              Text('Available balance', style: theme.textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant)),
                              const SizedBox(height: 3),
                              Text('\$8,294.60', style: theme.textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -1)),
                              const SizedBox(height: 15),
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 15, color: scheme.primary),
                                const SizedBox(width: 6),
                                Expanded(child: Text('You’re all up to date',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant))),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            hintText: 'Search transactions',
                            prefixIcon: const Icon(Icons.search_rounded, size: 22),
                            filled: true,
                            fillColor: scheme.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final (index, label) in ['All', 'Money out', 'Money in'].indexed)
                              ChoiceChip(
                                label: Text(label),
                                selected: _filter == index,
                                showCheckmark: false,
                                selectedColor: dark ? const Color(0xFFC5DDAD) : const Color(0xFF254C38),
                                backgroundColor: scheme.surface,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _filter == index
                                      ? (dark ? const Color(0xFF173122) : Colors.white)
                                      : scheme.onSurfaceVariant,
                                ),
                                side: BorderSide(color: _filter == index
                                    ? Colors.transparent : scheme.outlineVariant),
                                shape: const StadiumBorder(),
                                onSelected: (_) => setState(() => _filter = index),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: Column(children: [
                  _group('Today', 'June 18', _today),
                  _group('Yesterday', 'June 17', _yesterday),
                  _group('Earlier this week', 'June 16', _earlier),
                  if (!hasResults)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No transactions found. Try another search.'),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.lock_outline_rounded, size: 13,
                          color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Flexible(child: Text('Your money. Your peace of mind.',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant))),
                    ]),
                  ),
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.onTap});

  final _Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final amount = Text(transaction.amount,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: transaction.income ? scheme.primary : scheme.onSurface,
        ));
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: transaction.color.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.25 : 0.11),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(transaction.icon, size: 23,
                  color: theme.brightness == Brightness.dark
                      ? Color.lerp(transaction.color, Colors.white, 0.45)
                      : transaction.color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.name, style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(transaction.detail, style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
                  if (transaction.pending) ...[
                    const SizedBox(height: 5),
                    Text('Pending', style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                  if (largeText) ...[const SizedBox(height: 8), amount],
                ],
              ),
            ),
            if (!largeText) ...[const SizedBox(width: 12), amount],
          ],
        ),
      ),
    );
  }
}
