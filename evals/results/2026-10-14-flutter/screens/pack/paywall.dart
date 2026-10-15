// Paywall for "Margin", a journaling app.
// Paywall. Job: pick a plan and start the trial. Focal: the headline + the pre-selected yearly card.
// Primary: "Start 7-day free trial" (pinned). Cutting: feature comparison table, testimonials.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margin',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _PaywallScreen(),
    );
  }
}

enum _Plan { monthly, yearly }

// Sample pricing — one format for every amount on the screen.
const _monthlyPrice = r'$5.99';
const _yearlyPrice = r'$39.99';
const _yearlyPerMonth = r'$3.33/mo';
const _trialDays = 7;

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  _Plan _plan = _Plan.yearly;
  bool _purchasing = false;

  static const _benefits = [
    'Unlimited entries, photos and voice notes',
    'Prompts that adapt to how your week is going',
    'A monthly look-back at your moods and themes',
    'Entries locked behind Face ID or a passcode',
  ];

  bool get _hasTrial => _plan == _Plan.yearly;

  String get _ctaLabel =>
      _hasTrial ? 'Start $_trialDays-day free trial' : 'Subscribe for $_monthlyPrice/month';

  String get _terms => _hasTrial
      ? '$_trialDays days free, then $_yearlyPrice/year. Renews automatically. Cancel anytime in Settings.'
      : '$_monthlyPrice/month. Renews automatically. Cancel anytime in Settings.';

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    HapticFeedback.heavyImpact();
    if (mounted) setState(() => _purchasing = false);
  }

  List<Widget> _legal(BuildContext context) => [
        Text(_terms, style: context.t.bodySmall, textAlign: TextAlign.center),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.md,
          children: [
            TertiaryButton(label: 'Terms of use', onPressed: () {}),
            TertiaryButton(label: 'Privacy policy', onPressed: () {}),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final stacked = isLargeText(context);

    final monthly = PlanCard(
      name: 'Monthly',
      price: _monthlyPrice,
      period: '/mo',
      detail: 'No trial, billed monthly',
      selected: _plan == _Plan.monthly,
      onTap: () => setState(() => _plan = _Plan.monthly),
    );
    final yearly = PlanCard(
      name: 'Yearly',
      price: _yearlyPrice,
      period: '/yr',
      detail: '$_yearlyPerMonth · $_trialDays days free',
      badge: 'Save 44%',
      selected: _plan == _Plan.yearly,
      onTap: () => setState(() => _plan = _Plan.yearly),
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
          TertiaryButton(label: 'Restore', onPressed: () {}),
          const SizedBox(width: Space.xs),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.margin, Space.md, Space.margin, Space.xxl),
        children: [
          Text('MARGIN PRO', style: context.t.labelSmall),
          const SizedBox(height: Space.xs),
          Semantics(
            header: true,
            child: Text('Make room for\nwhat you think.', style: context.t.headlineLarge),
          ),
          const SizedBox(height: Space.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.sm,
            children: [
              for (final b in _benefits)
                MergeSemantics(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.sm,
                    children: [
                      Icon(Icons.check_rounded, size: 20, color: q.ink2),
                      Expanded(child: Text(b, style: context.t.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          if (stacked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.sm,
              children: [yearly, monthly],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.sm,
                children: [Expanded(child: monthly), Expanded(child: yearly)],
              ),
            ),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
            switchInCurve: Motion.curve,
            child: _hasTrial
                ? const Padding(
                    key: ValueKey('timeline'),
                    padding: EdgeInsets.only(top: Space.xxl),
                    child: _TrialTimeline(),
                  )
                : const SizedBox(key: ValueKey('none'), width: double.infinity),
          ),
          LargeTextFooter(children: _legal(context)),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        footer: _legal(context),
        children: [PrimaryButton(label: _ctaLabel, loading: _purchasing, onPressed: _purchase)],
      ),
    );
  }
}

/// Today → Day 5 → Day 7: what happens during the trial, in plain words.
class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline();

  static const _steps = [
    ('Today', 'Every Pro feature unlocks. Your existing entries stay as they are.'),
    ('Day 5', 'We send a reminder that your trial is ending.'),
    ('Day $_trialDays', 'You’re charged $_yearlyPrice for the year, unless you cancel before.'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOW YOUR TRIAL WORKS', style: context.t.labelSmall),
        const SizedBox(height: Space.md),
        for (var i = 0; i < _steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.md,
              children: [
                ExcludeSemantics(
                  child: SizedBox(
                    width: Space.sm,
                    child: Column(
                      children: [
                        const SizedBox(height: Space.xxs),
                        Container(
                          width: Space.sm,
                          height: Space.sm,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0 ? q.ink : q.surface,
                            border: Border.all(color: i == 0 ? q.ink : q.ink3, width: 2),
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Expanded(child: Container(width: 2, color: q.hairline)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: MergeSemantics(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? Space.lg : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Space.xxs,
                        children: [
                          Text(_steps[i].$1, style: context.t.titleMedium),
                          Text(_steps[i].$2, style: context.t.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
