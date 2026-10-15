import 'package:flutter/material.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  static const Color _seed = Color(0xFF5B4BDB);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
      home: const _WelcomeScreen(),
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
    'Talk, don\'t type',
    'Record a thought in one tap — even from the lock screen.',
  ),
  _Feature(
    Icons.auto_awesome_rounded,
    'Instant summaries',
    'Get clean transcripts, key points and to-dos in seconds.',
  ),
  _Feature(
    Icons.lock_outline_rounded,
    'Private by default',
    'Notes are encrypted and stay yours. Delete anytime.',
  ),
];

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandRow(),
                        const SizedBox(height: 24),
                        const _NotePreviewCard(),
                        const SizedBox(height: 32),
                        Semantics(
                          header: true,
                          child: Text(
                            'Your thoughts,\nbeautifully organized.',
                            style: text.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.5,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Speak freely. Murmur turns your voice notes into searchable '
                          'transcripts, summaries and action items.',
                          style: text.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
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
            const _BottomActions(),
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(Icons.mic_rounded, color: scheme.onPrimary, size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Murmur',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _NotePreviewCard extends StatelessWidget {
  const _NotePreviewCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Semantics(
      label: 'Example voice note: Product sync recap, 2 minutes 14 seconds, '
          'with an AI summary and two action items.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outlineVariant.withAlpha(140)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: scheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product sync recap',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Today, 9:41 AM · 2:14',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
                  unplayed: scheme.outlineVariant,
                  progress: 0.38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withAlpha(160),
                borderRadius: BorderRadius.circular(16),
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
                          style: text.labelLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Launch moved to Nov 4. Maya owns the onboarding copy; '
                    'beta feedback review on Thursday.',
                    style: text.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TaskChip(label: 'Send deck to Maya'),
                _TaskChip(label: 'Book Thursday review'),
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
    final scheme = Theme.of(context).colorScheme;
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
          Icon(Icons.check_circle_outline_rounded, size: 16, color: scheme.tertiary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.played,
    required this.unplayed,
    required this.progress,
  });

  final Color played;
  final Color unplayed;
  final double progress;

  static const List<double> _levels = [
    0.25, 0.4, 0.7, 0.5, 0.9, 0.6, 0.35, 0.55, 0.8, 1.0, 0.65, 0.4, 0.3, 0.5,
    0.75, 0.45, 0.6, 0.85, 0.5, 0.3, 0.2, 0.45, 0.7, 0.95, 0.6, 0.4, 0.55,
    0.35, 0.6, 0.8, 0.5, 0.3, 0.45, 0.25, 0.4, 0.6, 0.35, 0.2,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.5;
    final count = (size.width / (barWidth * 2)).floor().clamp(1, 200);
    final gap = (size.width - count * barWidth) / (count - 1 == 0 ? 1 : count - 1);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final level = _levels[i % _levels.length];
      final h = (size.height * level).clamp(barWidth, size.height);
      final x = i * (barWidth + gap);
      paint.color = (i / count) < progress ? played : unplayed;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (size.height - h) / 2, barWidth, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.played != played ||
      oldDelegate.unplayed != unplayed ||
      oldDelegate.progress != progress;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
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
            child: Icon(feature.icon, size: 22, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.body,
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant.withAlpha(100))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
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
              TextButton(
                onPressed: () {},
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 4),
              Text(
                'By continuing you agree to our Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
