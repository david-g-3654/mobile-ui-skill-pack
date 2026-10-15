import 'package:flutter/material.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  static const Color _seed = Color(0xFF1F5EFF);

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
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        thickness: 1,
        space: 1,
      ),
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

enum _Category { groceries, dining, transport, salary, shopping, utilities, transfer, entertainment, health, refund }

enum _Filter { all, income, expenses, pending }

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
  final int amountCents; // negative = debit
  final DateTime date;
  final bool pending;
  final String? note;

  bool get isIncome => amountCents > 0;
}

final DateTime _today = DateTime(2026, 10, 15);

final List<_Txn> _transactions = [
  _Txn(merchant: 'Whole Foods Market', category: _Category.groceries, amountCents: -8743, date: _today.add(const Duration(hours: 18, minutes: 42)), pending: true),
  _Txn(merchant: 'Uber', category: _Category.transport, amountCents: -1890, date: _today.add(const Duration(hours: 8, minutes: 15)), pending: true),
  _Txn(merchant: 'Blue Bottle Coffee', category: _Category.dining, amountCents: -625, date: _today.add(const Duration(hours: 7, minutes: 31))),
  _Txn(merchant: 'Acme Corp Payroll', category: _Category.salary, amountCents: 412500, date: _today.subtract(const Duration(days: 1)).add(const Duration(hours: 6)), note: 'Direct deposit'),
  _Txn(merchant: 'Netflix', category: _Category.entertainment, amountCents: -1549, date: _today.subtract(const Duration(days: 1)).add(const Duration(hours: 3, minutes: 2))),
  _Txn(merchant: 'Sarah Chen', category: _Category.transfer, amountCents: 4200, date: _today.subtract(const Duration(days: 1)).add(const Duration(hours: 20, minutes: 11)), note: 'Dinner split'),
  _Txn(merchant: 'Pacific Gas & Electric', category: _Category.utilities, amountCents: -11426, date: _today.subtract(const Duration(days: 3)).add(const Duration(hours: 9))),
  _Txn(merchant: 'Amazon', category: _Category.shopping, amountCents: -3499, date: _today.subtract(const Duration(days: 3)).add(const Duration(hours: 14, minutes: 27))),
  _Txn(merchant: 'Amazon', category: _Category.refund, amountCents: 2199, date: _today.subtract(const Duration(days: 3)).add(const Duration(hours: 11, minutes: 4)), note: 'Return processed'),
  _Txn(merchant: 'CVS Pharmacy', category: _Category.health, amountCents: -2318, date: _today.subtract(const Duration(days: 4)).add(const Duration(hours: 17, minutes: 50))),
  _Txn(merchant: 'Shell', category: _Category.transport, amountCents: -5612, date: _today.subtract(const Duration(days: 4)).add(const Duration(hours: 8, minutes: 5))),
  _Txn(merchant: 'Trader Joe’s', category: _Category.groceries, amountCents: -6407, date: _today.subtract(const Duration(days: 6)).add(const Duration(hours: 12, minutes: 33))),
  _Txn(merchant: 'Sweetgreen', category: _Category.dining, amountCents: -1475, date: _today.subtract(const Duration(days: 6)).add(const Duration(hours: 12, minutes: 58))),
];

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

String _money(int cents, {bool signed = false}) {
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString();
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  final frac = (abs % 100).toString().padLeft(2, '0');
  final sign = cents < 0 ? '−' : (signed && cents > 0 ? '+' : '');
  return '$sign\$$buf.$frac';
}

String _time(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

String _dayLabel(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  final diff = _today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}';
}

