import SwiftUI

// MARK: - Models

fileprivate struct SneakerColorway: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let primary: Color
    let accent: Color
    let sole: Color
}

fileprivate struct SneakerSize: Identifiable, Hashable {
    let id = UUID()
    let us: Double
    let inStock: Bool
    var label: String {
        us.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", us) : String(format: "%.1f", us)
    }
}

fileprivate struct Review: Identifiable {
    let id = UUID()
    let author: String
    let rating: Int
    let date: String
    let title: String
    let body: String
    let fit: String
}

fileprivate struct Sneaker {
    let brand: String
    let name: String
    let category: String
    let price: Double
    let originalPrice: Double?
    let rating: Double
    let reviewCount: Int
    let description: String
    let highlights: [(String, String)]
    let colorways: [SneakerColorway]
    let sizes: [SneakerSize]
    let reviews: [Review]
    let styleCode: String
}

fileprivate enum SampleData {
    static let sneaker = Sneaker(
        brand: "Stride Athletics",
        name: "Aero Runner 2",
        category: "Men's Road Running Shoe",
        price: 129.99,
        originalPrice: 160.00,
        rating: 4.6,
        reviewCount: 1284,
        description: "Built for daily miles, the Aero Runner 2 pairs a responsive nitrogen-infused foam midsole with an engineered knit upper that breathes where you need it and locks down where you don't. A redesigned heel counter adds stability without the weight, so long runs feel just as fresh at mile 12 as they did at mile one.",
        highlights: [
            ("bolt.fill", "Responsive foam"),
            ("wind", "Breathable knit"),
            ("scalemass", "8.9 oz (US 9)"),
            ("arrow.down.right", "8 mm drop")
        ],
        colorways: [
            SneakerColorway(name: "Volt Glow", primary: Color(red: 0.86, green: 0.95, blue: 0.20), accent: Color(red: 0.10, green: 0.10, blue: 0.12), sole: .white),
            SneakerColorway(name: "Midnight Navy", primary: Color(red: 0.12, green: 0.17, blue: 0.35), accent: Color(red: 0.98, green: 0.45, blue: 0.25), sole: Color(white: 0.92)),
            SneakerColorway(name: "Triple White", primary: Color(white: 0.96), accent: Color(white: 0.80), sole: Color(white: 0.88)),
            SneakerColorway(name: "Ember Red", primary: Color(red: 0.86, green: 0.18, blue: 0.20), accent: .white, sole: Color(white: 0.15))
        ],
        sizes: [7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 13].map {
            SneakerSize(us: $0, inStock: ![7.5, 11.5, 13].contains($0))
        },
        reviews: [
            Review(author: "Marcus T.", rating: 5, date: "Sep 28, 2026", title: "Best daily trainer I've owned", body: "Logged about 120 miles so far and the cushioning still feels springy. Upper is super breathable on hot days.", fit: "True to size"),
            Review(author: "Priya S.", rating: 4, date: "Sep 12, 2026", title: "Great ride, snug toe box", body: "Love the bounce on tempo runs. If you have wider feet consider going up half a size.", fit: "Runs slightly small"),
            Review(author: "Dan K.", rating: 5, date: "Aug 30, 2026", title: "Light and stable", body: "Finally a lightweight shoe that doesn't feel wobbly on the heel. The Volt colorway pops in person.", fit: "True to size")
        ],
        styleCode: "AR2-7741-700"
    )
}

// MARK: - Screen

struct S_detail: View {
    init() {}

    var body: some View {
        NavigationStack {
            ProductDetailView(sneaker: SampleData.sneaker)
        }
    }
}

