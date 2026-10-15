// Product detail — sneaker store.
// Archetype: Detail. Job: choose a colour + size and add the pair to the bag.
// Focal: full-bleed product media, then the title/price block. Primary: "Add to bag · $135.00" (pinned).
// Cutting: inline size grid (moved to a sheet), "Buy now" button, review list, spec table (behind disclosure).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack04/components.dart';
import 'package:fl_eval/pack04/theme.dart';

class DetailEvalApp extends StatelessWidget {
  const DetailEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halden',
      theme: quietTheme(Brightness.light),
      darkTheme: quietTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const _SneakerDetailScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

String _usd(double value) => '\$${value.toStringAsFixed(2)}';

class _Colorway {
  const _Colorway({
    required this.name,
    required this.upper,
    required this.overlay,
    required this.sole,
    this.soldOut = const [],
    this.stockNote,
  });

  final String name;
  final Color upper;
  final Color overlay;
  final Color sole;
  final List<String> soldOut;
  final String? stockNote;
}

const _colorways = [
  _Colorway(
    name: 'Sea salt / gum',
    upper: Color(0xFFF1EEE6), // mobile-ui: content-color
    overlay: Color(0xFFD6CFBF), // mobile-ui: content-color
    sole: Color(0xFFC08A52), // mobile-ui: content-color
    soldOut: ['12', '13'],
  ),
  _Colorway(
    name: 'Slate / bone',
    upper: Color(0xFF6B7480), // mobile-ui: content-color
    overlay: Color(0xFF3F4650), // mobile-ui: content-color
    sole: Color(0xFFEDE6D6), // mobile-ui: content-color
    soldOut: ['7'],
  ),
  _Colorway(
    name: 'Forest / cream',
    upper: Color(0xFF2F4A3A), // mobile-ui: content-color
    overlay: Color(0xFF1F3328), // mobile-ui: content-color
    sole: Color(0xFFEFE7D2), // mobile-ui: content-color
  ),
  _Colorway(
    name: 'Black / black',
    upper: Color(0xFF262626), // mobile-ui: content-color
    overlay: Color(0xFF141414), // mobile-ui: content-color
    sole: Color(0xFF2E2E2E), // mobile-ui: content-color
    soldOut: ['8.5', '9', '13'],
    stockNote: 'Low stock — a few pairs left in most sizes',
  ),
];

const _sizes = ['7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '13'];

const _angles = ['Side view', 'Inner side', 'Toe detail'];

const _description =
    'A 1974 court shoe, rebuilt for walking all day. The pig suede upper sits on a cupsole that is '
    'stitched, not glued, so a cobbler can resole it. The natural gum outsole grips wet pavement and '
    'softens with wear, and the recycled EVA footbed keeps its shape well past the first month.';

const _disclosures = [
  (
    'Details',
    'Upper: pig suede with recycled nylon mesh panels\n'
        'Lining: unbleached cotton canvas\n'
        'Outsole: natural rubber, stitched cupsole\n'
        'Weight: 410 g per shoe (US 9)\n'
        'Style code: HM74-SG',
  ),
  (
    'Size & fit',
    'Runs half a size large. If you are between sizes, go down. Roomy forefoot with a snug, '
        'padded heel; the suede relaxes after a week of wear.',
  ),
  (
    'Delivery & returns',
    'Free standard delivery on orders over \$75.00, usually 3–5 business days. Return unworn pairs '
        'within 30 days for a full refund — the label is in the box.',
  ),
];

class _Related {
  const _Related(this.name, this.price, this.colorway);
  final String name;
  final double price;
  final _Colorway colorway;
}

final _related = [
  _Related('Meridian 74 canvas', 95, _colorways[2]),
  _Related('Kestrel trail mid', 168, _colorways[1]),
  _Related('Port runner', 122.5, _colorways[3]),
  _Related('Meridian 74 high', 150, _colorways[0]),
];

// ── Screen ──────────────────────────────────────────────────────────

class _SneakerDetailScreen extends StatefulWidget {
  const _SneakerDetailScreen();

  @override
  State<_SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends State<_SneakerDetailScreen> {
  static const _name = 'Meridian 74 suede low';
  static const _price = 135.0;

  final _pages = PageController();
  int _page = 0;
  int _colorIndex = 0;
  String? _size;
  bool _saved = false;
  bool _descriptionOpen = false;

  _Colorway get _colorway => _colorways[_colorIndex];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _pickSize() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SizeSheet(selected: _size, colorway: _colorway),
    );
    if (picked != null && mounted) setState(() => _size = picked);
  }

  Future<void> _addToBag() async {
    if (_size == null) await _pickSize();
    if (!mounted || _size == null) return;
    HapticFeedback.mediumImpact();
    showQToast(context, 'Added $_name, US $_size, to your bag');
  }

  void _selectColor(int index) {
    setState(() {
      _colorIndex = index;
      if (_size != null && _colorways[index].soldOut.contains(_size)) _size = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.qText;
    final width = MediaQuery.sizeOf(context).width;
    final mediaHeight = width.clamp(280.0, 520.0);
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      bottomNavigationBar: QBottomActionBar(
        children: [QPrimaryButton(label: 'Add to bag · ${_usd(_price)}', onPressed: _addToBag)],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: mediaHeight,
            backgroundColor: q.canvas,
            automaticallyImplyLeading: false,
            leading: Center(
              child: _GlyphButton(
                tooltip: 'Back',
                icon: const BackButtonIcon(),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              _GlyphButton(
                tooltip: _saved ? 'Remove from saved' : 'Save',
                icon: Icon(_saved ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _saved = !_saved);
                },
              ),
              _GlyphButton(tooltip: 'Share', icon: const Icon(Icons.ios_share_rounded), onPressed: () {}),
              const SizedBox(width: QSpace.xs),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _Gallery(
                controller: _pages,
                page: _page,
                colorway: _colorway,
                onPageChanged: (i) => setState(() => _page = i),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.xl, QSpace.margin, QSpace.xxl),
            sliver: SliverList.list(
              children: [
                // Title block: what it is, how much, one proof point.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: QSpace.xxs,
                  children: [
                    Text('Halden · Lifestyle'.toUpperCase(), style: t.labelSmall),
                    Semantics(header: true, child: Text(_name, style: t.titleLarge)),
                    const SizedBox(height: QSpace.xxs),
                    Wrap(
                      spacing: QSpace.sm,
                      runSpacing: QSpace.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_usd(_price),
                            style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                        MergeSemantics(
                          child: Text.rich(
                            TextSpan(children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ExcludeSemantics(
                                  child: Icon(Icons.star_rounded,
                                      size: MediaQuery.textScalerOf(context).scale(16), color: q.accent),
                                ),
                              ),
                              TextSpan(text: ' 4.7', style: t.bodyMedium?.copyWith(color: q.ink)),
                              const TextSpan(text: ' · 318 reviews'),
                            ]),
                            semanticsLabel: 'Rated 4.7 out of 5 from 318 reviews',
                            style: t.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: QSpace.xl),

                // Colour — four options, so inline swatches.
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Colour  '),
                    TextSpan(text: _colorway.name, style: t.bodyLarge?.copyWith(color: q.ink2)),
                  ]),
                  style: t.bodyLarge,
                ),
                const SizedBox(height: QSpace.xxs),
                Wrap(
                  spacing: QSpace.xxs,
                  runSpacing: QSpace.xxs,
                  children: [
                    for (var i = 0; i < _colorways.length; i++)
                      QSwatch(
                        name: _colorways[i].name,
                        color: _colorways[i].upper,
                        selected: i == _colorIndex,
                        onTap: () => _selectColor(i),
                      ),
                  ],
                ),
                if (_colorway.stockNote != null) ...[
                  const SizedBox(height: QSpace.xxs),
                  Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: QSpace.xxs),
                          child: Icon(Icons.inventory_2_rounded,
                              size: MediaQuery.textScalerOf(context).scale(14), color: q.ink2),
                        ),
                      ),
                      TextSpan(text: _colorway.stockNote),
                    ]),
                    style: t.bodyMedium,
                  ),
                ],
                const SizedBox(height: QSpace.md),

