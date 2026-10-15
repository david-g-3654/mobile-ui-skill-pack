// Auth — sign-in entry for "Fernway", a hiking journal that syncs routes, photos and trail notes.
// Job: get the user in with minimum typing. Focal: the brand line. Primary: the platform provider
// (Apple on iOS, Google elsewhere). Cut: password field, "Forgot password?", separate sign-up flow —
// email is a one-field step (magic code) that branches to sign-up or sign-in after the address is known.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

class AuthEvalApp extends StatelessWidget {
  const AuthEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fernway',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SignInScreen(),
    );
  }
}

// ── Sample content ──────────────────────────────────────────────────

const _appName = 'Fernway';
const _headline = 'Every trail you’ve walked, kept in one place';
const _subhead = 'Sign in to sync routes, photos and trail notes across your phone and watch. '
    'New here? The same buttons create your account.';
const _legal = 'By continuing, you agree to Fernway’s Terms of Service and Privacy Policy.';

enum _Provider { apple, google }

// ── Entry screen ────────────────────────────────────────────────────

class _SignInScreen extends StatelessWidget {
  const _SignInScreen();

  void _signIn(BuildContext context, _Provider provider) {
    HapticFeedback.mediumImpact();
    // TODO: wire `sign_in_with_apple` / `google_sign_in` and swap in the official branded buttons.
    final name = provider == _Provider.apple ? 'Apple' : 'Google';
    showToast(context, 'Opening $name sign-in…');
  }

  void _openEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _EmailStep()));
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    final platform = Theme.of(context).platform;
    final applePlatform = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    // The platform's own provider is the primary; the other is secondary; email is always last.
    // TODO: replace with the official Apple / Google button assets (keep 52 height) — never draw the logos.
    final primary = applePlatform ? _Provider.apple : _Provider.google;
    final secondary = applePlatform ? _Provider.google : _Provider.apple;
    String label(_Provider p) => p == _Provider.apple ? 'Continue with Apple' : 'Continue with Google';

    final legal = <Widget>[
      Text(_legal, style: t.bodySmall?.copyWith(color: q.ink2)),
      Wrap(
        spacing: Space.xs,
        children: [
          TertiaryButton(label: 'Read the terms', onPressed: () {}),
          TertiaryButton(label: 'Privacy policy', onPressed: () {}),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.margin, Space.xxxl, Space.margin, Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AppMark(),
                    const SizedBox(height: Space.xxl),
                    Semantics(
                      header: true,
                      child: Text(_headline, style: t.headlineLarge?.copyWith(color: q.ink)),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(_subhead, style: t.bodyLarge?.copyWith(color: q.ink2)),
                    const Spacer(),
                    const SizedBox(height: Space.xxl),
                    Column(
                      spacing: Space.sm,
                      children: [
                        PrimaryButton(label: label(primary), onPressed: () => _signIn(context, primary)),
                        SecondaryButton(label: label(secondary), onPressed: () => _signIn(context, secondary)),
                        SecondaryButton(label: 'Continue with email', onPressed: () => _openEmail(context)),
                      ],
                    ),
                    const SizedBox(height: Space.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Space.xxs,
                      children: legal,
                    ),
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

/// Brand moment: the app icon, built from tokens. The accent's one use on this screen.
class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ExcludeSemantics(
      child: Container(
        width: 72,
        height: 72,
        decoration: ShapeDecoration(
          color: q.accentSoft,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.l)),
        ),
        child: Icon(Icons.landscape_rounded, size: 40, color: q.accent),
      ),
    );
  }
}

// ── Email step (one field) ──────────────────────────────────────────

class _EmailStep extends StatefulWidget {
  const _EmailStep();

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  bool get _valid => _emailPattern.hasMatch(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid) {
      setState(() => _error = 'That doesn’t look like an email address. Check for a missing @ or dot.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _error = null;
      _sending = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _sending = false);
    showToast(context, 'Code sent to ${_controller.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: 'Email me a code',
            loading: _sending,
            onPressed: _controller.text.trim().isEmpty ? null : _submit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.margin, Space.xs, Space.margin, Space.xxl),
        children: [
          Semantics(
            header: true,
            child: Text('What’s your email?', style: t.headlineLarge?.copyWith(color: q.ink)),
          ),
          const SizedBox(height: Space.sm),
          Text(
            'We’ll send a 6-digit code — no password to remember. '
            'If you’re new to $_appName, we’ll set up your account.',
            style: t.bodyLarge?.copyWith(color: q.ink2),
          ),
          const SizedBox(height: Space.xl),
          Text('Email', style: t.titleMedium?.copyWith(color: q.ink)),
          const SizedBox(height: Space.xs),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.go,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            autocorrect: false,
            enableSuggestions: false,
            style: t.bodyLarge?.copyWith(color: q.ink),
            decoration: InputDecoration(
              hintText: 'maya.okafor@gmail.com',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
