// Detail archetype — sneaker product page.
// Job: decide on this shoe and add it to the bag. Focal: full-bleed product media + title/price block.
// Primary: "Add to bag · $138.00" pinned in a BottomActionBar. Secondary: save/share as nav glyphs.
// Cut: "Buy now" button, inline review list, size grid on the page (size lives behind a row + sheet).

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
      home: const _ProductDetailScreen(),
    );
  }
}

// ── Sample data ─────────────────────────────────────────────────────

const _brand = 'Halden';
const _name = 'Court 74 suede low-top';
const _price = r'$138.00';
const _rating = '4.7';
const _reviewCount = '318 reviews';

const _colorways = ['Bone / gum', 'Black / gum', 'Sand / off-white', 'Forest / gum'];

const _sizes = [
  'US 7', 'US 7.5', 'US 8', 'US 8.5', 'US 9', 'US 9.5', //
  'US 10', 'US 10.5', 'US 11', 'US 11.5', 'US 12',
];

const _description =
    'Cut from our 1974 court pattern, the Court 74 swaps smooth leather for a brushed suede upper '
    'that softens with every wear. A cork-blend footbed, a natural gum cupsole and waxed cotton '
    'laces keep it grounded — and the stitched sole means a cobbler can resole it when the tread '
    'wears thin.';

const _disclosures = [
  (
    'Materials & care',
    'Upper: brushed cow suede from an LWG Gold-rated tannery. Lining: recycled polyester mesh. '
        'Outsole: natural gum rubber. Brush off dry dirt with a suede brush; don\'t machine wash.'
  ),
  (
    'Size & fit',
    'Runs true to size for 82% of reviewers. Between sizes? Go half a size up. Medium width with a '
        'roomy toe box.'
  ),
  (
    'Shipping & returns',
    'Free standard delivery in 2–4 business days. Free returns within 30 days if unworn and in the '
        'original box.'
  ),
];

class _Related {
  const _Related(this.name, this.price, {this.highTop = false, this.mirrored = false});
  final String name;
  final String price;
  final bool highTop;
  final bool mirrored;
}

const _related = [
  _Related('Court 74 canvas', r'$96.00', mirrored: true),
  _Related('Court 74 suede high-top', r'$152.00', highTop: true),
  _Related('Harbor deck shoe', r'$118.00'),
  _Related('Court 74 leather', r'$128.00', mirrored: true),
];

