// Transactions — Feed / list archetype.
// Job: scan recent account activity. Focal: month-to-date spend summary, then the rows.
// Primary action: none in content (search lives in the app bar). Cutting: per-row chevrons,
// category color circles, charts (those belong on a stats screen).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transactions',
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
    required this.icon,
    required this.cents,
    required this.time,
    this.pending = false,
  });

  final String merchant;
  final String category;
  final IconData icon;

  /// Signed: negative is money out.
  final int cents;
  final String time;
  final bool pending;

  bool get isCredit => cents > 0;
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
        pending: true),
    _Txn(
        merchant: 'Lyft',
        category: 'Transport',
        icon: Icons.directions_car_rounded,
        cents: -1894,
        time: '7:48 AM',
        pending: true),
  ]),
  _Day('Yesterday', [
    _Txn(
        merchant: 'Trader Joe’s',
        category: 'Groceries',
        icon: Icons.shopping_basket_rounded,
        cents: -6418,
        time: '6:35 PM'),
    _Txn(
        merchant: 'Maya Lindqvist',
        category: 'Transfer in · Concert tickets',
        icon: Icons.south_west_rounded,
        cents: 4250,
        time: '2:10 PM'),
    _Txn(
        merchant: 'Spotify',
        category: 'Subscriptions',
        icon: Icons.subscriptions_rounded,
        cents: -1199,
        time: '9:00 AM'),
  ]),
  _Day('Tuesday, Oct 13', [
    _Txn(
        merchant: 'PG&E',
        category: 'Utilities · Autopay',
        icon: Icons.bolt_rounded,
        cents: -12733,
        time: '11:02 AM'),
    _Txn(
        merchant: 'Sweetgreen',
        category: 'Restaurants',
        icon: Icons.restaurant_rounded,
        cents: -1645,
        time: '12:41 PM'),
  ]),
  _Day('Monday, Oct 12', [
    _Txn(
        merchant: 'Northwind Design Co.',
        category: 'Payroll deposit',
        icon: Icons.account_balance_rounded,
        cents: 284016,
        time: '6:00 AM'),
    _Txn(
        merchant: 'Shell',
        category: 'Fuel',
        icon: Icons.local_gas_station_rounded,
        cents: -5207,
        time: '5:24 PM'),
    _Txn(
        merchant: 'Amazon',
        category: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        cents: -3899,
        time: '1:15 PM'),
    _Txn(
        merchant: 'Bay Club Gym',
        category: 'Health & fitness',
        icon: Icons.fitness_center_rounded,
        cents: -8900,
        time: '7:30 AM'),
  ]),
];

/// One formatter for the whole screen: "−$64.18" / "+$2,840.16".
String _money(int cents, {bool signed = true}) {
  final abs = cents.abs();
  final dollars = abs ~/ 100;
  final rest = (abs % 100).toString().padLeft(2, '0');
  final grouped = dollars.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  final sign = !signed ? '' : (cents < 0 ? '−' : '+');
  return '$sign\$$grouped.$rest';
}

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

  void _openDetail(_Txn t) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TxnSheet(txn: t),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      for (final d in _days)
        if (d.items.where(_matches).isNotEmpty) _Day(d.label, d.items.where(_matches).toList()),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Transactions'),
            actions: [
              IconButton(
                tooltip: 'Search transactions',
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: QSpace.xxs),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                const QHeroMetric(
                  label: 'Spent in October',
                  prefix: '\$',
                  value: '2,184',
                  suffix: '.37',
                  context: 'Everyday Checking ••4821',
                ),
                const SizedBox(height: QSpace.xl),
                Wrap(
                  spacing: QSpace.xs,
                  runSpacing: QSpace.xs,
                  children: [
                    for (final f in _Filter.values)
                      QChip(
                        label: f.label,
                        selected: f == _filter,
                        onTap: () => setState(() => _filter = f),
                      ),
                  ],
                ),
                const SizedBox(height: QSpace.xl),
                if (days.isEmpty)
                  QEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No ${_filter.label.toLowerCase()} transactions',
                    message: 'Nothing matches this filter in the last 30 days.',
                    actionLabel: 'Show all transactions',
                    onAction: () => setState(() => _filter = _Filter.all),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: QSpace.xl,
                    children: [
                      for (final d in days)
                        QGroupedSection(
                          header: d.label,
                          children: [
                            for (final t in d.items) _TxnRow(txn: t, onTap: () => _openDetail(t)),
                          ],
                        ),
                    ],
                  ),
                if (days.isNotEmpty) ...[
                  const SizedBox(height: QSpace.lg),
                  Center(
                    child: QTertiaryButton(label: 'Show September', onPressed: () {}),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row ─────────────────────────────────────────────────────────────

/// Glyph · merchant + category · amount. Debits in ink with a minus; only credits get color
/// (paired with "+", so it never relies on color alone). Stacks at accessibility sizes.
class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.onTap});

  final _Txn txn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.qText;
    final stacked = qIsLargeText(context);
    final meta = txn.pending ? 'Pending · ${txn.category}' : '${txn.category} · ${txn.time}';
    final amount = Text(
      _money(txn.cents),
      style: t.bodyLarge?.copyWith(
        color: txn.isCredit ? q.positive : q.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final glyph = ExcludeSemantics(
      child: SizedBox(width: 28, child: Icon(txn.icon, size: 22, color: q.ink2)),
    );

    return MergeSemantics(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.sm),
            child: Row(
              spacing: QSpace.sm,
              children: [
                if (!stacked) glyph,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(txn.merchant, style: t.bodyLarge, maxLines: stacked ? null : 1,
                          overflow: stacked ? null : TextOverflow.ellipsis),
                      Text(meta, style: t.bodyMedium, maxLines: stacked ? null : 1,
                          overflow: stacked ? null : TextOverflow.ellipsis),
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

// ── Detail sheet ────────────────────────────────────────────────────

class _TxnSheet extends StatelessWidget {
  const _TxnSheet({required this.txn});

  final _Txn txn;

  @override
  Widget build(BuildContext context) {
    final t = context.qText;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(QSpace.margin, 0, QSpace.margin, QSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: QSpace.xl,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: QSpace.xxs,
              children: [
                Semantics(header: true, child: Text(txn.merchant, style: t.titleLarge)),
                QDisplayScale(
                  child: Text(_money(txn.cents),
                      style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ),
              ],
            ),
            QGroupedSection(
              children: [
                QListRow(title: 'Status', value: txn.pending ? 'Pending' : 'Posted'),
                QListRow(title: 'Category', value: txn.category.split(' · ').first),
                QListRow(title: 'Time', value: txn.time),
                const QListRow(title: 'Account', value: 'Checking ••4821'),
              ],
            ),
            QSecondaryButton(
              label: 'Report a problem',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
