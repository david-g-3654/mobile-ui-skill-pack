// Screen.swift — Sneaker product detail (mobile-ui "Detail" archetype, default Quiet skin).
// Job: pick a size and add the pair to the bag.
// Focal: full-bleed product media + title/price block. Primary: "Add to bag · $142" (pinned).
// Cut: "Buy now" button, inline reviews (moved behind a disclosure row).

import SwiftUI

// MARK: - Sample data

fileprivate struct Colorway: Identifiable, Hashable {
    let id: String
    let name: String
    /// Product colors (what the shoe physically looks like), not UI roles.
    let upper: Color
    let backdrop: Color
}

fileprivate struct ShoeSize: Identifiable, Hashable {
    let us: Double
    let stock: Int
    var id: Double { us }
    var label: String { us.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(us)) : String(format: "%.1f", us) }
    var isSoldOut: Bool { stock == 0 }
    var isLow: Bool { stock > 0 && stock <= 3 }
}

fileprivate struct RelatedShoe: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let colorway: Colorway
    let symbol: String
}

fileprivate struct InfoSection: Identifiable {
    let id = UUID()
    let title: String
    let lines: [String]
}

fileprivate enum Catalog {
    // Product colorways (photography stand-ins). Physical product colors, kept as data.
    static let bone  = Colorway(id: "bone",  name: "Bone / Gum",
                                upper: .adaptive(light: 0xC2A77C, dark: 0xC2A77C),
                                backdrop: .adaptive(light: 0xEFE9DD, dark: 0x2A2723))
    static let black = Colorway(id: "black", name: "Triple Black",
                                upper: .adaptive(light: 0x1F1F21, dark: 0x0E0E0F),
                                backdrop: .adaptive(light: 0xDEDEDA, dark: 0x3A3A3D))
    static let ember = Colorway(id: "ember", name: "Ember / Sail",
                                upper: .adaptive(light: 0xB9532C, dark: 0xC85F36),
                                backdrop: .adaptive(light: 0xF3E4D7, dark: 0x33251F))
    static let sage  = Colorway(id: "sage",  name: "Sage",
                                upper: .adaptive(light: 0x7A8A6A, dark: 0x8C9C7C),
                                backdrop: .adaptive(light: 0xE5E9DF, dark: 0x252A22))

    static let colorways = [bone, black, ember, sage]

    static let sizes: [ShoeSize] = [
        .init(us: 7, stock: 6), .init(us: 7.5, stock: 0), .init(us: 8, stock: 11),
        .init(us: 8.5, stock: 9), .init(us: 9, stock: 14), .init(us: 9.5, stock: 2),
        .init(us: 10, stock: 3), .init(us: 10.5, stock: 7), .init(us: 11, stock: 5),
        .init(us: 11.5, stock: 0), .init(us: 12, stock: 4), .init(us: 13, stock: 1),
    ]

    static let related: [RelatedShoe] = [
        .init(name: "Meridian 90 Suede", price: "$128", colorway: sage, symbol: "shoe.fill"),
        .init(name: "Courtline Mid", price: "$156", colorway: black, symbol: "shoe.fill"),
        .init(name: "Arc Trail Low", price: "$168", colorway: ember, symbol: "shoe.fill"),
        .init(name: "Meridian 90 Kids", price: "$74", colorway: bone, symbol: "shoe.2.fill"),
    ]

    static let sections: [InfoSection] = [
        .init(title: "Details", lines: [
            "Full-grain leather upper with suede overlays",
            "Recycled polyester lining and padded collar",
            "EVA midsole wedge, 28 mm heel stack",
            "Natural gum rubber cupsole",
            "Style HA-M90-214",
        ]),
        .init(title: "Size & fit", lines: [
            "Runs about half a size large. Between sizes? Go down.",
            "Medium width. The leather softens after a few wears.",
        ]),
        .init(title: "Shipping & returns", lines: [
            "Free standard delivery on orders over $75 (3–5 business days).",
            "Express delivery from $12.40.",
            "Free returns within 30 days on unworn pairs.",
        ]),
        .init(title: "Reviews (1,284)", lines: [
            "4.7 out of 5 · 81% say true to size, 16% say runs large",
            "“Broke in after two days and it’s been my daily pair since.” — Priya R.",
            "“Gum sole picks up dirt, but the leather is excellent for the price.” — Marcus T.",
        ]),
    ]
}

