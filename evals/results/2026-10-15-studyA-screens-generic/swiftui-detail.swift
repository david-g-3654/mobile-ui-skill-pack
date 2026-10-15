import SwiftUI

// MARK: - Model

fileprivate struct Colorway: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let primary: Color
    let secondary: Color
    let accent: Color
}

fileprivate struct ShoeSize: Identifiable, Hashable {
    let id = UUID()
    let us: Double
    let inStock: Bool
    let lowStock: Bool

    var label: String {
        us.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", us) : String(format: "%.1f", us)
    }
}

fileprivate struct Review: Identifiable {
    let id = UUID()
    let author: String
    let rating: Int
    let title: String
    let body: String
    let date: String
    let fit: String
}

fileprivate struct Product {
    let brand: String
    let name: String
    let category: String
    let price: Decimal
    let originalPrice: Decimal?
    let rating: Double
    let reviewCount: Int
    let description: String
    let highlights: [(icon: String, title: String, detail: String)]
    let specs: [(String, String)]
    let colorways: [Colorway]
    let sizes: [ShoeSize]
    let reviews: [Review]
}

fileprivate enum SampleData {
    static let product = Product(
        brand: "Stride Lab",
        name: "Aero Glide 3",
        category: "Men's Road Running Shoe",
        price: 139.99,
        originalPrice: 165.00,
        rating: 4.6,
        reviewCount: 1284,
        description: "The Aero Glide 3 pairs a supercritical foam midsole with a breathable engineered mesh upper for a ride that feels light on easy days and snappy when you pick up the pace. A redesigned heel counter locks you in without pressure points.",
        highlights: [
            ("bolt.fill", "Responsive cushioning", "Nitrogen-infused foam returns more energy every stride."),
            ("wind", "Breathable upper", "Engineered mesh keeps feet cool over long miles."),
            ("leaf.fill", "Made with recycled materials", "At least 30% recycled content by weight.")
        ],
        specs: [
            ("Weight", "8.9 oz (252 g)"),
            ("Heel-to-toe drop", "8 mm"),
            ("Stack height", "38 mm / 30 mm"),
            ("Surface", "Road, track"),
            ("Style code", "SL-AG3-104")
        ],
        colorways: [
            Colorway(name: "Volt Rush", primary: Color(red: 0.12, green: 0.14, blue: 0.20), secondary: Color(red: 0.80, green: 0.95, blue: 0.20), accent: Color(red: 0.80, green: 0.95, blue: 0.20)),
            Colorway(name: "Ember Sunset", primary: Color(red: 0.95, green: 0.42, blue: 0.22), secondary: Color(red: 0.99, green: 0.80, blue: 0.40), accent: Color(red: 0.95, green: 0.42, blue: 0.22)),
            Colorway(name: "Glacier", primary: Color(red: 0.30, green: 0.55, blue: 0.90), secondary: Color(red: 0.82, green: 0.92, blue: 1.00), accent: Color(red: 0.30, green: 0.55, blue: 0.90)),
            Colorway(name: "Triple White", primary: Color(white: 0.82), secondary: Color(white: 0.97), accent: Color(white: 0.45))
        ],
        sizes: [
            ShoeSize(us: 7, inStock: true, lowStock: false),
            ShoeSize(us: 7.5, inStock: false, lowStock: false),
            ShoeSize(us: 8, inStock: true, lowStock: false),
            ShoeSize(us: 8.5, inStock: true, lowStock: true),
            ShoeSize(us: 9, inStock: true, lowStock: false),
            ShoeSize(us: 9.5, inStock: true, lowStock: false),
            ShoeSize(us: 10, inStock: true, lowStock: true),
            ShoeSize(us: 10.5, inStock: false, lowStock: false),
            ShoeSize(us: 11, inStock: true, lowStock: false),
            ShoeSize(us: 11.5, inStock: true, lowStock: false),
            ShoeSize(us: 12, inStock: true, lowStock: true),
            ShoeSize(us: 13, inStock: false, lowStock: false)
        ],
        reviews: [
            Review(author: "Marcus T.", rating: 5, title: "Best daily trainer I've owned", body: "Logged 120 miles so far and the foam still feels fresh. Lockdown is excellent and there's zero heel slip.", date: "Sep 28, 2026", fit: "True to size"),
            Review(author: "Priya K.", rating: 4, title: "Great ride, slightly narrow", body: "Super comfortable for tempo runs. The toe box is a little snug, so wide-footed runners may want to go up half a size.", date: "Sep 12, 2026", fit: "Runs small"),
            Review(author: "Dan W.", rating: 5, title: "Light and bouncy", body: "Noticeably lighter than the previous version. Ran a half marathon PR in these.", date: "Aug 30, 2026", fit: "True to size")
        ]
    )
}

