import 'package:flutter/material.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

/// Transactions list — Feed / list archetype.
/// Job: review recent account activity. Focal: available balance. Primary: none (search in the bar).
class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _TransactionsScreen(),
    );
  }
}

// ── Data ────────────────────────────────────────────────────────────

enum _Filter { all, moneyIn, moneyOut, pending }

extension on _Filter {
  String get label => switch (this) {
        _Filter.all => 'All',
        _Filter.moneyIn => 'Money in',
        _Filter.moneyOut => 'Money out',
        _Filter.pending => 'Pending',
      };
}

class _Txn {
  const _Txn({
    required this.merchant,
    required this.category,
    required this.time,
    required this.cents,
    required this.icon,
    this.pending = false,
  });

  final String merchant;
  final String category;
  final String time;

  /// Negative = money out.
  final int cents;
  final IconData icon;
  final bool pending;

  bool get isCredit => cents > 0;
}

class _Day {
  const _Day(this.label, this.items);
  final String label;
  final List<_Txn> items;
}

const _days = <_Day>[
  _Day('Pending', [
    _Txn(
        merchant: 'Blue Bottle Coffee',
        category: 'Coffee',
        time: 'Card ··4417',
        cents: -675,
        icon: Icons.local_cafe_rounded,
        pending: true),
    _Txn(
        merchant: 'Lyft',
        category: 'Transport',
        time: 'Card ··4417',
        cents: -1842,
        icon: Icons.local_taxi_rounded,
        pending: true),
  ]),
  _Day('Today', [
    _Txn(
        merchant: 'Whole Foods Market',
        category: 'Groceries',
        time: '9:12 AM',
        cents: -8412,
        icon: Icons.shopping_basket_rounded),
    _Txn(
        merchant: 'Refund · REI Co-op',
        category: 'Shopping',
        time: '7:40 AM',
        cents: 6495,
        icon: Icons.undo_rounded),
  ]),
  _Day('Yesterday', [
    _Txn(
        merchant: 'Northwind Labs payroll',
        category: 'Salary',
        time: '6:02 AM',
        cents: 264000,
        icon: Icons.work_rounded),
    _Txn(
        merchant: 'Pacific Gas & Electric',
        category: 'Utilities',
        time: '11:30 AM',
        cents: -11873,
        icon: Icons.bolt_rounded),
    _Txn(
        merchant: 'Trader Joe’s',
        category: 'Groceries',
        time: '5:48 PM',
        cents: -4327,
        icon: Icons.shopping_basket_rounded),
    _Txn(
        merchant: 'Spotify',
        category: 'Subscriptions',
        time: '8:00 PM',
        cents: -1199,
        icon: Icons.autorenew_rounded),
  ]),
  _Day('Monday, Oct 12', [
    _Txn(
        merchant: 'Rent · Maple Court Apartments',
        category: 'Housing',
        time: '10:15 AM',
        cents: -218500,
        icon: Icons.home_rounded),
    _Txn(
        merchant: 'From Priya Raman',
        category: 'Transfer · Dinner split',
        time: '8:21 PM',
        cents: 3850,
        icon: Icons.swap_horiz_rounded),
    _Txn(
        merchant: 'Shell',
        category: 'Fuel',
        time: '6:05 PM',
        cents: -5216,
        icon: Icons.local_gas_station_rounded),
  ]),
  _Day('Sunday, Oct 11', [
    _Txn(
        merchant: 'Tartine Bakery',
        category: 'Dining',
        time: '10:34 AM',
        cents: -2360,
        icon: Icons.restaurant_rounded),
    _Txn(
        merchant: 'Apple.com',
        category: 'Shopping',
        time: '3:17 PM',
        cents: -12900,
        icon: Icons.shopping_bag_rounded),
  ]),
];

String _money(int cents) {
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString();
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  final frac = (abs % 100).toString().padLeft(2, '0');
  return '\$$buf.$frac';
}

String _signed(int cents) => cents > 0 ? '+${_money(cents)}' : '−${_money(cents)}';

// ── Screen ──────────────────────────────────────────────────────────

class _TransactionsScreen extends StatefulWidget {
  const _TransactionsScreen();

  @override
  State<_TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<_TransactionsScreen> {
  _Filter _filter = _Filter.all;

  bool _matches(_Txn t) => switch (_filter) {
        _Filter.all => true,
        _Filter.moneyIn => t.isCredit,
        _Filter.moneyOut => !t.isCredit,
        _Filter.pending => t.pending,
      };

  List<_Day> get _visibleDays => [
        for (final d in _days)
          if (d.items.where(_matches).isNotEmpty) _Day(d.label, d.items.where(_matches).toList()),
      ];

  Future<void> _refresh() => Future<void>.delayed(const Duration(milliseconds: 800));

  @override
  Widget build(BuildContext context) {
    final days = _visibleDays;
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: const Text('Activity'),
              actions: [
                IconButton(
                  tooltip: 'Search transactions',
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {},
                ),
                const SizedBox(width: Space.xxs),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Space.xl,
                  children: [
                    const HeroMetric(
                      label: 'Available balance',
                      prefix: '\$',
                      value: '4,218',
                      suffix: '.36',
                      context: 'Everyday checking ··4417',
                    ),
                    Wrap(
                      spacing: Space.xs,
                      runSpacing: Space.xs,
                      children: [
                        for (final f in _Filter.values)
                          QuietChip(
                            label: f.label,
                            selected: f == _filter,
                            onTap: () => setState(() => _filter = f),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (days.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No ${_filter.label.toLowerCase()} transactions',
                  message: 'Nothing matches this filter in the last 7 days.',
                  actionLabel: 'Show all activity',
                  onAction: () => setState(() => _filter = _Filter.all),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.margin, Space.xxl, Space.margin, Space.xxl),
                sliver: SliverList.separated(
                  itemCount: days.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.xxl),
                  itemBuilder: (context, i) {
                    if (i == days.length) return const _ListFooter();
                    final day = days[i];
                    return GroupedSection(
                      header: day.label,
                      children: [for (final t in day.items) _TxnRow(txn: t)],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Row ─────────────────────────────────────────────────────────────

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});

  final _Txn txn;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final stacked = isLargeText(context);
    final subtitle = txn.pending ? 'Pending · ${txn.time}' : '${txn.category} · ${txn.time}';
    final amount = Text(
      _signed(txn.cents),
      textAlign: TextAlign.right,
      style: context.t.bodyLarge?.copyWith(
        color: txn.isCredit ? q.positive : (txn.pending ? q.ink2 : q.ink),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final glyph = ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(color: q.surface2, shape: BoxShape.circle),
        child: SizedBox.square(
          dimension: 40,
          child: Icon(txn.icon, size: 20, color: q.ink2),
        ),
      ),
    );
    final label = '${txn.merchant}, $subtitle, '
        '${txn.isCredit ? 'received' : 'spent'} ${_money(txn.cents)}';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {},
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
            child: Row(
              spacing: Space.sm,
              children: [
                if (!stacked) glyph,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        txn.merchant,
                        style: context.t.titleMedium,
                        maxLines: stacked ? null : 1,
                        overflow: stacked ? null : TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: context.t.bodyMedium,
                        maxLines: stacked ? null : 1,
                        overflow: stacked ? null : TextOverflow.ellipsis,
                      ),
                      if (stacked) amount,
                    ],
                  ),
                ),
                if (!stacked) amount,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.xxs,
      children: [
        Text('Showing the last 7 days.', style: context.t.bodyMedium),
        TertiaryButton(label: 'Show earlier activity', onPressed: () {}),
      ],
    );
  }
}
