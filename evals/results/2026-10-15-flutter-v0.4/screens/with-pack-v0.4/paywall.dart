// Paywall — "Margins", a journaling app. Job: pick a plan and start.
// Focal: headline + pre-selected yearly plan. Primary: one pinned CTA that states the deal.
// Cut: feature comparison table (behind "See everything in Plus"), testimonials, hero art.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margins Plus',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _PaywallScreen(),
    );
  }
}

enum _Plan { monthly, yearly }

// Sample pricing — one currency format across the screen.
const _monthlyPrice = '\$5.99';
const _yearlyPrice = '\$39.99';
const _yearlyPerMonth = '\$3.33';
const _trialDays = 7;

const _benefits = [
  'Unlimited entries, photos and voice notes',
  'Monthly look-backs that show what changed',
  'Entries locked behind Face ID or a passcode',
  'Your journal on phone, tablet and the web',
];

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  _Plan _plan = _Plan.yearly;
  bool _purchasing = false;

  bool get _hasTrial => _plan == _Plan.yearly;

  String get _cta => _hasTrial ? 'Start $_trialDays-day free trial' : 'Subscribe for $_monthlyPrice/month';

  String get _terms => _hasTrial
      ? '$_trialDays days free, then $_yearlyPrice/year. Cancel anytime in Settings.'
      : '$_monthlyPrice/month, renews automatically. Cancel anytime in Settings.';

  Future<void> _subscribe() async {
    setState(() => _purchasing = true);
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _purchasing = false);
    showQToast(context, _hasTrial ? 'Your free week has started' : 'Welcome to Margins Plus');
  }

  void _restore() => showQToast(context, 'No earlier purchases found on this account');

  void _select(_Plan plan) => setState(() => _plan = plan);

  List<Widget> _legal(BuildContext context) => [
        Text(_terms, style: context.qText.bodySmall, textAlign: TextAlign.center),
        Wrap(
          alignment: WrapAlignment.center,
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
    final large = qIsLargeText(context);

    final monthly = QPlanCard(
      name: 'Monthly',
      price: _monthlyPrice,
      period: '/mo',
      detail: 'No trial, billed monthly',
      selected: _plan == _Plan.monthly,
      onTap: () => _select(_Plan.monthly),
    );
    final yearly = QPlanCard(
      name: 'Yearly',
      price: _yearlyPrice,
      period: '/yr',
      detail: '$_yearlyPerMonth/mo · $_trialDays days free',
      badge: 'Save 44%',
      selected: _plan == _Plan.yearly,
      onTap: () => _select(_Plan.yearly),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          style: IconButton.styleFrom(backgroundColor: q.surface2, foregroundColor: q.ink2),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          QTertiaryButton(label: 'Restore', onPressed: _restore),
          const SizedBox(width: QSpace.xs),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.md, QSpace.margin, QSpace.xxl),
        children: [
          Text('MARGINS PLUS', style: context.qText.labelSmall),
          const SizedBox(height: QSpace.xs),
          Semantics(
            header: true,
            child: QDisplayScale(
              child: Text('Keep the thread\nof your days.', style: context.qText.headlineLarge),
            ),
          ),
          const SizedBox(height: QSpace.xl),
          Column(
            spacing: QSpace.sm,
            children: [for (final b in _benefits) _Benefit(text: b)],
          ),
          const SizedBox(height: QSpace.xl),
          if (large)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: QSpace.sm,
              children: [yearly, monthly],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: QSpace.sm,
                children: [Expanded(child: monthly), Expanded(child: yearly)],
              ),
            ),
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : QMotion.medium,
            curve: QMotion.curve,
            alignment: Alignment.topCenter,
            child: _hasTrial
                ? const Padding(
                    padding: EdgeInsets.only(top: QSpace.xxl),
                    child: _TrialTimeline(),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: QSpace.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: QTertiaryButton(label: 'See everything in Plus', onPressed: () {}),
          ),
          QLargeTextFooter(children: _legal(context)),
        ],
      ),
      bottomNavigationBar: QBottomActionBar(
        footer: _legal(context),
        children: [QPrimaryButton(label: _cta, loading: _purchasing, onPressed: _subscribe)],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: QSpace.sm,
      children: [
        ExcludeSemantics(child: Icon(Icons.check_rounded, size: 20, color: context.q.ink2)),
        Expanded(child: Text(text, style: context.qText.bodyLarge)),
      ],
    );
  }
}

/// Trust timeline for the trial: what happens today, when we remind, when billing starts.
class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline();

  static const _steps = [
    ('Today', 'Every Plus feature unlocks.'),
    ('In 5 days', 'We send a reminder before your trial ends.'),
    ('In $_trialDays days', 'You’re charged $_yearlyPrice. Cancel before then and pay nothing.'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOW YOUR TRIAL WORKS', style: context.qText.labelSmall),
        const SizedBox(height: QSpace.sm),
        for (final (i, step) in _steps.indexed)
          MergeSemantics(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: QSpace.sm,
                children: [
                  ExcludeSemantics(
                    child: SizedBox(
                      width: 12,
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          DecoratedBox(
                            decoration: ShapeDecoration(
                              color: i == 0 ? q.accent : q.surface,
                              shape: CircleBorder(side: BorderSide(color: i == 0 ? q.accent : q.ink3, width: 2)),
                            ),
                            child: const SizedBox.square(dimension: 12),
                          ),
                          if (i < _steps.length - 1)
                            Expanded(child: Container(width: 2, color: q.hairline)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? QSpace.md : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: QSpace.xxs,
                        children: [
                          Text(step.$1, style: context.qText.titleMedium),
                          Text(step.$2, style: context.qText.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
