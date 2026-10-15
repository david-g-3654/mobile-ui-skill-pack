// Onboarding — single welcome + value list for "Murmur", an AI voice notes app.
// Job: get a new user to their first recording. Focal: the outcome headline.
// Primary: "Record your first note". Cut: carousel, permission prompts (asked in context later).

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
  _ValueProp(
    Icons.mic_none_rounded,
    'Record with one tap',
    'Keeps going offline and with your screen locked',
  ),
  _ValueProp(
    Icons.auto_awesome_rounded,
    'Summaries write themselves',
    'Key points and to-dos after every recording',
  ),
  _ValueProp(
    Icons.manage_search_rounded,
    'Search what you said',
    'Find any phrase across months of rambling',
  ),
];

/// Bar heights for the decorative waveform (a frozen 0:42 memo).
const _waveform = <double>[
  8, 16, 28, 20, 40, 56, 32, 24, 44, 64, 48, 28, 16, 36, 52, 40, //
  20, 12, 24, 44, 60, 36, 20, 28, 48, 32, 16, 8, 20, 12, 8,
];

// ── Screen ──────────────────────────────────────────────────────────

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  void _start() => HapticFeedback.mediumImpact();

  void _logIn() {}

  @override
  Widget build(BuildContext context) {
    final legal = Text(
      'By continuing you agree to our Terms and Privacy Policy. '
      'Recordings stay on your device until you choose to sync.',
      style: context.t.bodySmall,
      textAlign: TextAlign.center,
    );

    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        footer: [legal],
        children: [
          PrimaryButton(label: 'Record your first note', onPressed: _start),
          TertiaryButton(label: 'I already have an account', onPressed: _logIn),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Space.margin, Space.xxxl, Space.margin, Space.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Waveform(),
              const SizedBox(height: Space.xxl),
              Semantics(
                header: true,
                child: Text('Think out loud.\nWe’ll take the notes.', style: context.t.headlineLarge),
              ),
              const SizedBox(height: Space.sm),
              Text(
                'Murmur turns voice memos into clean, searchable text in seconds.',
                style: context.t.bodyLarge?.copyWith(color: context.q.ink2),
              ),
              const SizedBox(height: Space.xxl),
              Column(
                spacing: Space.xl,
                children: [for (final p in _valueProps) _ValuePropRow(prop: p)],
              ),
              LargeTextFooter(children: [legal]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pieces ──────────────────────────────────────────────────────────

/// Personality moment: a static accent waveform. Decorative, so hidden from screen readers.
class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ExcludeSemantics(
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: Space.xxs,
          children: [
            for (final h in _waveform)
              Container(
                width: Space.xxs,
                height: h,
                decoration: BoxDecoration(color: q.accent, borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ValuePropRow extends StatelessWidget {
  const _ValuePropRow({required this.prop});

  final _ValueProp prop;

  @override
  Widget build(BuildContext context) {
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
                Text(prop.title, style: context.t.titleMedium),
                Text(prop.subtitle, style: context.t.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
