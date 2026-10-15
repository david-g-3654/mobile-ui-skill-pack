// Screen.swift — Sneaker product detail (mobile-ui "Detail" archetype, default Quiet skin).
// Job: pick a colour and size, then add to bag.
// Focal: full-bleed product media + name/price block. Primary: pinned "Add to bag · $price".
// Cut: "Buy now" / wishlist / share buttons in content (save + share live as nav glyphs);
// long copy lives behind disclosure rows.

import SwiftUI

// MARK: - Root

struct S_detail: View {
    init() {}

    var body: some View {
        NavigationStack {
            ProductDetailView(product: Sneaker.meridian)
        }
        .tint(Palette.ink)
    }
}

// MARK: - Model

/// Literal material colours of the product (content data, not UI roles) — identical in light and dark,
/// because a black shoe is black in both modes.
fileprivate enum Dye {
    static let moss    = Color.adaptive(light: 0x4F5E3C, dark: 0x4F5E3C)
    static let onyx    = Color.adaptive(light: 0x1B1B1D, dark: 0x1B1B1D)
    static let glacier = Color.adaptive(light: 0xAEBCC6, dark: 0xAEBCC6)
    static let ember   = Color.adaptive(light: 0xB24A2C, dark: 0xB24A2C)
    static let sand    = Color.adaptive(light: 0xC9B48F, dark: 0xC9B48F)
    static let slate   = Color.adaptive(light: 0x55606B, dark: 0x55606B)
}

fileprivate struct Colorway: Identifiable, Hashable {
    let id: String
    let name: String
    let dye: Color
}

fileprivate struct SizeOption: Identifiable, Hashable {
    enum Stock { case available, low(Int), soldOut }
    let us: String
    let stock: Stock
    var id: String { us }

    var isSoldOut: Bool { if case .soldOut = stock { return true } else { return false } }
    var unitsLeft: Int? { if case .low(let n) = stock { return n } else { return nil } }

    static func == (a: SizeOption, b: SizeOption) -> Bool { a.us == b.us }
    func hash(into h: inout Hasher) { h.combine(us) }
}

fileprivate struct MediaView: Identifiable {
    let id: Int
    let symbol: String
    let mirrored: Bool
    let caption: String
}

