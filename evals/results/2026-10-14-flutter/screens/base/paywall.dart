import 'package:flutter/material.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  static const Color _seed = Color(0xFF5B4B8A);

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021(platform: TargetPlatform.iOS)
          .black
          .apply(
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inkwell Premium',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _PaywallScreen(),
    );
  }
}

enum _PlanId { yearly, monthly }

class _Plan {
  const _Plan({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.detail,
    this.badge,
  });

  final _PlanId id;
  final String title;
  final String price;
  final String period;
  final String detail;
  final String? badge;
}

class _Benefit {
  const _Benefit(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const List<_Plan> _plans = [
  _Plan(
    id: _PlanId.yearly,
    title: 'Yearly',
    price: r'$39.99',
    period: '/year',
    detail: r'7 days free, then $39.99/year ($3.33/mo)',
    badge: 'Save 44%',
  ),
  _Plan(
    id: _PlanId.monthly,
    title: 'Monthly',
    price: r'$5.99',
    period: '/month',
    detail: 'Billed monthly. Cancel anytime.',
  ),
];

const List<_Benefit> _benefits = [
  _Benefit(
    Icons.auto_awesome_outlined,
    'Guided prompts every day',
    '400+ reflections for gratitude, growth and hard days',
  ),
  _Benefit(
    Icons.insights_outlined,
    'Mood & habit insights',
    'See patterns across weeks, months and years',
  ),
  _Benefit(
    Icons.lock_outline,
    'Private, encrypted sync',
    'Face ID lock and end-to-end encrypted backup',
  ),
  _Benefit(
    Icons.photo_library_outlined,
    'Unlimited photos & voice notes',
    'Capture moments the way you remember them',
  ),
];

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  _PlanId _selected = _PlanId.yearly;

  _Plan get _selectedPlan => _plans.firstWhere((p) => p.id == _selected);

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isYearly = _selected == _PlanId.yearly;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => _showMessage('Paywall dismissed'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showMessage('Restoring purchases…'),
                    child: const Text('Restore'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const _Hero(),
                        const SizedBox(height: 20),
                        Text(
                          'Make journaling a habit that sticks',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inkwell Premium gives you everything you need to '
                          'write a little every day.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (final b in _benefits) _BenefitRow(benefit: b),
                        const SizedBox(height: 16),
                        Semantics(
                          header: true,
                          child: Text(
                            'Choose your plan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final plan in _plans) ...[
                          _PlanCard(
                            plan: plan,
                            selected: plan.id == _selected,
                            onTap: () => setState(() => _selected = plan.id),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        const _Testimonial(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _BottomBar(
              ctaLabel: isYearly ? 'Start 7-day free trial' : 'Subscribe monthly',
              terms: isYearly
                  ? r'Free for 7 days, then $39.99/year. We’ll remind you '
                      '2 days before your trial ends. Cancel anytime in Settings.'
                  : r'$5.99/month, renews automatically. Cancel anytime in '
                      'Settings.',
              onPressed: () =>
                  _showMessage('Continuing with ${_selectedPlan.title} plan'),
              onTerms: () => _showMessage('Opening Terms of Use'),
              onPrivacy: () => _showMessage('Opening Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primaryContainer, scheme.tertiaryContainer],
            ),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 44,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit});

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                benefit.icon,
                size: 22,
                color: scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    benefit.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    final bg = selected
        ? scheme.primaryContainer.withValues(alpha: 0.45)
        : scheme.surfaceContainerLow;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      checked: selected,
      button: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outline,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            plan.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (plan.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.tertiary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                plan.badge!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onTertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      plan.period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  const _Testimonial();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Rated 5 out of 5',
              child: ExcludeSemantics(
                child: Row(
                  children: List.generate(
                    5,
                    (_) => Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: scheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '“I’ve tried to journal for years. The daily prompts finally '
              'made it stick — 212 days and counting.”',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Priya S., Premium member since 2025',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.ctaLabel,
    required this.terms,
    required this.onPressed,
    required this.onTerms,
    required this.onPrivacy,
  });

  final String ctaLabel;
  final String terms;
  final VoidCallback onPressed;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: scheme.surfaceContainer,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, 8 + bottomInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: onPressed,
                  child: Text(ctaLabel, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                Text(
                  terms,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onTerms,
                      child: const Text('Terms of Use'),
                    ),
                    TextButton(
                      onPressed: onPrivacy,
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