fileprivate struct ProductDetailView: View {
    let sneaker: Sneaker

    @State private var selectedColor: SneakerColorway
    @State private var selectedSize: SneakerSize?
    @State private var isFavorite = false
    @State private var imagePage = 0
    @State private var showSizeError = false
    @State private var addedToBag = false
    @State private var bagCount = 2
    @State private var expandDescription = false
    @State private var showSizeGuide = false

    init(sneaker: Sneaker) {
        self.sneaker = sneaker
        _selectedColor = State(initialValue: sneaker.colorways[0])
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                gallery
                VStack(alignment: .leading, spacing: 24) {
                    header
                    colorSection
                    sizeSection
                    highlights
                    descriptionSection
                    shippingInfo
                    reviewsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {} label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
                .accessibilityLabel("Back")
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: "Check out the \(sneaker.brand) \(sneaker.name)") {
                    Image(systemName: "square.and.arrow.up")
                }
                Button {} label: {
                    Image(systemName: "bag")
                        .overlay(alignment: .topTrailing) {
                            if bagCount > 0 {
                                Text("\(bagCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 16, minHeight: 16)
                                    .background(Circle().fill(.red))
                                    .offset(x: 9, y: -8)
                            }
                        }
                }
                .accessibilityLabel("Bag, \(bagCount) items")
            }
        }
        .tint(.primary)
        .safeAreaInset(edge: .bottom) { purchaseBar }
        .sheet(isPresented: $showSizeGuide) { SizeGuideSheet() }
        .sensoryFeedback(.success, trigger: addedToBag) { _, new in new }
        .sensoryFeedback(.error, trigger: showSizeError) { _, new in new }
    }

    // MARK: Gallery

    private var gallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $imagePage) {
                ForEach(0..<3, id: \.self) { i in
                    SneakerArt(colorway: selectedColor, angle: i)
                        .padding(36)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 340)
            .background(
                LinearGradient(colors: [selectedColor.primary.opacity(0.18), Color(.secondarySystemBackground)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .animation(.easeInOut(duration: 0.3), value: selectedColor)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i == imagePage ? Color.primary : Color.primary.opacity(0.25))
                        .frame(width: i == imagePage ? 18 : 6, height: 6)
                }
            }
            .animation(.spring(duration: 0.3), value: imagePage)
            .padding(.bottom, 14)
        }
        .overlay(alignment: .topLeading) {
            if let original = sneaker.originalPrice {
                let pct = Int(((original - sneaker.price) / original * 100).rounded())
                Text("\(pct)% OFF")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.red))
                    .padding(16)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { isFavorite.toggle() }
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isFavorite ? .red : .primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .scaleEffect(isFavorite ? 1.08 : 1)
            }
            .padding(16)
            .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sneaker.brand.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
            Text(sneaker.name)
                .font(.system(.title, design: .rounded, weight: .bold))
            Text(sneaker.category)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                StarRow(rating: sneaker.rating, size: 13)
                Text(String(format: "%.1f", sneaker.rating))
                    .font(.subheadline.weight(.semibold))
                Text("(\(sneaker.reviewCount.formatted()) reviews)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rated \(String(format: "%.1f", sneaker.rating)) out of 5, \(sneaker.reviewCount) reviews")

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(sneaker.price, format: .currency(code: "USD"))
                    .font(.title2.weight(.bold))
                if let original = sneaker.originalPrice {
                    Text(original, format: .currency(code: "USD"))
                        .font(.body)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)

            Text("or 4 interest-free payments of \((sneaker.price / 4).formatted(.currency(code: "USD")))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Color

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Color").font(.headline)
                Text(selectedColor.name).foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sneaker.colorways) { cw in
                        Button {
                            withAnimation(.snappy) { selectedColor = cw }
                        } label: {
                            SneakerArt(colorway: cw, angle: 0)
                                .padding(8)
                                .frame(width: 76, height: 60)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(cw == selectedColor ? Color.primary : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(cw.name)
                        .accessibilityAddTraits(cw == selectedColor ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: Size

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Size (US)").font(.headline)
                Spacer()
                Button {
                    showSizeGuide = true
                } label: {
                    Label("Size Guide", systemImage: "ruler")
                        .font(.subheadline.weight(.medium))
                        .underline()
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(sneaker.sizes) { size in
                    SizeChip(size: size, isSelected: selectedSize == size) {
                        withAnimation(.snappy) {
                            selectedSize = size
                            showSizeError = false
                        }
                    }
                }
            }

            if showSizeError {
                Label("Please select a size", systemImage: "exclamationmark.circle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Label("Fits true to size. 82% of customers agree.", systemImage: "checkmark.seal")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Highlights

    private var highlights: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(sneaker.highlights, id: \.1) { item in
                HStack(spacing: 10) {
                    Image(systemName: item.0)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.primary.opacity(0.07)))
                    Text(item.1)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 0)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            }
        }
    }

    // MARK: Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details").font(.headline)
            Text(sneaker.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(expandDescription ? nil : 3)
                .lineSpacing(3)
            Button(expandDescription ? "Show less" : "Read more") {
                withAnimation(.easeInOut) { expandDescription.toggle() }
            }
            .font(.subheadline.weight(.semibold))
            .buttonStyle(.plain)
            Text("Style: \(sneaker.styleCode)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: Shipping

    private var shippingInfo: some View {
        VStack(spacing: 0) {
            InfoRow(icon: "shippingbox", title: "Free shipping", subtitle: "Arrives Fri, Oct 17 – Tue, Oct 21")
            Divider().padding(.leading, 48)
            InfoRow(icon: "arrow.uturn.left", title: "Free 30-day returns", subtitle: "Wear-tested? Still returnable.")
            Divider().padding(.leading, 48)
            InfoRow(icon: "storefront", title: "Pick up in store", subtitle: "In stock at Union Square · 0.8 mi")
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    // MARK: Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Reviews").font(.headline)
                Spacer()
                Button("See all \(sneaker.reviewCount.formatted())") {}
                    .font(.subheadline.weight(.medium))
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", sneaker.rating))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    StarRow(rating: sneaker.rating, size: 11)
                    Text("\(sneaker.reviewCount.formatted()) ratings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    ForEach([(5, 0.72), (4, 0.18), (3, 0.06), (2, 0.02), (1, 0.02)], id: \.0) { star, frac in
                        HStack(spacing: 6) {
                            Text("\(star)").font(.caption2.monospacedDigit()).foregroundStyle(.secondary)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.primary.opacity(0.08))
                                    Capsule().fill(Color.orange).frame(width: geo.size.width * frac)
                                }
                            }
                            .frame(height: 5)
                        }
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))

            ForEach(sneaker.reviews) { review in
                ReviewCard(review: review)
                if review.id != sneaker.reviews.last?.id { Divider() }
            }
        }
    }

    // MARK: Purchase bar

    private var purchaseBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(sneaker.price, format: .currency(code: "USD"))
                    .font(.headline)
                Text(selectedSize.map { "Size \($0.label) · \(selectedColor.name)" } ?? "No size selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Button {
                guard selectedSize != nil else {
                    withAnimation(.snappy) { showSizeError = true }
                    return
                }
                bagCount += 1
                withAnimation(.snappy) { addedToBag = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.snappy) { addedToBag = false }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: addedToBag ? "checkmark" : "bag.badge.plus")
                        .contentTransition(.symbolEffect(.replace))
                    Text(addedToBag ? "Added" : "Add to Bag")
                        .contentTransition(.opacity)
                }
                .font(.headline)
                .foregroundStyle(Color(.systemBackground))
                .frame(width: 170, height: 52)
                .background(Capsule().fill(addedToBag ? Color.green : Color.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }
}