// ── Screen ──────────────────────────────────────────────────────────

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen();

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  final _pages = PageController();
  int _page = 0;
  bool _barOpaque = false;
  bool _saved = false;
  bool _descriptionOpen = false;
  String _colorway = _colorways.first;
  String _size = 'US 10';

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n, double threshold) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final opaque = n.metrics.pixels > threshold;
    if (opaque != _barOpaque) setState(() => _barOpaque = opaque);
    return false;
  }

  void _toggleSaved() {
    HapticFeedback.selectionClick();
    setState(() => _saved = !_saved);
    showToast(context, _saved ? 'Saved to favorites' : 'Removed from favorites');
  }

  void _share() {
    showToast(context, 'Link copied');
  }

  void _addToBag() {
    HapticFeedback.mediumImpact();
    showToast(context, 'Added $_size in $_colorway to your bag', undoLabel: 'Undo', onUndo: () {});
  }

  Future<void> _pickColorway() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SheetBody(
        title: 'Color',
        child: GroupedSection(
          children: [
            for (final c in _colorways)
              ListRow(
                title: c,
                kind: RowKind.action,
                trailing: c == _colorway ? Icon(Icons.check_rounded, size: 20, color: context.q.ink) : null,
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _colorway = picked);
  }

  Future<void> _pickSize() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SheetBody(
        title: 'Size',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.md,
          children: [
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: [
                for (final s in _sizes)
                  QuietChip(label: s, selected: s == _size, onTap: () => Navigator.pop(context, s)),
              ],
            ),
            Text('US 12.5 and 13 are sold out. Runs true to size.', style: context.t.bodySmall),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _size = picked);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    final mediaHeight = MediaQuery.sizeOf(context).width;
    final threshold = mediaHeight - kToolbarHeight - MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _barOpaque ? q.canvas : Colors.transparent,
        shape: _barOpaque ? Border(bottom: BorderSide(color: q.hairline, width: 0.5)) : null,
        title: AnimatedOpacity(
          opacity: _barOpaque ? 1 : 0,
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.fast,
          child: Text(_name, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        actions: [
          _NavGlyph(
            icon: _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            tooltip: _saved ? 'Remove from favorites' : 'Save to favorites',
            onPressed: _toggleSaved,
          ),
          _NavGlyph(icon: Icons.ios_share_rounded, tooltip: 'Share product', onPressed: _share),
          const SizedBox(width: Space.xs),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        children: [PrimaryButton(label: 'Add to bag · $_price', onPressed: _addToBag)],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onScroll(n, threshold),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Gallery(
                controller: _pages,
                page: _page,
                colorway: _colorway,
                onPageChanged: (i) => setState(() => _page = i),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Space.margin, Space.xl, Space.margin, Space.xxl),
              sliver: SliverList.list(
                children: [
                  // Title block: what it is, how much, one proof point.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.xxs,
                    children: [
                      Text(_brand, style: t.bodyMedium),
                      Semantics(header: true, child: Text(_name, style: t.titleLarge)),
                      const SizedBox(height: Space.xxs),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Space.sm,
                        runSpacing: Space.xxs,
                        children: [
                          Text(_price,
                              style: t.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                          Text.rich(
                            TextSpan(children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: Space.xxs),
                                  child: Icon(Icons.star_rounded, size: 16, color: q.accent),
                                ),
                              ),
                              TextSpan(text: '$_rating · $_reviewCount'),
                            ]),
                            style: t.bodyMedium,
                            semanticsLabel: 'Rated $_rating out of 5, $_reviewCount',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xl),

                  // Options as rows that open sheets.
                  GroupedSection(
                    children: [
                      ListRow(title: 'Color', value: _colorway, onTap: _pickColorway),
                      ListRow(title: 'Size', value: _size, onTap: _pickSize),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Space.xs,
                      children: [
                        _Footnote(icon: Icons.inventory_2_rounded, text: 'Only 3 left in $_size'),
                        const _Footnote(
                          icon: Icons.local_shipping_rounded,
                          text: 'Free delivery by Fri, Oct 16 · Free 30-day returns',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.xxl),

                  // Description: 3-line preview + More.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      TertiaryButton(
                        label: _descriptionOpen ? 'Show less' : 'Read more',
                        onPressed: () => setState(() => _descriptionOpen = !_descriptionOpen),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.md),

                  // Long content behind disclosure.
                  GroupedSection(
                    children: [for (final d in _disclosures) _Disclosure(title: d.$1, body: d.$2)],
                  ),
                  const SizedBox(height: Space.xxl),

                  const SectionHeader(title: 'You might also like'),
                  const SizedBox(height: Space.sm),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: _RelatedCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: Space.xxl)),
          ],
        ),
      ),
    );
  }
}

// ── Pieces ──────────────────────────────────────────────────────────

