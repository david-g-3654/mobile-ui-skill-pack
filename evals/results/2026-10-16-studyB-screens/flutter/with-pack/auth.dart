import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class AuthEvalApp extends StatelessWidget {
  const AuthEvalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const _AuthScreen(),
  );
}

class _AuthScreen extends StatelessWidget {
  const _AuthScreen();

  void _provider(BuildContext context, String provider) {
    showQToast(context, '$provider sign-in is not connected in this preview.');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.q;
    final alternatives = <Widget>[
      _ProviderButton(
        label: 'Continue with Google',
        mark: Image.memory(_googleMark, width: QSpace.xl, height: QSpace.xl),
        onPressed: () => _provider(context, 'Google'),
      ),
      _ProviderButton(
        label: 'Continue with email',
        mark: Icon(Icons.mail_outline_rounded, color: colors.ink),
        onPressed: () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => const _EmailScreen())),
      ),
      const SizedBox(height: QSpace.xs),
      const _LegalFooter(),
    ];

    return Scaffold(
      bottomNavigationBar: QBottomActionBar(
        footer: alternatives,
        children: [
          _ProviderButton(
            label: 'Continue with Apple',
            primary: true,
            mark: Icon(Icons.apple, color: colors.onPrimary),
            onPressed: () => _provider(context, 'Apple'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    QSpace.margin,
                    QSpace.xl,
                    QSpace.margin,
                    QSpace.xxl,
                  ),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: QSpace.sm,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                Icons.spa_outlined,
                                size: QSpace.xxl,
                                color: colors.accent,
                              ),
                            ),
                            Text('Still', style: context.qText.titleLarge),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: QSpace.xxxl),
                        Semantics(
                          header: true,
                          child: QDisplayScale(
                            child: Text(
                              'Make room\nfor you.',
                              style: context.qText.displayLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: QSpace.xl),
                        Text(
                          'A quiet place for your thoughts,\nplans and little wins.',
                          style: context.qText.bodyLarge?.copyWith(
                            color: colors.ink2,
                          ),
                        ),
                        const SizedBox(height: QSpace.xxxl),
                        const Spacer(),
                        Text(
                          'Sign in or create your account',
                          style: context.qText.bodySmall?.copyWith(
                            color: colors.ink2,
                          ),
                        ),
                        QLargeTextFooter(children: alternatives),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.mark,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final Widget mark;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.q;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 568),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, QMetrics.buttonHeight),
              backgroundColor: primary ? colors.primaryFill : colors.surface,
              foregroundColor: primary ? colors.onPrimary : colors.ink,
              side: BorderSide(
                color: primary ? colors.primaryFill : colors.hairline,
              ),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: QSpace.xl,
                vertical: QSpace.md,
              ),
              textStyle: context.qText.titleMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: QSpace.sm,
              children: [
                ExcludeSemantics(child: mark),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  void _showLegal(BuildContext context, String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(QSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: QSpace.md,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: context.qText.titleLarge),
              ),
              Text(message, style: context.qText.bodyLarge),
              QTertiaryButton(
                label: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'By continuing, you agree to our',
        textAlign: TextAlign.center,
        style: context.qText.bodySmall?.copyWith(color: context.q.ink2),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: QSpace.xs,
        children: [
          _link(
            context,
            'Terms of Service',
            'This is a sign-in preview. No account is created and no subscription is started.',
          ),
          _link(
            context,
            'Privacy Policy',
            'This preview keeps entered information on this screen only. It does not send your email to a server.',
          ),
        ],
      ),
    ],
  );

  Widget _link(BuildContext context, String title, String message) =>
      TextButton(
        onPressed: () => _showLegal(context, title, message),
        style: TextButton.styleFrom(
          foregroundColor: context.q.ink2,
          minimumSize: const Size(QMetrics.minTap, QMetrics.minTap),
          textStyle: context.qText.bodySmall?.copyWith(
            decoration: TextDecoration.underline,
          ),
          padding: const EdgeInsets.symmetric(horizontal: QSpace.xxs),
        ),
        child: Text(title),
      );
}

class _EmailScreen extends StatefulWidget {
  const _EmailScreen();

  @override
  State<_EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<_EmailScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continue() {
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
        .hasMatch(_email.text.trim());
    setState(() {
      _error = valid ? null : 'Enter a valid email, like alex@hey.com.';
      _submitted = valid;
    });
    if (valid) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(title: const Text('Continue with email')),
    bottomNavigationBar: QBottomActionBar(
      children: [
        QPrimaryButton(
          label: _submitted ? 'Edit email address' : 'Continue with email',
          onPressed: _submitted
              ? () => setState(() => _submitted = false)
              : _continue,
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(QSpace.margin),
      children: [
        const SizedBox(height: QSpace.xxl),
        Semantics(
          header: true,
          child: QDisplayScale(
            child: Text(
              'Your space awaits.',
              style: context.qText.headlineLarge,
            ),
          ),
        ),
        const SizedBox(height: QSpace.md),
        Text(
          'Use your email to find your account or start a new one.',
          style: context.qText.bodyLarge?.copyWith(color: context.q.ink2),
        ),
        const SizedBox(height: QSpace.xxl),
        Text('Email address', style: context.qText.titleMedium),
        const SizedBox(height: QSpace.xs),
        AutofillGroup(
          child: TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.go,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            enableSuggestions: false,
            readOnly: _submitted,
            onSubmitted: (_) => _continue(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: 'alex@hey.com',
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
        ),
        if (_submitted) ...[
          const SizedBox(height: QSpace.xl),
          Semantics(
            liveRegion: true,
            child: Text(
              'Your email is ready. This preview is not connected to an authentication service, so no sign-in link has been sent.',
              style: context.qText.bodyLarge,
            ),
          ),
        ],
      ],
    ),
  );
}

final _googleMark = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAABnUlEQVR4nO3Yu23DQBAEUCXuyGrALsE1qRcV4YoUK1Mg4wICNE0d77O7M3eeATa9nX0JAZ5OoNw+z8+aQfUMSy3IvwCzRpkGKwpmOCwkDDUSGoQWCg1ADYU+mhoJfSw1EvpIaiT0ccIRjnDoZgocr/3D4kR0srToLhNdejqcyJ5euw4Xs+HsdfXe9WchMwwsj+834bxKwllGODtZA7Ugofu7ZovTAoW+wTU5oBIkdH/3HAHlkNDd3VOCk0NC93dPDdAWCt09JC1ACxK6e0hagdJYd/m43J8MQ4kjIAEJSEACElAdkoAEJCABoXAEJKB+IDYkNIwp0Pv1i/p3BxQo4QgoA7Me0P2HMQNKacVhBTLFSWnFYUUKBTrCYUQyB0pphWEDMv3Er9ODw4LkhrOkBweN1ItTBNSLg0IKwVlihRQFZYEDA/JGSu+H4qwXM0Nt354CyAIq924YTgRSCVjLW6FAkUjWE4IzO5IJzqxIpjijI+1BuQDNguSGMwOSO86oSGEwIyJBcEaBQtv8ChqDFmYbwRRGMBURSmVGwfgB5LRR88gVcvQAAAAASUVORK5CYII=',
);