// MARK: - Components

fileprivate struct SneakerArt: View {
    let colorway: SneakerColorway
    let angle: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let side = min(w, h * 2.0)
            ZStack {
                // shadow
                Ellipse()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: side * 0.85, height: side * 0.06)
                    .blur(radius: 6)
                    .offset(y: side * 0.22)

                ZStack {
                    // sole
                    SoleShape()
                        .fill(colorway.sole)
                        .overlay(SoleShape().stroke(Color.black.opacity(0.12), lineWidth: 1))
                    // upper
                    UpperShape()
                        .fill(
                            LinearGradient(colors: [colorway.primary, colorway.primary.opacity(0.82)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(UpperShape().stroke(Color.black.opacity(0.15), lineWidth: 1))
                    // swoosh-like stripe
                    StripeShape()
                        .fill(colorway.accent)
                    // laces
                    LacesShape()
                        .stroke(colorway.accent.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                .frame(width: side, height: side * 0.5)
                .scaleEffect(x: angle == 1 ? -1 : 1, y: 1)
                .rotationEffect(.degrees(angle == 2 ? -12 : 0))
            }
            .frame(width: w, height: h)
        }
        .aspectRatio(2, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

fileprivate struct SoleShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: w * 0.04, y: h * 0.78))
        p.addLine(to: CGPoint(x: w * 0.90, y: h * 0.78))
        p.addQuadCurve(to: CGPoint(x: w * 0.99, y: h * 0.86), control: CGPoint(x: w * 0.99, y: h * 0.78))
        p.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.98), control: CGPoint(x: w * 0.99, y: h * 0.98))
        p.addLine(to: CGPoint(x: w * 0.08, y: h * 0.98))
        p.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * 0.78), control: CGPoint(x: w * 0.0, y: h * 0.96))
        p.closeSubpath()
        return p
    }
}

