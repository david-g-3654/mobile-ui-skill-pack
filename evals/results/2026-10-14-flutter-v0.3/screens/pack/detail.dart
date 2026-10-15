// Detail — sneaker product page.
// Job: pick a size and add the pair to the bag. Focal: full-bleed media + title/price block.
// Primary: pinned "Add to bag · price". Secondary actions (save, share) are nav glyphs.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_eval/pack/components.dart';
import 'package:fl_eval/pack/theme.dart';

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

class _Colorway {
  const _Colorway({
    required this.name,
    required this.upper,
    required this.overlay,
    required this.midsole,
    required this.outsole,
    required this.lowStockSizes,
  });

  final String name;
  final Color upper;
  final Color overlay;
  final Color midsole;
  final Color outsole;
  final Set<String> lowStockSizes;
}

const _colorways = <_Colorway>[
  _Colorway(
    name: 'Castlerock grey',
    upper: Color(0xFFA2A5A7), // mobile-ui: content-color
    overlay: Color(0xFF6C7072), // mobile-ui: content-color
    midsole: Color(0xFFF2F0EA), // mobile-ui: content-color
    outsole: Color(0xFF3B3B3B), // mobile-ui: content-color
    lowStockSizes: {'10', '10.5'},
  ),
  _Colorway(
    name: 'Harbour navy',
    upper: Color(0xFF34435F), // mobile-ui: content-color
    overlay: Color(0xFF1D2739), // mobile-ui: content-color
    midsole: Color(0xFFECE9E1), // mobile-ui: content-color
    outsole: Color(0xFF2A2A2A), // mobile-ui: content-color
    lowStockSizes: {'9'},
  ),
  _Colorway(
    name: 'Sea salt',
    upper: Color(0xFFE8E2D4), // mobile-ui: content-color
    overlay: Color(0xFFC4B89E), // mobile-ui: content-color
    midsole: Color(0xFFF8F6F0), // mobile-ui: content-color
    outsole: Color(0xFF8A785B), // mobile-ui: content-color
    lowStockSizes: {'11', '11.5', '12'},
  ),
  _Colorway(
    name: 'Black suede',
    upper: Color(0xFF2A2A2A), // mobile-ui: content-color
    overlay: Color(0xFF151515), // mobile-ui: content-color
    midsole: Color(0xFFEDEDEA), // mobile-ui: content-color
    outsole: Color(0xFF1A1A1A), // mobile-ui: content-color
    lowStockSizes: {},
  ),
];