// MARK: - Screen

struct S_detail: View {
    @State private var colorway: Colorway = Catalog.bone
    @State private var size: ShoeSize? = nil
    @State private var isSaved = false
    @State private var showSizes = false
    @State private var descriptionExpanded = false
    @State private var showsCompactBar = false
    @State private var toastMessage: String? = nil
    @State private var addedCount = 0

    private let price = "$142"

    init() {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxl) {
                    ProductMedia(colorway: colorway)
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(key: MediaOffsetKey.self,
                                                       value: proxy.frame(in: .named("scroll")).maxY)
                            }
                        }

                    VStack(alignment: .leading, spacing: Space.xxl) {
                        titleBlock
                        options
                        descriptionBlock
                        infoSections
                    }
                    .padding(.horizontal, Space.margin)

                    related
                }
                .padding(.bottom, Space.xxl)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(MediaOffsetKey.self) { maxY in
                let compact = maxY < 120
                if compact != showsCompactBar {
                    withAnimation(Motion.snappy) { showsCompactBar = compact }
                }
            }
            .ignoresSafeArea(edges: .top)
            .canvasBackground()
            .navigationTitle(showsCompactBar ? "Meridian 90 Low" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(showsCompactBar ? .visible : .hidden, for: .navigationBar)
            .toolbarBackground(Palette.canvas, for: .navigationBar)
            .toolbar { toolbarContent }
            .bottomActionBar {
                Button(action: primaryTapped) {
                    Text(size == nil ? "Select a size" : "Add to bag · \(price)")
                        .contentTransition(.opacity)
                }
                .buttonStyle(.primary)
                .sensoryFeedback(.success, trigger: addedCount)
            }
            .sheet(isPresented: $showSizes) {
                SizePickerSheet(selection: $size) { showSizes = false }
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(Radius.xl)
                    .presentationBackground(Palette.canvas)
            }
            .toast(toastMessage)
        }
        .tint(Palette.ink)
    }

    // MARK: Title block — what it is, how much, one proof point

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text("Halden · Men's lifestyle")
                .overlineStyle()
            Text("Meridian 90 Low")
                .font(.dsTitle)
                .foregroundStyle(Palette.ink)
                .accessibilityAddTraits(.isHeader)
            HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
                Text(price)
                    .font(.dsTitle)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink)
                HStack(spacing: Space.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Palette.accent)
                        .accessibilityHidden(true)
                    Text("4.7")
                        .foregroundStyle(Palette.ink)
                    Text("(1,284)")
                        .foregroundStyle(Palette.ink2)
                }
                .font(.dsSubhead)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rated 4.7 out of 5, 1,284 reviews")
            }
        }
    }

    // MARK: Options — colorway swatches inline (≤6), size as a row → sheet

    private var options: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            VStack(alignment: .leading, spacing: Space.sm) {
                HStack(spacing: Space.xs) {
                    Text("Colour").font(.dsHeadline).foregroundStyle(Palette.ink)
                    Text(colorway.name).font(.dsSubhead).foregroundStyle(Palette.ink2)
                }
                HStack(spacing: Space.sm) {
                    ForEach(Catalog.colorways) { option in
                        SwatchButton(colorway: option, isSelected: option == colorway) {
                            withAnimation(Motion.smooth) { colorway = option }
                        }
                    }
                }
            }

            Divider().overlay(Palette.hairline)

            Button { showSizes = true } label: {
                HStack(spacing: Space.sm) {
                    Text("Size").font(.dsHeadline).foregroundStyle(Palette.ink)
                    Spacer()
                    Text(size.map { "US \($0.label)" } ?? "Select")
                        .font(.dsSubhead)
                        .foregroundStyle(size == nil ? Palette.ink2 : Palette.ink)
                    Image(systemName: "chevron.right")
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: Metrics.minTap)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(size.map { "Size, US \($0.label)" } ?? "Select size")

            VStack(alignment: .leading, spacing: Space.xs) {
                if let size, size.isLow {
                    Label("Only \(size.stock) left in US \(size.label)", systemImage: "exclamationmark.circle")
                        .foregroundStyle(Palette.warning)
                }
                Label("Free delivery by \(deliveryDate) · Free 30-day returns", systemImage: "shippingbox")
                    .foregroundStyle(Palette.ink2)
            }
            .font(.dsSubhead)
            .symbolRenderingMode(.hierarchical)
        }
    }

    private var deliveryDate: String {
        let date = Calendar.current.date(byAdding: .day, value: 3, to: .now) ?? .now
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    // MARK: Description — 3-line preview + More

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text("A ’90s court silhouette rebuilt for all-day city miles. Full-grain leather sits on a soft EVA wedge, and the natural gum outsole grips wet pavement without the squeak. Padded collar, cushioned footbed, and laces that hold their knot.")
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
                .lineLimit(descriptionExpanded ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)
            Button(descriptionExpanded ? "Less" : "More") {
                withAnimation(Motion.smooth) { descriptionExpanded.toggle() }
            }
            .buttonStyle(TertiaryButtonStyle(tint: Palette.ink))
            .padding(.leading, -Space.xs)
        }
    }

    // MARK: Disclosure sections

    private var infoSections: some View {
        VStack(spacing: 0) {
            Divider().overlay(Palette.hairline)
            ForEach(Catalog.sections) { section in
                AccordionRow(section: section)
                Divider().overlay(Palette.hairline)
            }
        }
    }

    // MARK: Related carousel

    private var related: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "More from Halden")
                .padding(.horizontal, Space.margin)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Space.sm) {
                    ForEach(Catalog.related) { item in
                        RelatedCard(item: item)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, Space.margin, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
        }
    }

    // MARK: Toolbar — two glyphs: save, share

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                withAnimation(Motion.snappy) { isSaved.toggle() }
            } label: {
                GlyphCircle(systemImage: isSaved ? "heart.fill" : "heart", isFloating: !showsCompactBar)
                    .contentTransition(.symbolEffect(.replace))
            }
            .sensoryFeedback(.selection, trigger: isSaved)
            .accessibilityLabel(isSaved ? "Remove from saved" : "Save sneaker")

            ShareLink(item: "Halden Meridian 90 Low in \(colorway.name) — \(price)") {
                GlyphCircle(systemImage: "square.and.arrow.up", isFloating: !showsCompactBar)
            }
            .accessibilityLabel("Share sneaker")
        }
    }

    // MARK: Actions

    private func primaryTapped() {
        guard let size else {
            showSizes = true
            return
        }
        addedCount += 1
        toastMessage = "Added US \(size.label) to bag"
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            toastMessage = nil
        }
    }
}