fileprivate struct Sneaker: Identifiable, Hashable {
    let id: String
    let brand: String
    let name: String
    let category: String
    let price: Decimal
    let rating: Double
    let reviewCount: Int
    let colorways: [Colorway]
    let sizes: [SizeOption]
    let summary: String
    let details: [String]
    let fit: [String]
    let delivery: [String]

    static func == (a: Sneaker, b: Sneaker) -> Bool { a.id == b.id }
    func hash(into h: inout Hasher) { h.combine(id) }

    var priceText: String { price.formatted(.currency(code: "USD")) }

    static let media: [MediaView] = [
        MediaView(id: 0, symbol: "shoe.fill", mirrored: false, caption: "Side profile"),
        MediaView(id: 1, symbol: "shoe.fill", mirrored: true, caption: "Medial side"),
        MediaView(id: 2, symbol: "shoe.2.fill", mirrored: false, caption: "Pair, three-quarter view"),
        MediaView(id: 3, symbol: "shoeprints.fill", mirrored: false, caption: "Outsole lug pattern"),
    ]

    private static let menSizes: [SizeOption] = [
        .init(us: "7", stock: .soldOut), .init(us: "7.5", stock: .available),
        .init(us: "8", stock: .available), .init(us: "8.5", stock: .available),
        .init(us: "9", stock: .available), .init(us: "9.5", stock: .low(3)),
        .init(us: "10", stock: .available), .init(us: "10.5", stock: .low(2)),
        .init(us: "11", stock: .available), .init(us: "11.5", stock: .soldOut),
        .init(us: "12", stock: .available), .init(us: "13", stock: .low(1)),
    ]

    private static let standardDelivery = [
        "Free standard delivery on orders over $75, 3–5 business days.",
        "Free returns within 30 days, unworn and in the original box.",
        "Express delivery available at checkout for $14.95.",
    ]

    static let meridian = Sneaker(
        id: "meridian-2",
        brand: "Northline Running Co.",
        name: "Meridian 2 trail runner",
        category: "Men's trail running shoe",
        price: 142,
        rating: 4.7,
        reviewCount: 1284,
        colorways: [
            Colorway(id: "moss", name: "Moss / Sand", dye: Dye.moss),
            Colorway(id: "onyx", name: "Onyx / Gum", dye: Dye.onyx),
            Colorway(id: "glacier", name: "Glacier", dye: Dye.glacier),
            Colorway(id: "ember", name: "Ember", dye: Dye.ember),
        ],
        sizes: menSizes,
        summary: "Built for the long way round. A responsive nitrogen-infused midsole keeps its bounce past mile 20, while 4 mm lugs bite into loose gravel and wet roots. The knit upper drains fast after creek crossings and the gusseted tongue keeps grit out.",
        details: [
            "Upper: recycled engineered knit with a TPU toe bumper",
            "Midsole: nitrogen-infused EVA, 8 mm drop",
            "Outsole: sticky rubber with 4 mm multidirectional lugs",
            "Weight: 289 g (US M 9)",
            "Style: NL-M2-304",
        ],
        fit: [
            "Runs true to size. Between sizes? Go half a size up.",
            "Standard width with a roomy toe box for downhill swelling.",
            "Our model is 6'1\" and wears US M 10.",
        ],
        delivery: standardDelivery
    )

    static let related: [Sneaker] = [
        Sneaker(
            id: "ridgeback", brand: "Northline Running Co.", name: "Ridgeback GTX",
            category: "Men's waterproof trail shoe", price: 168, rating: 4.5, reviewCount: 612,
            colorways: [Colorway(id: "slate", name: "Slate", dye: Dye.slate),
                        Colorway(id: "onyx", name: "Onyx", dye: Dye.onyx)],
            sizes: menSizes,
            summary: "A waterproof membrane and a rock plate for winter miles on wet, technical ground. Heavier than the Meridian, but it shrugs off slush and sleet.",
            details: ["Upper: waterproof breathable membrane", "Midsole: EVA with rock plate, 6 mm drop", "Weight: 334 g (US M 9)"],
            fit: ["Runs slightly snug. Consider half a size up for thick socks."],
            delivery: standardDelivery
        ),
        Sneaker(
            id: "tempo-road", brand: "Northline Running Co.", name: "Tempo Road 4",
            category: "Men's road running shoe", price: 128, rating: 4.6, reviewCount: 2051,
            colorways: [Colorway(id: "ember", name: "Ember", dye: Dye.ember),
                        Colorway(id: "glacier", name: "Glacier", dye: Dye.glacier)],
            sizes: menSizes,
            summary: "Light, lively and made for pavement. A daily trainer that is quick enough for intervals on Thursday.",
            details: ["Upper: single-layer mesh", "Midsole: supercritical foam, 10 mm drop", "Weight: 241 g (US M 9)"],
            fit: ["Runs true to size."],
            delivery: standardDelivery
        ),
        Sneaker(
            id: "basecamp", brand: "Northline Running Co.", name: "Basecamp recovery slide",
            category: "Unisex recovery slide", price: 54, rating: 4.3, reviewCount: 397,
            colorways: [Colorway(id: "sand", name: "Sand", dye: Dye.sand)],
            sizes: menSizes,
            summary: "Thick, soft foam for the walk back to the car park after a long day out.",
            details: ["Material: closed-cell foam", "Weight: 180 g (US M 9)"],
            fit: ["Whole sizes only. Between sizes? Go up."],
            delivery: standardDelivery
        ),
    ]
}

// MARK: - Detail screen

