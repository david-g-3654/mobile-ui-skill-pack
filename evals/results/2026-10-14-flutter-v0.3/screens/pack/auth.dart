// Auth entry for "Margin", a reading app that keeps book highlights in sync.
// Archetype: Auth. Job: get the reader in with the fewest taps.
// Focal: the headline + the platform's own provider (Apple on iOS, Google elsewhere).
// Primary: that provider, pinned above the home indicator. Cut: password fields, "Forgot?",
// a separate sign-up flow (email branches after the address is known), extra providers.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class AuthEvalApp extends StatelessWidget {
  const AuthEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margin',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SignInScreen(),
    );
  }
}

enum _Provider { apple, google, email }

// ── Entry ───────────────────────────────────────────────────────────

class _SignInScreen extends StatefulWidget {
  const _SignInScreen();

  @override
  State<_SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<_SignInScreen> {
  _Provider? _pending;

  Future<void> _continueWith(_Provider provider) async {
    if (_pending != null) return;
    if (provider == _Provider.email) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _EmailStep()));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _pending = provider);
    // Stand-in for the provider's native sheet.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final large = isLargeText(context);

    // The most likely method leads and is the only filled button.
    final primary = ios ? _Provider.apple : _Provider.google;
    final others = [ios ? _Provider.google : _Provider.apple, _Provider.email];

    Widget button(_Provider p) => _ProviderButton(
          provider: p,
          filled: p == primary,
          loading: _pending == p,
          onPressed: _pending == null || _pending == p ? () => _continueWith(p) : null,
        );

    final secondaryButtons = [for (final p in others) button(p)];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: BottomActionBar(
        // At accessibility sizes only the primary stays pinned; the rest move into the scroll.
        footer: const [_TermsLine()],
        children: [button(primary), if (!large) ...secondaryButtons],
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xl, Space.margin, Space.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - Space.xl * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppMark(),
                  const SizedBox(height: Space.xl),
                  Semantics(
                    header: true,
                    child: DisplayScale(
                      child: Text('Every highlight from every book, in one place', style: t.headlineLarge),
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    'Sign in to sync your shelf and notes across phone, tablet and e-reader.',
                    style: t.bodyLarge?.copyWith(color: q.ink2),
                  ),
                  if (large) ...[
                    const SizedBox(height: Space.xl),
                    Column(spacing: Space.xs, children: secondaryButtons),
                  ],
                  const LargeTextFooter(children: [_TermsLine()]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand moment: the app icon, 72pt, continuous corners.
class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: 72,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: q.accent,
            shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.l)),
          ),
          child: Icon(Icons.bookmark_rounded, size: 36, color: q.onPrimary),
        ),
      ),
    );
  }
}

