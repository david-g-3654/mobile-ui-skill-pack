// Screen.swift — Sneaker product detail (mobile-ui "Detail" archetype, default Quiet skin).
//
// Job: pick a colour + size and add this pair to the bag.
// Focal: full-bleed product media, then the title/price block.
// Primary: "Add to bag · $148.00", pinned in the bottom action bar.
// Cutting: "Buy now" / inline share buttons (share + save live in the nav bar as glyphs),
// the full spec table (behind "Details"), and inline size radios (sizes open a sheet: 13 > 6 options).

import SwiftUI

// MARK: - Sample data

fileprivate struct Colorway: Identifiable, Hashable {
    let id: String
    let name: String
    let swatch: Color
    let soldOutSizes: Set<Double>
    let lowStock: [Double: Int]
}

fileprivate struct ShoeSize: Identifiable, Hashable {
    let us: Double
    var id: Double { us }
    var usLabel: String { "US " + us.formatted(.number.precision(.fractionLength(0...1))) }
    var euLabel: String { "EU " + (us + 33).formatted(.number.precision(.fractionLength(0...1))) }
}

fileprivate struct MediaAngle: Identifiable {
    let id: Int
    let name: String
    let symbol: String
    let rotation: Double
    let mirrored: Bool
}

fileprivate struct InfoSection: Identifiable {
    let id: String
    let title: String
    let body: String
}

fileprivate struct RelatedItem: Identifiable {
    let id: String
    let name: String
    let colorName: String
    let price: Decimal
    let tint: Color
    let symbol: String
}

fileprivate enum Catalog {
    static let brand = "Halden Running Co."
    static let name = "Fieldline 2 Low suede trainer"
    static let price: Decimal = 148
    static let rating = 4.7
    static let reviewCount = 318

    static let colorways: [Colorway] = [
        Colorway(id: "bone", name: "Bone / gum",
                 swatch: Color(red: 0.91, green: 0.88, blue: 0.80), // mobile-ui: content-color
                 soldOutSizes: [7, 12.5], lowStock: [10.5: 3, 11: 2]),
        Colorway(id: "black", name: "Washed black",
                 swatch: Color(red: 0.14, green: 0.14, blue: 0.15), // mobile-ui: content-color
                 soldOutSizes: [9.5], lowStock: [8: 1]),
        Colorway(id: "moss", name: "Moss",
                 swatch: Color(red: 0.36, green: 0.42, blue: 0.29), // mobile-ui: content-color
                 soldOutSizes: [8, 8.5, 13], lowStock: [10: 2]),
        Colorway(id: "clay", name: "Clay",
                 swatch: Color(red: 0.71, green: 0.42, blue: 0.30), // mobile-ui: content-color
                 soldOutSizes: [], lowStock: [9: 4]),
    ]

    static let sizes: [ShoeSize] = stride(from: 7.0, through: 13.0, by: 0.5).map { ShoeSize(us: $0) }

    static let angles: [MediaAngle] = [
        MediaAngle(id: 0, name: "Side", symbol: "shoe.fill", rotation: -8, mirrored: false),
        MediaAngle(id: 1, name: "Inner side", symbol: "shoe.fill", rotation: 0, mirrored: true),
        MediaAngle(id: 2, name: "Pair", symbol: "shoe.2.fill", rotation: -4, mirrored: false),
    ]

    static let description = "A low-profile trainer cut from water-repellent pig suede, set on a gum rubber cupsole that's stitched, not glued, so it can be resoled. The padded collar and recycled-mesh lining break in within a week, and the removable cork footbed moulds to your arch over time."

    static let sections: [InfoSection] = [
        InfoSection(id: "details", title: "Details",
                    body: "Upper: water-repellent suede with nubuck overlays\nLining: 100% recycled polyester mesh\nSole: natural gum rubber cupsole, Blake-stitched\nFootbed: removable cork and latex\nWeight: 412 g per shoe (US 9)\nStyle no. HF2-L-0418"),
        InfoSection(id: "fit", title: "Size & fit",
                    body: "Fits true to size. If you're between sizes or have a wide forefoot, go up half a size. The toe box is roomier than the Fieldline 1."),
        InfoSection(id: "shipping", title: "Shipping & returns",
                    body: "Free standard delivery in 2–4 business days. Free returns within 30 days on unworn pairs — print a label from your order page."),
    ]

    static let related: [RelatedItem] = [
        RelatedItem(id: "r1", name: "Fieldline 2 High", colorName: "Bone / gum", price: 162,
                    tint: Color(red: 0.91, green: 0.88, blue: 0.80), symbol: "shoe.fill"), // mobile-ui: content-color
        RelatedItem(id: "r2", name: "Tempo canvas runner", colorName: "Slate", price: 98,
                    tint: Color(red: 0.42, green: 0.47, blue: 0.53), symbol: "shoe.fill"), // mobile-ui: content-color
        RelatedItem(id: "r3", name: "Merino crew socks, 3-pack", colorName: "Oat marl", price: 26.5,
                    tint: Color(red: 0.80, green: 0.74, blue: 0.64), symbol: "shoeprints.fill"), // mobile-ui: content-color
        RelatedItem(id: "r4", name: "Suede care kit", colorName: "One size", price: 19,
                    tint: Color(red: 0.55, green: 0.38, blue: 0.27), symbol: "paintbrush.pointed.fill"), // mobile-ui: content-color
    ]

    /// Studio backdrop behind product media — photography stays on a light sweep in both modes.
    static let studio = Color(red: 0.93, green: 0.93, blue: 0.91) // mobile-ui: content-color
}