const _sizes = ['7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '13'];
const _soldOut = {'7', '13'};

class _Related {
  const _Related(this.name, this.price, this.colorway);
  final String name;
  final String price;
  final int colorway;
}

const _related = <_Related>[
  _Related('Field 98 Mid', r'$209.99', 1),
  _Related('Trail Two GTX', r'$149.00', 3),
  _Related('Court Low', r'$112.50', 2),
  _Related('Racer 5', r'$134.00', 0),
];

class _Section {
  const _Section(this.title, this.body);
  final String title;
  final String body;
}

const _sections = <_Section>[
  _Section(
    'Details',
    'Pigskin suede and breathable mesh upper\n'
        'Dual-density foam midsole, 12 mm drop\n'
        'Grippy rubber outsole with a cupsole heel\n'
        'Weight 312 g (US 9) · Style HF98-GRY',
  ),
  _Section(
    'Size & fit',
    'Runs true to size with a medium (D) width. Between sizes? Go half a size up — '
        'the toe box is snug for the first week while the suede gives.',
  ),
  _Section(
    'Delivery & returns',
    'Free standard delivery, arriving Fri, Oct 17. Express by Wed, Oct 15 for \$12.00. '
        'Return unworn pairs within 30 days for free.',
  ),
];

const _price = r'$184.99';
const _description =
    'The Field 98 keeps the 1998 trail-runner shape — the stacked heel, the low-slung toe — '
    'but swaps the heavy rubber for a lighter, grippier compound. A dual-density midsole '
    'makes it soft enough for a full day on your feet, and the suede is pre-treated so a '
    'surprise shower won\'t stain it.';

// ── Screen ──────────────────────────────────────────────────────────

class _SneakerDetailScreen extends StatefulWidget {
  const _SneakerDetailScreen();

  @override
  State<_SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends State<_SneakerDetailScreen> {
  int _colorway = 0;
  String? _size;
  bool _saved = false;
  bool _descriptionOpen = false;
  final Set<int> _openSections = {};

  _Colorway get _current => _colorways[_colorway];

  Future<void> _pickSize() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SizeSheet(selected: _size, lowStock: _current.lowStockSizes),
    );
    if (picked != null && mounted) setState(() => _size = picked);
  }

  void _addToBag() {
    if (_size == null) {
      _pickSize();
      return;
    }
    HapticFeedback.mediumImpact();
    showToast(context, 'Added to bag · US $_size');
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    final width = MediaQuery.sizeOf(context).width;
    final mediaHeight = math.min(width * 0.92, 440.0);
    final size = _size;
    final lowStock = size != null && _current.lowStockSizes.contains(size);

    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        children: [PrimaryButton(label: 'Add to bag · $_price', onPressed: _addToBag)],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: mediaHeight,
            backgroundColor: q.canvas,
            automaticallyImplyLeading: false,
            leading: Center(
              child: _NavGlyph(
                icon: Theme.of(context).platform == TargetPlatform.iOS
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              _NavGlyph(
                icon: _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                tooltip: _saved ? 'Remove from saved' : 'Save to wishlist',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _saved = !_saved);
                },
              ),
              const SizedBox(width: Space.xs),
              _NavGlyph(
                icon: Icons.ios_share_rounded,
                tooltip: 'Share product',
                onPressed: () => showToast(context, 'Link copied'),
              ),
              const SizedBox(width: Space.margin),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _Gallery(colorway: _current),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.margin, Space.xl, Space.margin, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title block: what it is, how much, one proof point.
                  Text('Halden · Trail heritage'.toUpperCase(), style: t.labelSmall),
                  const SizedBox(height: Space.xxs),
                  Semantics(
                    header: true,
                    child: Text('Field 98 suede runner', style: t.titleLarge),
                  ),
                  const SizedBox(height: Space.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Space.sm,
                    runSpacing: Space.xxs,
                    children: [
                      Text(_price,
                          style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                      MergeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Space.xxs,
                          children: [
                            ExcludeSemantics(child: Icon(Icons.star_rounded, size: 18, color: q.accent)),
                            Flexible(child: Text('4.7 · 1,284 reviews', style: t.bodyMedium)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xxl),

                  // Colour — inline swatches (4 options).
                  Row(
                    spacing: Space.xs,
                    children: [
                      Text('Colour', style: t.bodyLarge),
                      Flexible(child: Text(_current.name, style: t.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: Space.xxs),
                  Transform.translate(
                    offset: const Offset(-Space.xs, 0),
                    child: Wrap(
                      children: [
                        for (var i = 0; i < _colorways.length; i++)
                          Swatch(
                            name: _colorways[i].name,
                            color: _colorways[i].upper,
                            selected: i == _colorway,
                            onTap: () => setState(() => _colorway = i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.sm),

                  // Size — 12 options, so it opens a sheet.
                  GroupedSection(
                    children: [
                      ListRow(
                        title: 'Size',
                        value: size == null ? 'Select' : 'US $size',
                        onTap: _pickSize,
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  _InfoLine(
                    icon: lowStock ? Icons.inventory_2_outlined : Icons.local_shipping_outlined,
                    text: lowStock
                        ? 'Only 2 left in US $size'
                        : 'Free delivery by Fri, Oct 17 · Free 30-day returns',
                    color: lowStock ? q.warning : null,
                  ),
                  const SizedBox(height: Space.xxl),

                  // Description — 3-line preview.
                  AnimatedSize(
                    duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
                    curve: Motion.curve,
                    alignment: Alignment.topCenter,
                    child: Text(
                      _description,
                      style: t.bodyLarge,
                      maxLines: _descriptionOpen ? null : 3,
                      overflow: _descriptionOpen ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-Space.sm, 0),
                    child: TertiaryButton(
                      label: _descriptionOpen ? 'Show less' : 'Read more',
                      onPressed: () => setState(() => _descriptionOpen = !_descriptionOpen),
                    ),
                  ),
                  const SizedBox(height: Space.md),

                  // Long content behind disclosure.
                  const Divider(),
                  for (var i = 0; i < _sections.length; i++) ...[
                    _Disclosure(
                      section: _sections[i],
                      open: _openSections.contains(i),
                      onToggle: () => setState(() {
                        if (!_openSections.remove(i)) _openSections.add(i);
                      }),
                    ),
                    const Divider(),
                  ],
                  const SizedBox(height: Space.xxl),
                  const SectionHeader(title: 'You might also like'),
                  const SizedBox(height: Space.sm),
                ],
              ),
            ),
          ),
          // Related carousel: full-bleed, peeking.
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xxl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Space.sm,
                children: [
                  for (final r in _related)
                    _RelatedTile(item: r, width: math.min(width * 0.42, 200.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pieces ──────────────────────────────────────────────────────────

/// 36pt surface circle glyph over the media, 48pt tap target.
class _NavGlyph extends StatelessWidget {
  const _NavGlyph({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: Metrics.minTap, height: Metrics.minTap),
      padding: EdgeInsets.zero,
      icon: DecoratedBox(
        decoration: ShapeDecoration(color: q.surface.withValues(alpha: 0.88), shape: const CircleBorder()),
        child: SizedBox.square(dimension: 36, child: Icon(icon, size: 20, color: q.ink)),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.colorway});

  final _Colorway colorway;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  static const _views = ['Side view', 'Inside view', 'Heel detail'];
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ColoredBox(
      color: q.surface2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: _views.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Semantics(
              image: true,
              label: '${_views[i]}, ${widget.colorway.name}',
              child: Padding(
                padding: const EdgeInsets.only(top: Space.xxxl),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scaleByDouble(i == 1 ? -1.0 : 1.0, 1.0, 1.0, 1.0)
                    ..scaleByDouble(i == 2 ? 1.35 : 1.0, i == 2 ? 1.35 : 1.0, 1.0, 1.0),
                  child: CustomPaint(
                    painter: _SneakerPainter(widget.colorway, shadow: q.ink.withValues(alpha: 0.08)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: Space.md,
            child: Semantics(
              label: 'Image ${_page + 1} of ${_views.length}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Space.xs - 2,
                children: [
                  for (var i = 0; i < _views.length; i++)
                    AnimatedContainer(
                      duration: Motion.fast,
                      width: i == _page ? 16 : 6,
                      height: 6,
                      decoration: ShapeDecoration(
                        color: i == _page ? q.ink : q.ink3,
                        shape: const StadiumBorder(),
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

/// Product "photography": a stylised sneaker drawn in the selected colourway.
class _SneakerPainter extends CustomPainter {
  _SneakerPainter(this.c, {required this.shadow});

  final _Colorway c;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final sw = math.min(size.width * 0.78, size.height * 1.5);
    final l = (size.width - sw) / 2;
    final r = l + sw;
    final base = size.height * 0.5 + sw * 0.16;
    double x(double f) => l + sw * f;
    double y(double f) => base - sw * f;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, base + sw * 0.035), width: sw * 0.95, height: sw * 0.06),
      Paint()..color = shadow,
    );

    // Upper.
    final upper = Path()
      ..moveTo(x(0.03), y(0.06))
      ..quadraticBezierTo(x(-0.02), y(0.14), x(0.13), y(0.18))
      ..quadraticBezierTo(x(0.36), y(0.22), x(0.52), y(0.37))
      ..lineTo(x(0.6), y(0.43))
      ..quadraticBezierTo(x(0.72), y(0.35), x(0.87), y(0.41))
      ..quadraticBezierTo(r + sw * 0.015, y(0.3), r - sw * 0.01, y(0.06))
      ..close();
    canvas.drawPath(upper, Paint()..color = c.upper);

    // Suede overlays: toe cap and heel counter.
    final toe = Path()
      ..moveTo(x(0.03), y(0.06))
      ..quadraticBezierTo(x(-0.02), y(0.14), x(0.13), y(0.18))
      ..quadraticBezierTo(x(0.22), y(0.19), x(0.27), y(0.13))
      ..quadraticBezierTo(x(0.25), y(0.08), x(0.2), y(0.06))
      ..close();
    final heel = Path()
      ..moveTo(x(0.8), y(0.06))
      ..quadraticBezierTo(x(0.76), y(0.22), x(0.86), y(0.33))
      ..quadraticBezierTo(r + sw * 0.01, y(0.28), r - sw * 0.01, y(0.06))
      ..close();
    final overlay = Paint()..color = c.overlay;
    canvas.drawPath(toe, overlay);
    canvas.drawPath(heel, overlay);

    // Side stripe.
    canvas.drawPath(
      Path()
        ..moveTo(x(0.36), y(0.08))
        ..quadraticBezierTo(x(0.52), y(0.12), x(0.7), y(0.31)),
      Paint()
        ..color = c.overlay
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 0.04
        ..strokeCap = StrokeCap.round,
    );

    // Laces.
    final lace = Paint()
      ..color = c.midsole
      ..strokeWidth = sw * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final f = 0.3 + i * 0.065;
      final p = Offset(x(f), y(0.2 + i * 0.045));
      canvas.drawLine(p, p.translate(sw * 0.035, -sw * 0.035), lace);
    }

    // Outline.
    canvas.drawPath(
      upper,
      Paint()
        ..color = c.overlay
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Midsole + outsole.
    canvas.drawRRect(
      RRect.fromLTRBR(x(0.0), y(0.075), r, base, Radius.circular(sw * 0.035)),
      Paint()..color = c.midsole,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(x(0.01), base - sw * 0.012, r - sw * 0.01, base + sw * 0.016, Radius.circular(sw * 0.01)),
      Paint()..color = c.outsole,
    );
  }

  @override
  bool shouldRepaint(_SneakerPainter old) => old.c != c || old.shadow != shadow;
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.q.ink2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.xs,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 18, color: tint)),
        Expanded(child: Text(text, style: context.t.bodyMedium?.copyWith(color: tint))),
      ],
    );
  }
}

class _Disclosure extends StatelessWidget {
  const _Disclosure({required this.section, required this.open, required this.onToggle});

  final _Section section;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: open,
          child: InkWell(
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Metrics.rowMinHeight),
              child: Row(
                children: [
                  Expanded(child: Text(section.title, style: t.bodyLarge)),
                  ExcludeSemantics(
                    child: Icon(open ? Icons.remove_rounded : Icons.add_rounded, size: 20, color: q.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
          curve: Motion.curve,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(bottom: Space.md),
                  child: Text(section.body, style: t.bodyMedium),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.item, required this.width});

  final _Related item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return SizedBox(
      width: width,
      child: MergeSemantics(
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(Radii.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.xxs,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Material(
                  color: q.surface,
                  shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(Radii.m)),
                  child: CustomPaint(
                    painter: _SneakerPainter(_colorways[item.colorway], shadow: q.ink.withValues(alpha: 0.06)),
                  ),
                ),
              ),
              const SizedBox(height: Space.xxs),
              Text(item.name, style: t.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(item.price, style: t.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeSheet extends StatelessWidget {
  const _SizeSheet({required this.selected, required this.lowStock});

  final String? selected;
  final Set<String> lowStock;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(header: true, child: Text('Select size', style: t.titleLarge)),
          const SizedBox(height: Space.xxs),
          Text("US men's · Runs true to size", style: t.bodyMedium),
          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final s in _sizes)
                if (_soldOut.contains(s))
                  Semantics(
                    label: 'US $s, sold out',
                    excludeSemantics: true,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 36, minWidth: 56),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: StadiumBorder(side: BorderSide(color: q.hairline)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                          child: Text(
                            s,
                            textAlign: TextAlign.center,
                            style: t.bodyMedium?.copyWith(color: q.ink3, decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 56),
                    child: QuietChip(
                      label: s,
                      selected: s == selected,
                      onTap: () => Navigator.pop(context, s),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            lowStock.isEmpty
                ? 'Sizes 7 and 13 are sold out in this colour.'
                : 'Low stock in US ${lowStock.join(', ')}. Sizes 7 and 13 are sold out.',
            style: t.bodyMedium,
          ),
        ],
      ),
    );
  }
}
