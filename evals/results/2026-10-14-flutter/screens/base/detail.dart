import 'package:flutter/material.dart';

class DetailEvalApp extends StatelessWidget {
  const DetailEvalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFE4572E);
    return MaterialApp(
      title: 'Stride — Product',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light, seed),
      darkTheme: _buildTheme(Brightness.dark, seed),
      home: const _ProductDetailScreen(product: _sampleProduct),
    );
  }
}

ThemeData _buildTheme(Brightness brightness, Color seed) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _Colorway {
  const _Colorway({
    required this.name,
    required this.upper,
    required this.accent,
    required this.sole,
    required this.backdrop,
  });

  final String name;
  final Color upper;
  final Color accent;
  final Color sole;
  final Color backdrop;
}

class _SizeOption {
  const _SizeOption(this.label, {this.stock = 10});

  final String label;
  final int stock;

  bool get soldOut => stock == 0;
  bool get lowStock => stock > 0 && stock <= 2;
}

class _Review {
  const _Review({
    required this.author,
    required this.rating,
    required this.date,
    required this.title,
    required this.body,
    required this.fit,
  });

  final String author;
  final int rating;
  final String date;
  final String title;
  final String body;
  final String fit;
}

class _Product {
  const _Product({
    required this.brand,
    required this.name,
    required this.category,
    required this.price,
    required this.compareAt,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.colorways,
    required this.sizes,
    required this.highlights,
    required this.specs,
    required this.reviews,
  });

  final String brand;
  final String name;
  final String category;
  final double price;
  final double? compareAt;
  final double rating;
  final int reviewCount;
  final String description;
  final List<_Colorway> colorways;
  final List<_SizeOption> sizes;
  final List<(IconData, String, String)> highlights;
  final List<(String, String)> specs;
  final List<_Review> reviews;
}

