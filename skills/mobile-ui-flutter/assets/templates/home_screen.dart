// home_screen.dart — Home/dashboard archetype (mobile-ui/references/screen-home.md).
// Job: "see what's left to spend". Focal: hero balance. Primary: none (add lives in the app bar).
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import 'package:flutter/material.dart';

import '../components.dart';
import '../theme.dart';

class Bill {
  const Bill(this.name, this.due, this.amount, this.icon);
  final String name;
  final String due;
  final String amount;
  final IconData icon;
}

const sampleBills = [
  Bill('Rent', 'Due Thursday', '−\$1,450.00', Icons.home_outlined),
  Bill('Spotify Family', 'Sep 18', '−\$16.99', Icons.music_note_outlined),
  Bill('Blue Bottle Coffee subscription', 'Sep 21', '−\$38.40', Icons.coffee_outlined),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.loading = false, this.bills = sampleBills});

  final bool loading;
  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('September'),
            actions: [
              IconButton(
                tooltip: 'Add expense',
                icon: const Icon(Icons.add_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: QSpace.xs),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                const QHeroMetric(
                  label: 'Left to spend',
                  prefix: '\$',
                  value: '2,140',
                  suffix: '.50',
                  context: '12 days to go',
                  delta: QDelta('\$86 under', up: false, upIsGood: false),
                ),
                const SizedBox(height: QSpace.xl),
                const QMetricRow(items: [
                  ('\$1,284', 'spent'),
                  ('\$107', 'per day'),
                  ('62%', 'of budget'),
                ]),
                const SizedBox(height: QSpace.xxl),
                QSectionHeader(title: 'Up next', actionLabel: 'See all', onAction: () {}),
                const SizedBox(height: QSpace.sm),
                if (loading)
                  const QGroupedSection(children: [QSkeletonRow(), QSkeletonRow(), QSkeletonRow()])
                else if (bills.isEmpty)
                  const QEmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'Nothing due',
                    message: "Bills you add show up here a week before they're due.",
                  )
                else
                  QGroupedSection(children: [
                    for (final b in bills) QListRow(icon: b.icon, title: b.name, subtitle: b.due, value: b.amount),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
