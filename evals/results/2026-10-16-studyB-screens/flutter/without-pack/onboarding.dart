import 'package:flutter/material.dart';

class OnboardingEvalApp extends StatelessWidget {
  const OnboardingEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF566844),
      brightness: brightness,
      surface: dark ? const Color(0xFF181C17) : const Color(0xFFF7F7F0),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'sans-serif',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark
              ? const Color(0xFFD6E9B8)
              : const Color(0xFF293E2D),
          foregroundColor: dark
              ? const Color(0xFF203222)
              : const Color(0xFFF8F9F0),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const _WelcomeScreen(),
      );
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? const Color(0xFFADB6A7) : const Color(0xFF6C7566);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 24, 26, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: dark
                                    ? const Color(0xFFD6E9B8)
                                    : const Color(0xFF293E2D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.graphic_eq_rounded,
                                size: 23,
                                color: dark
                                    ? const Color(0xFF293E2D)
                                    : const Color(0xFFE9F1DA),
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'murmur',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.1,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'VOICE TO CLARITY',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        const _NotePreview(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 23,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            for (var index = 0; index < 2; index++)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: CircleAvatar(
                                  radius: 2.5,
                                  backgroundColor:
                                      colors.outlineVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'A little less typing.\nA lot more thinking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 36,
                            height: 1.12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.7,
                          ),
                        ),
                        const SizedBox(height: 17),
                        Text(
                          'Speak your mind. Let AI turn your thoughts\ninto clear, organized notes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const _ReadyScreen(),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Find your flow',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 13, color: muted),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Your thoughts stay yours. Always.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: muted, fontSize: 11),
                              ),
                            ),
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

class _NotePreview extends StatelessWidget {
  const _NotePreview();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFE7ECDC) : const Color(0xFF293E2D);
    final secondary = dark ? const Color(0xFFBAC4AD) : const Color(0xFF6C765E);
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF303B29) : const Color(0xFFE8EDDA),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 23),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 7, color: ink),
              const SizedBox(width: 7),
              Expanded(
                child: Text('A THOUGHT, CAPTURED',
                    style: TextStyle(
                        color: ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6)),
              ),
              Text('0:24', style: TextStyle(color: secondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 22),
          Semantics(
            label: 'Audio waveform of a recorded voice note',
            child: SizedBox(
              height: 44,
              child: CustomPaint(
                size: const Size(double.infinity, 44),
                painter: _WavePainter(color: ink),
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(
            '“What if we made a little more room\nfor the things that matter?”',
            textAlign: TextAlign.center,
            style: TextStyle(color: ink, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          Icon(Icons.south_rounded, size: 18, color: secondary),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF20271D) : const Color(0xFFFCFDF6),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Make room for what matters',
                          style: TextStyle(
                              color: ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4)),
                    ),
                    const SizedBox(width: 7),
                    Icon(Icons.auto_awesome_rounded, color: secondary, size: 17),
                  ],
                ),
                const SizedBox(height: 9),
                Text('Protect time for creative work and\nmake space for everyday inspiration.',
                    style: TextStyle(
                        color: secondary, fontSize: 12, height: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(label: 'Personal', color: secondary, dark: dark),
                    _Tag(label: 'Ideas', color: secondary, dark: dark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.dark});
  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF333E2B) : const Color(0xFFEEF1E5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 9)),
      );
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const heights = <double>[
      6, 10, 16, 8, 22, 32, 18, 28, 40, 25, 15, 32, 44, 27, 19, 35,
      24, 12, 18, 30, 41, 29, 17, 25, 37, 21, 11, 18, 28, 14, 8, 13,
      20, 10, 6,
    ];
    final step = size.width / heights.length;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < heights.length; index++) {
      final position = (index + 0.5) * step;
      canvas.drawLine(
        Offset(position, (size.height - heights[index]) / 2),
        Offset(position, (size.height + heights[index]) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.color != color;
}

class _ReadyScreen extends StatelessWidget {
  const _ReadyScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Your space to think')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_none_rounded,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text('Every good idea starts somewhere.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const Text('You’re ready to turn your next thought into a note.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
}