const _sampleProduct = _Product(
  brand: 'Stride Athletics',
  name: 'Aero Runner 2',
  category: "Men's Road Running Shoe",
  price: 139.00,
  compareAt: 165.00,
  rating: 4.6,
  reviewCount: 1284,
  description:
      'The Aero Runner 2 pairs a supercritical foam midsole with a breathable '
      'engineered-mesh upper for a ride that feels light on easy days and '
      'springy when you pick up the pace. A reinforced heel counter and '
      'rubber outsole in high-wear zones keep it stable mile after mile.',
  colorways: [
    _Colorway(
      name: 'Ember / Bone',
      upper: Color(0xFFE4572E),
      accent: Color(0xFFF6F1E9),
      sole: Color(0xFFF6F1E9),
      backdrop: Color(0xFFFBD9CB),
    ),
    _Colorway(
      name: 'Midnight / Volt',
      upper: Color(0xFF1F2A44),
      accent: Color(0xFFD4F33B),
      sole: Color(0xFFEDEDED),
      backdrop: Color(0xFFCBD3E6),
    ),
    _Colorway(
      name: 'Sage / Sail',
      upper: Color(0xFF7FA48C),
      accent: Color(0xFFFFFFFF),
      sole: Color(0xFFF2EEE3),
      backdrop: Color(0xFFD6E6DA),
    ),
    _Colorway(
      name: 'Triple Black',
      upper: Color(0xFF222222),
      accent: Color(0xFF555555),
      sole: Color(0xFF2E2E2E),
      backdrop: Color(0xFFD9D9D9),
    ),
  ],
  sizes: [
    _SizeOption('7', stock: 4),
    _SizeOption('7.5', stock: 0),
    _SizeOption('8', stock: 12),
    _SizeOption('8.5', stock: 9),
    _SizeOption('9', stock: 15),
    _SizeOption('9.5', stock: 2),
    _SizeOption('10', stock: 11),
    _SizeOption('10.5', stock: 6),
    _SizeOption('11', stock: 0),
    _SizeOption('11.5', stock: 3),
    _SizeOption('12', stock: 1),
    _SizeOption('13', stock: 5),
  ],
  highlights: [
    (Icons.bolt_rounded, 'Responsive', 'Supercritical foam'),
    (Icons.air_rounded, 'Breathable', 'Engineered mesh'),
    (Icons.scale_rounded, 'Light', '248 g / 8.7 oz'),
  ],
  specs: [
    ('Drop', '8 mm'),
    ('Stack height', '38 mm heel / 30 mm forefoot'),
    ('Weight', '248 g (US 9)'),
    ('Support', 'Neutral'),
    ('Surface', 'Road, track'),
    ('Style code', 'AR2-604-EMB'),
  ],
  reviews: [
    _Review(
      author: 'Marcus T.',
      rating: 5,
      date: 'Sep 28, 2026',
      title: 'Best daily trainer I have owned',
      body:
          'Put 120 miles on these already. Cushion is still bouncy and the '
          'upper has zero hot spots. Picked up my tempo runs noticeably.',
      fit: 'True to size',
    ),
    _Review(
      author: 'Priya S.',
      rating: 4,
      date: 'Sep 15, 2026',
      title: 'Great ride, snug toe box',
      body:
          'Super comfortable and light. Toe box is a little narrow for me, '
          'so I would size up half if you have wider feet.',
      fit: 'Runs slightly small',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen({required this.product});

  final _Product product;

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  int _colorIndex = 0;
  int? _sizeIndex;
  bool _favorite = false;
  bool _descriptionExpanded = false;
  int _imageIndex = 0;
  bool _sizeError = false;

  _Product get p => widget.product;

  void _addToBag() {
    if (_sizeIndex == null) {
      setState(() => _sizeError = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Select a size to add to bag')),
        );
      return;
    }
    final size = p.sizes[_sizeIndex!].label;
    final color = p.colorways[_colorIndex].name;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added ${p.name} · $color · US $size to bag'),
          action: SnackBarAction(label: 'View bag', onPressed: () {}),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colorway = p.colorways[_colorIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {},
        ),
        title: Text(p.brand, style: theme.textTheme.titleMedium),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Bag, 2 items',
            onPressed: () {},
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Gallery(
            colorway: colorway,
            imageIndex: _imageIndex,
            onImageChanged: (i) => setState(() => _imageIndex = i),
            favorite: _favorite,
            onFavorite: () => setState(() => _favorite = !_favorite),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.category.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                _RatingRow(rating: p.rating, count: p.reviewCount),
                const SizedBox(height: 16),
                _PriceRow(price: p.price, compareAt: p.compareAt),
                const SizedBox(height: 8),
                Text(
                  'or 4 interest-free payments of \$${(p.price / 4).toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const _SectionDivider(),
          _Section(
            title: 'Color',
            trailing: Text(
              colorway.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < p.colorways.length; i++)
                  _ColorSwatch(
                    colorway: p.colorways[i],
                    selected: i == _colorIndex,
                    onTap: () => setState(() => _colorIndex = i),
                  ),
              ],
            ),
          ),
          _Section(
            title: 'Size (US)',
            trailing: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.straighten_rounded, size: 18),
              label: const Text('Size guide'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SizeGrid(
                  sizes: p.sizes,
                  selected: _sizeIndex,
                  error: _sizeError,
                  onSelect: (i) => setState(() {
                    _sizeIndex = i;
                    _sizeError = false;
                  }),
                ),
                const SizedBox(height: 12),
                _SizeHint(
                  size: _sizeIndex == null ? null : p.sizes[_sizeIndex!],
                  error: _sizeError,
                ),
              ],
            ),
          ),
          const _SectionDivider(),
          const _DeliveryCard(),
          const _SectionDivider(),
          _Section(
            title: 'Highlights',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < p.highlights.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _HighlightTile(data: p.highlights[i])),
                ],
              ],
            ),
          ),
          _Section(
            title: 'Description',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: Text(
                    p.description,
                    maxLines: _descriptionExpanded ? null : 3,
                    overflow: _descriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 40),
                  ),
                  onPressed: () => setState(
                    () => _descriptionExpanded = !_descriptionExpanded,
                  ),
                  child: Text(_descriptionExpanded ? 'Show less' : 'Read more'),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Specifications',
            child: _SpecTable(specs: p.specs),
          ),
          const _SectionDivider(),
          _Section(
            title: 'Reviews',
            trailing: TextButton(
              onPressed: () {},
              child: Text('See all ${p.reviewCount}'),
            ),
            child: Column(
              children: [
                _ReviewSummary(rating: p.rating, count: p.reviewCount),
                const SizedBox(height: 16),
                for (final r in p.reviews) ...[
                  _ReviewCard(review: r),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        price: p.price,
        sizeLabel: _sizeIndex == null ? null : p.sizes[_sizeIndex!].label,
        onAdd: _addToBag,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery
// ---------------------------------------------------------------------------

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.colorway,
    required this.imageIndex,
    required this.onImageChanged,
    required this.favorite,
    required this.onFavorite,
  });

  final _Colorway colorway;
  final int imageIndex;
  final ValueChanged<int> onImageChanged;
  final bool favorite;
  final VoidCallback onFavorite;

  static const _views = ['Side', 'Angle', 'Top'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final backdrop = dark
        ? Color.alphaBlend(
            colorway.backdrop.withValues(alpha: 0.18),
            theme.colorScheme.surfaceContainerHigh,
          )
        : colorway.backdrop;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: backdrop,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                      child: Semantics(
                        label: 'Aero Runner 2 in ${colorway.name}, '
                            '${_views[imageIndex]} view',
                        image: true,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: _transformFor(imageIndex),
                          child: CustomPaint(
                            painter: _SneakerPainter(colorway),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.inverseSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '16% OFF',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      tooltip:
                          favorite ? 'Remove from favorites' : 'Add to favorites',
                      isSelected: favorite,
                      onPressed: onFavorite,
                      icon: const Icon(Icons.favorite_border_rounded),
                      selectedIcon: Icon(
                        Icons.favorite_rounded,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _views.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == imageIndex ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: i == imageIndex ? 0.8 : 0.25,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _views.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _Thumb(
                    colorway: colorway,
                    backdrop: backdrop,
                    transform: _transformFor(i),
                    label: '${_views[i]} view',
                    selected: i == imageIndex,
                    onTap: () => onImageChanged(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Matrix4 _transformFor(int index) {
    switch (index) {
      case 1:
        return Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(-0.5)
          ..rotateZ(-0.12);
      case 2:
        return Matrix4.identity()..rotateZ(-0.28);
      default:
        return Matrix4.identity();
    }
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.colorway,
    required this.backdrop,
    required this.transform,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _Colorway colorway;
  final Color backdrop;
  final Matrix4 transform;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: backdrop,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? scheme.onSurface : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1.6,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: CustomPaint(painter: _SneakerPainter(colorway)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a stylised side-profile running shoe that scales to its box.
class _SneakerPainter extends CustomPainter {
  _SneakerPainter(this.c);

  final _Colorway c;

  @override
  void paint(Canvas canvas, Size size) {
    // Design space is 300 x 150; fit it centered into the given size.
    const dw = 300.0, dh = 150.0;
    final s = (size.width / dw) < (size.height / dh)
        ? size.width / dw
        : size.height / dh;
    canvas.save();
    canvas.translate((size.width - dw * s) / 2, (size.height - dh * s) / 2);
    canvas.scale(s);

    // Ground shadow.
    canvas.drawOval(
      const Rect.fromLTWH(30, 130, 250, 16),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Midsole.
    final sole = Path()
      ..moveTo(18, 108)
      ..quadraticBezierTo(14, 132, 40, 134)
      ..lineTo(262, 134)
      ..quadraticBezierTo(292, 132, 290, 112)
      ..quadraticBezierTo(288, 100, 270, 102)
      ..lineTo(30, 98)
      ..close();
    canvas.drawPath(sole, Paint()..color = c.sole);

    // Outsole strip.
    final outsole = Path()
      ..moveTo(22, 126)
      ..quadraticBezierTo(26, 136, 42, 136)
      ..lineTo(262, 136)
      ..quadraticBezierTo(284, 135, 289, 122)
      ..lineTo(289, 128)
      ..quadraticBezierTo(284, 142, 262, 142)
      ..lineTo(42, 142)
      ..quadraticBezierTo(22, 141, 22, 126)
      ..close();
    canvas.drawPath(
      outsole,
      Paint()..color = Color.lerp(c.sole, const Color(0xFF000000), 0.35)!,
    );

    // Upper.
    final upper = Path()
      ..moveTo(28, 100)
      ..quadraticBezierTo(18, 60, 36, 34)
      ..quadraticBezierTo(50, 22, 74, 28)
      ..quadraticBezierTo(90, 44, 108, 40)
      ..lineTo(150, 30)
      ..quadraticBezierTo(200, 52, 240, 70)
      ..quadraticBezierTo(284, 82, 282, 104)
      ..lineTo(28, 100)
      ..close();
    canvas.drawPath(upper, Paint()..color = c.upper);

    // Toe cap shading.
    final toe = Path()
      ..moveTo(230, 102)
      ..quadraticBezierTo(232, 76, 246, 72)
      ..quadraticBezierTo(282, 82, 282, 104)
      ..close();
    canvas.drawPath(
      toe,
      Paint()..color = Color.lerp(c.upper, const Color(0xFF000000), 0.12)!,
    );

    // Heel tab.
    final heel = Path()
      ..moveTo(36, 34)
      ..quadraticBezierTo(22, 50, 22, 74)
      ..lineTo(34, 74)
      ..quadraticBezierTo(34, 50, 44, 36)
      ..close();
    canvas.drawPath(heel, Paint()..color = c.accent);

    // Side stripes.
    final stripe = Paint()
      ..color = c.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = 110.0 + i * 22;
      canvas.drawLine(Offset(x, 92), Offset(x + 30, 46 + i * 4.0), stripe);
    }

    // Laces.
    final lace = Paint()
      ..color = c.accent
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final x = 122.0 + i * 18;
      final y = 34.0 + i * 7.5;
      canvas.drawLine(Offset(x, y), Offset(x + 12, y - 8), lace);
    }

    // Collar opening.
    final collar = Path()
      ..moveTo(44, 32)
      ..quadraticBezierTo(70, 22, 84, 34)
      ..quadraticBezierTo(70, 40, 50, 38)
      ..close();
    canvas.drawPath(
      collar,
      Paint()..color = Color.lerp(c.upper, const Color(0xFF000000), 0.45)!,
    );

    // Upper outline for crispness.
    canvas.drawPath(
      upper,
      Paint()
        ..color = const Color(0x22000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SneakerPainter oldDelegate) => oldDelegate.c != c;
}

// ---------------------------------------------------------------------------
// Info widgets
// ---------------------------------------------------------------------------

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Rated ${rating.toStringAsFixed(1)} out of 5, $count reviews',
      child: ExcludeSemantics(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            _Stars(rating: rating, size: 18),
            Text(
              rating.toStringAsFixed(1),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '(${_formatCount(count)} reviews)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCount(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A623);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star_rounded
                : rating >= i - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: gold,
          ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, this.compareAt});

  final double price;
  final double? compareAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (compareAt != null) ...[
          Text(
            '\$${compareAt!.toStringAsFixed(2)}',
            semanticsLabel: 'Was \$${compareAt!.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Save \$${(compareAt! - price).toStringAsFixed(0)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20),
      child: Divider(height: 1, indent: 20, endIndent: 20),
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
      child: Tooltip(
        message: colorway.name,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.onSurface : scheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: ClipOval(
              child: Column(
                children: [
                  Expanded(child: ColoredBox(color: colorway.upper)),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: ColoredBox(color: colorway.accent)),
                        Expanded(child: ColoredBox(color: colorway.sole)),
                      ],
                    ),
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

class _SizeGrid extends StatelessWidget {
  const _SizeGrid({
    required this.sizes,
    required this.selected,
    required this.error,
    required this.onSelect,
  });

  final List<_SizeOption> sizes;
  final int? selected;
  final bool error;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = textScale > 1.5 ? 3 : 4;
        final w = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < sizes.length; i++)
              SizedBox(
                width: w,
                child: _SizeChip(
                  option: sizes[i],
                  selected: selected == i,
                  error: error,
                  onTap: sizes[i].soldOut ? null : () => onSelect(i),
                  scheme: scheme,
                  theme: theme,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.option,
    required this.selected,
    required this.error,
    required this.onTap,
    required this.scheme,
    required this.theme,
  });

  final _SizeOption option;
  final bool selected;
  final bool error;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final soldOut = option.soldOut;
    final bg = selected ? scheme.onSurface : scheme.surface;
    final fg = selected
        ? scheme.surface
        : soldOut
            ? scheme.onSurface.withValues(alpha: 0.38)
            : scheme.onSurface;
    final borderColor = selected
        ? scheme.onSurface
        : error
            ? scheme.error
            : scheme.outlineVariant;

    return Semantics(
      button: true,
      enabled: !soldOut,
      selected: selected,
      label: 'US ${option.label}'
          '${soldOut ? ', sold out' : option.lowStock ? ', only ${option.stock} left' : ''}',
      excludeSemantics: true,
      child: Material(
        color: soldOut ? scheme.surfaceContainerHighest : bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      decoration: soldOut ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (option.lowStock && !selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
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

class _SizeHint extends StatelessWidget {
  const _SizeHint({required this.size, required this.error});

  final _SizeOption? size;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final IconData icon;
    final String text;
    Color color = scheme.onSurfaceVariant;

    if (error) {
      icon = Icons.error_outline_rounded;
      text = 'Please select a size.';
      color = scheme.error;
    } else if (size == null) {
      icon = Icons.info_outline_rounded;
      text = 'Fits true to size. Wide feet? Go up half a size.';
    } else if (size!.lowStock) {
      icon = Icons.local_fire_department_outlined;
      text = 'Only ${size!.stock} left in US ${size!.label}. Order soon.';
      color = scheme.tertiary;
    } else {
      icon = Icons.check_circle_outline_rounded;
      text = 'US ${size!.label} is in stock.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget row(IconData icon, String title, String subtitle) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            row(
              Icons.local_shipping_outlined,
              'Free delivery by Fri, Oct 17',
              'Order within 3 hrs 12 min · Ships to 94107',
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            row(
              Icons.storefront_outlined,
              'Pick up today at Market St.',
              'In stock at 2 stores near you',
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            row(
              Icons.autorenew_rounded,
              'Free 30-day returns',
              'Run in them. Not the right fit? Send them back.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.data});

  final (IconData, String, String) data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, title, sub) = data;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.onSecondaryContainer),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSecondaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecTable extends StatelessWidget {
  const _SpecTable({required this.specs});

  final List<(String, String)> specs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        for (var i = 0; i < specs.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: i == specs.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    specs[i].$1,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    specs[i].$2,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.rating, required this.count});

  final double rating;
  final int count;

  static const _distribution = [0.74, 0.16, 0.05, 0.03, 0.02];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            _Stars(rating: rating, size: 16),
            const SizedBox(height: 4),
            Text(
              '94% recommend',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text('${5 - i}', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _distribution[i],
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainerHighest,
                            color: const Color(0xFFF5A623),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  review.author[0],
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Verified buyer · ${review.date}',
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
            child: ExcludeSemantics(
              child: _Stars(rating: review.rating.toDouble(), size: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.title,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            review.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              Chip(
                avatar: const Icon(Icons.straighten_rounded, size: 16),
                label: Text(review.fit),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.price,
    required this.sizeLabel,
    required this.onAdd,
  });

  final double price;
  final String? sizeLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sizeLabel == null ? 'No size selected' : 'US $sizeLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text(
                    'Add to bag',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
