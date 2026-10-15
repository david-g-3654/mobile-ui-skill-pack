// Feed / list archetype (mobile-ui/references/screen-list.md + screen-states.md).
// Job: review recent account activity. Focal: the newest transactions (Today group).
// Primary action: none in content — search lives in the app bar, filters are chips.
// Cut: per-row cards, chevrons, red on every debit, the 2x2 "spending stats" grid.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harbor',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _TransactionsScreen(),
    );
  }
}

// ── Model & sample data ─────────────────────────────────────────────

enum _Status { posted, pending, declined }

enum _Filter { all, moneyIn, spending, pending, refunds }

extension on _Filter {
  String get label => switch (this) {
        _Filter.all => 'All',
        _Filter.moneyIn => 'Money in',
        _Filter.spending => 'Spending',
        _Filter.pending => 'Pending',
        _Filter.refunds => 'Refunds',
      };
}

class _Txn {
  const _Txn({
    required this.merchant,
    required this.category,
    required this.icon,
    required this.cents,
    required this.time,
    this.source = 'Debit ••4821',
    this.status = _Status.posted,
    this.refund = false,
  });

  final String merchant;
  final String category;
  final IconData icon;

  /// Negative = money out.
  final int cents;
  final String time;
  final String source;
  final _Status status;
  final bool refund;

  bool get incoming => cents > 0;
}

class _Day {
  const _Day(this.label, this.items);
  final String label;
  final List<_Txn> items;
}

const _days = <_Day>[
  _Day('Today', [
    _Txn(
        merchant: 'Blue Bottle Coffee',
        category: 'Coffee',
        icon: Icons.local_cafe_rounded,
        cents: -675,
        time: '8:12 AM',
        status: _Status.pending),
    _Txn(
        merchant: 'MTA OMNY',
        category: 'Transit',
        icon: Icons.train_rounded,
        cents: -290,
        time: '7:48 AM',
        status: _Status.pending),
  ]),
  _Day('Yesterday', [
    _Txn(
        merchant: 'Northwind Labs payroll',
        category: 'Salary',
        icon: Icons.account_balance_rounded,
        cents: 341000,
        time: '6:00 AM',
        source: 'Direct deposit'),
    _Txn(
        merchant: 'Trader Joe’s',
        category: 'Groceries',
        icon: Icons.shopping_basket_rounded,
        cents: -6438,
        time: '6:41 PM'),
    _Txn(
        merchant: 'Con Edison',
        category: 'Utilities',
        icon: Icons.bolt_rounded,
        cents: -11872,
        time: '9:15 AM',
        source: 'Autopay · Checking ••0193'),
  ]),
  _Day('Monday, Oct 12', [
    _Txn(
        merchant: 'Priya Raman',
        category: 'Transfer',
        icon: Icons.swap_horiz_rounded,
        cents: 4250,
        time: '9:27 PM',
        source: 'Dinner at Lilia'),
    _Txn(
        merchant: 'Lilia',
        category: 'Restaurants',
        icon: Icons.restaurant_rounded,
        cents: -16384,
        time: '8:55 PM'),
    _Txn(
        merchant: 'Equinox',
        category: 'Fitness',
        icon: Icons.fitness_center_rounded,
        cents: -24500,
        time: '12:02 AM',
        status: _Status.declined),
  ]),
  _Day('Saturday, Oct 10', [
    _Txn(
        merchant: 'Uniqlo SoHo',
        category: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        cents: 3990,
        time: '3:10 PM',
        refund: true),
    _Txn(
        merchant: 'Spotify',
        category: 'Subscriptions',
        icon: Icons.subscriptions_rounded,
        cents: -1199,
        time: '11:00 AM'),
    _Txn(
        merchant: 'Shell',
        category: 'Gas',
        icon: Icons.local_gas_station_rounded,
        cents: -5216,
        time: '10:34 AM'),
    _Txn(
        merchant: 'Duane Reade',
        category: 'Pharmacy',
        icon: Icons.local_pharmacy_rounded,
        cents: -1847,
        time: '9:02 AM'),
  ]),
];

String _money(int cents, {bool signed = true}) {
  final abs = cents.abs();
  final dollars = (abs ~/ 100).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  final value = '\$$dollars.${(abs % 100).toString().padLeft(2, '0')}';
  if (!signed) return value;
  return cents < 0 ? '−$value' : '+$value';
}

// ── Screen ──────────────────────────────────────────────────────────

class _TransactionsScreen extends StatefulWidget {
  const _TransactionsScreen();

