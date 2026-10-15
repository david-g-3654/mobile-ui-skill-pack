// components.dart — mobile-ui core components for Flutter.
// Prefer platform widgets (Scaffold + SliverAppBar/CupertinoSliverNavigationBar, NavigationBar/
// CupertinoTabBar, Switch.adaptive, showModalBottomSheet, showAdaptiveDialog, SegmentedButton/
// CupertinoSlidingSegmentedControl) and use these where the platform can't express the pattern.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

// ── Buttons ─────────────────────────────────────────────────────────

/// Filled primary button: one per screen. Ink fill, stadium, 52 high.
class QPrimaryButton extends StatelessWidget {
  const QPrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label, loading' : label,
      excludeSemantics: true,
      // Min height, not a fixed one: at accessibility sizes the label wraps and the button grows.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity, minHeight: QMetrics.buttonHeight),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: q.primaryFill,
            foregroundColor: q.onPrimary,
            disabledBackgroundColor: loading ? q.primaryFill : q.surface2,
            disabledForegroundColor: loading ? q.onPrimary : q.ink3,
            shape: const StadiumBorder(),
            textStyle: context.qText.titleMedium,
            padding: const EdgeInsets.symmetric(horizontal: QSpace.xl, vertical: QSpace.sm),
            elevation: 0,
          ),
          child: loading
              ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: q.onPrimary))
              : Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// Alternative action: same shape, tonal fill.
class QSecondaryButton extends StatelessWidget {
  const QSecondaryButton({super.key, required this.label, required this.onPressed, this.destructive = false, this.expand = true});

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: expand ? double.infinity : 0, minHeight: QMetrics.buttonHeight),
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: q.surface2,
          foregroundColor: destructive ? q.negative : q.ink,
          shape: const StadiumBorder(),
          textStyle: context.qText.titleMedium,
          padding: const EdgeInsets.symmetric(horizontal: QSpace.xl, vertical: QSpace.sm),
          elevation: 0,
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Escape hatches: "Not now", "Restore purchases", "Skip".
class QTertiaryButton extends StatelessWidget {
  const QTertiaryButton({super.key, required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? context.q.ink2,
        minimumSize: const Size(QMetrics.minTap, QMetrics.minTap),
        textStyle: context.qText.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: QSpace.xs),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

// ── Bottom action bar ───────────────────────────────────────────────

/// True at accessibility text sizes (scale ≥ 1.6): switch side-by-side layouts to stacked and stop
/// pinning tall footers.
bool qIsLargeText(BuildContext context) => MediaQuery.textScalerOf(context).scale(16) / 16 >= 1.6;

/// Caps text scaling for display type (hero numbers, onboarding/paywall/auth headlines) at 1.5×.
/// iOS large titles grow far less than body text; an uncapped 34pt headline at AX-XL fills half the
/// screen and orphans words. Body text stays uncapped. Usage: `QDisplayScale(child: Text(..., style: t.displaySmall))`.
class QDisplayScale extends StatelessWidget {
  const QDisplayScale({super.key, required this.child, this.maxScale = 1.5});

  final Widget child;
  final double maxScale;

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(maxScaleFactor: maxScale, child: child);
}

/// Pins the primary action above the home indicator. Use as `Scaffold.bottomNavigationBar` so content
/// insets itself (never overlay a bar on top of scroll content).
///
/// [footer] (terms, legal line, secondary links) is pinned at normal text sizes but NOT at accessibility
/// sizes — a tall pinned bar would cover the screen — so also place the same footer at the end of the
/// scroll content inside [QLargeTextFooter].
class QBottomActionBar extends StatelessWidget {
  const QBottomActionBar({super.key, required this.children, this.footer = const []});

  final List<Widget> children;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: q.canvas,
        border: Border(top: BorderSide(color: q.hairline, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: QSpace.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(QSpace.margin, QSpace.sm, QSpace.margin, QSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: QSpace.xs,
            children: [...children, if (!qIsLargeText(context)) ...footer],
          ),
        ),
      ),
    );
  }
}