fileprivate extension Decimal {
    var usd: String { formatted(.currency(code: "USD")) }
}

// MARK: - Screen

struct S_detail: View {
    @State private var colorway: Colorway = Catalog.colorways[0]
    @State private var size: ShoeSize?
    @State private var page = 0
    @State private var isSaved = false
    @State private var showSizes = false
    @State private var addAfterSizePick = false
    @State private var descriptionExpanded = false
    @State private var expandedSection: String?
    @State private var toast: String?
    @State private var barIsOpaque = false
    @State private var bagCount = 0

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    media
                        .background {
                            GeometryReader { geo in
                                Color.clear.preference(key: MediaBottomKey.self,
                                                       value: geo.frame(in: .named("scroll")).maxY)
                            }
                        }

                    VStack(alignment: .leading, spacing: QSpace.xxl) {
                        titleBlock
                        options
                        descriptionBlock
                        disclosures
                    }
                    .padding(.horizontal, QSpace.margin)
                    .padding(.top, QSpace.xl)

                    related
                        .padding(.top, QSpace.xxl)
                        .padding(.bottom, QSpace.xl)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(MediaBottomKey.self) { maxY in
                let opaque = maxY < 120
                if opaque != barIsOpaque { withAnimation(QMotion.smooth) { barIsOpaque = opaque } }
            }
            .ignoresSafeArea(.container, edges: .top)
            .qCanvasBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(barIsOpaque ? .visible : .hidden, for: .navigationBar)
            .toolbarBackground(QPalette.canvas, for: .navigationBar)
            .toolbar { toolbarContent }
            .qBottomActionBar { addToBagButton }
            .qToast(toast)
            .task(id: toast) {
                guard toast != nil else { return }
                try? await Task.sleep(for: .seconds(2.5))
                toast = nil
            }
            .sheet(isPresented: $showSizes, onDismiss: { addAfterSizePick = false }) {
                SizePickerSheet(colorway: colorway, selected: size) { picked in
                    size = picked
                    showSizes = false
                    if addAfterSizePick { addToBag(picked) }
                }
            }
            .sensoryFeedback(.success, trigger: bagCount)
        }
        .tint(QPalette.ink)
    }

    // MARK: Toolbar

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Fieldline 2 Low")
                .font(.dsHeadline)
                .foregroundStyle(QPalette.ink)
                .opacity(barIsOpaque ? 1 : 0)
                .accessibilityHidden(!barIsOpaque)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                withAnimation(QMotion.snappy) { isSaved.toggle() }
                toast = isSaved ? "Saved to favourites" : "Removed from favourites"
            } label: {
                NavGlyph(systemImage: isSaved ? "heart.fill" : "heart", onMedia: !barIsOpaque)
            }
            .accessibilityLabel(isSaved ? "Remove from favourites" : "Save to favourites")
            .sensoryFeedback(.selection, trigger: isSaved)

            ShareLink(item: URL(string: "https://haldenrunning.example/fieldline-2-low")!,
                      subject: Text(Catalog.name)) {
                NavGlyph(systemImage: "square.and.arrow.up", onMedia: !barIsOpaque)
            }
            .accessibilityLabel("Share trainer")
        }
    }

    // MARK: Media

    private var media: some View {
        TabView(selection: $page) {
            ForEach(Catalog.angles) { angle in
                ProductArt(symbol: angle.symbol, tint: colorway.swatch,
                           rotation: angle.rotation, mirrored: angle.mirrored)
                    .tag(angle.id)
                    .accessibilityElement()
                    .accessibilityLabel("\(Catalog.name) in \(colorway.name), \(angle.name.lowercased()) view")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(4.0 / 4.4, contentMode: .fit)
        .background(Catalog.studio)
        .overlay(alignment: .bottom) { pageDots.padding(.bottom, QSpace.md) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Product photos, \(page + 1) of \(Catalog.angles.count)")
    }

    private var pageDots: some View {
        HStack(spacing: QSpace.xs) {
            ForEach(Catalog.angles) { angle in
                Capsule()
                    .fill(Color(white: 0, opacity: angle.id == page ? 0.75 : 0.2)) // mobile-ui: content-color
                    .frame(width: angle.id == page ? 16 : 6, height: 6)
            }
        }
        .animation(QMotion.snappy, value: page)
        .accessibilityHidden(true)
    }

    // MARK: Title block (3 facts: what, how much, proof)

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text(Catalog.brand).qOverlineStyle()
            Text(Catalog.name)
                .font(.dsTitle)
                .foregroundStyle(QPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: QSpace.sm) { priceText; ratingText }
                VStack(alignment: .leading, spacing: QSpace.xxs) { priceText; ratingText }
            }
            .padding(.top, QSpace.xxs)
        }
    }

    private var priceText: some View {
        Text(Catalog.price.usd)
            .font(.dsTitle)
            .monospacedDigit()
            .foregroundStyle(QPalette.ink)
    }

    private var ratingText: some View {
        HStack(spacing: QSpace.xxs) {
            Image(systemName: "star.fill")
                .foregroundStyle(QPalette.accent)
                .accessibilityHidden(true)
            Text(Catalog.rating.formatted(.number.precision(.fractionLength(1))))
                .foregroundStyle(QPalette.ink)
            Text("(\(Catalog.reviewCount) reviews)")
                .foregroundStyle(QPalette.ink2)
        }
        .font(.dsSubhead)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rated \(Catalog.rating.formatted()) out of 5, \(Catalog.reviewCount) reviews")
    }

    // MARK: Options

    private var options: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: QSpace.xs) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: QSpace.xs) { colourLabel }
                    VStack(alignment: .leading, spacing: QSpace.xxs) { colourLabel }
                }
                HStack(spacing: 0) {
                    ForEach(Catalog.colorways) { option in
                        QSwatch(name: option.name, color: option.swatch, isSelected: option == colorway) {
                            withAnimation(QMotion.snappy) {
                                colorway = option
                                if let s = size, option.soldOutSizes.contains(s.us) { size = nil }
                            }
                        }
                    }
                }
                .padding(.leading, -QSpace.xxs)
            }
            .padding(.vertical, QSpace.sm)

            Divider().overlay(QPalette.hairline)

            Button {
                addAfterSizePick = false
                showSizes = true
            } label: {
                QListRow(title: "Size") {
                    HStack(spacing: QSpace.xs) {
                        Text(size.map { "\($0.usLabel) · \($0.euLabel)" } ?? "Select")
                            .font(.dsBody)
                            .foregroundStyle(size == nil ? QPalette.ink2 : QPalette.ink)
                        Image(systemName: "chevron.right")
                            .font(.dsSubhead)
                            .foregroundStyle(QPalette.ink2)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens the size picker")

            Divider().overlay(QPalette.hairline)

            availabilityLine
                .padding(.top, QSpace.sm)
        }
    }

    @ViewBuilder private var colourLabel: some View {
        Text("Colour").font(.dsBody).foregroundStyle(QPalette.ink)
        Text(colorway.name).font(.dsBody).foregroundStyle(QPalette.ink2)
            .contentTransition(.opacity)
    }

    /// One reassurance line; becomes a stock note once a low-stock size is chosen.
    @ViewBuilder private var availabilityLine: some View {
        if let s = size, let left = colorway.lowStock[s.us] {
            Label("Only \(left) left in \(s.usLabel)", systemImage: "clock")
                .font(.dsSubhead)
                .foregroundStyle(QPalette.warning)
        } else {
            Label("Free delivery by Fri, Oct 18 · Free 30-day returns", systemImage: "shippingbox")
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
        }
    }

    // MARK: Description (3-line preview + More)

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text(Catalog.description)
                .font(.dsBody)
                .foregroundStyle(QPalette.ink)
                .lineSpacing(QSpace.xxs)
                .lineLimit(descriptionExpanded ? nil : 3)
            Button(descriptionExpanded ? "Less" : "More") {
                withAnimation(QMotion.smooth) { descriptionExpanded.toggle() }
            }
            .buttonStyle(QTertiaryButtonStyle(tint: QPalette.ink))
            .padding(.leading, -QSpace.xs)
            .accessibilityLabel(descriptionExpanded ? "Show less description" : "Read full description")
        }
    }

    // MARK: Disclosure sections

    private var disclosures: some View {
        VStack(spacing: 0) {
            Divider().overlay(QPalette.hairline)
            ForEach(Catalog.sections) { section in
                DisclosureRow(section: section, isExpanded: expandedSection == section.id) {
                    withAnimation(QMotion.smooth) {
                        expandedSection = expandedSection == section.id ? nil : section.id
                    }
                }
                Divider().overlay(QPalette.hairline)
            }
        }
    }

    // MARK: Related carousel

    private var related: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            Text("Complete the look")
                .qOverlineStyle()
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, QSpace.margin)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: QSpace.sm) {
                    ForEach(Catalog.related) { item in RelatedTile(item: item) }
                }
                .padding(.horizontal, QSpace.margin)
            }
            .scrollClipDisabled()
        }
    }

    // MARK: Primary action

    private var addToBagButton: some View {
        Button {
            if let size {
                addToBag(size)
            } else {
                addAfterSizePick = true
                showSizes = true
            }
        } label: {
            Text("Add to bag · \(Catalog.price.usd)")
                .monospacedDigit()
        }
        .buttonStyle(.qPrimary)
        .accessibilityHint(size == nil ? "Choose a size first" : "")
    }

    private func addToBag(_ size: ShoeSize) {
        bagCount += 1
        toast = "Added to bag · \(size.usLabel), \(colorway.name)"
    }
}