                // Size — twelve options, so a row that opens a sheet.
                QGroupedSection(
                  footer: 'Free delivery over ${_usd(75)} and free 30-day returns.',
                  children: [
                    QListRow(title: 'Size', value: _size == null ? 'Select' : 'US $_size', onTap: _pickSize),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),

                // Description: 3-line preview + More.
                AnimatedSize(
                  duration: animate ? QMotion.medium : Duration.zero,
                  curve: QMotion.curve,
                  alignment: Alignment.topLeft,
                  child: Text(
                    _description,
                    style: t.bodyLarge,
                    maxLines: _descriptionOpen ? null : 3,
                    overflow: _descriptionOpen ? null : TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _descriptionOpen = !_descriptionOpen),
                    style: TextButton.styleFrom(
                      foregroundColor: q.ink,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(QMetrics.minTap, QMetrics.minTap),
                      alignment: Alignment.centerLeft,
                      textStyle: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    child: Text(_descriptionOpen ? 'Less' : 'More'),
                  ),
                ),
                const SizedBox(height: QSpace.md),

                QGroupedSection(
                  children: [
                    for (final (title, body) in _disclosures) _DisclosureRow(title: title, body: body),
                  ],
                ),
                const SizedBox(height: QSpace.xxl),
                const QSectionHeader(title: 'Wear it with'),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: QSpace.margin),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: QSpace.sm,
                children: [for (final item in _related) _RelatedCard(item: item)],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: QSpace.xxl)),
        ],
      ),
    );
  }
}

