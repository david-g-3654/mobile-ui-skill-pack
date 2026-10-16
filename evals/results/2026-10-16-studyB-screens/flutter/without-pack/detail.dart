import 'dart:math' as math;

import 'package:flutter/material.dart';

class DetailEvalApp extends StatelessWidget {
  const DetailEvalApp({super.key});

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB64C2F),
      brightness: brightness,
      surface: dark ? const Color(0xFF191B19) : const Color(0xFFFAF9F6),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'sans-serif',
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        elevation: 0,
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
      home: const _DetailScreen(),
    );
  }
}

class _DetailScreen extends StatefulWidget {
  const _DetailScreen();

  @override
  State<_DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen> {
  int _size = 9;
  int _color = 0;
  bool _favorite = false;
  int _bagCount = 0;
  static const _colors = [Color(0xFFBD6549), Color(0xFF667265), Color(0xFF454647)];
  static const _colorNames = ['Clay / Chalk', 'Sage / Chalk', 'Graphite / Chalk'];

  void _showBag() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your bag', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text(_bagCount == 0 ? 'Your next favorite pair is waiting.' : '$_bagCount × Court 01 · ${_colorNames[_color]} · US $_size'),
              if (_bagCount > 0) ...[
                const SizedBox(height: 16),
                Text('Subtotal  \$${(_bagCount * 145).toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final muted = ink.withValues(alpha: 0.58);
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('S O L E   S T U D I O', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Shopping bag',
            onPressed: _showBag,
            icon: Badge(
              isLabelVisible: _bagCount > 0,
              label: Text('$_bagCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: ink.withValues(alpha: 0.1)))),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dark ? const Color(0xFFE8E9DB) : const Color(0xFF25352B),
              foregroundColor: dark ? const Color(0xFF25352B) : Colors.white,
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              setState(() => _bagCount++);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Court 01 · US $_size added to your bag'), action: SnackBarAction(label: 'View bag', onPressed: _showBag)),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Flexible(child: Text('Add to bag', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))), SizedBox(width: 16), Icon(Icons.arrow_forward_rounded, size: 21)],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Container(
                height: 300,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF2D302A) : const Color(0xFFECEDE5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _SneakerPainter(_colors[_color], dark))),
                    Positioned(
                      top: 18,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(7)),
                        child: const Text('THE EVERYDAY EDIT', style: TextStyle(fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        tooltip: _favorite ? 'Remove from favorites' : 'Save to favorites',
                        onPressed: () => setState(() => _favorite = !_favorite),
                        icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border, color: _favorite ? _colors[0] : ink),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 19, height: 5, decoration: BoxDecoration(color: ink.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(5))),
                        const SizedBox(width: 5),
                        Text('SIDE PROFILE', style: TextStyle(fontSize: 8, letterSpacing: 1.5, color: muted)),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: Text('LESS, BUT BETTER.', style: TextStyle(fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: muted))),
                  const Icon(Icons.star_rounded, color: Color(0xFFB47737), size: 17),
                  const SizedBox(width: 3),
                  Text('4.8 (124)', style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: Text('Court 01', style: TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -1.2))),
                  const SizedBox(width: 12),
                  Padding(padding: const EdgeInsets.only(top: 7), child: Text('\$145', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: ink))),
                ],
              ),
              const SizedBox(height: 7),
              Text('A classic silhouette. A lighter footprint.', style: TextStyle(fontSize: 14, height: 1.5, color: muted)),
              const SizedBox(height: 24),
              Text.rich(TextSpan(children: [const TextSpan(text: 'Color  ', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: _colorNames[_color], style: TextStyle(color: muted))]), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: List.generate(_colors.length, (index) => Semantics(
                  label: _colorNames[index],
                  selected: _color == index,
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => setState(() => _color = index),
                    child: Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _color == index ? ink : Colors.transparent, width: 1.5)),
                      child: DecoratedBox(decoration: BoxDecoration(color: _colors[index], shape: BoxShape.circle), child: _color == index ? const Icon(Icons.check, size: 18, color: Colors.white) : null),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 19),
              Row(
                children: [
                  const Expanded(child: Text('Select size · US Men', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Find your fit'),
                        content: const Text('Court 01 fits true to size.\n\nUS 7 · 25 cm\nUS 8 · 26 cm\nUS 9 · 27 cm\nUS 10 · 28 cm\nUS 11 · 29 cm\nUS 12 · 30 cm\n\nBetween sizes? Choose the larger size.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
                      ),
                    ),
                    child: Text('Size guide', style: TextStyle(color: muted, decoration: TextDecoration.underline, fontSize: 12)),
                  ),
                ],
              ),
              LayoutBuilder(builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                final columns = scale > 1.5 ? 3 : 6;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(6, (index) {
                    final size = index + 7;
                    final selected = _size == size;
                    return SizedBox(
                      width: (constraints.maxWidth - (columns - 1) * 8) / columns,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _size = size),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          foregroundColor: selected ? theme.colorScheme.surface : ink,
                          backgroundColor: selected ? ink : Colors.transparent,
                          side: BorderSide(color: selected ? ink : ink.withValues(alpha: 0.18)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('$size', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    );
                  }),
                );
              }),
              const SizedBox(height: 15),
              Row(children: [Icon(Icons.check_circle_outline, size: 15, color: muted), const SizedBox(width: 6), Expanded(child: Text('True to size. Made for all-day comfort.', style: TextStyle(fontSize: 12, color: muted)))]),
              const SizedBox(height: 25),
              Divider(color: ink.withValues(alpha: 0.12), height: 1),
              const SizedBox(height: 18),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.local_shipping_outlined, size: 21, color: ink),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Good things, delivered free.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Free shipping & 30-day returns.', style: TextStyle(fontSize: 12, color: muted)),
                ])),
              ]),
              const SizedBox(height: 18),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Thoughtfully made', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                children: const [Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Soft suede meets breathable recycled mesh. A cushioned footbed and durable rubber outsole bring everyday ease to a timeless court-inspired shape.', style: TextStyle(height: 1.6)))],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SneakerPainter extends CustomPainter {
  const _SneakerPainter(this.accent, this.dark);
  final Color accent;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 9);
    final scale = math.min(size.width / 370, size.height / 280);
    canvas.scale(scale);
    canvas.drawOval(const Rect.fromLTWH(-139, 56, 283, 19), Paint()..color = Colors.black.withValues(alpha: 0.13)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.rotate(-0.13);
    final sole = Path()..moveTo(-148, 28)..cubicTo(-147, 10, -132, 9, -109, 8)..lineTo(108, 18)..quadraticBezierTo(147, 24, 152, 39)..lineTo(149, 53)..quadraticBezierTo(82, 69, -114, 52)..quadraticBezierTo(-150, 50, -148, 28)..close();
    canvas.drawPath(sole, Paint()..color = const Color(0xFFD4C7B0));
    final upper = Path()..moveTo(-145, 27)..lineTo(-137, -56)..quadraticBezierTo(-133, -65, -119, -57)..lineTo(-81, -35)..quadraticBezierTo(-65, -27, -48, -45)..lineTo(-30, -68)..quadraticBezierTo(-20, -75, -10, -65)..lineTo(40, -22)..quadraticBezierTo(61, -8, 105, 1)..quadraticBezierTo(141, 7, 148, 29)..quadraticBezierTo(81, 49, -124, 34)..close();
    canvas.drawPath(upper, Paint()..color = const Color(0xFFE5DFCF));
    final heel = Path()..moveTo(-145, 27)..lineTo(-137, -56)..quadraticBezierTo(-133, -65, -119, -57)..lineTo(-94, -42)..lineTo(-100, 29)..close();
    canvas.drawPath(heel, Paint()..color = accent);
    final collar = Path()..moveTo(-126, -54)..quadraticBezierTo(-85, -14, -45, -47)..lineTo(-33, -65)..quadraticBezierTo(-56, -64, -70, -48)..quadraticBezierTo(-87, -39, -115, -61)..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xFF4B4940));
    final toe = Path()..moveTo(68, -6)..quadraticBezierTo(137, 1, 148, 29)..quadraticBezierTo(128, 38, 91, 38)..quadraticBezierTo(75, 21, 68, -6)..close();
    canvas.drawPath(toe, Paint()..color = accent);
    final panel = Path()..moveTo(-88, -17)..lineTo(-49, -32)..lineTo(30, 12)..lineTo(65, 13)..lineTo(48, 33)..lineTo(-87, 29)..close();
    canvas.drawPath(panel, Paint()..color = const Color(0xFFD4CBB9));
    final stripe = Path()..moveTo(-68, -11)..lineTo(-49, -21)..lineTo(-7, 12)..lineTo(27, -5)..lineTo(44, 5)..lineTo(-8, 32)..close();
    canvas.drawPath(stripe, Paint()..color = accent);
    final tongue = Path()..moveTo(-41, -43)..lineTo(-27, -67)..quadraticBezierTo(-21, -74, -12, -63)..lineTo(52, -10)..lineTo(26, 2)..close();
    canvas.drawPath(tongue, Paint()..color = const Color(0xFFEEE9DA));
    final stitch = Paint()..color = const Color(0xFFB0A48E)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawPath(Path()..moveTo(-132, 30)..quadraticBezierTo(-10, 46, 141, 31), stitch);
    canvas.drawPath(Path()..moveTo(76, -1)..quadraticBezierTo(82, 20, 96, 32), stitch);
    for (var index = 0; index < 5; index++) {
      final horizontal = -28.0 + index * 13;
      final vertical = -43.0 + index * 10;
      canvas.drawCircle(Offset(horizontal - 5, vertical + 8), 2.8, Paint()..color = const Color(0xFF8D8372));
      canvas.drawLine(Offset(horizontal - 5, vertical + 8), Offset(horizontal + 11, vertical - 2), Paint()..color = const Color(0xFFFAF6E9)..strokeWidth = 4..strokeCap = StrokeCap.round);
    }
    for (var index = 0; index < 22; index++) {
      final horizontal = -124.0 + index * 12;
      canvas.drawLine(Offset(horizontal, 49), Offset(horizontal + 1, 54), Paint()..color = const Color(0xFFAB9B7E)..strokeWidth = 1.3);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SneakerPainter oldDelegate) => accent != oldDelegate.accent || dark != oldDelegate.dark;
}