// MARK: - Screen

struct S_detail: View {
    init() {}

    var body: some View {
        NavigationStack {
            ProductDetailView(product: SampleData.product)
        }
    }
}

fileprivate struct ProductDetailView: View {
    let product: Product

    @State private var selectedColorway: Colorway
    @State private var selectedSize: ShoeSize?
    @State private var isFavorite = false
    @State private var showSizeError = false
    @State private var addedToBag = false
    @State private var bagCount = 2
    @State private var showSizeGuide = false

    init(product: Product) {
        self.product = product
        _selectedColorway = State(initialValue: product.colorways[0])
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HeroGallery(colorway: selectedColorway)

                VStack(alignment: .leading, spacing: 28) {
                    header
                    colorwaySection
                    sizeSection
                    deliverySection
                    highlightsSection
                    detailsSection
                    reviewsSection
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    withAnimation(.snappy) { isFavorite.toggle() }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? Color.red : Color.primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                .sensoryFeedback(.selection, trigger: isFavorite)

                ShareLink(item: "Check out the \(product.brand) \(product.name)") {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")

                Button {} label: {
                    Image(systemName: "bag")
                        .overlay(alignment: .topTrailing) {
                            if bagCount > 0 {
                                Text("\(bagCount)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(Color.red))
                                    .offset(x: 8, y: -8)
                                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                            }
                        }
                }
                .accessibilityLabel("Bag, \(bagCount) items")
            }
        }
        .safeAreaInset(edge: .bottom) { purchaseBar }
        .sheet(isPresented: $showSizeGuide) { SizeGuideSheet() }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.brand.uppercased())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1.2)
            Text(product.name)
                .font(.largeTitle.bold())
            Text(product.category)
                .font(.body)
                .foregroundStyle(.secondary)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) { priceView; Spacer(minLength: 8); ratingView }
                VStack(alignment: .leading, spacing: 8) { priceView; ratingView }
            }
            .padding(.top, 4)
        }
    }

    private var priceView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(product.price, format: .currency(code: "USD"))
                .font(.title2.bold())
            if let original = product.originalPrice {
                Text(original, format: .currency(code: "USD"))
                    .font(.body)
                    .strikethrough()
                    .foregroundStyle(.secondary)
                Text("-\(discountPercent(original))%")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.red))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(priceAccessibilityLabel)
    }

    private var ratingView: some View {
        HStack(spacing: 6) {
            StarRating(rating: product.rating)
            Text(product.rating, format: .number.precision(.fractionLength(1)))
                .font(.subheadline.bold())
            Text("(\(product.reviewCount.formatted()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rated \(product.rating.formatted()) out of 5, \(product.reviewCount) reviews")
    }

    private var colorwaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Color").font(.headline)
                Text(selectedColorway.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(product.colorways) { colorway in
                        ColorwaySwatch(colorway: colorway, isSelected: colorway == selectedColorway) {
                            withAnimation(.spring(duration: 0.35)) { selectedColorway = colorway }
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 2)
            }
            .sensoryFeedback(.selection, trigger: selectedColorway)
        }
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Select Size (US)").font(.headline)
                Spacer()
                Button {
                    showSizeGuide = true
                } label: {
                    Label("Size Guide", systemImage: "ruler")
                        .font(.subheadline)
                }
            }

            SizeGrid(sizes: product.sizes, selected: $selectedSize)
                .sensoryFeedback(.selection, trigger: selectedSize)

            if showSizeError && selectedSize == nil {
                Label("Please choose a size to continue.", systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if let size = selectedSize, size.lowStock {
                Label("Only a few left in size \(size.label)", systemImage: "flame.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            } else {
                Label("Most runners say this fits true to size.", systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var deliverySection: some View {
        VStack(spacing: 0) {
            InfoRow(icon: "shippingbox", title: "Free delivery", detail: "Arrives Fri, Oct 18 – Mon, Oct 21")
            Divider().padding(.leading, 52)
            InfoRow(icon: "storefront", title: "Pick up in store", detail: "Available today at Union Square")
            Divider().padding(.leading, 52)
            InfoRow(icon: "arrow.uturn.left", title: "Free 30-day returns", detail: "Even if you've worn them outside")
        }
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why you'll love it").font(.title3.bold())
            Text(product.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(product.highlights, id: \.title) { item in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: item.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(selectedColorway.accent == Color(white: 0.45) ? Color.accentColor : selectedColorway.primary)
                        .frame(width: 28)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.subheadline.weight(.semibold))
                        Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Specifications").font(.title3.bold())
            VStack(spacing: 0) {
                ForEach(Array(product.specs.enumerated()), id: \.offset) { index, spec in
                    SpecRow(name: spec.0, value: spec.1)
                    if index < product.specs.count - 1 { Divider() }
                }
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Reviews").font(.title3.bold())
                Spacer()
                Button("See All") {}
                    .font(.subheadline)
            }
            RatingSummary(rating: product.rating, count: product.reviewCount)
            ForEach(product.reviews) { review in
                ReviewCard(review: review)
            }
        }
    }

    private var purchaseBar: some View {
        VStack(spacing: 0) {
            Divider()
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) {
                    barPrice
                    addButton.frame(maxWidth: 260)
                }
                VStack(alignment: .leading, spacing: 10) {
                    barPrice
                    addButton
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }

    private var barPrice: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(product.price, format: .currency(code: "USD"))
                .font(.headline)
            Text(selectedSize.map { "Size \($0.label) · \(selectedColorway.name)" } ?? selectedColorway.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var addButton: some View {
        Button(action: addToBag) {
            Label(addedToBag ? "Added to Bag" : "Add to Bag",
                  systemImage: addedToBag ? "checkmark" : "bag.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(addedToBag ? .green : .primary)
        .foregroundStyle(addedToBag ? Color.white : Color(.systemBackground))
        .sensoryFeedback(.success, trigger: bagCount)
        .sensoryFeedback(.error, trigger: showSizeError) { _, new in new }
    }

    // MARK: Actions & helpers

    private func addToBag() {
        guard selectedSize != nil else {
            withAnimation(.snappy) { showSizeError = true }
            return
        }
        withAnimation(.snappy) {
            showSizeError = false
            addedToBag = true
            bagCount += 1
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.snappy) { addedToBag = false }
        }
    }

    private func discountPercent(_ original: Decimal) -> Int {
        let o = NSDecimalNumber(decimal: original).doubleValue
        let p = NSDecimalNumber(decimal: product.price).doubleValue
        guard o > 0 else { return 0 }
        return Int(((o - p) / o * 100).rounded())
    }

    private var priceAccessibilityLabel: String {
        let now = product.price.formatted(.currency(code: "USD"))
        if let original = product.originalPrice {
            return "Price \(now), was \(original.formatted(.currency(code: "USD"))), \(discountPercent(original)) percent off"
        }
        return "Price \(now)"
    }
}

// MARK: - Hero

fileprivate struct HeroGallery: View {
    let colorway: Colorway
    @State private var page = 0
    @ScaledMetric(relativeTo: .largeTitle) private var heroHeight: CGFloat = 320

    private let angles: [(String, Double, Bool)] = [
        ("Side view", -12, false),
        ("Front angle", 0, true),
        ("Top view", 18, false)
    ]

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $page) {
                ForEach(Array(angles.enumerated()), id: \.offset) { index, angle in
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(colors: [colorway.secondary.opacity(0.55), colorway.primary.opacity(0.25)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Circle()
                            .fill(colorway.secondary.opacity(0.35))
                            .frame(width: 220, height: 220)
                            .blur(radius: 30)
                        Ellipse()
                            .fill(.black.opacity(0.18))
                            .frame(width: 200, height: 22)
                            .blur(radius: 10)
                            .offset(y: 80)
                        Image(systemName: "shoe.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 230)
                            .foregroundStyle(
                                LinearGradient(colors: [colorway.primary, colorway.primary.opacity(0.8), colorway.accent],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .scaleEffect(x: angle.2 ? -1 : 1, y: 1)
                            .rotationEffect(.degrees(angle.1))
                            .shadow(color: .black.opacity(0.2), radius: 12, y: 10)
                    }
                    .padding(.horizontal)
                    .tag(index)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(colorway.name) sneaker, \(angle.0)")
                    .accessibilityAddTraits(.isImage)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: min(max(heroHeight, 300), 420))

            HStack(spacing: 8) {
                ForEach(angles.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Color.primary : Color.secondary.opacity(0.35))
                        .frame(width: i == page ? 20 : 8, height: 8)
                }
            }
            .animation(.snappy, value: page)
            .accessibilityElement()
            .accessibilityLabel("Image \(page + 1) of \(angles.count)")
        }
        .padding(.top, 8)
    }
}

// MARK: - Components

fileprivate struct ColorwaySwatch: View {
    let colorway: Colorway
    let isSelected: Bool
    let action: () -> Void
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 64

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.18)
                    .foregroundStyle(LinearGradient(colors: [colorway.primary, colorway.accent],
                                                    startPoint: .leading, endPoint: .trailing))
            }
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(colorway.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

fileprivate struct SizeGrid: View {
    let sizes: [ShoeSize]
    @Binding var selected: ShoeSize?
    @ScaledMetric(relativeTo: .body) private var minWidth: CGFloat = 72

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minWidth), spacing: 10)], spacing: 10) {
            ForEach(sizes) { size in
                let isSelected = selected == size
                Button {
                    withAnimation(.snappy) { selected = size }
                } label: {
                    Text(size.label)
                        .font(.body.weight(.medium))
                        .strikethrough(!size.inStock)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.vertical, 4)
                        .foregroundStyle(isSelected ? Color(.systemBackground) : (size.inStock ? Color.primary : Color.secondary.opacity(0.6)))
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? Color.primary : Color(.secondarySystemBackground))
                        )
                        .overlay(alignment: .topTrailing) {
                            if size.lowStock && size.inStock {
                                Circle().fill(.orange).frame(width: 7, height: 7).padding(6)
                            }
                        }
                }
                .buttonStyle(.plain)
                .disabled(!size.inStock)
                .accessibilityLabel("US size \(size.label)")
                .accessibilityValue(size.inStock ? (size.lowStock ? "Low stock" : "In stock") : "Sold out")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

fileprivate struct InfoRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.tint)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct SpecRow: View {
    let name: String
    let value: String
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).foregroundStyle(.secondary)
                    Text(value)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text(name).foregroundStyle(.secondary)
                    Spacer(minLength: 12)
                    Text(value).multilineTextAlignment(.trailing)
                }
            }
        }
        .font(.subheadline)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct StarRating: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                let value = Double(i)
                Image(systemName: rating >= value ? "star.fill" : (rating >= value - 0.5 ? "star.leadinghalf.filled" : "star"))
            }
        }
        .font(.caption)
        .foregroundStyle(.orange)
        .accessibilityHidden(true)
    }
}

