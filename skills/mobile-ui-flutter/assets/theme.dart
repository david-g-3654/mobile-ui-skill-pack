// theme.dart — mobile-ui "Quiet" skin for Flutter (Material 3, platform-adaptive).
// Screens use these roles only: `context.q.ink`, `QSpace.lg`, `Theme.of(context).textTheme.titleLarge`.
// No raw Color(0x…) or fontSize in screens. To rebrand: change `accent` below.
// See mobile-ui/references/style-guide.md.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ── Color roles ─────────────────────────────────────────────────────

@immutable
class Quiet extends ThemeExtension<Quiet> {
  const Quiet({
    required this.canvas,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.hairline,
    required this.accent,
    required this.accentSoft,
    required this.primaryFill,
    required this.onPrimary,
    required this.positive,
    required this.negative,
    required this.warning,
  });

  final Color canvas;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color ink2;

  /// Placeholder and disabled only — never information.
  final Color ink3;
  final Color hairline;

  /// Editorial accent: ≤2 elements per screen.
  final Color accent;
  final Color accentSoft;
  final Color primaryFill;
  final Color onPrimary;
  final Color positive;
  final Color negative;
  final Color warning;

  static const light = Quiet(
    canvas: Color(0xFFF5F5F2),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEDEDEA),
    ink: Color(0xFF121212),
    ink2: Color(0xFF5E5E5B),
    ink3: Color(0xFF9B9B97),
    hairline: Color(0x1A121212),
    accent: Color(0xFFC2410C),
    accentSoft: Color(0x1AC2410C),
    primaryFill: Color(0xFF121212),
    onPrimary: Color(0xFFFFFFFF),
    positive: Color(0xFF1E7F46),
    negative: Color(0xFFC8312A),
    warning: Color(0xFF9A5B00),
  );

  static const dark = Quiet(
    canvas: Color(0xFF111113),
    surface: Color(0xFF1E1E21),
    surface2: Color(0xFF2A2A2E),
    ink: Color(0xFFF4F4F2),
    ink2: Color(0xFFA3A3A0),
    ink3: Color(0xFF6E6E6B),
    hairline: Color(0x1AFFFFFF),
    accent: Color(0xFFFF6B35),
    accentSoft: Color(0x29FF6B35),
    primaryFill: Color(0xFFF4F4F2),
    onPrimary: Color(0xFF121212),
    positive: Color(0xFF3DD27A),
    negative: Color(0xFFFF6159),
    warning: Color(0xFFF5B342),
  );

  @override
  Quiet copyWith({Color? accent, Color? accentSoft}) => Quiet(
        canvas: canvas,
        surface: surface,
        surface2: surface2,
        ink: ink,
        ink2: ink2,
        ink3: ink3,
        hairline: hairline,
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        primaryFill: primaryFill,
        onPrimary: onPrimary,
        positive: positive,
        negative: negative,
        warning: warning,
      );

  @override
  Quiet lerp(Quiet? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Quiet(
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      hairline: l(hairline, other.hairline),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      primaryFill: l(primaryFill, other.primaryFill),
      onPrimary: l(onPrimary, other.onPrimary),
      positive: l(positive, other.positive),
      negative: l(negative, other.negative),
      warning: l(warning, other.warning),
    );
  }
}

extension QuietContext on BuildContext {
  /// Color roles: `context.q.ink`.
  Quiet get q => Theme.of(this).extension<Quiet>()!;

  /// Text styles: `context.qText.titleLarge`.
  TextTheme get qText => Theme.of(this).textTheme;
}

// ── Spacing, radius, metrics ────────────────────────────────────────

abstract final class QSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  /// Screen margin: matches iOS large titles, inset-grouped lists and M3 compact margins.
  static const double margin = 16;
  static const double lg = 20; // card padding
  static const double xl = 24;
  static const double xxl = 32; // between unrelated sections
  static const double xxxl = 48;
}

abstract final class QRadii {
  static const double s = 8;
  static const double m = 14;
  static const double l = 20;
  static const double xl = 28;

  /// Concentric inner radius for an element inset by [padding] inside a container of [outer] radius.
  static double inner(double outer, double padding) => (outer - padding).clamp(4, outer);
}

abstract final class QMetrics {
  static const double buttonHeight = 52;
  static const double rowMinHeight = 52;
  static const double fieldHeight = 52;
  static const double minTap = 48; // 44 on iOS is the floor; 48 satisfies both
}

abstract final class QMotion {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const curve = Curves.easeOutCubic;
}

// ── Typography ──────────────────────────────────────────────────────
// Platform default family (SF on iOS, Roboto on Android). Personality: set [displayFamily]
// to ONE bundled/google font — applied to display/headline/title-large roles only.

const String? displayFamily = null;