  @override
  State<_TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<_TransactionsScreen> {
  _Filter _filter = _Filter.all;
  int _tab = 1;

  bool _matches(_Txn t) => switch (_filter) {
        _Filter.all => true,
        _Filter.moneyIn => t.incoming && !t.refund,
        _Filter.spending => !t.incoming && t.status != _Status.declined,
        _Filter.pending => t.status == _Status.pending,
        _Filter.refunds => t.refund,
      };

  Future<void> _refresh() => Future<void>.delayed(const Duration(milliseconds: 600));

  void _open(_Txn t, String day) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _DetailSheet(txn: t, day: day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      for (final d in _days)
        if (d.items.any(_matches)) _Day(d.label, d.items.where(_matches).toList()),
    ];

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
            SliverToBoxAdapter(child: _Summary()),
            SliverToBoxAdapter(
              child: _FilterBar(
                selected: _filter,
                onSelect: (f) => setState(() => _filter = f),
              ),
            ),
            if (days.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No ${_filter.label.toLowerCase()} in the last 30 days',
                  message: 'Try another filter, or pull down to check for new activity.',
                  actionLabel: 'Show all activity',
                  onAction: () => setState(() => _filter = _Filter.all),
                ),
              )
            else ...[
              for (final day in days) ...[
                SliverToBoxAdapter(child: _DayHeader(label: day.label)),
                SliverList.separated(
                  itemCount: day.items.length,
                  separatorBuilder: (_, _) => const Divider(indent: 72),
                  itemBuilder: (context, i) => _TxnRow(
                    txn: day.items[i],
                    onTap: () => _open(day.items[i], day.label),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.margin, Space.xl, Space.margin, Space.xxl),
                  child: Column(
                    spacing: Space.xxs,
                    children: [
                      Text('Showing activity since Oct 10', style: context.t.bodySmall),
                      TertiaryButton(label: 'Load earlier transactions', onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.credit_card_rounded), label: 'Cards'),
        ],
      ),
    );
  }
}

// ── Pieces ──────────────────────────────────────────────────────────

/// One quiet line of context under the title — not a stat grid.
class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.sm),
      child: Text.rich(
        TextSpan(
          style: context.t.bodyMedium,
          children: [
            const TextSpan(text: 'October so far  '),
            TextSpan(
              text: '${_money(-128452, signed: false)} spent',
              style: TextStyle(color: q.ink, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const TextSpan(text: '  ·  '),
            TextSpan(
              text: '${_money(345250, signed: false)} in',
              style: TextStyle(color: q.ink, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final _Filter selected;
  final ValueChanged<_Filter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xs),
      child: Row(
        spacing: Space.xs,
        children: [
          for (final f in _Filter.values)
            QuietChip(label: f.label, selected: f == selected, onTap: () => onSelect(f)),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.margin, Space.xl, Space.margin, Space.xs),
      child: Semantics(header: true, child: Text(label.toUpperCase(), style: context.t.labelSmall)),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: q.surface2, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: q.ink2),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.onTap});

  final _Txn txn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final stacked = isLargeText(context);
    final declined = txn.status == _Status.declined;

    final meta = switch (txn.status) {
      _Status.pending => 'Pending · ${txn.category}',
      _Status.declined => 'Declined · ${txn.category}',
      _Status.posted => txn.refund ? 'Refund · ${txn.category}' : '${txn.category} · ${txn.source}',
    };

    // Debits stay ink with a minus sign; color only for money in and declines (plus text).
    final amountColor = declined
        ? q.ink2
        : txn.incoming
            ? q.positive
            : q.ink;
    final amount = Text(
      _money(txn.cents),
      style: context.t.bodyLarge?.copyWith(
        color: amountColor,
        fontFeatures: const [FontFeature.tabularFigures()],
        decoration: declined ? TextDecoration.lineThrough : null,
        decorationColor: q.ink2,
      ),
    );

    final metaText = Text(
      meta,
      style: context.t.bodyMedium?.copyWith(color: declined ? q.negative : null),
      maxLines: stacked ? null : 1,
      overflow: stacked ? null : TextOverflow.ellipsis,
    );

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.margin, vertical: Space.sm),
            child: Row(
              spacing: Space.md,
              children: [
                if (!stacked) _Glyph(icon: txn.icon),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(txn.merchant,
                          style: context.t.titleMedium,
                          maxLines: stacked ? null : 1,
                          overflow: stacked ? null : TextOverflow.ellipsis),
                      metaText,
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

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.txn, required this.day});

  final _Txn txn;
  final String day;

  @override
  Widget build(BuildContext context) {
    final status = switch (txn.status) {
      _Status.pending => 'Pending',
      _Status.declined => 'Declined',
      _Status.posted => 'Posted',
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: Space.xl,
        children: [
          HeroMetric(label: txn.merchant, value: _money(txn.cents), context: '$day · ${txn.time}'),
          GroupedSection(children: [
            ListRow(title: 'Status', value: status),
            ListRow(title: 'Category', value: txn.category),
            ListRow(title: 'Paid with', value: txn.source),
          ]),
          SecondaryButton(
            label: 'Report a problem',
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
