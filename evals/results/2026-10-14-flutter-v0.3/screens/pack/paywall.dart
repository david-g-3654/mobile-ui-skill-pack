// Paywall — Margin journal. Job: pick a plan and start writing with Margin Plus.
// Focal: headline + the pre-selected yearly plan. Primary: pinned CTA that states the deal.
// Cut: feature comparison table (behind "See everything in Plus"), testimonials, hero illustration.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margin Plus',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _PaywallScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

enum _PlanId { monthly, yearly }

class _Plan {
  const _Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.periodWord,
    this.detail,
    this.badge,
    this.trialDays,
  });

  final _PlanId id;
  final String name;
  final String price;
  final String period;
  final String periodWord;
  final String? detail;
  final String? badge;
  final int? trialDays;
}

const _plans = [
  _Plan(
    id: _PlanId.monthly,
    name: 'Monthly',
    price: r'$6.99',
    period: ' /mo',
    periodWord: 'month',
    detail: 'Billed monthly',
  ),
  _Plan(
    id: _PlanId.yearly,
    name: 'Yearly',
    price: r'$47.99',
    period: ' /yr',
    periodWord: 'year',
    detail: r'$4.00/mo, billed yearly',
    badge: 'Save 43%',
    trialDays: 7,
  ),
];

const _benefits = [
  'Unlimited entries, photos and voice notes',
  'Weekly reflections on your moods and themes',
  'On this day: revisit past entries each morning',
  'Locked with Face ID and end-to-end encryption',
  'Export to PDF or Markdown whenever you like',
];

// ── Screen ──────────────────────────────────────────────────────────

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  _PlanId _selected = _PlanId.yearly;
  bool _purchasing = false;

  _Plan get _plan => _plans.firstWhere((p) => p.id == _selected);

  String get _ctaLabel {
    final plan = _plan;
    return plan.trialDays != null
        ? 'Start ${plan.trialDays}-day free trial'
        : 'Subscribe for ${plan.price}/${plan.periodWord}';
  }

  String get _terms {
    final plan = _plan;
    return plan.trialDays != null
        ? '${plan.trialDays} days free, then ${plan.price}/${plan.periodWord}. Cancel anytime in Settings.'
        : '${plan.price}/${plan.periodWord}, renews automatically. Cancel anytime in Settings.';
  }

  Future<void> _purchase() async {
    HapticFeedback.mediumImpact();
    setState(() => _purchasing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _purchasing = false);
    showToast(context, 'Welcome to Margin Plus');
  }

  List<Widget> _footer(BuildContext context) => [
        Text(
          _terms,
          textAlign: TextAlign.center,
          style: context.t.bodySmall?.copyWith(color: context.q.ink2),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.xs,
          children: [
            TertiaryButton(label: 'Terms', onPressed: () {}),
            TertiaryButton(label: 'Privacy', onPressed: () {}),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    final large = isLargeText(context);

    final planCards = [
      for (final plan in _plans)
        PlanCard(
          name: plan.name,
          price: plan.price,
          period: plan.period,
          detail: plan.detail,
          badge: plan.badge,
          selected: plan.id == _selected,
          onTap: () => setState(() => _selected = plan.id),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close',
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          TertiaryButton(label: 'Restore', onPressed: () => showToast(context, 'No previous purchases found')),
          const SizedBox(width: Space.xs),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        footer: _footer(context),
        children: [
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.fast,
            child: PrimaryButton(
              key: ValueKey(_selected),
              label: _ctaLabel,
              loading: _purchasing,
              onPressed: _purchase,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
        children: [
          // Headline — the focal zone.
          Text('Margin Plus'.toUpperCase(), style: t.labelSmall?.copyWith(color: q.ink2)),
          const SizedBox(height: Space.xs),
          DisplayScale(
            child: Semantics(
              header: true,
              child: Text('Write a little.\nRemember a lot.', style: t.headlineLarge),
            ),
          ),
          const SizedBox(height: Space.xl),

          // Benefits — outcomes, monochrome checks.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.sm,
            children: [for (final b in _benefits) _Benefit(text: b)],
          ),
          const SizedBox(height: Space.xxl),

          // Plans — yearly pre-selected.
          if (large)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: planCards)
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.sm,
                children: [for (final card in planCards) Expanded(child: card)],
              ),
            ),
          const SizedBox(height: Space.xxl),

          // Trial timeline — only meaningful when the selected plan has a trial.
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _plan.trialDays == null
                ? const SizedBox(width: double.infinity)
                : _TrialTimeline(price: _plan.price, periodWord: _plan.periodWord),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: TertiaryButton(label: 'See everything in Plus', onPressed: () {}),
          ),

          LargeTextFooter(children: _footer(context)),
        ],
      ),
    );
  }
}

// ── Pieces ──────────────────────────────────────────────────────────

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ExcludeSemantics(child: Icon(Icons.check_rounded, size: 20, color: context.q.ink)),
          ),
          Expanded(child: Text(text, style: context.t.bodyLarge)),
        ],
      ),
    );
  }
}

class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline({required this.price, required this.periodWord});

  final String price;
  final String periodWord;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Today', 'Full access to every Plus feature.'),
      ('Day 5', 'We’ll send a reminder before your trial ends.'),
      ('Day 7', 'You’re charged $price/$periodWord unless you cancel.'),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text('How your trial works', style: context.t.titleMedium)),
          const SizedBox(height: Space.sm),
          for (var i = 0; i < steps.length; i++)
            _TimelineStep(
              title: steps[i].$1,
              body: steps[i].$2,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.body, required this.isLast});

  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return MergeSemantics(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.sm,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: Space.sm,
                child: Column(
                  children: [
                    const SizedBox(height: Space.xxs + 2),
                    DecoratedBox(
                      decoration: ShapeDecoration(color: q.ink, shape: const CircleBorder()),
                      child: const SizedBox.square(dimension: Space.xs),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Space.xxs),
                          child: VerticalDivider(width: 1, thickness: 1, color: q.hairline),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Space.xxs / 2,
                  children: [
                    Text(title, style: context.t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text(body, style: context.t.bodyMedium?.copyWith(color: q.ink2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