// MARK: - Helpers

fileprivate struct MediaBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// 36pt glyph on a blurred circle while it sits over media; plain glyph once the bar is opaque.
fileprivate struct NavGlyph: View {
    let systemImage: String
    let onMedia: Bool

    var body: some View {
        Image(systemName: systemImage)
            .font(.dsBody)
            .foregroundStyle(QPalette.ink)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 36, height: 36)
            .background {
                Circle().fill(.ultraThinMaterial).opacity(onMedia ? 1 : 0)
            }
            .frame(minWidth: QMetrics.minTap, minHeight: QMetrics.minTap)
    }
}

/// Stand-in product photography: the shoe rendered in its colourway on a studio sweep.
fileprivate struct ProductArt: View {
    let symbol: String
    let tint: Color
    let rotation: Double
    let mirrored: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Catalog.studio
                Ellipse()
                    .fill(Color(white: 0, opacity: 0.08)) // mobile-ui: content-color
                    .frame(width: geo.size.width * 0.55, height: geo.size.width * 0.06)
                    .blur(radius: 6)
                    .offset(y: geo.size.width * 0.17)
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
                    .overlay {
                        Image(systemName: symbol)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color(white: 0, opacity: 0.12)) // mobile-ui: content-color
                            .mask(LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom))
                    }
                    .frame(width: geo.size.width * 0.66)
                    .scaleEffect(x: mirrored ? -1 : 1, y: 1)
                    .rotationEffect(.degrees(rotation))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

