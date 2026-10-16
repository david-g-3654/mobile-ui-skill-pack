import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_eval/pack04/theme.dart';
import 'package:fl_eval/pack04/components.dart';

class DetailEvalApp extends StatelessWidget {
  const DetailEvalApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: quietTheme(Brightness.light),
    darkTheme: quietTheme(Brightness.dark),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    home: const _SneakerDetail(),
  );
}

class _SneakerDetail extends StatefulWidget {
  const _SneakerDetail();

  @override
  State<_SneakerDetail> createState() => _SneakerDetailState();
}

class _SneakerDetailState extends State<_SneakerDetail> {
  String _size = '9';
  bool _saved = false;
  int _bagCount = 0;

  void _showSizeGuide() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          QSpace.margin,
          QSpace.xs,
          QSpace.margin,
          QSpace.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: QSpace.lg,
          children: [
            Semantics(
              header: true,
              child: Text('Find your fit', style: context.qText.titleLarge),
            ),
            Text(
              'Court 01 fits true to size. Between sizes? Choose the larger size for a little more room.',
              style: context.qText.bodyMedium,
            ),
            for (final entry in const [
              ('US 7', '25 cm'),
              ('US 8', '26 cm'),
              ('US 9', '27 cm'),
              ('US 10', '28 cm'),
              ('US 11', '29 cm'),
              ('US 12', '30 cm'),
            ])
              Row(
                children: [
                  Expanded(
                    child: Text(entry.$1, style: context.qText.titleMedium),
                  ),
                  Text(entry.$2, style: context.qText.bodyMedium),
                ],
              ),
            Text(
              'Measurements are heel to toe.',
              style: context.qText.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
        title: Text('FIELDWORK', style: context.qText.titleMedium),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _saved ? 'Remove from saved sneakers' : 'Save sneaker',
            isSelected: _saved,
            selectedIcon: const Icon(Icons.favorite_rounded),
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _saved = !_saved);
              showQToast(
                context,
                _saved ? 'Court 01 saved' : 'Removed from saved sneakers',
              );
            },
          ),
          const SizedBox(width: QSpace.xs),
        ],
      ),
      bottomNavigationBar: QBottomActionBar(
        children: [
          QPrimaryButton(
            label: 'Add to bag · \$138.00',
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() => _bagCount++);
              showQToast(
                context,
                'Court 01 · US $_size added to bag ($_bagCount)',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProductImage(background: q.surface2),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          QSpace.margin,
                          QSpace.xl,
                          QSpace.margin,
                          QSpace.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE EVERYDAY COLLECTION',
                              style: context.qText.bodySmall,
                            ),
                            const SizedBox(height: QSpace.xs),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: QSpace.xl,
                              runSpacing: QSpace.xxs,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'Court 01',
                                    style: context.qText.titleLarge,
                                  ),
                                ),
                                Text(
                                  '\$138.00',
                                  style: context.qText.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: QSpace.xs),
                            MergeSemantics(
                              child: Row(
                                spacing: QSpace.xxs,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: QSpace.md,
                                    color: q.ink2,
                                  ),
                                  Flexible(
                                    child: Text(
                                      '4.8 / 5 · 126 reviews',
                                      style: context.qText.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: QSpace.xl),
                            Text.rich(
                              TextSpan(
                                text: 'Colour  ',
                                style: context.qText.titleMedium,
                                children: [
                                  TextSpan(
                                    text: 'Chalk / Graphite',
                                    style: context.qText.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: QSpace.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Size · US men’s',
                                    style: context.qText.titleMedium,
                                  ),
                                ),
                                QTertiaryButton(
                                  label: 'Size guide',
                                  onPressed: _showSizeGuide,
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: QSpace.xs,
                              runSpacing: QSpace.xs,
                              children: [
                                for (final size in const [
                                  '7',
                                  '8',
                                  '9',
                                  '10',
                                  '11',
                                  '12',
                                ])
                                  _SizeOption(
                                    label: size,
                                    selected: _size == size,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _size = size);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: QSpace.xl),
                            Text(
                              'Free shipping · 30-day returns',
                              style: context.qText.bodySmall,
                            ),
                            const SizedBox(height: QSpace.xxl),
                            Text(
                              'A court classic, made for the long way home. Soft leather, a cushioned footbed and a sturdy stitched cupsole.',
                              style: context.qText.bodyMedium,
                            ),
                            const SizedBox(height: QSpace.lg),
                            const _DetailDisclosure(
                              title: 'Materials & care',
                              text: 'Full-grain leather upper. Recycled textile lining. Rubber cupsole. Wipe clean with a damp cloth and air dry away from direct heat.',
                            ),
                            const _DetailDisclosure(
                              title: 'Delivery & returns',
                              text: 'Ships within 2 business days. Standard delivery takes 3–5 business days. Return unworn sneakers in their original box within 30 days.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: 'US size $label',
    child: Material(
      color: selected ? context.q.accentSoft : context.q.canvas,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? context.q.accent : context.q.hairline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: QSpace.xxxl,
            minHeight: QSpace.xxxl,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QSpace.sm,
              vertical: QSpace.xs,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.qText.titleMedium?.copyWith(
                color: selected ? context.q.accent : context.q.ink,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DetailDisclosure extends StatelessWidget {
  const _DetailDisclosure({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.q.hairline)),
    ),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: QSpace.lg),
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(title, style: context.qText.titleMedium),
      iconColor: context.q.ink2,
      collapsedIconColor: context.q.ink2,
      children: [Text(text, style: context.qText.bodyMedium)],
    ),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.background});
  final Color background;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Court 01 sneaker in chalk leather with graphite heel and side panels, side view',
    child: ExcludeSemantics(
      child: ColoredBox(
        color: background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.45,
              child: CustomPaint(painter: _SneakerPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                QSpace.margin,
                0,
                QSpace.margin,
                QSpace.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DESIGNED FOR DAILY LIFE',
                    style: context.qText.bodySmall,
                  ),
                  Text('01 / COURT', style: context.qText.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SneakerPainter extends CustomPainter {
  final _chalk = Quiet.light.canvas;
  final _leather = Quiet.light.surface;
  final _edge = Quiet.light.ink3;
  final _graphite = Quiet.light.ink2;
  final _rubber = Quiet.light.surface2;

  void _panel(Canvas canvas, Path path, Color color, {bool outline = true}) {
    canvas.drawPath(path, Paint()..color = color);
    if (outline) {
      canvas.drawPath(
        path,
        Paint()
          ..color = _edge.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 420, size.height / 290);
    canvas.translate(8, -5);
    canvas.drawOval(
      const Rect.fromLTWH(45, 237, 326, 12),
      Paint()..color = Quiet.light.ink.withValues(alpha: 0.07),
    );
    canvas.translate(210, 157);
    canvas.rotate(-0.12);
    canvas.translate(-210, -157);
    _panel(
      canvas,
      Path()
        ..moveTo(38, 204)
        ..cubicTo(42, 187, 65, 179, 103, 168)
        ..lineTo(202, 126)
        ..lineTo(268, 94)
        ..lineTo(294, 111)
        ..cubicTo(307, 127, 325, 135, 349, 115)
        ..lineTo(367, 105)
        ..cubicTo(377, 128, 376, 166, 380, 207)
        ..cubicTo(323, 233, 113, 239, 42, 219)
        ..close(),
      _chalk,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(253, 104)
        ..quadraticBezierTo(265, 78, 279, 85)
        ..lineTo(321, 128)
        ..lineTo(276, 163)
        ..lineTo(226, 131)
        ..close(),
      _leather,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(294, 111)
        ..quadraticBezierTo(323, 149, 367, 105)
        ..lineTo(373, 128)
        ..quadraticBezierTo(329, 164, 305, 136)
        ..close(),
      _graphite,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(119, 164)
        ..lineTo(216, 123)
        ..lineTo(278, 157)
        ..lineTo(307, 201)
        ..quadraticBezierTo(221, 218, 126, 208)
        ..quadraticBezierTo(147, 187, 119, 164)
        ..close(),
      _leather,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(149, 178)
        ..lineTo(249, 147)
        ..lineTo(264, 158)
        ..lineTo(176, 196)
        ..close(),
      _graphite,
      outline: false,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(164, 192)
        ..lineTo(261, 162)
        ..lineTo(269, 174)
        ..lineTo(185, 208)
        ..close(),
      _graphite,
      outline: false,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(303, 149)
        ..lineTo(321, 145)
        ..lineTo(344, 162)
        ..lineTo(367, 136)
        ..lineTo(378, 201)
        ..lineTo(308, 213)
        ..quadraticBezierTo(320, 180, 303, 149)
        ..close(),
      _chalk,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(48, 193)
        ..quadraticBezierTo(69, 174, 120, 163)
        ..quadraticBezierTo(156, 183, 137, 209)
        ..lineTo(45, 216)
        ..close(),
      _leather,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(36, 207)
        ..cubicTo(124, 220, 289, 218, 380, 201)
        ..lineTo(381, 223)
        ..cubicTo(299, 247, 120, 244, 39, 228)
        ..quadraticBezierTo(33, 222, 36, 207)
        ..close(),
      _rubber,
    );
    canvas.drawPath(
      Path()
        ..moveTo(39, 216)
        ..cubicTo(146, 232, 292, 229, 378, 211),
      Paint()
        ..color = _edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    _panel(
      canvas,
      Path()
        ..moveTo(132, 160)
        ..lineTo(216, 121)
        ..lineTo(286, 153)
        ..lineTo(276, 168)
        ..lineTo(210, 139)
        ..lineTo(146, 174)
        ..close(),
      _chalk,
    );
    final seam = Paint()
      ..color = _edge
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(54, 195)
        ..quadraticBezierTo(103, 176, 121, 175)
        ..quadraticBezierTo(140, 186, 126, 204),
      seam,
    );
    canvas.drawPath(
      Path()
        ..moveTo(315, 154)
        ..quadraticBezierTo(334, 175, 319, 204),
      seam,
    );
    for (var index = 0; index < 6; index++) {
      final start = Offset(151 + index * 15, 157 - index * 6);
      final end = Offset(179 + index * 17, 165 - index * 2);
      canvas.drawCircle(start, 3.3, Paint()..color = _edge);
      canvas.drawCircle(end, 3.3, Paint()..color = _edge);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = _rubber
          ..strokeWidth = 4.6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        start.translate(0, -0.8),
        end.translate(0, -0.8),
        Paint()
          ..color = _leather
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
    for (var row = 0; row < 3; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              74 + column * 10 + row * 5,
              188 + row * 6 - column * 2,
            ),
            width: 2.1,
            height: 1.4,
          ),
          Paint()..color = _edge.withValues(alpha: 0.6),
        );
      }
    }
    for (var index = 0; index < 44; index++) {
      final position = 49.0 + index * 7.3;
      canvas.drawLine(
        Offset(position, 232 - (position - 180).abs() * 0.035),
        Offset(position, 236 - (position - 180).abs() * 0.035),
        seam,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SneakerPainter oldDelegate) => false;
}
