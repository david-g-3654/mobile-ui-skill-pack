import 'package:flutter/material.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  static const Color _seed = Color(0xFF0B6E4F);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transactions',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _TransactionsScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum _Category { groceries, dining, transport, income, shopping, bills, transfer, entertainment, health, refund }

enum _Filter { all, income, expenses, pending }

class _CategoryStyle {
  const _CategoryStyle(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

const Map<_Category, _CategoryStyle> _categoryStyles = {
  _Category.groceries: _CategoryStyle('Groceries', Icons.shopping_basket_outlined, Color(0xFF2E7D32)),
  _Category.dining: _CategoryStyle('Dining', Icons.restaurant_outlined, Color(0xFFE65100)),
  _Category.transport: _CategoryStyle('Transport', Icons.directions_car_outlined, Color(0xFF1565C0)),
  _Category.income: _CategoryStyle('Income', Icons.account_balance_outlined, Color(0xFF00796B)),
  _Category.shopping: _CategoryStyle('Shopping', Icons.shopping_bag_outlined, Color(0xFF6A1B9A)),
  _Category.bills: _CategoryStyle('Bills & utilities', Icons.receipt_long_outlined, Color(0xFF5D4037)),
  _Category.transfer: _CategoryStyle('Transfer', Icons.swap_horiz, Color(0xFF455A64)),
  _Category.entertainment: _CategoryStyle('Entertainment', Icons.movie_outlined, Color(0xFFC2185B)),
  _Category.health: _CategoryStyle('Health', Icons.local_pharmacy_outlined, Color(0xFFD84315)),
  _Category.refund: _CategoryStyle('Refund', Icons.undo, Color(0xFF00838F)),
};

class _Txn {
  const _Txn({
    required this.merchant,
    required this.category,
    required this.amountCents,
    required this.date,
    this.pending = false,
    this.note,
  });

  final String merchant;
  final _Category category;

  /// Positive = money in, negative = money out.
  final int amountCents;
  final DateTime date;
  final bool pending;
  final String? note;

  bool get isCredit => amountCents > 0;
}

final List<_Txn> _transactions = [
  _Txn(merchant: 'Whole Foods Market', category: _Category.groceries, amountCents: -8743, date: DateTime(2026, 10, 14, 18, 22), pending: true),
  _Txn(merchant: 'Uber', category: _Category.transport, amountCents: -1890, date: DateTime(2026, 10, 14, 8, 47), pending: true, note: 'Trip to Market St'),
  _Txn(merchant: 'Blue Bottle Coffee', category: _Category.dining, amountCents: -625, date: DateTime(2026, 10, 14, 7, 55)),
  _Txn(merchant: 'Sarah Chen', category: _Category.transfer, amountCents: 4200, date: DateTime(2026, 10, 13, 21, 10), note: 'Dinner split'),
  _Txn(merchant: 'Netflix', category: _Category.entertainment, amountCents: -1549, date: DateTime(2026, 10, 13, 4, 0)),
  _Txn(merchant: 'Shell', category: _Category.transport, amountCents: -5412, date: DateTime(2026, 10, 13, 17, 31)),
  _Txn(merchant: 'Acme Corp Payroll', category: _Category.income, amountCents: 384615, date: DateTime(2026, 10, 12, 6, 0), note: 'Direct deposit'),
  _Txn(merchant: 'Amazon', category: _Category.shopping, amountCents: -12999, date: DateTime(2026, 10, 12, 14, 12)),
  _Txn(merchant: 'CVS Pharmacy', category: _Category.health, amountCents: -2367, date: DateTime(2026, 10, 12, 19, 44)),
  _Txn(merchant: 'PG&E', category: _Category.bills, amountCents: -11284, date: DateTime(2026, 10, 10, 9, 15), note: 'Autopay'),
  _Txn(merchant: 'Amazon', category: _Category.refund, amountCents: 3499, date: DateTime(2026, 10, 10, 11, 2), note: 'Return: headphones case'),
  _Txn(merchant: 'Trader Joe\'s', category: _Category.groceries, amountCents: -6420, date: DateTime(2026, 10, 9, 18, 5)),
  _Txn(merchant: 'Chipotle Mexican Grill', category: _Category.dining, amountCents: -1385, date: DateTime(2026, 10, 9, 12, 30)),
  _Txn(merchant: 'Savings ••7730', category: _Category.transfer, amountCents: -50000, date: DateTime(2026, 10, 8, 10, 0), note: 'Monthly auto-save'),
  _Txn(merchant: 'Comcast Xfinity', category: _Category.bills, amountCents: -7999, date: DateTime(2026, 10, 8, 3, 0)),
];

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

String _money(int cents, {bool signed = false}) {
  final abs = cents.abs();
  final dollars = abs ~/ 100;
  final rem = (abs % 100).toString().padLeft(2, '0');
  final digits = dollars.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final sign = cents < 0 ? '−' : (signed && cents > 0 ? '+' : '');
  return '$sign\$$buf.$rem';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

final DateTime _today = DateTime(2026, 10, 14);

String _dayLabel(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  final diff = _today.difference(day).inDays;
  final dateText = '${_months[d.month - 1]} ${d.day}';
  if (diff == 0) return 'Today · $dateText';
  if (diff == 1) return 'Yesterday · $dateText';
  return '${_weekdays[d.weekday - 1]} · $dateText';
}

String _time(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _TransactionsScreen extends StatefulWidget {
  const _TransactionsScreen();

  @override
  State<_TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<_TransactionsScreen> {
  _Filter _filter = _Filter.all;
  String _query = '';

  List<_Txn> get _visible {
    final q = _query.trim().toLowerCase();
    return _transactions.where((t) {
      final matchesFilter = switch (_filter) {
        _Filter.all => true,
        _Filter.income => t.isCredit,
        _Filter.expenses => !t.isCredit,
        _Filter.pending => t.pending,
      };
      if (!matchesFilter) return false;
      if (q.isEmpty) return true;
      return t.merchant.toLowerCase().contains(q) ||
          _categoryStyles[t.category]!.label.toLowerCase().contains(q) ||
          (t.note?.toLowerCase().contains(q) ?? false);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    // Group by calendar day, preserving order.
    final groups = <DateTime, List<_Txn>>{};
    for (final t in visible) {
      groups.putIfAbsent(DateTime(t.date.year, t.date.month, t.date.day), () => []).add(t);
    }

    final moneyIn = _transactions.where((t) => t.isCredit).fold<int>(0, (s, t) => s + t.amountCents);
    final moneyOut = _transactions.where((t) => !t.isCredit).fold<int>(0, (s, t) => s + t.amountCents);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            pinned: true,
            title: const Text('Transactions'),
            actions: [
              IconButton(
                tooltip: 'Download statement',
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: _SummaryCard(balanceCents: 1284733, moneyInCents: moneyIn, moneyOutCents: moneyOut),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SearchBar(
                hintText: 'Search merchants, categories',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  for (final f in _Filter.values) ...[
                    ChoiceChip(
                      label: Text(switch (f) {
                        _Filter.all => 'All',
                        _Filter.income => 'Money in',
                        _Filter.expenses => 'Money out',
                        _Filter.pending => 'Pending',
                      }),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
          else
            for (final entry in groups.entries) ...[
              SliverToBoxAdapter(child: _DayHeader(day: entry.key, txns: entry.value)),
              SliverList.separated(
                itemCount: entry.value.length,
                itemBuilder: (context, i) => _TransactionTile(txn: entry.value[i]),
                separatorBuilder: (context, i) => const Divider(indent: 72),
              ),
            ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.balanceCents, required this.moneyInCents, required this.moneyOutCents});

  final int balanceCents;
  final int moneyInCents;
  final int moneyOutCents;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Everyday Checking ••4821',
              style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 4),
            Text(
              _money(balanceCents),
              style: text.headlineMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              'Available balance',
              style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FlowPill(icon: Icons.south_west, label: 'In this month', value: _money(moneyInCents)),
                _FlowPill(icon: Icons.north_east, label: 'Out this month', value: _money(moneyOutCents.abs())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowPill extends StatelessWidget {
  const _FlowPill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              Text(value, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.txns});

  final DateTime day;
  final List<_Txn> txns;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final net = txns.fold<int>(0, (s, t) => s + t.amountCents);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                _dayLabel(day),
                style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _money(net, signed: true),
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn});

  final _Txn txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final style = _categoryStyles[txn.category]!;
    final isDark = theme.brightness == Brightness.dark;
    final creditColor = isDark ? const Color(0xFF6FDBA8) : const Color(0xFF0A7A45);
    final iconColor = isDark ? Color.lerp(style.color, Colors.white, 0.45)! : style.color;
    final iconBg = Color.lerp(style.color, scheme.surface, isDark ? 0.78 : 0.88)!;

    final subtitleParts = <String>[style.label, _time(txn.date)];
    final amount = _money(txn.amountCents, signed: true);

    return Semantics(
      button: true,
      label: '${txn.merchant}, ${style.label}, '
          '${txn.isCredit ? 'received' : 'spent'} ${_money(txn.amountCents.abs())}'
          '${txn.pending ? ', pending' : ''}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(style.icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      txn.note != null ? '${subtitleParts.join(' · ')} · ${txn.note}' : subtitleParts.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: txn.isCredit ? creditColor : scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (txn.pending) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pending',
                        style: text.labelSmall?.copyWith(color: scheme.onTertiaryContainer),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No matching transactions', style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            'Try a different search or filter.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
