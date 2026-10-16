import 'package:flutter/material.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class ListEvalApp extends StatelessWidget {
  const ListEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _TransactionsScreen(),
    );
  }
}

class _Transaction {
  const _Transaction(
    this.merchant,
    this.category,
    this.amount,
    this.day,
    this.time,
    this.icon, {
    this.pending = false,
  });

  final String merchant;
  final String category;
  final String amount;
  final int day;
  final String time;
  final IconData icon;
  final bool pending;

  bool get incoming => amount.startsWith('+');
}

const _transactions = [
  _Transaction(
    'Blue Bottle Coffee',
    'Coffee & dining',
    '−\$6.80',
    0,
    '9:42 AM',
    Icons.local_cafe_outlined,
    pending: true,
  ),
  _Transaction(
    'Whole Foods Market',
    'Groceries',
    '−\$74.29',
    0,
    '8:16 AM',
    Icons.shopping_bag_outlined,
  ),
  _Transaction(
    'From Maya Chen',
    'Transfer received',
    '+\$48.50',
    0,
    '7:35 AM',
    Icons.south_west_outlined,
  ),
  _Transaction(
    'Spotify',
    'Subscription',
    '−\$11.99',
    1,
    '6:02 PM',
    Icons.headphones_outlined,
  ),
  _Transaction(
    'City of Portland Parking',
    'Transport',
    '−\$3.25',
    1,
    '12:48 PM',
    Icons.local_parking_outlined,
  ),
  _Transaction(
    'Everlane',
    'Shopping · Refund',
    '+\$68.00',
    1,
    '10:21 AM',
    Icons.keyboard_return_outlined,
  ),
  _Transaction(
    'Northstar Studio',
    'Salary',
    '+\$3,240.75',
    2,
    '8:00 AM',
    Icons.work_outline_outlined,
  ),
  _Transaction(
    'Powell’s Books',
    'Shopping',
    '−\$28.95',
    2,
    '7:14 AM',
    Icons.menu_book_outlined,
  ),
  _Transaction(
    'TriMet',
    'Transport',
    '−\$2.80',
    3,
    '5:32 PM',
    Icons.directions_bus_outlined,
  ),
];

class _TransactionsScreen extends StatefulWidget {
  const _TransactionsScreen();