fileprivate struct DisclosureRow: View {
    let section: InfoSection
    let isExpanded: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: toggle) {
                HStack {
                    Text(section.title).font(.dsBody).foregroundStyle(QPalette.ink)
                    Spacer(minLength: QSpace.xs)
                    Image(systemName: isExpanded ? "minus" : "plus")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                        .contentTransition(.symbolEffect(.replace))
                        .accessibilityHidden(true)
                }
                .frame(minHeight: QMetrics.rowMinHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

            if isExpanded {
                Text(section.body)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .lineSpacing(QSpace.xxs)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, QSpace.md)
                    .transition(.opacity)
            }
        }
    }
}

fileprivate struct RelatedTile: View {
    let item: RelatedItem
    @ScaledMetric(relativeTo: .body) private var width: CGFloat = 148

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            ZStack {
                Catalog.studio
                Image(systemName: item.symbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(item.tint)
                    .padding(QSpace.xl)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink)
                    .lineLimit(2, reservesSpace: true)
                Text(item.colorName)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                Text(item.price.usd)
                    .font(.dsSubhead)
                    .monospacedDigit()
                    .foregroundStyle(QPalette.ink)
            }
        }
        .frame(width: min(width, 240))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

fileprivate struct SizePickerSheet: View {
    let colorway: Colorway
    let selected: ShoeSize?
    let onPick: (ShoeSize) -> Void
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .body) private var cellWidth: CGFloat = 96

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.md) {
                    Label("Fits true to size. Between sizes? Go up half.", systemImage: "ruler")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: cellWidth), spacing: QSpace.xs)],
                              spacing: QSpace.xs) {
                        ForEach(Catalog.sizes) { size in
                            SizeCell(size: size,
                                     isSelected: size == selected,
                                     isSoldOut: colorway.soldOutSizes.contains(size.us),
                                     stockLeft: colorway.lowStock[size.us]) {
                                onPick(size)
                            }
                        }
                    }
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.vertical, QSpace.md)
            }
            .qCanvasBackground()
            .navigationTitle("Select size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
        .tint(QPalette.ink)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(QRadius.xl)
        .presentationBackground(QPalette.canvas)
    }
}