// MARK: - Media

fileprivate struct ProductMedia: View {
    let colorway: Colorway
    @State private var page = 0

    private let angles: [(symbol: String, mirrored: Bool, tilt: Double, label: String)] = [
        ("shoe.fill", false, 0, "Side view"),
        ("shoe.fill", true, -10, "Inside view"),
        ("shoe.2.fill", false, 0, "Pair view"),
    ]

    var body: some View {
        TabView(selection: $page) {
            ForEach(angles.indices, id: \.self) { index in
                let angle = angles[index]
                ZStack {
                    Ellipse()
                        .fill(Palette.ink.opacity(0.08))
                        .frame(width: 220, height: 20)
                        .offset(y: 92)
                    Image(systemName: angle.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .foregroundStyle(colorway.upper)
                        .scaleEffect(x: angle.mirrored ? -1 : 1, y: 1)
                        .rotationEffect(.degrees(angle.tilt))
                }
                .offset(y: Space.md)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(index)
                .accessibilityElement()
                .accessibilityLabel("Meridian 90 Low in \(colorway.name), \(angle.label.lowercased())")
                .accessibilityAddTraits(.isImage)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(alignment: .bottomTrailing) {
            PageDots(count: angles.count, current: page)
                .padding(Space.md)
        }
        .background(colorway.backdrop)
        .aspectRatio(4.0 / 5.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: Space.xxs) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Palette.ink : Palette.ink.opacity(0.25))
                    .frame(width: index == current ? 16 : 6, height: 6)
            }
        }
        .animation(Motion.snappy, value: current)
        .accessibilityElement()
        .accessibilityLabel("Photo \(current + 1) of \(count)")
    }
}

