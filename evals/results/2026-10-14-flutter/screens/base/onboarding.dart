import 'package:flutter/material.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  static const Color _seed = Color(0xFF5B4BDB);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.12,
        ),
        bodyLarge: TextStyle(height: 1.45),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Murmur',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _OnboardingScreen(),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const List<_Feature> _features = [
  _Feature(
    Icons.graphic_eq_rounded,
    'Talk, don’t type',
    'Record a thought in one tap, even with your screen locked.',
  ),
  _Feature(
    Icons.auto_awesome_rounded,
    'Summaries in seconds',
    'Get key points and to-dos pulled from every recording.',
  ),
  _Feature(
    Icons.search_rounded,
    'Find anything you said',
    'Search across months of notes by word, topic or person.',
  ),
];

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  _BrandMark(color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Murmur',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _NotePreviewCard(),
                        const SizedBox(height: 32),
                        Text(
                          'Say it once.\nKeep it forever.',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Murmur turns your rambling voice memos into clean '
                          'notes, summaries and action items — automatically.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        for (final f in _features) ...[
                          _FeatureRow(feature: f),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _BottomBar(scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.mic_rounded,
        size: 18,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

class _NotePreviewCard extends StatelessWidget {
  const _NotePreviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label: 'Example note: Q3 planning sync, 2 minutes 14 seconds, '
          'with an AI summary and two action items',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      color: scheme.onPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q3 planning sync',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Today, 9:41 AM · 2:14',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: CustomPaint(
                painter: _WaveformPainter(
                  played: scheme.primary,
                  pending: scheme.outlineVariant,
                  progress: 0.38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: scheme.onPrimaryContainer),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'AI summary',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Launch moves to Sept 18. Priya owns the pricing page; '
                    'design review on Thursday.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TaskChip(label: 'Draft pricing copy'),
                _TaskChip(label: 'Book design review'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 16, color: scheme.tertiary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: theme.textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.played,
    required this.pending,
    required this.progress,
  });

  final Color played;
  final Color pending;
  final double progress;

  static const List<double> _levels = [
    0.30, 0.55, 0.42, 0.80, 0.62, 0.95, 0.70, 0.45, 0.58, 0.85, //
    0.50, 0.35, 0.66, 0.90, 0.74, 0.40, 0.28, 0.52, 0.78, 0.60, //
    0.44, 0.70, 0.92, 0.65, 0.38, 0.55, 0.82, 0.48, 0.33, 0.60, //
    0.75, 0.50, 0.30, 0.46, 0.68, 0.40, 0.25, 0.36, 0.22, 0.18,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final n = _levels.length;
    final slot = size.width / n;
    final barWidth = slot * 0.55;
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < n; i++) {
      final h = (size.height * _levels[i]).clamp(4.0, size.height);
      final x = i * slot + slot / 2;
      paint
        ..color = (i / n) < progress ? played : pending
        ..strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2 + barWidth / 2),
        Offset(x, size.height / 2 + h / 2 - barWidth / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.played != played ||
      old.pending != pending ||
      old.progress != progress;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(feature.icon,
              size: 20, color: scheme.onSecondaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                feature.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Record your first note'),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Sign in')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