  @override
  State<_TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<_TransactionsScreen> {
  final _search = TextEditingController();
  int _filter = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Transaction> get _visible {
    final query = _search.text.trim().toLowerCase();
    return _transactions.where((transaction) {
      final matchesFilter =
          _filter == 0 ||
          (_filter == 1 && !transaction.incoming) ||
          (_filter == 2 && transaction.incoming);
      final searchable = '${transaction.merchant} ${transaction.category}'
          .toLowerCase();
      return matchesFilter && searchable.contains(query);
    }).toList();
  }

  String _date(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final short = '${months[date.month - 1]} ${date.day}';
    return switch (daysAgo) {
      0 => 'Today · $short',
      1 => 'Yesterday · $short',
      _ => short,
    };
  }

  void _showDetails(_Transaction transaction) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            QSpace.margin,
            QSpace.xs,
            QSpace.margin,
            QSpace.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: QSpace.xl,
            children: [
              Semantics(
                header: true,
                child: Text(
                  transaction.merchant,
                  style: context.qText.titleLarge,
                ),
              ),
              QHeroMetric(
                label: transaction.incoming ? 'Money received' : 'Payment',
                value: transaction.amount,
              ),
              QGroupedSection(
                children: [
                  QListRow(
                    title: 'Status',
                    value: transaction.pending ? 'Pending' : 'Completed',
                  ),
                  QListRow(title: 'Category', value: transaction.category),
                  QListRow(
                    title: _date(transaction.day),
                    value: transaction.time,
                  ),
                  const QListRow(title: 'Account', value: 'Everyday · 4821'),
                ],
              ),
              if (transaction.pending)
                Text(
                  'This payment is still being processed. The final amount '
                  'may change when the merchant completes it.',
                  style: context.qText.bodyMedium,
                ),
              QSecondaryButton(
                label: 'Close details',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final days = visible.map((transaction) => transaction.day).toSet();
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            await Future<void>.delayed(QMotion.medium);
            if (mounted) setState(() {});
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverAppBar.large(
                title: Text('Transactions'),
                centerTitle: false,
                pinned: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  QSpace.margin,
                  QSpace.xs,
                  QSpace.margin,
                  QSpace.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: QSpace.xl,
                    children: [
                      const QHeroMetric(
                        label: 'Available balance',
                        prefix: '\$',
                        value: '8,246.38',
                        context: 'Everyday account · •• 4821',
                      ),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: context.qText.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'Search transactions',
                          labelStyle: context.qText.bodyMedium,
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            color: context.q.ink2,
                          ),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close_outlined),
                                  onPressed: () => setState(_search.clear),
                                ),
                        ),
                      ),
                      Wrap(
                        spacing: QSpace.xs,
                        runSpacing: QSpace.xs,
                        children: [
                          for (final (index, label) in [
                            'All',
                            'Money out',
                            'Money in',
                          ].indexed)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: QMetrics.minTap,
                              ),
                              child: FilterChip(
                                label: Text(label),
                                labelStyle: context.qText.bodyMedium?.copyWith(
                                  color: _filter == index
                                      ? context.q.accent
                                      : context.q.ink2,
                                ),
                                selected: _filter == index,
                                selectedColor: context.q.accentSoft,
                                backgroundColor: context.q.canvas,
                                checkmarkColor: context.q.accent,
                                shape: const StadiumBorder(),
                                side: BorderSide(
                                  color: _filter == index
                                      ? context.q.accent
                                      : context.q.hairline,
                                ),
                                onSelected: (_) =>
                                    setState(() => _filter = index),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: QEmptyState(
                    icon: Icons.search_outlined,
                    title: 'No matching transactions',
                    message:
                        'Try a different merchant or clear your filters '
                        'to see all your activity.',
                    actionLabel: 'Clear filters',
                    onAction: () => setState(() {
                      _search.clear();
                      _filter = 0;
                    }),
                  ),
                ),
              for (final day in days) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DateHeader(
                    label: _date(day),
                    background: context.q.canvas,
                    style: context.qText.bodyMedium!,
                    height:
                        MediaQuery.textScalerOf(context).scale(QSpace.lg) +
                        QSpace.xl,
                  ),
                ),
                SliverList.separated(
                  itemCount: visible.where((item) => item.day == day).length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: QSpace.margin + QSpace.xxl + QSpace.xs,
                    endIndent: QSpace.margin,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = visible
                        .where((item) => item.day == day)
                        .elementAt(index);
                    return MergeSemantics(
                      child: QListRow(
                        title: transaction.merchant,
                        subtitle: transaction.pending
                            ? '${transaction.category} · Pending'
                            : transaction.category,
                        icon: transaction.icon,
                        value: transaction.amount,
                        kind: QRowKind.action,
                        onTap: () => _showDetails(transaction),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: QSpace.md)),
              ],
              if (visible.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(QSpace.xl),
                    child: Text(
                      'You’re up to date',
                      textAlign: TextAlign.center,
                      style: context.qText.bodyMedium,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SafeArea(top: false, child: SizedBox(height: QSpace.md)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends SliverPersistentHeaderDelegate {
  const _DateHeader({
    required this.label,
    required this.background,
    required this.style,
    required this.height,
  });

  final String label;
  final Color background;
  final TextStyle style;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QSpace.margin),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Semantics(header: true, child: Text(label, style: style)),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_DateHeader oldDelegate) =>
      label != oldDelegate.label ||
      background != oldDelegate.background ||
      style != oldDelegate.style ||
      height != oldDelegate.height;
}
