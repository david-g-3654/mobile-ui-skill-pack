// DesignSystem.swift — mobile-ui "Quiet" skin for SwiftUI (iOS 17+).
// Copy into the app target. Screens use these roles only: no raw hex, no raw font sizes.
// To rebrand: change `accent` (and optionally the neutrals) below. See mobile-ui/references/style-guide.md.

import SwiftUI
import UIKit

// MARK: - Color roles

extension Color {
    /// Builds a light/dark adaptive color from two hex values.
    static func qAdaptive(light: UInt32, dark: UInt32, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkAlpha)
                : UIColor(hex: light, alpha: lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

/// Semantic color roles. Use `QPalette.ink`, never `Color.black` or `Color(hex:)` in screens.
enum QPalette {
    static let canvas      = Color.qAdaptive(light: 0xF5F5F2, dark: 0x111113)
    static let surface     = Color.qAdaptive(light: 0xFFFFFF, dark: 0x1E1E21)
    static let surface2    = Color.qAdaptive(light: 0xEDEDEA, dark: 0x2A2A2E)
    static let ink         = Color.qAdaptive(light: 0x121212, dark: 0xF4F4F2)
    static let ink2        = Color.qAdaptive(light: 0x5E5E5B, dark: 0xA3A3A0)
    /// Placeholder and disabled only — never information.
    static let ink3        = Color.qAdaptive(light: 0x9B9B97, dark: 0x6E6E6B)
    static let hairline    = Color.qAdaptive(light: 0x121212, dark: 0xFFFFFF, lightAlpha: 0.10, darkAlpha: 0.10)
    /// Editorial accent: ≤2 elements per screen.
    static let accent      = Color.qAdaptive(light: 0xC2410C, dark: 0xFF6B35)
    static let accentSoft  = Color.qAdaptive(light: 0xC2410C, dark: 0xFF6B35, lightAlpha: 0.10, darkAlpha: 0.16)
    static let primaryFill = Color.qAdaptive(light: 0x121212, dark: 0xF4F4F2)
    static let onPrimary   = Color.qAdaptive(light: 0xFFFFFF, dark: 0x121212)
    static let positive    = Color.qAdaptive(light: 0x1E7F46, dark: 0x3DD27A)
    static let negative    = Color.qAdaptive(light: 0xC8312A, dark: 0xFF6159)
    static let warning     = Color.qAdaptive(light: 0x9A5B00, dark: 0xF5B342)
}

// MARK: - Typography
// Built on iOS text styles so Dynamic Type works for free.
// Personality: set `QTypeface.display` to .serif, .rounded or .monospaced for display sizes only.

enum QTypeface {
    static let display: Font.Design = .default
}

extension Font {
    static var dsLargeTitle: Font { .system(.largeTitle, design: QTypeface.display, weight: .bold) }
    static var dsTitle: Font      { .system(.title2, design: QTypeface.display, weight: .semibold) }
    static var dsHeadline: Font   { .system(.headline) }
    static var dsBody: Font       { .system(.body) }
    static var dsSubhead: Font    { .system(.subheadline) }
    static var dsFootnote: Font   { .system(.footnote) }
    static var dsOverline: Font   { .system(.caption, weight: .semibold) }
}

/// The one focal number on a screen. Scales with Dynamic Type via @ScaledMetric.
struct QHeroText: View {
    let text: String
    var size: CGFloat = 56
    @ScaledMetric(relativeTo: .largeTitle) private var scale: CGFloat = 1

    var body: some View {
        Text(text)
            .font(.system(size: size * scale, weight: .semibold, design: QTypeface.display))
            .monospacedDigit()
            .tracking(-size * 0.02)
            .foregroundStyle(QPalette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}

extension View {
    /// UPPERCASE group label (the only place caps are allowed).
    func qOverlineStyle() -> some View {
        self.font(.dsOverline)
            .textCase(.uppercase)
            .tracking(0.7)
            .foregroundStyle(QPalette.ink2)
    }
}

// MARK: - Spacing, radius, layout

enum QSpace {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    /// Screen margin: matches iOS large titles, inset-grouped lists and M3 compact margins.
    static let margin: CGFloat = 16
    static let lg: CGFloat = 20   // card padding
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32  // between unrelated sections
    static let xxxl: CGFloat = 48
}

enum QRadius {
    static let s: CGFloat = 8
    static let m: CGFloat = 14
    static let l: CGFloat = 20
    static let xl: CGFloat = 28

    /// Concentric inner radius for an element inset by `padding` inside a container of `outer` radius.
    static func inner(_ outer: CGFloat, padding: CGFloat) -> CGFloat { max(4, outer - padding) }
}

enum QMetrics {
    static let buttonHeight: CGFloat = 52
    static let rowMinHeight: CGFloat = 52
    static let fieldHeight: CGFloat = 52
    static let minTap: CGFloat = 44
}

// MARK: - QMotion

enum QMotion {
    static let snappy: Animation = .snappy(duration: 0.2)
    static let smooth: Animation = .smooth(duration: 0.3)
    static let celebrate: Animation = .bouncy(duration: 0.5)
}

// MARK: - Screen scaffolding

extension View {
    /// Canvas background for scroll views and lists (hides the default list background).
    func qCanvasBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(QPalette.canvas.ignoresSafeArea())
    }
}