/// Renders its children only at accessibility text sizes — pair with [QBottomActionBar.footer].
class QLargeTextFooter extends StatelessWidget {
  const QLargeTextFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!qIsLargeText(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: QSpace.xl),
      child: Column(mainAxisSize: MainAxisSize.min, spacing: QSpace.xs, children: children),
    );
  }
}

// ── Section header & grouped section ────────────────────────────────

class QSectionHeader extends StatelessWidget {
  const QSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Semantics(header: true, child: Text(title, style: context.qText.titleLarge))),
        if (actionLabel != null) QTertiaryButton(label: actionLabel!, onPressed: onAction),
      ],
    );
  }
}

/// Inset-grouped section: surface on canvas, radius 20, hairlines between rows. No shadow.
class QGroupedSection extends StatelessWidget {
  const QGroupedSection({super.key, this.header, this.footer, required this.children});

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) rows.add(const Divider(indent: QSpace.md));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: QSpace.xs,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md),
            child: Semantics(header: true, child: Text(header!.toUpperCase(), style: context.qText.labelSmall)),
          ),
        Material(
          color: q.surface,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(QRadii.l)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md),
            child: Text(footer!, style: context.qText.bodySmall),
          ),
      ],
    );
  }
}

// ── Rows ────────────────────────────────────────────────────────────

enum QRowKind { navigate, action, link }

class QListRow extends StatelessWidget {
  const QListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.value,
    this.onTap,
    this.kind = QRowKind.navigate,
    this.destructive = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final String? value;
  final VoidCallback? onTap;

  /// navigate → chevron · action → no accessory · link → external arrow.
  final QRowKind kind;
  final bool destructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    Widget? accessory = trailing;
    if (accessory == null && onTap != null) {
      accessory = switch (kind) {
        QRowKind.navigate => Icon(Icons.chevron_right_rounded, size: 20, color: q.ink3),
        QRowKind.link => Icon(Icons.north_east_rounded, size: 16, color: q.ink3),
        QRowKind.action => null,
      };
    }
    // At accessibility sizes the value moves under the title and the leading element sits on top,
    // so titles never get squeezed against the value.
    final stacked = qIsLargeText(context);
    final valueText = value == null
        ? null
        : Text(value!,
            style: context.qText.bodyLarge?.copyWith(color: q.ink2, fontFeatures: const [FontFeature.tabularFigures()]));
    final lead = leading ?? (icon == null ? null : SizedBox(width: 28, child: Icon(icon, size: 20, color: q.ink2)));
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: QMetrics.rowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.sm),
          child: Row(
            spacing: QSpace.sm,
            children: [
              if (!stacked) ?lead,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    if (stacked && leading != null) leading!,
                    Text(title,
                        style: (leading != null ? context.qText.titleMedium : context.qText.bodyLarge)
                            ?.copyWith(color: destructive ? q.negative : q.ink)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: context.qText.bodyMedium,
                          maxLines: stacked ? null : 2,
                          overflow: stacked ? null : TextOverflow.ellipsis),
                    if (stacked) ?valueText,
                  ],
                ),
              ),
              if (!stacked) ?valueText,
              ?accessory,
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle row: applies immediately (no Save). The whole row toggles.
class QToggleRow extends StatelessWidget {
  const QToggleRow({super.key, required this.title, this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  void _set(bool v) {
    HapticFeedback.selectionClick();
    onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => _set(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: QMetrics.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.xs),
            child: Row(
              spacing: QSpace.sm,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: context.qText.bodyLarge),
                      if (subtitle != null) Text(subtitle!, style: context.qText.bodyMedium),
                    ],
                  ),
                ),
                Switch.adaptive(value: value, onChanged: _set),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero metric & metric row ────────────────────────────────────────

class QDelta {
  const QDelta(this.text, {required this.up, this.upIsGood = true});
  final String text;
  final bool up;
  final bool upIsGood;
}

/// The single focal number. [prefix]/[suffix] render smaller and in ink2 ("$", ".50", "mi").
class QHeroMetric extends StatelessWidget {
  const QHeroMetric({super.key, required this.label, required this.value, this.prefix, this.suffix, this.context, this.delta});

