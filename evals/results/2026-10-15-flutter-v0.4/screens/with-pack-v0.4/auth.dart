// Auth entry — Larder (weekly dinner planner).
// Job: get the cook signed in with the least typing.
// Focal: the brand line. Primary: the platform provider (Apple on iOS, Google elsewhere).
// Email is one field per step and branches sign-in / sign-up after the address is known.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class AuthEvalApp extends StatelessWidget {
  const AuthEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Larder',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SignInScreen(),
    );
  }
}

// ── Sample copy ─────────────────────────────────────────────────────

const _appName = 'Larder';
const _headline = 'Dinner, planned by Sunday night';
const _pitch = 'Pick five recipes, get one shopping list sorted by aisle, '
    'and skip the 6 pm “what’s for dinner” scramble.';

enum _Provider { apple, google }

// ── Entry screen ────────────────────────────────────────────────────

class _SignInScreen extends StatefulWidget {
  const _SignInScreen();

  @override
  State<_SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<_SignInScreen> {
  _Provider? _pending;

  Future<void> _continueWith(_Provider provider) async {
    HapticFeedback.mediumImpact();
    setState(() => _pending = provider);
    // Stand-in for the provider's native sheet.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _pending = null);
  }

  void _continueWithEmail() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _EmailStepScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final large = qIsLargeText(context);
    final busy = _pending != null;

    final apple = _ProviderButton(
      label: 'Continue with Apple',
      mark: const _AppleMark(),
      filled: ios,
      loading: _pending == _Provider.apple,
      onPressed: busy ? null : () => _continueWith(_Provider.apple),
    );
    final google = _ProviderButton(
      label: 'Continue with Google',
      mark: const _GoogleMark(),
      filled: !ios,
      loading: _pending == _Provider.google,
      onPressed: busy ? null : () => _continueWith(_Provider.google),
    );
    final email = _ProviderButton(
      label: 'Continue with email',
      mark: const _EmailMark(),
      filled: false,
      onPressed: busy ? null : _continueWithEmail,
    );

    final primary = ios ? apple : google;
    final secondary = [ios ? google : apple, email];
    const terms = _TermsNote();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xxxl, QSpace.margin, QSpace.xxl),
              sliver: SliverList.list(
                children: [
                  const _AppMark(),
                  const SizedBox(height: QSpace.xl),
                  QDisplayScale(
                    child: Semantics(
                      header: true,
                      child: Text(_headline, style: context.qText.headlineLarge),
                    ),
                  ),
                  const SizedBox(height: QSpace.sm),
                  Text(_pitch, style: context.qText.bodyLarge?.copyWith(color: context.q.ink2)),
                  // At accessibility sizes only the primary stays pinned; the rest scrolls.
                  if (large) ...[
                    const SizedBox(height: QSpace.xxl),
                    Column(spacing: QSpace.sm, children: secondary),
                  ],
                  const QLargeTextFooter(children: [terms]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: QBottomActionBar(
        footer: const [terms],
        children: [
          primary,
          if (!large) ...secondary,
        ],
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Semantics(
      label: _appName,
      image: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: q.surface,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(QRadii.l),
              side: BorderSide(color: q.hairline),
            ),
          ),
          child: SizedBox.square(
            dimension: 72,
            child: ExcludeSemantics(
              child: Icon(Icons.soup_kitchen_rounded, size: 36, color: q.accent),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsNote extends StatelessWidget {
  const _TermsNote();

  @override
  Widget build(BuildContext context) {
    final base = context.qText.bodySmall;
    final link = base?.copyWith(
      color: context.q.ink,
      decoration: TextDecoration.underline,
      decorationColor: context.q.ink2,
    );
    return Padding(
      padding: const EdgeInsets.only(top: QSpace.xxs),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'By continuing you agree to Larder’s '),
            TextSpan(text: 'Terms of Service', style: link),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: link),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Provider button ─────────────────────────────────────────────────

/// Stadium, 52 min height, mark + label. Filled = the one primary (ink); otherwise tonal surface2.
class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.mark,
    required this.filled,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final Widget mark;
  final bool filled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final bg = filled ? q.primaryFill : q.surface2;
    final fg = filled ? q.onPrimary : q.ink;
    final style = FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg,
      disabledForegroundColor: loading ? fg : fg.withValues(alpha: 0.5),
      shape: const StadiumBorder(),
      textStyle: context.qText.titleMedium,
      padding: const EdgeInsets.symmetric(horizontal: QSpace.xl, vertical: QSpace.sm),
      elevation: 0,
    );

    final content = loading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(fg)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: QSpace.sm,
            children: [
              ExcludeSemantics(child: IconTheme.merge(data: IconThemeData(color: fg, size: 20), child: mark)),
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: loading ? '$label, connecting' : label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity, minHeight: QMetrics.buttonHeight),
        child: FilledButton(onPressed: onPressed, style: style, child: content),
      ),
    );
  }
}

class _AppleMark extends StatelessWidget {
  const _AppleMark();

  @override
  Widget build(BuildContext context) => const Icon(Icons.apple);
}

class _EmailMark extends StatelessWidget {
  const _EmailMark();

  @override
  Widget build(BuildContext context) => const Icon(Icons.mail_outline_rounded);
}

/// Google's four-color "G", built to the published proportions (no asset files allowed here).
/// Swap for the official bundled asset or `sign_in_button` in production.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    final size = IconTheme.of(context).size ?? 20;
    return SizedBox.square(dimension: size, child: const CustomPaint(painter: _GoogleGPainter()));
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4); // mobile-ui: content-color
  static const _green = Color(0xFF34A853); // mobile-ui: content-color
  static const _yellow = Color(0xFFFBBC05); // mobile-ui: content-color
  static const _red = Color(0xFFEA4335); // mobile-ui: content-color

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final r = (s - stroke) / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);
    double rad(double deg) => deg * math.pi / 180;

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Angles clockwise from 3 o'clock; the opening sits at the upper right.
    canvas.drawArc(rect, rad(0), rad(42), false, arc(_blue));
    canvas.drawArc(rect, rad(42), rad(100), false, arc(_green));
    canvas.drawArc(rect, rad(142), rad(76), false, arc(_yellow));
    canvas.drawArc(rect, rad(218), rad(100), false, arc(_red));
    // Crossbar.
    canvas.drawRect(
      Rect.fromLTRB(c.dx - stroke * 0.1, c.dy - stroke / 2, c.dx + r + stroke / 2, c.dy + stroke / 2),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Email step (one field) ──────────────────────────────────────────

class _EmailStepScreen extends StatefulWidget {
  const _EmailStepScreen();

  @override
  State<_EmailStepScreen> createState() => _EmailStepScreenState();
}

class _EmailStepScreenState extends State<_EmailStepScreen> {
  final _controller = TextEditingController(text: 'maya.okafor@fastmail.com');
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!valid) {
      setState(() => _error = 'That doesn’t look like an email. Try something like name@example.com.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _error = null;
      _sending = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _sending = false);
    showQToast(context, 'Link sent to $value');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.qText;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xs, QSpace.margin, QSpace.xxl),
        children: [
          QDisplayScale(
            child: Semantics(header: true, child: Text('What’s your email?', style: t.headlineLarge)),
          ),
          const SizedBox(height: QSpace.sm),
          Text(
            'We’ll email you a sign-in link. New to Larder? The same link sets up your account.',
            style: t.bodyLarge?.copyWith(color: context.q.ink2),
          ),
          const SizedBox(height: QSpace.xxl),
          Text('Email', style: t.titleMedium),
          const SizedBox(height: QSpace.xs),
          AutofillGroup(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.go,
              autofillHints: const [AutofillHints.email, AutofillHints.username],
              autocorrect: false,
              enableSuggestions: false,
              style: t.bodyLarge,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'name@example.com',
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: QBottomActionBar(
        children: [
          QPrimaryButton(label: 'Email me a sign-in link', loading: _sending, onPressed: _submit),
        ],
      ),
    );
  }
}