fileprivate struct MediaOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

fileprivate struct GlyphCircle: View {
    let systemImage: String
    var isFloating: Bool

    var body: some View {
        Image(systemName: systemImage)
            .font(.dsSubhead.weight(.semibold))
            .foregroundStyle(Palette.ink)
            .frame(width: 36, height: 36)
            .background {
                if isFloating {
                    Circle().fill(.ultraThinMaterial)
                }
            }
            .frame(minWidth: Metrics.minTap, minHeight: Metrics.minTap)
            .contentShape(Rectangle())
    }
}

// MARK: - Options

fileprivate struct SwatchButton: View {
    let colorway: Colorway
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(colorway.upper)
                .overlay(Circle().strokeBorder(Palette.hairline, lineWidth: 1))
                .frame(width: 32, height: 32)
                .padding(Space.xxs)
                .overlay {
                    Circle().strokeBorder(isSelected ? Palette.ink : .clear, lineWidth: 2)
                }
                .frame(minWidth: Metrics.minTap, minHeight: Metrics.minTap)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(colorway.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

fileprivate struct SizePickerSheet: View {
    @Binding var selection: ShoeSize?
    let onDone: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: Space.xs)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.md) {
                    Text("US men's sizes. Runs about half a size large.")
                        .font(.dsSubhead)
                        .foregroundStyle(Palette.ink2)
                    LazyVGrid(columns: columns, spacing: Space.xs) {
                        ForEach(Catalog.sizes) { size in
                            SizeCell(size: size, isSelected: selection == size) {
                                selection = size
                                onDone()
                            }
                        }
                    }
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.xs)
            }
            .canvasBackground()
            .navigationTitle("Select size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDone).fontWeight(.semibold)
                }
            }
        }
        .tint(Palette.ink)
    }
}

fileprivate struct SizeCell: View {
    let size: ShoeSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(size.label)
                    .font(.dsHeadline)
                    .monospacedDigit()
                    .strikethrough(size.isSoldOut)
                if size.isLow {
                    Text("\(size.stock) left")
                        .font(.dsSubhead)
                        .foregroundStyle(isSelected ? Palette.onPrimary : Palette.warning)
                }
            }
            .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
            .foregroundStyle(isSelected ? Palette.onPrimary : (size.isSoldOut ? Palette.ink3 : Palette.ink))
            .background(isSelected ? Palette.primaryFill : Palette.surface,
                        in: RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                    .strokeBorder(Palette.hairline, lineWidth: isSelected ? 0 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(size.isSoldOut)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var accessibilityText: String {
        if size.isSoldOut { return "US \(size.label), sold out" }
        if size.isLow { return "US \(size.label), only \(size.stock) left" }
        return "US \(size.label)"
    }
}

// MARK: - Disclosure

fileprivate struct AccordionRow: View {
    let section: InfoSection
    @State private var isOpen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(Motion.smooth) { isOpen.toggle() }
            } label: {
                HStack {
                    Text(section.title)
                        .font(.dsHeadline)
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.dsSubhead.weight(.semibold))
                        .foregroundStyle(Palette.ink2)
                        .rotationEffect(.degrees(isOpen ? 45 : 0))
                        .accessibilityHidden(true)
                }
                .frame(minHeight: Metrics.rowMinHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isOpen ? "Expanded" : "Collapsed")

            if isOpen {
                VStack(alignment: .leading, spacing: Space.xs) {
                    ForEach(section.lines, id: \.self) { line in
                        Text(line)
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, Space.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Related

fileprivate struct RelatedCard: View {
    let item: RelatedShoe

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Image(systemName: item.symbol)
                .resizable()
                .scaledToFit()
                .foregroundStyle(item.colorway.upper)
                .padding(Space.lg)
                .frame(width: 160, height: 160)
                .background(item.colorway.backdrop,
                            in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(item.name)
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text(item.price)
                    .font(.dsSubhead)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink2)
            }
        }
        .frame(width: 160, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews

#Preview("Light") { S_detail() }
#Preview("Dark") { S_detail().preferredColorScheme(.dark) }
#Preview("Large text") { S_detail().dynamicTypeSize(.accessibility2) }
