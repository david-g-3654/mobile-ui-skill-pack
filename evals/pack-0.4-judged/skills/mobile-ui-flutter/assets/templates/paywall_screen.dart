// paywall_screen.dart — Paywall archetype (mobile-ui/references/screen-paywall.md).
// Push with `MaterialPageRoute(fullscreenDialog: true)`.
// Close visible from frame one. Recommended plan pre-selected. CTA states the deal. Terms beside CTA.
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components.dart';
import '../theme.dart';

enum Plan { monthly, yearly }

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Plan plan = Plan.yearly;
  bool purchasing = false;

  static const benefits = [
    'Unlimited journals and entries',
    'Weekly insights on your mood patterns',
    'Sync across all your devices',
    'Lock sensitive entries with your face or fingerprint',
  ];

  String get cta => plan == Plan.yearly ? 'Start 7-day free trial' : 'Subscribe for \$7.99/month';
  String get terms => plan == Plan.yearly
      ? '7 days free, then \$49.99/year. Cancel anytime in Settings.'
      : '\$7.99/month. Cancel anytime in Settings.';

  Future<void> _purchase() async {
    setState(() => purchasing = true);
    // await Purchases.purchasePackage(...)
    HapticFeedback.heavyImpact();
    if (mounted) setState(() => purchasing = false);
  }

  /// Plain-language terms + links: pinned under the CTA, or in the scroll content at large text sizes.
  List<Widget> _legal(BuildContext context) => [
        Text(terms, style: context.qText.bodySmall, textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: QSpace.md,
          children: [
            QTertiaryButton(label: 'Terms', onPressed: () {}),
            QTertiaryButton(label: 'Privacy', onPressed: () {}),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(backgroundColor: q.surface2, foregroundColor: q.ink2),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [QTertiaryButton(label: 'Restore', onPressed: () {}), const SizedBox(width: QSpace.xs)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xl, QSpace.margin, QSpace.xl),
        children: [
          // Editorial personality: serif for the headline only.
          QDisplayScale(
            child: Text('Write it down.\nSee the pattern.',
                style: context.qText.headlineLarge?.copyWith(fontFamily: 'serif', fontFamilyFallback: const ['Georgia'])),
          ),
          const SizedBox(height: QSpace.xl),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: QSpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: QSpace.sm,
                children: [
                  Icon(Icons.check_rounded, size: 20, color: q.accent),
                  Expanded(child: Text(b, style: context.qText.bodyLarge)),
                ],
              ),
            ),
          const SizedBox(height: QSpace.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: QSpace.sm,
              children: [
                Expanded(
                  child: QPlanCard(
                    name: 'Monthly',
                    price: '\$7.99',
                    period: '/mo',
                    detail: 'Billed monthly',
                    selected: plan == Plan.monthly,
                    onTap: () => setState(() => plan = Plan.monthly),
                  ),
                ),
                Expanded(
                  child: QPlanCard(
                    name: 'Yearly',
                    price: '\$49.99',
                    period: '/yr',
                    detail: '\$4.17/mo',
                    badge: 'Save 48%',
                    selected: plan == Plan.yearly,
                    onTap: () => setState(() => plan = Plan.yearly),
                  ),
                ),
              ],
            ),
          ),
          // At accessibility sizes the bar pins only the button; the terms move here.
          QLargeTextFooter(children: _legal(context)),
        ],
      ),
      bottomNavigationBar: QBottomActionBar(
        footer: _legal(context),
        children: [QPrimaryButton(label: cta, loading: purchasing, onPressed: _purchase)],
      ),
    );
  }
}