fileprivate struct RatingSummary: View {
    let rating: Double
    let count: Int
    private let distribution: [Double] = [0.72, 0.17, 0.06, 0.03, 0.02]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 20) { score; bars }
            VStack(alignment: .leading, spacing: 12) { score; bars }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    private var score: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rating, format: .number.precision(.fractionLength(1)))
                .font(.system(.largeTitle, design: .rounded).bold())
            StarRating(rating: rating)
            Text("\(count.formatted()) ratings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Average \(rating.formatted()) out of 5 from \(count) ratings")
    }

    private var bars: some View {
        VStack(spacing: 4) {
            ForEach(Array(distribution.enumerated()), id: \.offset) { index, fraction in
                HStack(spacing: 8) {
                    Text("\(5 - index)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    ProgressView(value: fraction)
                        .tint(.orange)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(5 - index) stars, \(Int(fraction * 100)) percent")
            }
        }
        .frame(minWidth: 140)
    }
}

fileprivate struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StarRating(rating: Double(review.rating))
                Spacer()
                Text(review.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(review.title).font(.subheadline.weight(.semibold))
            Text(review.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 6) {
                Text(review.author).font(.caption.weight(.medium))
                Text("·").foregroundStyle(.secondary)
                Text("Fit: \(review.fit)").font(.caption).foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(review.rating) stars. \(review.title). \(review.body). By \(review.author), \(review.date). Fit: \(review.fit)")
    }
}

fileprivate struct SizeGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let rows: [(us: String, uk: String, eu: String, cm: String)] = [
        ("7", "6", "40", "25.0"), ("8", "7", "41", "26.0"), ("9", "8", "42.5", "27.0"),
        ("10", "9", "44", "28.0"), ("11", "10", "45", "29.0"), ("12", "11", "46", "30.0"), ("13", "12", "47.5", "31.0")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(rows, id: \.us) { row in
                        LabeledContent("US \(row.us)") {
                            Text("UK \(row.uk) · EU \(row.eu) · \(row.cm) cm")
                        }
                    }
                } footer: {
                    Text("Measure your foot from heel to longest toe and choose the size with the closest length in centimeters.")
                }
            }
            .navigationTitle("Size Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    S_detail()
}