// ── Media ───────────────────────────────────────────────────────────

class _Gallery extends StatelessWidget {
  const _Gallery({required this.controller, required this.page, required this.colorway, required this.onPageChanged});

  final PageController controller;
  final int page;
  final _Colorway colorway;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: q.surface2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label: '${colorway.name}, ${_angles[page]}, photo ${page + 1} of ${_angles.length}',
            image: true,
            child: PageView.builder(
              controller: controller,
              itemCount: _angles.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.fromLTRB(QSpace.xl, top + QSpace.xxxl, QSpace.xl, QSpace.xxl),
                child: CustomPaint(
                  painter: _SneakerPainter(
                    colorway: colorway,
                    line: q.ink,
                    flip: i == 1,
                    zoom: i == 2 ? 1.7 : 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: QSpace.md,
            bottom: QSpace.md,
            child: ExcludeSemantics(
              child: Row(
                spacing: QSpace.xxs + 2,
                children: [
                  for (var i = 0; i < _angles.length; i++)
                    AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : QMotion.fast,
                      width: QSpace.xs,
                      height: QSpace.xs,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == page ? q.ink : q.ink.withValues(alpha: 0.24),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A stylised side-profile low-top, drawn in the selected colourway (stand-in for product photography).
class _SneakerPainter extends CustomPainter {
  _SneakerPainter({required this.colorway, required this.line, this.flip = false, this.zoom = 1});

  final _Colorway colorway;
  final Color line;
  final bool flip;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawing space: 100 × 60 units.
    final scale = (size.width / 100).clamp(0.0, size.height / 60) * zoom;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    if (flip) canvas.scale(-1, 1);
    canvas.scale(scale);
    // Zoomed page frames the toe box.
    canvas.translate(zoom > 1 ? -72 : -50, zoom > 1 ? -40 : -36);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = line.withValues(alpha: 0.28);

    // Ground shadow.
    canvas.drawOval(Rect.fromCenter(center: const Offset(51, 57), width: 92, height: 4),
        Paint()..color = line.withValues(alpha: 0.08));

    // Upper.
    final upper = Path()
      ..moveTo(7, 46)
      ..lineTo(7, 26)
      ..quadraticBezierTo(7, 19, 14, 19)
      ..quadraticBezierTo(26, 20, 34, 26)
      ..lineTo(40, 15)
      ..quadraticBezierTo(44, 12, 48, 15)
      ..lineTo(72, 32)
      ..quadraticBezierTo(90, 35, 95, 41)
      ..quadraticBezierTo(97, 46, 93, 46)
      ..close();
    canvas.drawPath(upper, Paint()..color = colorway.upper);

    // Overlays: heel tab, side stripe, toe cap.
    final overlay = Paint()..color = colorway.overlay;
    canvas.drawPath(
      Path()
        ..moveTo(7, 46)
        ..lineTo(7, 26)
        ..quadraticBezierTo(7, 19, 14, 19)
        ..lineTo(18, 19.4)
        ..lineTo(16, 46)
        ..close(),
      overlay,
    );
    canvas.drawPath(
      Path()
        ..moveTo(22, 44)
        ..quadraticBezierTo(46, 40, 66, 30)
        ..lineTo(71, 33)
        ..quadraticBezierTo(50, 44, 27, 46)
        ..close(),
      overlay,
    );
    canvas.drawPath(
      Path()
        ..moveTo(77, 46)
        ..quadraticBezierTo(77, 37, 83, 34)
        ..quadraticBezierTo(92, 36.5, 95, 41)
        ..quadraticBezierTo(97, 46, 93, 46)
        ..close(),
      overlay,
    );
    canvas.drawPath(upper, outline);

    // Laces.
    final lace = Paint()..color = line.withValues(alpha: 0.35);
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(46 + i * 5.2, 18.5 + i * 3.4), 0.9, lace);
    }

    // Sole.
    final sole = Path()
      ..moveTo(6, 45.5)
      ..lineTo(92, 45.5)
      ..quadraticBezierTo(98.5, 45.5, 98, 50)
      ..quadraticBezierTo(97, 55, 89, 55)
      ..lineTo(10, 55)
      ..quadraticBezierTo(4, 55, 4, 50)
      ..quadraticBezierTo(4, 45.5, 6, 45.5)
      ..close();
    canvas.drawPath(sole, Paint()..color = colorway.sole);
    canvas.drawPath(sole, outline);
    canvas.drawLine(const Offset(8, 49), const Offset(95, 49), outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SneakerPainter old) =>
      old.colorway != colorway || old.line != line || old.flip != flip || old.zoom != zoom;
}

// ── Pieces ──────────────────────────────────────────────────────────

/// Nav glyph on a small surface disc so it reads over the media.
class _GlyphButton extends StatelessWidget {
  const _GlyphButton({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      iconSize: 20,
      style: IconButton.styleFrom(
        backgroundColor: q.surface.withValues(alpha: 0.92),
        foregroundColor: q.ink,
        fixedSize: const Size.square(40),
      ),
    );
  }
}

class _DisclosureRow extends StatefulWidget {
  const _DisclosureRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  State<_DisclosureRow> createState() => _DisclosureRowState();
}

class _DisclosureRowState extends State<_DisclosureRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.qText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _open = !_open);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: QMetrics.rowMinHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.sm),
                child: Row(
                  spacing: QSpace.sm,
                  children: [
                    Expanded(child: Text(widget.title, style: t.bodyLarge)),
                    ExcludeSemantics(
                      child: Icon(_open ? Icons.remove_rounded : Icons.add_rounded, size: 20, color: q.ink2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : QMotion.medium,
          curve: QMotion.curve,
          alignment: Alignment.topLeft,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(QSpace.md, 0, QSpace.md, QSpace.md),
                  child: Text(widget.body, style: t.bodyMedium),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.item});

  final _Related item;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.qText;
    return SizedBox(
      width: 156,
      child: MergeSemantics(
        child: QObjectCard(
          padding: EdgeInsets.zero,
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(
                  color: q.surface2,
                  child: Padding(
                    padding: const EdgeInsets.all(QSpace.sm),
                    child: ExcludeSemantics(
                      child: CustomPaint(painter: _SneakerPainter(colorway: item.colorway, line: q.ink)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(QSpace.sm, QSpace.sm, QSpace.sm, QSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(item.name, style: t.bodyMedium?.copyWith(color: q.ink)),
                    Text(_usd(item.price),
                        style: t.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeSheet extends StatelessWidget {
  const _SizeSheet({required this.selected, required this.colorway});

  final String? selected;
  final _Colorway colorway;

  @override
  Widget build(BuildContext context) {
    final t = context.qText;
    final available = [for (final s in _sizes) if (!colorway.soldOut.contains(s)) s];
    final soldOut = colorway.soldOut.map((s) => 'US $s').join(', ');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(QSpace.margin, 0, QSpace.margin, QSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: QSpace.sm,
        children: [
          Semantics(header: true, child: Text('Choose a size (US)', style: t.titleLarge)),
          Text('Runs half a size large — if you are between sizes, go down.', style: t.bodyMedium),
          const SizedBox(height: QSpace.xxs),
          Wrap(
            spacing: QSpace.xs,
            runSpacing: QSpace.xs,
            children: [
              for (final s in available)
                QChip(label: 'US $s', selected: s == selected, onTap: () => Navigator.pop(context, s)),
            ],
          ),
          if (colorway.soldOut.isNotEmpty)
            Text('Sold out in ${colorway.name}: $soldOut.', style: t.bodySmall),
        ],
      ),
    );
  }
}