/// Stadium provider button carrying the provider's own mark. Filled = primary (ink), else tonal.
class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.provider, required this.filled, required this.loading, required this.onPressed});

  final _Provider provider;
  final bool filled;
  final bool loading;
  final VoidCallback? onPressed;

  String get _label => switch (provider) {
        _Provider.apple => 'Continue with Apple',
        _Provider.google => 'Continue with Google',
        _Provider.email => 'Continue with email',
      };

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final fg = filled ? q.onPrimary : q.ink;
    final bg = filled ? q.primaryFill : q.surface2;

    final Widget mark = loading
        ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        : switch (provider) {
            _Provider.apple => Icon(Icons.apple, size: 22, color: fg),
            _Provider.google => const _GoogleMark(size: 20),
            _Provider.email => Icon(Icons.mail_outline_rounded, size: 20, color: fg),
          };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: loading ? '$_label, connecting' : _label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity, minHeight: Metrics.buttonHeight),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: loading ? bg : q.surface2,
            disabledForegroundColor: loading ? fg : q.ink3,
            shape: const StadiumBorder(),
            textStyle: context.t.titleMedium,
            padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.sm),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Space.sm,
            children: [
              SizedBox.square(dimension: 24, child: Center(child: mark)),
              Flexible(child: Text(_label, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google's four-colour "G", traced from the official sign-in branding geometry (48×48 artboard).
/// No packages or bundled assets are allowed in this harness, so it is reproduced unmodified as a path.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: CustomPaint(size: Size.square(size), painter: const _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  static const _red = Color(0xFFEA4335); // mobile-ui: content-color
  static const _blue = Color(0xFF4285F4); // mobile-ui: content-color
  static const _yellow = Color(0xFFFBBC05); // mobile-ui: content-color
  static const _green = Color(0xFF34A853); // mobile-ui: content-color

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48, size.height / 48);
    final paint = Paint()..isAntiAlias = true;

    final red = Path()
      ..moveTo(24, 9.5)
      ..relativeCubicTo(3.54, 0, 6.71, 1.22, 9.21, 3.6)
      ..relativeLineTo(6.85, -6.85)
      ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
      ..relativeLineTo(7.98, 6.19)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
      ..close();

    final blue = Path()
      ..moveTo(46.98, 24.55)
      ..relativeCubicTo(0, -1.57, -0.15, -3.09, -0.38, -4.55)
      ..lineTo(24, 20)
      ..lineTo(24, 29.02)
      ..lineTo(36.94, 29.02)
      ..relativeCubicTo(-0.58, 2.96, -2.26, 5.48, -4.78, 7.18)
      ..relativeLineTo(7.73, 6)
      ..relativeCubicTo(4.51, -4.18, 7.09, -10.36, 7.09, -17.65)
      ..close();

    final yellow = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.03, 27.14, 9.75, 25.6, 9.75, 24)
      ..cubicTo(9.75, 22.4, 10.02, 20.86, 10.53, 19.41)
      ..relativeLineTo(-7.98, -6.19)
      ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24)
      ..relativeCubicTo(0, 3.88, 0.92, 7.54, 2.56, 10.78)
      ..relativeLineTo(7.97, -6.19)
      ..close();

    final green = Path()
      ..moveTo(24, 48)
      ..relativeCubicTo(6.48, 0, 11.93, -2.13, 15.89, -5.81)
      ..relativeLineTo(-7.73, -6)
      ..relativeCubicTo(-2.15, 1.45, -4.92, 2.3, -8.16, 2.3)
      ..relativeCubicTo(-6.26, 0, -11.57, -4.22, -13.47, -9.91)
      ..relativeLineTo(-7.98, 6.19)
      ..cubicTo(6.51, 42.62, 14.62, 48, 24, 48)
      ..close();

    canvas
      ..drawPath(red, paint..color = _red)
      ..drawPath(blue, paint..color = _blue)
      ..drawPath(yellow, paint..color = _yellow)
      ..drawPath(green, paint..color = _green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Footnote with tappable Terms and Privacy Policy links.
class _TermsLine extends StatefulWidget {
  const _TermsLine();

  @override
  State<_TermsLine> createState() => _TermsLineState();
}

class _TermsLineState extends State<_TermsLine> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => showToast(context, 'Opening Terms of Service');
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => showToast(context, 'Opening Privacy Policy');

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final link = t.bodySmall?.copyWith(decoration: TextDecoration.underline, decorationColor: context.q.ink2);
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          style: t.bodySmall,
          children: [
            const TextSpan(text: 'By continuing you agree to the '),
            TextSpan(text: 'Terms', style: link, recognizer: _terms),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: link, recognizer: _privacy),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Email step: one field, branches to code or password once the address is known ─────────

class _EmailStep extends StatefulWidget {
  const _EmailStep();

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _controller = TextEditingController();
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) {
      setState(() => _error = email.isEmpty
          ? 'Enter the email you use for Margin.'
          : 'That address is missing something. Check for a typo after the @.');
      return;
    }
    setState(() {
      _error = null;
      _sending = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _sending = false);
    HapticFeedback.mediumImpact();
    showToast(context, 'We sent a 6-digit code to $email');
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      bottomNavigationBar: BottomActionBar(
        children: [PrimaryButton(label: 'Send sign-in code', loading: _sending, onPressed: _submit)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
        children: [
          Semantics(header: true, child: Text("What's your email?", style: t.titleLarge)),
          const SizedBox(height: Space.xs),
          Text(
            "New here? We'll set up your shelf. Already reading with us? We'll find it.",
            style: t.bodyMedium,
          ),
          const SizedBox(height: Space.xl),
          Text('Email', style: t.bodyMedium?.copyWith(color: q.ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: Space.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.go,
            autocorrect: false,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            style: t.bodyLarge,
            decoration: InputDecoration(hintText: 'priya.raman@fastmail.com', errorText: _error),
          ),
          const SizedBox(height: Space.sm),
          Text(
            "If you've set a password, we'll ask for it next instead.",
            style: t.bodySmall?.copyWith(color: q.ink2),
          ),
        ],
      ),
    );
  }
}
