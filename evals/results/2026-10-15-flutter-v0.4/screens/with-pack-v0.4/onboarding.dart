// Onboarding — single welcome + value list for "Hushnote", an AI voice notes app.
// Job: get a new user to their first recording. Focal: the outcome headline.
// Primary: "Record my first note". Cut: carousel, permission prompts (asked in context on first record).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushnote',
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
  _ValueProp(
    Icons.mic_none_rounded,
    'Talk the way you think',
    'On a walk, in the car, at 2 a.m. Up to 3 hours per note.',
  ),
  _ValueProp(
    Icons.auto_awesome_outlined,
    'Get the gist in seconds',
    'Summaries, key points and to-dos pulled out for you.',
  ),
  _ValueProp(
    Icons.manage_search_rounded,
    'Find any word you said',
    'Search every recording, in 42 languages.',
  ),
];

// Relative bar heights for the decorative waveform mark (multiples of 4).
const _waveHeights = <double>[12, 20, 32, 24, 40, 28, 16, 36, 44, 24, 12, 28, 20, 8];

// ── Screen ──────────────────────────────────────────────────────────

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  void _start(BuildContext context) {
    HapticFeedback.mediumImpact();
    showQToast(context, 'Microphone access is asked when you tap record.');
  }

  void _logIn(BuildContext context) {
    showQToast(context, 'Log in is coming up next.');
  }

  List<Widget> _footer(BuildContext context) => [
        QTertiaryButton(label: 'I already have an account', onPressed: () => _logIn(context)),
        Text(
          'By continuing you agree to the Terms and Privacy Policy. '
          'Recordings stay on this phone until you turn on sync.',
          style: context.qText.bodySmall,
          textAlign: TextAlign.center,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final t = context.qText;
    final q = context.q;

    return Scaffold(
      backgroundColor: q.canvas,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xxxl, QSpace.margin, QSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WaveMark(),
              const SizedBox(height: QSpace.xxl),
              Semantics(
                header: true,
                child: QDisplayScale(
                  child: Text('Think out loud.\nKeep every word.', style: t.headlineLarge),
                ),
              ),
              const SizedBox(height: QSpace.sm),
              Text(
                'Hushnote turns rambling voice memos into clean, searchable notes.',
                style: t.bodyLarge?.copyWith(color: q.ink2),
              ),
              const SizedBox(height: QSpace.xxl),
              Column(
                spacing: QSpace.xl,
                children: [for (final p in _valueProps) _ValuePropRow(prop: p)],
              ),
              QLargeTextFooter(children: _footer(context)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: QBottomActionBar(
        footer: _footer(context),
        children: [
          QPrimaryButton(label: 'Record my first note', onPressed: () => _start(context)),
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
    final t = context.qText;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: QSpace.md,
        children: [
          ExcludeSemantics(child: Icon(prop.icon, size: 24, color: context.q.ink)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: QSpace.xxs,
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

/// The one accent on the screen: a static waveform mark that stands in for a brand illustration.
class _WaveMark extends StatelessWidget {
  const _WaveMark();

  @override
  Widget build(BuildContext context) {
    final accent = context.q.accent;
    return ExcludeSemantics(
      child: SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: QSpace.xxs,
          children: [
            for (final h in _waveHeights)
              Container(
                width: QSpace.xxs,
                height: h,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(QSpace.xxs)),
              ),
          ],
        ),
      ),
    );
  }
}