fileprivate struct UpperShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: w * 0.05, y: h * 0.80))
        p.addQuadCurve(to: CGPoint(x: w * 0.06, y: h * 0.25), control: CGPoint(x: w * 0.0, y: h * 0.45))
        p.addQuadCurve(to: CGPoint(x: w * 0.24, y: h * 0.12), control: CGPoint(x: w * 0.12, y: h * 0.08))
        p.addQuadCurve(to: CGPoint(x: w * 0.36, y: h * 0.30), control: CGPoint(x: w * 0.30, y: h * 0.28))
        p.addLine(to: CGPoint(x: w * 0.60, y: h * 0.42))
        p.addQuadCurve(to: CGPoint(x: w * 0.96, y: h * 0.70), control: CGPoint(x: w * 0.92, y: h * 0.50))
        p.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.80), control: CGPoint(x: w * 0.99, y: h * 0.80))
        p.closeSubpath()
        return p
    }
}

fileprivate struct StripeShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: w * 0.20, y: h * 0.70))
        p.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.48), control: CGPoint(x: w * 0.50, y: h * 0.72))
        p.addQuadCurve(to: CGPoint(x: w * 0.26, y: h * 0.62), control: CGPoint(x: w * 0.48, y: h * 0.60))
        p.closeSubpath()
        return p
    }
}

fileprivate struct LacesShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        for i in 0..<4 {
            let t = CGFloat(i) / 3
            let x = w * (0.38 + 0.18 * t)
            let y = h * (0.32 + 0.10 * t)
            p.move(to: CGPoint(x: x - w * 0.02, y: y + h * 0.06))
            p.addLine(to: CGPoint(x: x + w * 0.03, y: y - h * 0.02))
        }
        return p
    }
}

fileprivate struct SizeChip: View {
    let size: SneakerSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.label)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
                .foregroundStyle(isSelected ? Color(.systemBackground) : (size.inStock ? Color.primary : Color.secondary.opacity(0.6)))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.primary : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.primary.opacity(isSelected ? 0 : 0.18), lineWidth: 1)
                )
                .overlay {
                    if !size.inStock {
                        GeometryReader { g in
                            Path { p in
                                p.move(to: CGPoint(x: 6, y: g.size.height - 6))
                                p.addLine(to: CGPoint(x: g.size.width - 6, y: 6))
                            }
                            .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(!size.inStock)
        .accessibilityLabel("Size \(size.label)\(size.inStock ? "" : ", sold out")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

fileprivate struct StarRow: View {
    let rating: Double
    var size: CGFloat = 12

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                let v = rating - Double(i)
                Image(systemName: v >= 0.75 ? "star.fill" : (v >= 0.25 ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size: size))
                    .foregroundStyle(.orange)
            }
        }
    }
}

fileprivate struct InfoRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

fileprivate struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                StarRow(rating: Double(review.rating), size: 11)
                Spacer()
                Text(review.date).font(.caption).foregroundStyle(.secondary)
            }
            Text(review.title).font(.subheadline.weight(.semibold))
            Text(review.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 6) {
                Text(review.author).font(.caption.weight(.medium))
                Text("·").foregroundStyle(.tertiary)
                Label("Verified buyer", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Spacer()
                Text("Fit: \(review.fit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

fileprivate struct SizeGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let rows: [(String, String, String)] = [
        ("7", "40", "25.0"), ("8", "41", "26.0"), ("9", "42.5", "27.0"),
        ("10", "44", "28.0"), ("11", "45", "29.0"), ("12", "46", "30.0"), ("13", "47.5", "31.0")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 10) {
                        GridRow {
                            Text("US").bold(); Text("EU").bold(); Text("CM").bold()
                        }
                        Divider()
                        ForEach(rows, id: \.0) { r in
                            GridRow {
                                Text(r.0); Text(r.1); Text(r.2)
                            }
                        }
                    }
                    .font(.subheadline.monospacedDigit())
                } footer: {
                    Text("Measure your foot from heel to longest toe. Between sizes? We recommend sizing up.")
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