  final String label;
  final String value;
  final String? prefix;
  final String? suffix;
  final String? context;
  final QDelta? delta;

  @override
  Widget build(BuildContext ctx) {
    final q = ctx.q;
    final small = ctx.qText.titleLarge?.copyWith(color: q.ink2);
    final good = delta == null || delta!.up == delta!.upIsGood;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: QSpace.xs,
        children: [
          Text(label.toUpperCase(), style: ctx.qText.labelSmall),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: QDisplayScale(child: Text.rich(
              TextSpan(children: [
                if (prefix != null) TextSpan(text: prefix, style: small),
                TextSpan(text: value, style: ctx.qText.displayLarge),
                if (suffix != null) TextSpan(text: suffix, style: small),
              ]),
            )),
          ),
          if (delta != null || context != null)
            Wrap(
              spacing: QSpace.xs,
              runSpacing: QSpace.xxs,
              children: [
                // One Text.rich, not a Row: the delta must wrap at large text sizes instead of
                // running off the screen (eval finding). The arrow scales with the text.
                if (delta != null)
                  Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: QSpace.xxs),
                          child: Icon(delta!.up ? Icons.north_east_rounded : Icons.south_east_rounded,
                              size: MediaQuery.textScalerOf(ctx).scale(16), color: good ? q.positive : q.negative),
                        ),
                      ),
                      TextSpan(text: delta!.text),
                    ]),
                    style: ctx.qText.bodyMedium?.copyWith(color: good ? q.positive : q.negative, fontWeight: FontWeight.w600),
                  ),
                if (context != null) Text(context!, style: ctx.qText.bodyMedium),
              ],
            ),
        ],
      ),
    );
  }
}

/// 2–3 secondary metrics in a quiet row. No icons, no tiles. Wraps at large text sizes.
class QMetricRow extends StatelessWidget {
  const QMetricRow({super.key, required this.items});