TextTheme _textTheme(Quiet c, TargetPlatform platform) {
  final ios = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  final base = (ios ? Typography.material2021(platform: platform).black : Typography.material2021().black)
      .apply(bodyColor: c.ink, displayColor: c.ink);
  const tabular = [FontFeature.tabularFigures()];
  return base.copyWith(
    // hero — the one focal number
    displayLarge: base.displayLarge?.copyWith(
        fontSize: 56, height: 60 / 56, fontWeight: FontWeight.w600, letterSpacing: -1.1,
        fontFeatures: tabular, fontFamily: displayFamily),
    // largeTitle (headlineMedium too: SliverAppBar.large uses it for the expanded title)
    headlineMedium: base.headlineMedium?.copyWith(
        fontSize: ios ? 34 : 32, height: ios ? 41 / 34 : 40 / 32, fontWeight: FontWeight.w700,
        letterSpacing: ios ? -0.4 : 0, fontFamily: displayFamily),
    headlineLarge: base.headlineLarge?.copyWith(
        fontSize: ios ? 34 : 32, height: ios ? 41 / 34 : 40 / 32, fontWeight: FontWeight.w700,
        letterSpacing: ios ? -0.4 : 0, fontFamily: displayFamily),
    // title
    titleLarge: base.titleLarge?.copyWith(
        fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600, fontFamily: displayFamily),
    // headline (row titles, buttons)
    titleMedium: base.titleMedium?.copyWith(
        fontSize: ios ? 17 : 16, height: ios ? 22 / 17 : 24 / 16, fontWeight: FontWeight.w600, letterSpacing: 0),
    // body
    bodyLarge: base.bodyLarge?.copyWith(
        fontSize: ios ? 17 : 16, height: ios ? 22 / 17 : 24 / 16, fontWeight: FontWeight.w400, letterSpacing: 0),
    // subhead
    bodyMedium: base.bodyMedium?.copyWith(
        fontSize: ios ? 15 : 14, height: 20 / (ios ? 15 : 14), fontWeight: FontWeight.w400, color: c.ink2, letterSpacing: 0),
    // footnote
    bodySmall: base.bodySmall?.copyWith(
        fontSize: ios ? 13 : 12, height: ios ? 18 / 13 : 16 / 12, fontWeight: FontWeight.w400, color: c.ink2, letterSpacing: 0),
    // overline (uppercase group labels — apply .toUpperCase() to the string)
    labelSmall: base.labelSmall?.copyWith(
        fontSize: ios ? 12 : 11, height: 16 / (ios ? 12 : 11), fontWeight: FontWeight.w600, letterSpacing: 0.7, color: c.ink2),
  );
}

// ── ThemeData ───────────────────────────────────────────────────────

ThemeData quietTheme(Brightness brightness, {TargetPlatform? platform}) {
  final c = brightness == Brightness.dark ? Quiet.dark : Quiet.light;
  final p = platform ?? defaultTargetPlatform;
  final ios = p == TargetPlatform.iOS;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primaryFill,
    onPrimary: c.onPrimary,
    secondary: c.accent,
    onSecondary: c.onPrimary,
    tertiary: c.accent,
    onTertiary: c.onPrimary,
    error: c.negative,
    onError: c.onPrimary,
    surface: c.canvas,
    onSurface: c.ink,
    onSurfaceVariant: c.ink2,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface2,
    surfaceContainerHighest: c.surface2,
    outline: c.ink3,
    outlineVariant: c.hairline,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    platform: p,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.canvas,
    textTheme: _textTheme(c, p),
    extensions: [c],
    splashFactory: ios ? NoSplash.splashFactory : InkSparkle.splashFactory,
    highlightColor: ios ? c.surface2 : null,
    dividerTheme: DividerThemeData(color: c.hairline, thickness: 0.5, space: 0.5),
    appBarTheme: AppBarTheme(
      backgroundColor: c.canvas,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: ios,
      surfaceTintColor: Colors.transparent,
    ),
    // iOS tab bars have no selection pill: selection is ink vs ink2 only (eval finding: the M3 pill
    // reads as "Material on iOS").
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.canvas,
      indicatorColor: ios ? Colors.transparent : c.surface2,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.ink)),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.ink : c.ink2)),
    ),
    // Capsule chips per mobile-ui components §14: no checkmark, selection shown by fill.
    chipTheme: ChipThemeData(
      showCheckmark: false,
      backgroundColor: c.surface2,
      selectedColor: c.primaryFill,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      // RawChip resolves state from the label *color*, so it must be a WidgetStateColor.
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? c.onPrimary : c.ink),
      ),
      padding: const EdgeInsets.symmetric(horizontal: QSpace.xs),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.positive : c.ink3.withValues(alpha: 0.35)),
      thumbColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.canvas,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.ink3,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(QRadii.xl))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.primaryFill,
      contentTextStyle: TextStyle(color: c.onPrimary, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: QSpace.md, vertical: 15),
      hintStyle: TextStyle(color: c.ink3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(QRadii.m), borderSide: BorderSide(color: c.hairline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(QRadii.m), borderSide: BorderSide(color: c.hairline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(QRadii.m), borderSide: BorderSide(color: c.ink, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(QRadii.m), borderSide: BorderSide(color: c.negative, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(QRadii.m), borderSide: BorderSide(color: c.negative, width: 1.5)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.surface : c.surface2),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.ink : c.ink2),
        side: WidgetStatePropertyAll(BorderSide(color: c.surface2)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    }),
    cupertinoOverrideTheme: CupertinoThemeData(primaryColor: c.ink, brightness: brightness),
  );
}