fileprivate struct ProductDetailView: View {
    let product: Sneaker

    @State private var colorway: Colorway
    @State private var page = 0
    @State private var selectedSize: SizeOption?
    @State private var showSizeSheet = false
    @State private var isSaved = false
    @State private var addedCount = 0
    @State private var toastMessage: String?

    init(product: Sneaker) {
        self.product = product
        _colorway = State(initialValue: product.colorways[0])
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MediaGallery(colorway: colorway, page: $page)

                VStack(alignment: .leading, spacing: Space.xxl) {
                    TitleBlock(product: product)
                    optionsBlock
                    DescriptionBlock(product: product)
                    if product == .meridian { RelatedCarousel(items: Sneaker.related) }
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.lg)
                .padding(.bottom, Space.xl)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(Palette.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { navGlyphs }
        .bottomActionBar {
            Button(action: primaryAction) {
                Text(ctaTitle).contentTransition(.opacity)
            }
            .buttonStyle(.primary)
            .sensoryFeedback(.success, trigger: addedCount)
        }
        .sheet(isPresented: $showSizeSheet) {
            SizePickerSheet(product: product, selection: $selectedSize)
        }
        .toast(toastMessage)
    }

    // MARK: Primary action

    private var ctaTitle: String {
        selectedSize == nil ? "Choose a size" : "Add to bag · \(product.priceText)"
    }

    private func primaryAction() {
        guard let size = selectedSize else {
            showSizeSheet = true
            return
        }
        addedCount += 1
        toastMessage = "Added US M \(size.us), \(colorway.name)"
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            toastMessage = nil
        }
    }

    // MARK: Nav glyphs (secondary actions)

    @ToolbarContentBuilder
    private var navGlyphs: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                withAnimation(Motion.snappy) { isSaved.toggle() }
            } label: {
                GlyphCircle(systemImage: isSaved ? "heart.fill" : "heart")
            }
            .accessibilityLabel(isSaved ? "Remove from saved" : "Save sneaker")
            .sensoryFeedback(.selection, trigger: isSaved)

            ShareLink(item: "\(product.name) by \(product.brand) — \(product.priceText)") {
                GlyphCircle(systemImage: "square.and.arrow.up")
            }
            .accessibilityLabel("Share sneaker")
        }
    }

    // MARK: Options

    private var optionsBlock: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("Colour").font(.dsBody).foregroundStyle(Palette.ink)
                Spacer()
                Text(colorway.name).font(.dsSubhead).foregroundStyle(Palette.ink2)
            }

            HStack(spacing: Space.xxs) {
                ForEach(product.colorways) { option in
                    Swatch(colorway: option, isSelected: option == colorway) {
                        withAnimation(Motion.snappy) { colorway = option; page = 0 }
                    }
                }
            }
            .padding(.leading, -Space.xxs)

            VStack(spacing: 0) {
                Divider().overlay(Palette.hairline)
                Button { showSizeSheet = true } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Size").font(.dsBody).foregroundStyle(Palette.ink)
                        Spacer()
                        Text(selectedSize.map { "US M \($0.us)" } ?? "Select")
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink2)
                        Image(systemName: "chevron.right")
                            .font(.dsFootnote.weight(.semibold))
                            .foregroundStyle(Palette.ink2)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: Metrics.rowMinHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Size")
                .accessibilityValue(selectedSize.map { "US men's \($0.us)" } ?? "Not selected")
                .accessibilityHint("Opens size chart")
                Divider().overlay(Palette.hairline)
            }

            if let left = selectedSize?.unitsLeft {
                Label("Only \(left) left in this size", systemImage: "exclamationmark.circle")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.warning)
            }

            Label("Free delivery by \(deliveryDate) · Free 30-day returns", systemImage: "shippingbox")
                .font(.dsFootnote)
                .foregroundStyle(Palette.ink2)
                .padding(.top, Space.xxs)
        }
    }

    private var deliveryDate: String {
        let date = Calendar.current.date(byAdding: .day, value: 4, to: .now) ?? .now
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

// MARK: - Media

fileprivate struct MediaGallery: View {
    let colorway: Colorway
    @Binding var page: Int

    var body: some View {
        TabView(selection: $page) {
            ForEach(Sneaker.media) { view in
                ZStack {
                    Palette.surface2
                    Image(systemName: view.symbol)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(colorway.dye)
                        .scaleEffect(x: view.mirrored ? -1 : 1, y: 1)
                        .padding(.horizontal, Space.xxxl)
                        .padding(.top, Space.xxxl + Space.xl)
                        .padding(.bottom, Space.xxxl)
                }
                .tag(view.id)
                .accessibilityElement()
                .accessibilityLabel("\(view.caption), \(colorway.name)")
                .accessibilityAddTraits(.isImage)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .aspectRatio(4.0 / 4.4, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .animation(Motion.smooth, value: colorway)
    }
}

fileprivate struct GlyphCircle: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.dsSubhead.weight(.semibold))
            .foregroundStyle(Palette.ink)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial, in: Circle())
    }
}

// MARK: - Title block (3 facts: what, how much, proof)

fileprivate struct TitleBlock: View {
    let product: Sneaker

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(product.brand).overlineStyle()
            Text(product.name)
                .font(.dsTitle)
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: Space.sm) { price; proof }
                VStack(alignment: .leading, spacing: Space.xxs) { price; proof }
            }
        }
    }

    private var price: some View {
        Text(product.priceText)
            .font(.dsTitle)
            .monospacedDigit()
            .foregroundStyle(Palette.ink)
    }

    private var proof: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.xxs) {
            Image(systemName: "star.fill")
                .font(.dsFootnote)
                .foregroundStyle(Palette.accent)
                .accessibilityHidden(true)
            Text(product.rating.formatted(.number.precision(.fractionLength(1))))
                .font(.dsSubhead.weight(.semibold))
                .foregroundStyle(Palette.ink)
            Text("(\(product.reviewCount.formatted()) reviews)")
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rated \(product.rating.formatted()) out of 5 from \(product.reviewCount.formatted()) reviews")
    }
}

// MARK: - Swatch