({IconData icon, String label, Color color}) _categoryStyle(_Category c) {
  switch (c) {
    case _Category.groceries:
      return (icon: Icons.local_grocery_store_outlined, label: 'Groceries', color: const Color(0xFF2E9D5B));
    case _Category.dining:
      return (icon: Icons.restaurant_outlined, label: 'Dining', color: const Color(0xFFE07A1F));
    case _Category.transport:
      return (icon: Icons.directions_car_outlined, label: 'Transport', color: const Color(0xFF3B6FE0));
    case _Category.salary:
      return (icon: Icons.account_balance_outlined, label: 'Income', color: const Color(0xFF1E8E6E));
    case _Category.shopping:
      return (icon: Icons.shopping_bag_outlined, label: 'Shopping', color: const Color(0xFFC2417A));
    case _Category.utilities:
      return (icon: Icons.bolt_outlined, label: 'Utilities', color: const Color(0xFFB58A00));
    case _Category.transfer:
      return (icon: Icons.swap_horiz_rounded, label: 'Transfer', color: const Color(0xFF6A55D8));
    case _Category.entertainment:
      return (icon: Icons.movie_outlined, label: 'Entertainment', color: const Color(0xFFD2453A));
    case _Category.health:
      return (icon: Icons.medical_services_outlined, label: 'Health', color: const Color(0xFF0E8FA8));
    case _Category.refund:
      return (icon: Icons.replay_rounded, label: 'Refund', color: const Color(0xFF1E8E6E));
  }
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

  List<_Txn> get _visible {
    switch (_filter) {
      case _Filter.all:
        return _transactions;
      case _Filter.income:
        return _transactions.where((t) => t.isIncome).toList();
      case _Filter.expenses:
        return _transactions.where((t) => !t.isIncome).toList();
      case _Filter.pending:
        return _transactions.where((t) => t.pending).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final groups = <String, List<_Txn>>{};
    for (final t in visible) {
      groups.putIfAbsent(_dayLabel(t.date), () => []).add(t);
    }

    final slivers = <Widget>[
      SliverAppBar.large(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Search transactions',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Download statement',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      const SliverToBoxAdapter(child: _SummaryCard()),
      SliverToBoxAdapter(
        child: _FilterBar(
          selected: _filter,
          onChanged: (f) => setState(() => _filter = f),
        ),
      ),
    ];

    if (visible.isEmpty) {
      slivers.add(const SliverFillRemaining(hasScrollBody: false, child: _EmptyState()));
    } else {
      for (final entry in groups.entries) {
        final total = entry.value.fold<int>(0, (s, t) => s + t.amountCents);
        slivers.add(SliverToBoxAdapter(child: _DateHeader(label: entry.key, totalCents: total)));
        slivers.add(SliverList.separated(
          itemCount: entry.value.length,
          itemBuilder: (context, i) => _TransactionTile(txn: entry.value[i]),
          separatorBuilder: (context, i) => const Divider(indent: 76),
        ));
      }
    }
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(slivers: slivers),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final income = _transactions.where((t) => t.isIncome).fold<int>(0, (s, t) => s + t.amountCents);
    final spent = _transactions.where((t) => !t.isIncome).fold<int>(0, (s, t) => s + t.amountCents);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Everyday Checking •• 4821',
              style: theme.textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 6),
            Semantics(
              label: 'Available balance ${_money(864217)}',
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _money(864217),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            Text(
              'Available balance',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatPill(
                  icon: Icons.south_west_rounded,
                  label: 'In this week',
                  value: _money(income, signed: true),
                  color: const Color(0xFF1E8E6E),
                ),
                _StatPill(
                  icon: Icons.north_east_rounded,
                  label: 'Out this week',
                  value: _money(spent),
                  color: scheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;

  static const _labels = {
    _Filter.all: 'All',
    _Filter.income: 'Income',
    _Filter.expenses: 'Expenses',
    _Filter.pending: 'Pending',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (final f in _Filter.values) ...[
            ChoiceChip(
              label: Text(_labels[f]!),
              selected: selected == f,
              showCheckmark: false,
              onSelected: (_) => onChanged(f),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label, required this.totalCents});

  final String label;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(label, style: style),
            Text(
              _money(totalCents, signed: true),
              style: style?.copyWith(fontWeight: FontWeight.w500, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        ),
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
    final cat = _categoryStyle(txn.category);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? Color.lerp(cat.color, Colors.white, 0.35)! : cat.color;
    final incomeColor = isDark ? const Color(0xFF6FD6A8) : const Color(0xFF16774F);
    final largeText = MediaQuery.textScalerOf(context).scale(16) / 16 >= 1.6;

    final subtitleParts = [cat.label, _time(txn.date), if (txn.note != null) txn.note!];

    final amount = Text(
      _money(txn.amountCents, signed: true),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: txn.isIncome ? incomeColor : scheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    final pendingBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Pending',
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.onTertiaryContainer, fontWeight: FontWeight.w600),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          txn.merchant,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          maxLines: largeText ? 3 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitleParts.join(' · '),
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          maxLines: largeText ? 4 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (largeText) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [amount, if (txn.pending) pendingBadge],
          ),
        ],
      ],
    );

    final semanticsLabel = [
      txn.merchant,
      txn.isIncome ? 'received ${_money(txn.amountCents)}' : 'spent ${_money(txn.amountCents.abs())}',
      cat.label,
      _time(txn.date),
      if (txn.note != null) txn.note!,
      if (txn.pending) 'pending',
    ].join(', ');

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {},
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: largeText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(cat.icon, color: accent, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(child: details),
                if (!largeText) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      amount,
                      if (txn.pending) ...[const SizedBox(height: 4), pendingBadge],
                    ],
                  ),
                ],
              ],
            ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No transactions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Nothing matches this filter yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