/// Nav-bar glyph on a 36pt surface circle (stays legible over media), 48pt tap target.
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
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: q.surface,
        foregroundColor: q.ink,
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.controller, required this.page, required this.colorway, required this.onPageChanged});

  final PageController controller;
  final int page;
  final String colorway;
  final ValueChanged<int> onPageChanged;

  static const _views = ['side view', 'inside view', 'toe detail'];

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return AspectRatio(
      aspectRatio: 1,
      child: ColoredBox(
        color: q.surface2,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: _views.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) => Semantics(
                image: true,
                label: '$_name in ${colorway.toLowerCase()}, ${_views[i]}',
                child: SafeArea(
                  bottom: false,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SneakerPainter(
                      upper: q.surface,
                      line: q.ink,
                      midsole: q.canvas,
                      sole: q.ink2,
                      mirrored: i == 1,
                      zoom: i == 2 ? 1.7 : 1,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: Semantics(
                  label: 'Photo ${page + 1} of ${_views.length}',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Space.xxs,
                    children: [
                      for (var i = 0; i < _views.length; i++)
                        AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.fast,
                          width: i == page ? Space.lg : Space.xs,
                          height: Space.xs,
                          decoration: ShapeDecoration(
                            color: i == page ? q.ink : q.ink3,
                            shape: const StadiumBorder(),
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

class _Footnote extends StatelessWidget {
  const _Footnote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.xs,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 16, color: q.ink2)),
        Expanded(child: Text(text, style: context.t.bodySmall)),
      ],
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.margin, 0, Space.margin, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.md,
        children: [
          Semantics(header: true, child: Text(title, style: context.t.titleLarge)),
          child,
        ],
      ),
    );
  }
}

/// Accordion row: collapsed by default, + / − glyph, body in subhead.
class _Disclosure extends StatefulWidget {
  const _Disclosure({required this.title, required this.body});

  final String title;
  final String body;

  @override
  State<_Disclosure> createState() => _DisclosureState();
}

class _DisclosureState extends State<_Disclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return Semantics(
      button: true,
      expanded: _open,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
            child: AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.medium,
              curve: Motion.curve,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Space.xs,
                children: [
                  Row(
                    spacing: Space.sm,
                    children: [
                      Expanded(child: Text(widget.title, style: t.bodyLarge)),
                      ExcludeSemantics(
                        child: Icon(_open ? Icons.remove_rounded : Icons.add_rounded, size: 20, color: q.ink2),
                      ),
                    ],
                  ),
                  if (_open) Text(widget.body, style: t.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedCarousel extends StatelessWidget {
  const _RelatedCarousel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Space.margin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.sm,
        children: [for (final r in _related) _RelatedTile(item: r)],
      ),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.item});

  final _Related item;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final t = context.t;
    return SizedBox(
      width: 152,
      child: MergeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.l),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.xxs,
            children: [
              ClipRSuperellipse(
                borderRadius: BorderRadius.circular(Radii.l),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ColoredBox(
                    color: q.surface2,
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: _SneakerPainter(
                          upper: q.surface,
                          line: q.ink,
                          midsole: q.canvas,
                          sole: q.ink2,
                          highTop: item.highTop,
                          mirrored: item.mirrored,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Space.xxs),
              Text(item.name, style: t.bodyMedium?.copyWith(color: q.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(item.price, style: t.bodySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Product illustration (stands in for photography; colors come from roles) ──

class _SneakerPainter extends CustomPainter {
  _SneakerPainter({
    required this.upper,
    required this.line,
    required this.midsole,
    required this.sole,
    this.highTop = false,
    this.mirrored = false,
    this.zoom = 1,
  });

  final Color upper;
  final Color line;
  final Color midsole;
  final Color sole;
  final bool highTop;
  final bool mirrored;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    if (zoom != 1) {
      // Zoom toward the toe box.
      final focus = Offset(size.width * 0.78, size.height * 0.6);
      canvas.translate(focus.dx, focus.dy);
      canvas.scale(zoom);
      canvas.translate(-focus.dx, -focus.dy);
    }

    final w = size.width * 0.8;
    final h = w * 0.5;
    final ox = (size.width - w) / 2;
    final oy = (size.height - h) / 2 + h * 0.08;
    Offset p(double x, double y) => Offset(ox + x * w, oy + y * h);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.007)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = line;
    Paint fill(Color c) => Paint()..color = c;

    // Outsole + midsole.
    final outsole = RRect.fromRectAndRadius(Rect.fromPoints(p(0.03, 0.80), p(0.98, 0.92)), Radius.circular(h * 0.05));
    canvas.drawRRect(outsole, fill(sole));
    canvas.drawRRect(outsole, stroke);
    final mid = RRect.fromRectAndRadius(Rect.fromPoints(p(0.03, 0.69), p(0.98, 0.81)), Radius.circular(h * 0.04));
    canvas.drawRRect(mid, fill(midsole));
    canvas.drawRRect(mid, stroke);

    // Upper.
    final body = Path()..moveTo(p(0.05, 0.69).dx, p(0.05, 0.69).dy);
    void lineTo(double x, double y) => body.lineTo(p(x, y).dx, p(x, y).dy);
    void quad(double cx, double cy, double x, double y) =>
        body.quadraticBezierTo(p(cx, cy).dx, p(cx, cy).dy, p(x, y).dx, p(x, y).dy);
    final Offset laceStart;
    if (highTop) {
      lineTo(0.06, 0.12);
      quad(0.06, 0.02, 0.16, 0.02);
      lineTo(0.30, 0.04);
      quad(0.34, -0.06, 0.39, 0.02);
      lineTo(0.43, 0.14);
      laceStart = const Offset(0.43, 0.16);
    } else {
      lineTo(0.04, 0.46);
      quad(0.04, 0.30, 0.15, 0.30);
      quad(0.26, 0.40, 0.36, 0.30);
      lineTo(0.40, 0.17);
      quad(0.44, 0.12, 0.48, 0.19);
      laceStart = const Offset(0.47, 0.22);
    }
    lineTo(0.74, 0.46);
    quad(0.93, 0.50, 0.97, 0.62);
    lineTo(0.98, 0.69);
    body.close();
    canvas.drawPath(body, fill(upper));
    canvas.drawPath(body, stroke);

    // Toe cap, heel counter, side panel.
    canvas.drawPath(
        Path()
          ..moveTo(p(0.74, 0.46).dx, p(0.74, 0.46).dy)
          ..quadraticBezierTo(p(0.69, 0.60).dx, p(0.69, 0.60).dy, p(0.71, 0.69).dx, p(0.71, 0.69).dy),
        stroke);
    canvas.drawPath(
        Path()
          ..moveTo(p(0.04, 0.50).dx, p(0.04, 0.50).dy)
          ..quadraticBezierTo(p(0.17, 0.48).dx, p(0.17, 0.48).dy, p(0.21, 0.69).dx, p(0.21, 0.69).dy),
        stroke);
    canvas.drawPath(
        Path()
          ..moveTo(p(0.27, 0.66).dx, p(0.27, 0.66).dy)
          ..quadraticBezierTo(p(0.38, 0.44).dx, p(0.38, 0.44).dy, p(0.60, 0.44).dx, p(0.60, 0.44).dy),
        stroke);

    // Laces: short ticks across the lace line.
    final a = p(laceStart.dx, laceStart.dy);
    final b = p(0.70, 0.44);
    final dir = (b - a) / (b - a).distance;
    final normal = Offset(-dir.dy, dir.dx) * (w * 0.03);
    for (var i = 0; i < 5; i++) {
      final c = Offset.lerp(a, b, i / 4)!;
      canvas.drawLine(c - normal, c + normal, stroke);
      canvas.drawCircle(c - normal, w * 0.006, fill(line));
    }

    // Outsole tread marks.
    for (var i = 0; i < 12; i++) {
      final x = 0.08 + i * 0.075;
      canvas.drawLine(p(x, 0.84), p(x, 0.89), stroke..color = midsole);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SneakerPainter old) =>
      old.upper != upper ||
      old.line != line ||
      old.midsole != midsole ||
      old.sole != sole ||
      old.highTop != highTop ||
      old.mirrored != mirrored ||
      old.zoom != zoom;
}