fileprivate struct Swatch: View {
    let colorway: Colorway
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(colorway.dye)
                .overlay(Circle().strokeBorder(Palette.hairline, lineWidth: 1))
                .frame(width: 32, height: 32)
                .padding(Space.xxs)
                .overlay {
                    Circle()
                        .strokeBorder(isSelected ? Palette.ink : .clear, lineWidth: 2)
                }
                .frame(width: Metrics.minTap, height: Metrics.minTap)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(colorway.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Description + disclosures

fileprivate struct DescriptionBlock: View {
    let product: Sneaker
    @State private var showFullSummary = false
    @State private var openSection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(product.summary)
                    .font(.dsBody)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(Space.xxs)
                    .lineLimit(showFullSummary ? nil : 3)
                Button(showFullSummary ? "Show less" : "Read more") {
                    withAnimation(Motion.smooth) { showFullSummary.toggle() }
                }
                .buttonStyle(.tertiary)
                .padding(.leading, -Space.xs)
            }

            VStack(spacing: 0) {
                DisclosureRow(title: "Details", lines: product.details, openSection: $openSection)
                DisclosureRow(title: "Size & fit", lines: product.fit, openSection: $openSection)
                DisclosureRow(title: "Delivery & returns", lines: product.delivery, openSection: $openSection)
                Divider().overlay(Palette.hairline)
            }
        }
    }
}

fileprivate struct DisclosureRow: View {
    let title: String
    let lines: [String]
    @Binding var openSection: String?

    private var isOpen: Bool { openSection == title }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().overlay(Palette.hairline)
            Button {
                withAnimation(Motion.smooth) { openSection = isOpen ? nil : title }
            } label: {
                HStack {
                    Text(title).font(.dsBody).foregroundStyle(Palette.ink)
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
            .accessibilityHint(isOpen ? "Collapses section" : "Expands section")

            if isOpen {
                VStack(alignment: .leading, spacing: Space.xs) {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.dsSubhead)
                            .foregroundStyle(Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, Space.md)
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Related carousel

fileprivate struct RelatedCarousel: View {
    let items: [Sneaker]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "More from Northline")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Space.sm) {
                    ForEach(items) { item in
                        NavigationLink {
                            ProductDetailView(product: item)
                        } label: {
                            RelatedTile(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, Space.margin, for: .scrollContent)
            .padding(.horizontal, -Space.margin)
        }
    }
}

fileprivate struct RelatedTile: View {
    let item: Sneaker

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            ZStack {
                Palette.surface
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(item.colorways[0].dye)
                    .padding(Space.lg)
            }
            .frame(width: 148, height: 148)
            .clipShape(RoundedRectangle(cornerRadius: Radius.l, style: .continuous))

            Text(item.name)
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.priceText)
                .font(.dsFootnote)
                .monospacedDigit()
                .foregroundStyle(Palette.ink2)
        }
        .frame(width: 148, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Size sheet

fileprivate struct SizePickerSheet: View {
    let product: Sneaker
    @Binding var selection: SizeOption?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Space.xs), count: typeSize.isAccessibilitySize ? 2 : 4)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    LazyVGrid(columns: columns, spacing: Space.xs) {
                        ForEach(product.sizes) { size in
                            SizeCell(size: size, isSelected: selection == size) {
                                selection = size
                                dismiss()
                            }
                        }
                    }
                    ForEach(product.fit, id: \.self) { line in
                        Text(line)
                            .font(.dsFootnote)
                            .foregroundStyle(Palette.ink2)
                    }
                }
                .padding(.horizontal, Space.margin)
                .padding(.vertical, Space.md)
            }
            .background(Palette.canvas.ignoresSafeArea())
            .navigationTitle("Select US men's size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
        .tint(Palette.ink)
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(Radius.xl)
        .presentationBackground(Palette.canvas)
    }
}

fileprivate struct SizeCell: View {
    let size: SizeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(size.us)
                    .font(.dsBody.weight(isSelected ? .semibold : .regular))
                    .monospacedDigit()
                    .strikethrough(size.isSoldOut)
                if let left = size.unitsLeft {
                    Text("\(left) left")
                        .font(.dsFootnote)
                        .foregroundStyle(isSelected ? Palette.onPrimary : Palette.warning)
                }
            }
            .foregroundStyle(isSelected ? Palette.onPrimary : (size.isSoldOut ? Palette.ink3 : Palette.ink))
            .frame(maxWidth: .infinity, minHeight: Metrics.rowMinHeight)
            .background(
                isSelected ? Palette.primaryFill : Palette.surface,
                in: RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(size.isSoldOut)
        .accessibilityLabel("US \(size.us)")
        .accessibilityValue(size.isSoldOut ? "Sold out" : (size.unitsLeft.map { "\($0) left" } ?? "In stock"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Previews

#Preview("Light") {
    S_detail()
}

#Preview("Dark") {
    S_detail().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_detail().dynamicTypeSize(.accessibility2)
}
