import 'package:flutter/material.dart';

class PaywallEvalApp extends StatelessWidget {
  const PaywallEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF52654B),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF191D18)
          : const Color(0xFFFAF8F2),
      textTheme: Typography.material2021().black.apply(
        bodyColor: dark ? const Color(0xFFECEDE3) : const Color(0xFF293429),
        displayColor: dark ? const Color(0xFFECEDE3) : const Color(0xFF293429),
      ),
      dividerColor: dark ? const Color(0xFF3A4237) : const Color(0xFFDEDED3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _PaywallScreen(),
    );
  }
}

class _PaywallScreen extends StatefulWidget {
  const _PaywallScreen();

  @override
  State<_PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<_PaywallScreen> {
  bool _yearly = true;

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = Theme.of(context).colorScheme.onSurface;
    final muted = dark ? const Color(0xFFADB6A6) : const Color(0xFF737B6D);
    final accent = dark ? const Color(0xFFBBCDAA) : const Color(0xFF485D3F);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.spa_outlined, color: accent, size: 22),
                      const SizedBox(width: 7),
                      Text(
                        'still',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _message(
                          'You’re welcome to keep journaling with the free plan.',
                        ),
                        style: TextButton.styleFrom(foregroundColor: muted),
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const SizedBox(height: 145, child: _JournalIllustration()),
                  const SizedBox(height: 18),
                  Text(
                    'A LITTLE SPACE, JUST FOR YOU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      letterSpacing: 2.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Make room for\nmore of you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 39,
                      height: 1.08,
                      letterSpacing: -1.3,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Go deeper, find clarity, and grow at your own pace\nwith Still Plus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _Benefit(
                    icon: Icons.auto_stories_outlined,
                    title: 'Your thoughts, without limits',
                    subtitle: 'Unlimited journals, photos & entries',
                    color: accent,
                    muted: muted,
                  ),
                  const SizedBox(height: 15),
                  _Benefit(
                    icon: Icons.wb_sunny_outlined,
                    title: 'A little guidance, every day',
                    subtitle: 'Thoughtful prompts & guided reflections',
                    color: accent,
                    muted: muted,
                  ),
                  const SizedBox(height: 15),
                  _Benefit(
                    icon: Icons.insights_rounded,
                    title: 'See how far you’ve come',
                    subtitle: 'Mood patterns & personal insights',
                    color: accent,
                    muted: muted,
                  ),
                  const SizedBox(height: 27),
                  _PlanCard(
                    selected: _yearly,
                    title: 'Yearly',
                    price: '\$29.99',
                    period: '/ year',
                    detail: 'Just \$2.50 a month, billed yearly',
                    badge: 'SAVE 58%',
                    onTap: () => setState(() => _yearly = true),
                  ),
                  const SizedBox(height: 10),
                  _PlanCard(
                    selected: !_yearly,
                    title: 'Monthly',
                    price: '\$5.99',
                    period: '/ month',
                    detail: 'A little space, one month at a time',
                    onTap: () => setState(() => _yearly = false),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => _message(
                      'You selected Still Plus ${_yearly ? 'Yearly at \$29.99/year' : 'Monthly at \$5.99/month'}. Purchases are not connected in this preview.',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: dark
                          ? const Color(0xFFB8CBA7)
                          : const Color(0xFF485D3F),
                      foregroundColor: dark
                          ? const Color(0xFF21301B)
                          : const Color(0xFFFCFCF5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Continue with Plus',
                            textAlign: TextAlign.center,
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
                  const SizedBox(height: 12),
                  Text(
                    '${_yearly ? '\$29.99/year' : '\$5.99/month'} • Auto-renews. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 11, height: 1.5),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (final label in [
                        'Restore purchases',
                        'Terms',
                        'Privacy',
                      ])
                        TextButton(
                          onPressed: () => _message(
                            label == 'Restore purchases'
                                ? 'No existing purchases found in this preview.'
                                : '$label information is unavailable in this preview.',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: muted,
                            textStyle: const TextStyle(fontSize: 11),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(label),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 12, color: muted),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Your journal stays yours. Always.',
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
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.muted,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 21, color: color),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.period,
    required this.detail,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final String title;
  final String price;
  final String period;
  final String detail;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? const Color(0xFFB8CBA7) : const Color(0xFF485D3F);
    final muted = dark ? const Color(0xFFADB6A6) : const Color(0xFF737B6D);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? (dark ? const Color(0xFF293325) : const Color(0xFFF0F2E8))
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: selected
                ? accent
                : (dark ? const Color(0xFF46503F) : const Color(0xFFDEDED3)),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : muted,
                  size: 23,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                badge!,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' $period',
                              style: TextStyle(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        detail,
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class _JournalIllustration extends StatelessWidget {
  const _JournalIllustration();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'An open journal with a growing sprig',
      image: true,
      child: CustomPaint(
        painter: _JournalPainter(dark),
        size: const Size(double.infinity, 145),
      ),
    );
  }
}

class _JournalPainter extends CustomPainter {
  const _JournalPainter(this.dark);

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 - 120, 0);
    final wash = Paint()
      ..color = dark ? const Color(0xFF293225) : const Color(0xFFEEF0E3);
    canvas.drawOval(const Rect.fromLTWH(16, 5, 210, 137), wash);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: dark ? 0.18 : 0.05);
    canvas.drawOval(const Rect.fromLTWH(35, 120, 181, 14), shadow);
    final cover = Path()
      ..moveTo(39, 45)
      ..lineTo(116, 52)
      ..lineTo(197, 34)
      ..lineTo(210, 116)
      ..lineTo(126, 133)
      ..lineTo(43, 121)
      ..close();
    canvas.drawPath(cover, Paint()..color = const Color(0xFF78866A));
    final page = Path()
      ..moveTo(44, 34)
      ..quadraticBezierTo(80, 30, 119, 49)
      ..quadraticBezierTo(155, 24, 191, 27)
      ..lineTo(202, 107)
      ..quadraticBezierTo(162, 105, 126, 126)
      ..quadraticBezierTo(86, 109, 47, 111)
      ..close();
    canvas.drawPath(page, Paint()..color = const Color(0xFFEEE9D9));
    final seam = Paint()
      ..color = const Color(0xFFCBC7B5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(119, 49), const Offset(126, 124), seam);
    final line = Paint()
      ..color = const Color(0xFFCBC7B5)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 5; index++) {
      final vertical = 53.0 + index * 10;
      canvas.drawLine(Offset(60, vertical), Offset(104, vertical + 7), line);
    }
    final stem = Paint()
      ..color = const Color(0xFF5D7151)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(146, 105)
        ..quadraticBezierTo(166, 74, 166, 15),
      stem,
    );
    final leafPaint = Paint()..color = const Color(0xFF7E9066);
    for (var index = 0; index < 4; index++) {
      final vertical = 30.0 + index * 17;
      final right = index.isEven;
      final leaf = Path()
        ..moveTo(164, vertical + 14)
        ..quadraticBezierTo(
          right ? 190 : 139,
          vertical + 7,
          right ? 183 : 142,
          vertical - 7,
        )
        ..quadraticBezierTo(
          right ? 165 : 153,
          vertical - 5,
          164,
          vertical + 14,
        );
      canvas.drawPath(leaf, leafPaint);
    }
    final gold = Paint()
      ..color = const Color(0xFFB89E69)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(43, 15), const Offset(43, 25), gold);
    canvas.drawLine(const Offset(38, 20), const Offset(48, 20), gold);
    canvas.drawCircle(const Offset(211, 64), 2.5, gold);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JournalPainter oldDelegate) =>
      dark != oldDelegate.dark;
}