fileprivate struct SizeCell: View {
    let size: ShoeSize
    let isSelected: Bool
    let isSoldOut: Bool
    let stockLeft: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(size.usLabel)
                    .font(.dsBody.weight(isSelected ? .semibold : .regular))
                    .strikethrough(isSoldOut)
                Text(isSoldOut ? "Sold out" : (stockLeft.map { "\($0) left" } ?? size.euLabel))
                    .font(.dsFootnote)
                    .foregroundStyle(isSelected ? QPalette.onPrimary : QPalette.ink2)
            }
            .foregroundStyle(isSelected ? QPalette.onPrimary : (isSoldOut ? QPalette.ink2 : QPalette.ink))
            .frame(maxWidth: .infinity, minHeight: 60)
            .padding(.vertical, QSpace.xxs)
            .background(isSelected ? QPalette.primaryFill : QPalette.surface,
                        in: RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: QRadius.m, style: .continuous)
                    .strokeBorder(QPalette.hairline, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: QRadius.m, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSoldOut)
        .accessibilityLabel(size.usLabel + (isSoldOut ? ", sold out" : ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Previews

#Preview("Light") { S_detail() }
#Preview("Dark") { S_detail().preferredColorScheme(.dark) }
#Preview("Large text") { S_detail().dynamicTypeSize(.accessibility2) }