  final List<(String value, String label)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: QSpace.xl,
      runSpacing: QSpace.sm,
      children: [
        for (final (value, label) in items)
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                Text(value,
                    style: context.qText.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                Text(label, style: context.qText.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Card (object) ───────────────────────────────────────────────────

/// Cards are for objects (a plan, a booking, a media tile) — not for wrapping sections.
class QObjectCard extends StatelessWidget {
  const QObjectCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(QSpace.lg)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.q.surface,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(QRadii.l)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

// ── Color swatch (product variants) ─────────────────────────────────

/// A product color (content, not UI — mark its definition with `// mobile-ui: content-color`). Always
/// ringed with a hairline so a black swatch survives dark mode and a white one survives light mode.
class QSwatch extends StatelessWidget {
  const QSwatch({super.key, required this.name, required this.color, this.selected = false, required this.onTap, this.size = 32});

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Semantics(
      label: name,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: InkResponse(
        onTap: () {
          if (!selected) HapticFeedback.selectionClick();
          onTap();
        },
        radius: QMetrics.minTap / 2,
        child: SizedBox.square(
          dimension: QMetrics.minTap,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(QSpace.xxs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? q.ink : Colors.transparent, width: 2),
              ),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: q.hairline)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chip, avatar, badge ─────────────────────────────────────────────

class QChip extends StatelessWidget {
  const QChip({super.key, required this.label, this.selected = false, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? q.primaryFill : q.surface2,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: QSpace.sm),
              child: Center(
                widthFactor: 1,
                child: Text(label,
                    style: context.qText.bodyMedium?.copyWith(
                        color: selected ? q.onPrimary : q.ink,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QAvatar extends StatelessWidget {
  const QAvatar({super.key, required this.name, this.image, this.size = 40});

  final String name;
  final ImageProvider? image;
  final double size;

  String get _initials => name.trim().split(RegExp(r'\s+')).take(2).map((p) => p[0]).join();

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Semantics(
      label: name,
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: q.accentSoft,
        foregroundImage: image,
        child: ExcludeSemantics(
          child: Text(_initials,
              style: TextStyle(color: q.accent, fontSize: size * 0.38, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class QBadge extends StatelessWidget {
  const QBadge({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.q.accent;
    return DecoratedBox(
      decoration: ShapeDecoration(color: tint.withValues(alpha: 0.12), shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: QSpace.xs, vertical: 2),
        child: Text(text, style: context.qText.bodySmall?.copyWith(color: tint, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Progress ring ───────────────────────────────────────────────────

class QProgressRing extends StatelessWidget {
  const QProgressRing({super.key, required this.progress, this.size = 240, this.stroke = 14, this.color, this.child});

  final double progress; // 0..1
  final double size;
  final double stroke;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final p = progress.clamp(0.0, 1.0);
    return Semantics(
      value: '${(p * 100).round()} percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: p),
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : QMotion.medium,
        curve: QMotion.curve,
        builder: (context, value, child) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(value, stroke, q.surface2, color ?? q.accent),
          child: SizedBox.square(dimension: size, child: Center(child: child)),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.stroke, this.track, this.color);
  final double progress;
  final double stroke;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, base..color = track);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * progress, false, base..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color || old.track != track;
}

// ── Plan card (paywall) ─────────────────────────────────────────────

class QPlanCard extends StatelessWidget {
  const QPlanCard({
    super.key,
    required this.name,
    required this.price,
    required this.period,
    this.detail,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final String period;
  final String? detail;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(QRadii.l),
      side: BorderSide(color: selected ? q.ink : q.hairline, width: selected ? 2 : 1),
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: [name, '$price $period', detail, badge].whereType<String>().join(', '),
      excludeSemantics: true,
      child: Material(
        color: q.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 132),
            child: Padding(
              padding: const EdgeInsets.all(QSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: QSpace.xs,
                children: [
                  Row(children: [
                    Expanded(child: Text(name, style: context.qText.titleMedium)),
                    Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: selected ? q.ink : q.ink3, size: 22),
                  ]),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: price,
                        style: context.qText.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                    TextSpan(text: period, style: context.qText.bodyMedium),
                  ])),
                  if (detail != null) Text(detail!, style: context.qText.bodySmall),
                  if (badge != null) QBadge(text: badge!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────

class QEmptyState extends StatelessWidget {
  const QEmptyState({super.key, this.icon, required this.title, required this.message, this.actionLabel, this.onAction});

  final IconData? icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QSpace.xl, vertical: QSpace.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: QSpace.sm,
        children: [
          if (icon != null) ExcludeSemantics(child: Icon(icon, size: 44, color: q.ink3)),
          Semantics(header: true, child: Text(title, style: context.qText.titleLarge, textAlign: TextAlign.center)),
          Text(message, style: context.qText.bodyLarge?.copyWith(color: q.ink2), textAlign: TextAlign.center),
          if (actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: QSpace.xs),
              child: QSecondaryButton(label: actionLabel!, onPressed: onAction, expand: false),
            ),
        ],
      ),
    );
  }
}

// ── QSkeleton ────────────────────────────────────────────────────────

class QSkeleton extends StatefulWidget {
  const QSkeleton({super.key, this.width, required this.height, this.radius = QRadii.s});

  final double? width;
  final double height;
  final double radius;

  @override
  State<QSkeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<QSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900), lowerBound: 0.45, upperBound: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _c,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(color: context.q.surface2, borderRadius: BorderRadius.circular(widget.radius)),
        ),
      ),
    );
  }
}

/// QSkeleton in the shape of a QListRow.
class QSkeletonRow extends StatelessWidget {
  const QSkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: QSpace.md, vertical: QSpace.sm),
      child: Row(
        spacing: QSpace.sm,
        children: [
          QSkeleton(width: 28, height: 28, radius: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: QSpace.xs,
              children: [
                FractionallySizedBox(widthFactor: 0.6, child: QSkeleton(height: 14)),
                FractionallySizedBox(widthFactor: 0.4, child: QSkeleton(height: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toast ───────────────────────────────────────────────────────────

/// Inverse capsule confirmation ("Copied", "Saved"). Uses the themed floating SnackBar.
void showQToast(BuildContext context, String message, {String? undoLabel, VoidCallback? onUndo}) {
  SemanticsService.sendAnnouncement(View.of(context), message, Directionality.of(context));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 2500),
      action: undoLabel == null ? null : SnackBarAction(label: undoLabel, onPressed: onUndo ?? () {}),
    ));
}

// ─── Bar chart ──────────────────────────────────────────────────────────────

/// One bar in a [QBarChart]. [shortLabel] is what the axis shows when the full label doesn't fit ("M" for "Mon").
class QBar {
  const QBar({required this.label, required this.shortLabel, required this.value, this.spokenValue});

  final String label;
  final String shortLabel;
  final double value;

  /// Spoken value, e.g. "6.2 kilometres". Defaults to the number.
  final String? spokenValue;
}

/// Single-series bar chart for stats screens (screen-stats.md): one highlighted bar in `accent`, the rest in
/// ink, an optional dashed goal line, minimal axes.
///
/// Axis labels never collide, at any text size: it measures the labels at the current text scale and uses
/// full labels when they fit their column, single letters when they don't (and always at accessibility
/// sizes), and every other letter as a last resort. (Eval finding: hand-rolled charts clipped or ran their
/// day names together at large text.)
class QBarChart extends StatelessWidget {
  const QBarChart({super.key, required this.bars, this.highlighted, this.goal, this.goalLabel, this.height = 180});

  final List<QBar> bars;
  final int? highlighted;
  final double? goal;
  final String? goalLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final q = context.q;
    final labelStyle = context.qText.labelMedium ?? const TextStyle();
    final top = math.max(bars.fold<double>(0, (m, b) => math.max(m, b.value)), goal ?? 0) * 1.15;
    final maxValue = top <= 0 ? 1.0 : top;

    return LayoutBuilder(builder: (context, constraints) {
      final column = constraints.maxWidth / bars.length;
      final scaler = MediaQuery.textScalerOf(context);
      double widest(Iterable<String> labels) => labels
          .map((l) => (TextPainter(
                text: TextSpan(text: l, style: labelStyle),
                textScaler: scaler,
                maxLines: 1,
                textDirection: Directionality.of(context),
              )..layout())
                  .width)
          .fold(0.0, math.max);
      final List<String?> labels;
      if (!qIsLargeText(context) && widest(bars.map((b) => b.label)) <= column - 4) {
        labels = [for (final b in bars) b.label];
      } else if (widest(bars.map((b) => b.shortLabel)) <= column - 2) {
        labels = [for (final b in bars) b.shortLabel];
      } else {
        labels = [for (var i = 0; i < bars.length; i++) i.isEven ? bars[i].shortLabel : null];
      }

      return Semantics(
        container: true,
        label: bars.map((b) => '${b.label} ${b.spokenValue ?? b.value.toString()}').join(', '),
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: height,
              child: Stack(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (var i = 0; i < bars.length; i++)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 0.55,
                          heightFactor: bars[i].value <= 0 ? 0.012 : (bars[i].value / maxValue).clamp(0.012, 1.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bars[i].value <= 0
                                  ? q.hairline
                                  : i == highlighted
                                      ? q.accent
                                      : q.ink.withValues(alpha: 0.85),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
                if (goal != null) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: height * goal! / maxValue,
                    child: CustomPaint(size: const Size.fromHeight(1), painter: _DashedLinePainter(q.ink3)),
                  ),
                  if (goalLabel != null)
                    Positioned(
                      right: 0,
                      bottom: height * goal! / maxValue + 4,
                      child: Text(goalLabel!, style: context.qText.labelSmall?.copyWith(color: q.ink2)),
                    ),
                ],
              ]),
            ),
            const SizedBox(height: QSpace.xs),
            Row(children: [
              for (var i = 0; i < bars.length; i++)
                Expanded(
                  child: Text(
                    labels[i] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: labelStyle.copyWith(
                      color: i == highlighted ? q.ink : q.ink2,
                      fontWeight: i == highlighted ? FontWeight.w600 : null,
                    ),
                  ),
                ),
            ]),
          ]),
        ),
      );
    });
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + 4, size.width), 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
