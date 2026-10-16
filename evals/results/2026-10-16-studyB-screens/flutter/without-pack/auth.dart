import 'package:flutter/material.dart';

class AuthEvalApp extends StatelessWidget {
  const AuthEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF52664A),
      brightness: brightness,
      surface: isDark ? const Color(0xFF171C18) : const Color(0xFFF8F7F2),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: 0.15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _SignInScreen(),
    );
  }
}

class _SignInScreen extends StatefulWidget {
  const _SignInScreen();

  @override
  State<_SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<_SignInScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _providerSignIn(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in isn’t connected in this preview.')),
    );
  }

  void _continueWithEmail() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _emailSent = true);
    }
  }

  void _showPolicy(String title) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                'This is a preview of Still, a little space for a calmer day. '
                'No account is created and no personal information is sent. '
                'Connected sign-in and complete policies will be available in the full app.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final muted = colors.onSurface.withValues(alpha: 0.62);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28, bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.spa_outlined, color: colors.primary, size: 27),
                            const SizedBox(width: 8),
                            Text('still', style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                            )),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Center(child: _QuietIllustration()),
                        const SizedBox(height: 26),
                        Text(
                          'A little space\nfor yourself.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1.3,
                            height: 1.13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in to find your everyday calm.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: muted, height: 1.5),
                        ),
                        const SizedBox(height: 30),
                        _ProviderButton(
                          label: 'Continue with Apple',
                          icon: const Icon(Icons.apple, size: 25),
                          onPressed: () => _providerSignIn('Apple'),
                        ),
                        const SizedBox(height: 12),
                        _ProviderButton(
                          label: 'Continue with Google',
                          icon: const _GoogleMark(),
                          onPressed: () => _providerSignIn('Google'),
                        ),
                        const SizedBox(height: 23),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or use email', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                          ),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 21),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Email address', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.go,
                                autofillHints: const [AutofillHints.email],
                                autocorrect: false,
                                onFieldSubmitted: (_) => _continueWithEmail(),
                                onChanged: (_) {
                                  if (_emailSent) setState(() => _emailSent = false);
                                },
                                validator: (value) {
                                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'you@example.com',
                                  hintStyle: TextStyle(color: muted),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF202620) : const Color(0xFFFEFEFB),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.35)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _continueWithEmail,
                                style: FilledButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFFB9CBA9) : const Color(0xFF41553B),
                                  foregroundColor: isDark ? const Color(0xFF203019) : Colors.white,
                                  minimumSize: const Size.fromHeight(56),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(child: Text('Continue with email', textAlign: TextAlign.center,
                                      style: theme.textTheme.labelLarge?.copyWith(color: isDark ? const Color(0xFF203019) : Colors.white))),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_rounded, size: 19),
                                  ],
                                ),
                              ),
                              if (_emailSent) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'You’re all set for the preview. In the full app, we’ll email you a secure sign-in link.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colors.primary, height: 1.5),
                                  textAlign: TextAlign.center,
                                  semanticsLabel: 'Email validated. This preview does not send email.',
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('New here? Your account is created automatically.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.5)),
                        const SizedBox(height: 26),
                        Text('By continuing, you agree to our',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(onPressed: () => _showPolicy('Terms of Service'), child: const Text('Terms of Service')),
                            Text('and', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                            TextButton(onPressed: () => _showPolicy('Privacy Policy'), child: const Text('Privacy Policy')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(child: icon),
          const SizedBox(width: 12),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CustomPaint(painter: _GooglePainter()),
  );
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4;
    const segments = [
      (Color(0xFF4285F4), -0.15, 0.95),
      (Color(0xFF34A853), 0.8, 1.5),
      (Color(0xFFFBBC05), 2.3, 1.1),
      (Color(0xFFEA4335), 3.4, 2.1),
    ];
    for (final segment in segments) {
      paint.color = segment.$1;
      canvas.drawArc(bounds, segment.$2, segment.$3, false, paint);
    }
    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(Offset(size.width / 2, size.height / 2), Offset(size.width - 1, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}

class _QuietIllustration extends StatelessWidget {
  const _QuietIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox(
        width: 180,
        height: 132,
        child: CustomPaint(painter: _LandscapePainter(isDark)),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final arch = Path()
      ..moveTo(16, 132)
      ..lineTo(16, 76)
      ..cubicTo(16, -22, 164, -22, 164, 76)
      ..lineTo(164, 132)
      ..close();
    canvas.save();
    canvas.clipPath(arch);
    canvas.drawRect(Offset.zero & size, Paint()..color = isDark ? const Color(0xFF303D32) : const Color(0xFFE7E8D9));
    canvas.drawCircle(const Offset(115, 43), 17, Paint()..color = isDark ? const Color(0xFFC9B383) : const Color(0xFFE5BD7E));
    final backHill = Path()
      ..moveTo(0, 104)
      ..cubicTo(45, 48, 86, 61, 180, 111)
      ..lineTo(180, 140)..lineTo(0, 140)..close();
    canvas.drawPath(backHill, Paint()..color = isDark ? const Color(0xFF5D7359) : const Color(0xFFA5B393));
    final frontHill = Path()
      ..moveTo(0, 129)
      ..cubicTo(64, 144, 105, 67, 180, 88)
      ..lineTo(180, 140)..lineTo(0, 140)..close();
    canvas.drawPath(frontHill, Paint()..color = isDark ? const Color(0xFF8DA17E) : const Color(0xFF718667));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LandscapePainter oldDelegate) => isDark != oldDelegate.isDark;
}
