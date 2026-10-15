// Onboarding — single welcome + value list for "Murmur", an AI voice notes app.
// Job: get a new user to record their first note. Focal: the outcome headline.
// Primary: "Record your first note". Cutting: carousel pages, permission prompts
// (microphone is asked in context on the record screen), feature grid.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Murmur',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _WelcomeScreen(),
    );
  }
}

// ── Sample content ──────────────────────────────────────────────────

class _ValueProp {
  const _ValueProp(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

const _valueProps = [
  _ValueProp(Icons.mic_none_rounded, 'Talk instead of type', 'Ideas on a walk, in the car, mid-meeting'),
  _ValueProp(Icons.auto_awesome_outlined, 'Get the gist in seconds', 'Summaries, action items and quotes, pulled out for you'),
  _ValueProp(Icons.search_rounded, 'Find any moment again', 'Search every word you’ve said, back to day one'),
];

// Relative bar heights for the decorative waveform (a real 3-second clip, normalised).
const _waveform = <double>[
  0.18, 0.32, 0.55, 0.40, 0.72, 0.95, 0.62, 0.38, 0.24, 0.46, 0.81, 0.58,
  0.30, 0.20, 0.44, 0.68, 0.88, 0.52, 0.34, 0.26, 0.50, 0.76, 0.42, 0.22,
  0.14, 0.36, 0.60, 0.48, 0.28, 0.16,
];

// ── Screen ──────────────────────────────────────────────────────────

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  void _recordFirstNote() => HapticFeedback.mediumImpact();

  void _logIn() {}

  List<Widget> _footer(BuildContext context) => [
        SecondaryButton(label: 'Log in', onPressed: _logIn),
        Text(
          'Recordings stay private to your account. By continuing you agree to the Terms and Privacy Policy.',
          style: context.t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Space.margin, Space.xxxl, Space.margin, Space.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExcludeSemantics(child: _Waveform(height: 56)),
              const SizedBox(height: Space.xxl),
              DisplayScale(
                child: Semantics(
                  header: true,
                  child: Text('Say it once.\nFind it forever.', style: t.headlineLarge),
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                'Murmur turns rambling voice memos into clean notes you can search, skim and share.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: Space.xxl),
              Column(
                spacing: Space.xl,
                children: [for (final p in _valueProps) _ValuePropRow(prop: p)],
              ),
              LargeTextFooter(children: _footer(context)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        footer: _footer(context),
        children: [
          PrimaryButton(label: 'Record your first note', onPressed: _recordFirstNote),
        ],
      ),
    );
  }
}

class _ValuePropRow extends StatelessWidget {
  const _ValuePropRow({required this.prop});

  final _ValueProp prop;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.md,
        children: [
          ExcludeSemantics(child: Icon(prop.icon, size: 24, color: context.q.ink)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.xxs,
              children: [
                Text(prop.title, style: t.titleMedium),
                Text(prop.subtitle, style: t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The one accent element on the screen: a short voice waveform, left-aligned with the headline.
class _Waveform extends StatelessWidget {
  const _Waveform({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _WaveformPainter(color: context.q.accent, levels: _waveform)),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color, required this.levels});

  final Color color;
  final List<double> levels;

  static const double _bar = 4;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final count = (size.width / (_bar + _gap)).floor().clamp(0, levels.length);
    final midY = size.height / 2;
    for (var i = 0; i < count; i++) {
      final h = (levels[i] * size.height).clamp(_bar, size.height);
      final rect = Rect.fromCenter(center: Offset(i * (_bar + _gap) + _bar / 2, midY), width: _bar, height: h);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(_bar / 2)), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.color != color || old.levels != levels;
}
