import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailEvalApp extends StatelessWidget {
  const DetailEvalApp({super.key});

  static const Color _seed = Color(0xFFE4572E);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: base.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _ProductDetailScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _Colorway {
  const _Colorway(this.name, this.upper, this.accent, this.sole, this.backdrop);
  final String name;
  final Color upper;
  final Color accent;
  final Color sole;
  final Color backdrop;
}

class _Review {
  const _Review(this.author, this.rating, this.date, this.title, this.body,
      this.fit);
  final String author;
  final int rating;
  final String date;
  final String title;
  final String body;
  final String fit;
}

const _colorways = <_Colorway>[
  _Colorway('Ember / Sail', Color(0xFFF4EFE6), Color(0xFFE4572E),
      Color(0xFFF9F6F0), Color(0xFFFBE3D6)),
  _Colorway('Midnight Navy', Color(0xFF1F2A44), Color(0xFF7FB7FF),
      Color(0xFFEDEDED), Color(0xFFDCE6F5)),
  _Colorway('Sage / Gum', Color(0xFFA9BFA3), Color(0xFF2F4A35),
      Color(0xFFC79A5B), Color(0xFFE3ECDF)),
  _Colorway('Triple Black', Color(0xFF26262A), Color(0xFF55555C),
      Color(0xFF1A1A1D), Color(0xFFE2E2E6)),
];

const _sizes = <double>[7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 13];
const _soldOut = <double>[7, 11.5];
const _lowStock = <double>[8.5, 12];

const _reviews = <_Review>[
  _Review(
    'Maya R.',
    5,
    'Sep 28, 2026',
    'Cloud-like but still stable',
    'Wore them for a full day at a conference and my feet never ached. '
        'The foam has real bounce and the heel lockdown is excellent.',
    'True to size',
  ),
  _Review(
    'Jordan K.',
    4,
    'Sep 14, 2026',
    'Great daily trainer',
    'Comfortable out of the box. Toe box is a touch narrow for me, so '
        'I would go half a size up if you have wide feet.',
    'Runs slightly small',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen();

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  int _colorIndex = 0;
  double? _size = 9.5;
  bool _favorite = false;
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _Colorway get _cw => _colorways[_colorIndex];

  void _addToBag() {
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Added Aero Glide 3 · ${_cw.name} · US ${_fmt(_size!)}'),
        action: SnackBarAction(label: 'View bag', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final backdrop = dark
        ? Color.alphaBlend(
            _cw.backdrop.withValues(alpha: 0.10), scheme.surfaceContainerHigh)
        : _cw.backdrop;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 380,
            backgroundColor: backdrop,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _CircleAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              _CircleAction(
                icon: Icons.ios_share_rounded,
                tooltip: 'Share',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _CircleAction(
                icon: _favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                tooltip: _favorite ? 'Remove from favorites' : 'Add to favorites',
                color: _favorite ? scheme.primary : null,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _favorite = !_favorite);
                },
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _Gallery(
                controller: _pageController,
                colorway: _cw,
                backdrop: backdrop,
                page: _page,
                onPageChanged: (p) => setState(() => _page = p),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        price: r'$145',
        size: _size,
        onAdd: _size == null ? null : _addToBag,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'STRIDE RUNNING',
                style: text.labelLarge?.copyWith(
                  color: scheme.primary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _Tag(label: 'New season', color: scheme.tertiaryContainer,
                  onColor: scheme.onTertiaryContainer),
            ],
          ),
          const SizedBox(height: 6),
          Text('Aero Glide 3', style: text.headlineSmall),
          const SizedBox(height: 2),
          Text("Men's road running shoe",
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(r'$145',
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Text(
                    r'$170',
                    style: text.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('15% off',
                      style: text.labelLarge?.copyWith(
                          color: scheme.primary, fontWeight: FontWeight.w700)),
                ],
              ),
              Semantics(
                label: 'Rated 4.7 out of 5 from 1,284 reviews',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 20, color: Color(0xFFF5A524)),
                    const SizedBox(width: 4),
                    Text('4.7', style: text.titleSmall),
                    const SizedBox(width: 4),
                    Text('(1,284)',
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Color', trailing: _cw.name),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < _colorways.length; i++)
                _ColorSwatch(
                  colorway: _colorways[i],
                  selected: i == _colorIndex,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _colorIndex = i);
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Size (US)',
            trailingWidget: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.straighten_rounded, size: 18),
              label: const Text('Size guide'),
            ),
          ),
          const SizedBox(height: 8),
          _SizeGrid(
            selected: _size,
            onSelected: (s) {
              HapticFeedback.selectionClick();
              setState(() => _size = s);
            },
          ),
          const SizedBox(height: 12),
          _InfoBanner(
            icon: Icons.info_outline_rounded,
            text: 'Fits true to size. Wide feet? Consider going up half a size.',
          ),
          const SizedBox(height: 28),
          Text('About this shoe', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Built for daily miles, the Aero Glide 3 pairs a responsive '
            'nitrogen-infused foam midsole with an engineered mesh upper that '
            'breathes where you need it and holds where it counts. A rockered '
            'geometry keeps transitions smooth from easy jogs to tempo days.',
            style: text.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          const _SpecGrid(),
          const SizedBox(height: 16),
          Card.outlined(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Free delivery',
                  subtitle: 'Arrives Fri, Oct 18 – Mon, Oct 21',
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                const _InfoTile(
                  icon: Icons.storefront_outlined,
                  title: 'Pick up in store',
                  subtitle: 'In stock at SoHo, Broadway · 0.8 mi',
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                const _InfoTile(
                  icon: Icons.assignment_return_outlined,
                  title: '60-day free returns',
                  subtitle: 'Even if you have run in them',
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: 'Reviews',
            trailingWidget: TextButton(
              onPressed: () {},
              child: const Text('See all 1,284'),
            ),
          ),
          const SizedBox(height: 4),
          const _RatingSummary(),
          const SizedBox(height: 16),
          for (final r in _reviews) ...[
            _ReviewCard(review: r),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

String _fmt(double s) =>
    s == s.roundToDouble() ? s.toStringAsFixed(0) : s.toStringAsFixed(1);

// ---------------------------------------------------------------------------
// Gallery
// ---------------------------------------------------------------------------

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.controller,
    required this.colorway,
    required this.backdrop,
    required this.page,
    required this.onPageChanged,
  });

  final PageController controller;
  final _Colorway colorway;
  final Color backdrop;
  final int page;
  final ValueChanged<int> onPageChanged;

  static const _views = ['Side view', 'Angled view', 'Sole view'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: backdrop,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: _views.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, i) => Semantics(
                  image: true,
                  label: 'Aero Glide 3 in ${colorway.name}, ${_views[i]}',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Transform.rotate(
                      angle: i == 1 ? -0.18 : 0,
                      child: CustomPaint(
                        painter: _SneakerPainter(
                          colorway: colorway,
                          showSole: i == 2,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _views.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == page ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == page
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SneakerPainter extends CustomPainter {
  _SneakerPainter({required this.colorway, required this.showSole});

  final _Colorway colorway;
  final bool showSole;

  @override
  void paint(Canvas canvas, Size size) {
    // Fit a 300x170 design box into the available area.
    const dw = 300.0, dh = 170.0;
    final scale = (size.width / dw).clamp(0.0, size.height / dh) * 0.92;
    final dx = (size.width - dw * scale) / 2;
    final dy = (size.height - dh * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // Ground shadow
    canvas.drawOval(
      const Rect.fromLTWH(30, 150, 250, 18),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    if (showSole) {
      _paintSole(canvas);
      canvas.restore();
      return;
    }

    // Midsole
    final sole = Path()
      ..moveTo(18, 118)
      ..quadraticBezierTo(14, 150, 46, 152)
      ..lineTo(258, 152)
      ..quadraticBezierTo(292, 150, 290, 122)
      ..quadraticBezierTo(288, 112, 276, 112)
      ..lineTo(30, 112)
      ..quadraticBezierTo(18, 112, 18, 118)
      ..close();
    canvas.drawPath(sole, Paint()..color = colorway.sole);
    canvas.drawPath(
      sole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.12),
    );
    // Outsole strip
    final outsole = Path()
      ..moveTo(22, 140)
      ..quadraticBezierTo(24, 152, 46, 152)
      ..lineTo(258, 152)
      ..quadraticBezierTo(286, 151, 289, 136)
      ..close();
    canvas.drawPath(
        outsole, Paint()..color = Colors.black.withValues(alpha: 0.18));

    // Upper
    final upper = Path()
      ..moveTo(26, 114)
      ..quadraticBezierTo(16, 80, 34, 52)
      ..quadraticBezierTo(44, 36, 62, 40)
      ..quadraticBezierTo(80, 46, 96, 44)
      ..quadraticBezierTo(116, 40, 128, 54)
      ..lineTo(176, 74)
      ..quadraticBezierTo(232, 86, 268, 98)
      ..quadraticBezierTo(286, 106, 280, 114)
      ..close();
    canvas.drawPath(upper, Paint()..color = colorway.upper);
    canvas.drawPath(
      upper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.15),
    );

    // Heel counter
    final heel = Path()
      ..moveTo(26, 114)
      ..quadraticBezierTo(16, 80, 34, 52)
      ..quadraticBezierTo(50, 70, 60, 114)
      ..close();
    canvas.drawPath(heel, Paint()..color = colorway.accent);

    // Swoosh-like accent stripe
    final stripe = Path()
      ..moveTo(70, 104)
      ..quadraticBezierTo(140, 100, 214, 72)
      ..quadraticBezierTo(150, 94, 76, 92)
      ..close();
    canvas.drawPath(stripe, Paint()..color = colorway.accent);

    // Toe cap overlay
    final toe = Path()
      ..moveTo(222, 88)
      ..quadraticBezierTo(262, 96, 274, 104)
      ..quadraticBezierTo(284, 110, 280, 114)
      ..lineTo(232, 114)
      ..quadraticBezierTo(224, 100, 222, 88)
      ..close();
    canvas.drawPath(
        toe, Paint()..color = Colors.black.withValues(alpha: 0.07));

    // Laces
    final lace = Paint()
      ..color = colorway.accent.withValues(alpha: 0.9)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final x = 130.0 + i * 15;
      final y = 58.0 + i * 5.2;
      canvas.drawLine(Offset(x - 4, y + 8), Offset(x + 8, y - 2), lace);
    }

    // Collar / opening
    final collar = Path()
      ..moveTo(36, 54)
      ..quadraticBezierTo(70, 58, 124, 54);
    canvas.drawPath(
      collar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.22),
    );

    // Pull tab
    final tab = RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 36, 9, 22), const Radius.circular(3));
    canvas.drawRRect(tab, Paint()..color = colorway.accent);

    canvas.restore();
  }

  void _paintSole(Canvas canvas) {
    final outline = Path()
      ..moveTo(30, 85)
      ..cubicTo(30, 50, 80, 40, 140, 48)
      ..cubicTo(200, 30, 285, 45, 285, 85)
      ..cubicTo(285, 125, 200, 140, 140, 122)
      ..cubicTo(80, 130, 30, 120, 30, 85)
      ..close();
    canvas.drawPath(outline, Paint()..color = colorway.sole);
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.18),
    );
    final lug = Paint()..color = colorway.accent.withValues(alpha: 0.75);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 9; col++) {
        final x = 58.0 + col * 24;
        final y = 62.0 + row * 14;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, y), width: 14, height: 7),
              const Radius.circular(3)),
          lug,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SneakerPainter old) =>
      old.colorway != colorway || old.showSole != showSole;
}

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface.withValues(alpha: 0.85),
        foregroundColor: color ?? scheme.onSurface,
      ),
      icon: Icon(icon),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.onColor});
  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: onColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing, this.trailingWidget});
  final String title;
  final String? trailing;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ?trailingWidget,
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.colorway,
    required this.selected,
    required this.onTap,
  });

  final _Colorway colorway;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: colorway.name,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: ClipOval(
              child: Row(
                children: [
                  Expanded(child: ColoredBox(color: colorway.upper)),
                  Expanded(child: ColoredBox(color: colorway.accent)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeGrid extends StatelessWidget {
  const _SizeGrid({required this.selected, required this.onSelected});
  final double? selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final minCell = 64.0 * textScale.clamp(1.0, 2.0);
        final columns =
            (constraints.maxWidth / (minCell + 10)).floor().clamp(2, 6);
        const gap = 10.0;
        final cell = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in _sizes)
              SizedBox(
                width: cell,
                child: _SizeCell(
                  size: s,
                  selected: s == selected,
                  soldOut: _soldOut.contains(s),
                  lowStock: _lowStock.contains(s),
                  onTap: () => onSelected(s),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SizeCell extends StatelessWidget {
  const _SizeCell({
    required this.size,
    required this.selected,
    required this.soldOut,
    required this.lowStock,
    required this.onTap,
  });

  final double size;
  final bool selected;
  final bool soldOut;
  final bool lowStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = _fmt(size);
    final bg = selected ? scheme.onSurface : scheme.surfaceContainerLow;
    final fg = selected
        ? scheme.surface
        : soldOut
            ? scheme.onSurface.withValues(alpha: 0.38)
            : scheme.onSurface;
    final status = soldOut
        ? ', sold out'
        : lowStock
            ? ', only a few left'
            : '';

    return Semantics(
      button: true,
      enabled: !soldOut,
      selected: selected,
      label: 'US size $label$status',
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: soldOut ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (soldOut)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StrikePainter(scheme.outlineVariant),
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (lowStock && !soldOut)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected ? scheme.primaryContainer : scheme.primary,
                        shape: BoxShape.circle,
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

class _StrikePainter extends CustomPainter {
  _StrikePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_StrikePainter old) => old.color != color;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid();

  static const _specs = <(IconData, String, String)>[
    (Icons.height_rounded, 'Drop', '8 mm'),
    (Icons.scale_outlined, 'Weight', '9.2 oz'),
    (Icons.layers_outlined, 'Cushion', 'Max'),
    (Icons.terrain_outlined, 'Surface', 'Road'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final cols = scale > 1.5 || c.maxWidth < 300 ? 2 : 4;
      const gap = 10.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final s in _specs)
            Container(
              width: w,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(s.$1, size: 22, color: scheme.primary),
                  const SizedBox(height: 6),
                  Text(s.$3,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(s.$2,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary();

  static const _dist = <int, double>{5: 0.78, 4: 0.14, 3: 0.05, 2: 0.02, 1: 0.01};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final big = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('4.7',
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const _Stars(rating: 5, size: 18),
        const SizedBox(height: 4),
        Text('1,284 ratings',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
    final bars = Column(
      children: [
        for (final e in _dist.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 14 * MediaQuery.textScalerOf(context).scale(1),
                  child: Text('${e.key}', style: theme.textTheme.bodySmall),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value,
                      minHeight: 6,
                      color: const Color(0xFFF5A524),
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.6;
    return Semantics(
      label: 'Average rating 4.7 out of 5 from 1,284 ratings. '
          '78 percent gave 5 stars.',
      excludeSemantics: true,
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [big, const SizedBox(height: 12), bars],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [big, const SizedBox(width: 24), Expanded(child: bars)],
            ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 16});
  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final off = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(Icons.star_rounded,
              size: size, color: i <= rating ? const Color(0xFFF5A524) : off),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final _Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(review.author[0],
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.author, style: theme.textTheme.titleSmall),
                      Text(
                        review.date,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: '${review.rating} out of 5 stars',
              excludeSemantics: true,
              child: _Stars(rating: review.rating),
            ),
            const SizedBox(height: 6),
            Text(review.title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(review.body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.straighten_rounded,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Fit: ${review.fit}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.price, required this.size, required this.onAdd});
  final String price;
  final double? size;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    final priceBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(price,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        Text(
          size == null ? 'Select a size' : 'US ${_fmt(size!)} · In stock',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
    final button = FilledButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.shopping_bag_outlined),
      label: const Text('Add to bag'),
    );

    return Material(
      color: scheme.surfaceContainer,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: large
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [priceBlock, const SizedBox(height: 10), button],
                  )
                : Row(
                    children: [
                      priceBlock,
                      const SizedBox(width: 16),
                      Expanded(child: button),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
