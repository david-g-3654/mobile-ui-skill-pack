import SwiftUI

struct S_detail: View {
    @State private var isSaved = false
    @State private var selectedSize: String?
    @State private var activeSheet: SneakerSheet?
    @State private var bagItems: [String: Int] = [:]
    @State private var detailsExpanded = false
    @State private var shippingExpanded = false
    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private var price: String { Self.money(138) }
    private var bagCount: Int { bagItems.values.reduce(0, +) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xl) {
                    SneakerArtwork()
                        .aspectRatio(1, contentMode: .fit)
                        .background(QPalette.surface2)
                        .accessibilityLabel("Pace 01 sneaker, with layered chalk suede, mesh panels and a sculpted stone sole, side view")

                    VStack(alignment: .leading, spacing: QSpace.xxl) {
                        productInformation
                        options
                        productDetails
                    }
                    .padding(.horizontal, QSpace.margin)
                    .padding(.bottom, QSpace.xxl)
                }
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .qCanvasBackground()
            .navigationTitle("Footwear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSaved.toggle()
                    } label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .foregroundStyle(QPalette.ink)
                    }
                    .accessibilityLabel(isSaved ? "Remove Pace 01 from favorites" : "Save Pace 01 to favorites")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: "Still Pace 01 — Chalk / Stone. A suede and mesh everyday sneaker. \(price).") {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share Pace 01")
                }
            }
            .qBottomActionBar {
                Button("Add to bag") {
                    guard let selectedSize else {
                        activeSheet = .sizes
                        return
                    }
                    bagItems[selectedSize, default: 0] += 1
                    activeSheet = .bag
                }
                .buttonStyle(.qPrimary)
                .accessibilityHint(selectedSize == nil ? "Choose your size before adding to bag" : "Adds size US \(selectedSize ?? "") to your bag")
            }
            .sheet(item: $activeSheet) { sheet in
                NavigationStack {
                    Group {
                        switch sheet {
                        case .sizes: sizePicker
                        case .bag: bagContents
                        }
                    }
                    .navigationTitle(sheet == .sizes ? "Select size" : "Your bag")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { activeSheet = nil }
                                .font(.dsHeadline)
                        }
                    }
                }
                .tint(QPalette.ink)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(QRadius.xl)
            }
            .sensoryFeedback(.selection, trigger: selectedSize)
            .sensoryFeedback(.success, trigger: bagCount)
        }
        .tint(QPalette.ink)
    }

    private var productInformation: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            Text("STILL / EVERYDAY SERIES")
                .font(.dsFootnote)
                .tracking(1)
                .foregroundStyle(QPalette.ink2)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Pace 01")
                    Spacer(minLength: QSpace.md)
                    Text(price).monospacedDigit()
                }
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text("Pace 01")
                    Text(price).monospacedDigit()
                }
            }
            .font(.dsTitle)
            .foregroundStyle(QPalette.ink)
            .accessibilityAddTraits(.isHeader)

            (typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs)) : AnyLayout(HStackLayout(spacing: QSpace.xs))) {
                Text("Suede & mesh sneaker")
                if !typeSize.isAccessibilitySize { Spacer(minLength: QSpace.xs) }
                HStack(spacing: QSpace.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(QPalette.accent)
                    Text("4.8 (86)")
                }
            }
            .font(.dsFootnote)
            .foregroundStyle(QPalette.ink2)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Suede and mesh sneaker. Rated 4.8 out of 5 from 86 reviews")
        }
    }

    private var options: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: QSpace.sm) {
                Text("Color")
                Spacer()
                Circle()
                    .fill(QPalette.surface2)
                    .overlay(Circle().strokeBorder(QPalette.ink2, lineWidth: 1))
                    .frame(width: QSpace.lg, height: QSpace.lg)
                    .accessibilityHidden(true)
                Text("Chalk / Stone").foregroundStyle(QPalette.ink2)
            }
            .frame(minHeight: QMetrics.rowMinHeight)
            .accessibilityElement(children: .combine)
            Divider().overlay(QPalette.hairline)
            Button {
                activeSheet = .sizes
            } label: {
                HStack(spacing: QSpace.sm) {
                    Text("Size")
                    Spacer()
                    Text(selectedSize.map { "US \($0)" } ?? "Select size")
                        .foregroundStyle(QPalette.ink2)
                    Image(systemName: "chevron.right")
                        .font(.dsFootnote)
                        .foregroundStyle(QPalette.ink2)
                }
                .frame(minHeight: QMetrics.rowMinHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Size, \(selectedSize.map { "US \($0)" } ?? "not selected")")
            .accessibilityHint("Opens available sizes and fit guidance")
            Divider().overlay(QPalette.hairline)
            Text("Free shipping · 30-day returns")
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                .padding(.top, QSpace.md)
        }
        .font(.dsSubhead)
        .foregroundStyle(QPalette.ink)
    }

    private var productDetails: some View {
        VStack(alignment: .leading, spacing: QSpace.md) {
            DisclosureGroup("Details & fit", isExpanded: $detailsExpanded) {
                Text("Soft suede meets breathable mesh in a quietly layered silhouette. A cushioned footbed and flexible rubber sole make long days feel lighter. Fits true to size; choose your usual US unisex size.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .padding(.top, QSpace.xs)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Divider().overlay(QPalette.hairline)
            DisclosureGroup("Shipping & returns", isExpanded: $shippingExpanded) {
                Text("Complimentary standard shipping arrives in 3–5 business days. Return unworn sneakers in their original box within 30 days for a full refund.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .padding(.top, QSpace.xs)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .font(.dsSubhead)
        .foregroundStyle(QPalette.ink)
    }

    private var sizePicker: some View {
        List {
            Section {
                ForEach(["6", "6.5", "7", "7.5", "8", "8.5", "9", "9.5", "10", "10.5", "11", "12"], id: \.self) { size in
                    Button {
                        selectedSize = size
                        activeSheet = nil
                    } label: {
                        HStack {
                            Text("US \(size)")
                            Spacer()
                            if size == "7.5" {
                                Text("Sold out").foregroundStyle(QPalette.ink2)
                            } else if selectedSize == size {
                                Image(systemName: "checkmark")
                            }
                        }
                        .frame(minHeight: QMetrics.minTap)
                    }
                    .disabled(size == "7.5")
                    .accessibilityLabel("US \(size)\(size == "7.5" ? ", sold out" : "")")
                    .accessibilityAddTraits(selectedSize == size ? .isSelected : [])
                    .listRowBackground(QPalette.surface)
                }
            } header: {
                Text("US unisex sizing")
            } footer: {
                Text("Fits true to size. Between sizes? Choose the larger size for a little more room.")
            }
        }
        .font(.dsSubhead)
        .listStyle(.insetGrouped)
        .qCanvasBackground()
    }

    private var bagContents: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xl) {
                Label("Added to your bag", systemImage: "checkmark.circle")
                    .font(.dsTitle)
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Text("Pace 01").font(.dsHeadline)
                    Text("Chalk / Stone")
                    ForEach(bagItems.keys.sorted { (Double($0) ?? 0) < (Double($1) ?? 0) }, id: \.self) { size in
                        Text("US \(size) · Quantity: \(bagItems[size, default: 0])")
                    }
                    Divider().overlay(QPalette.hairline)
                    LabeledContent("Subtotal", value: Self.money(Double(bagCount) * 138))
                        .font(.dsHeadline)
                        .padding(.top, QSpace.xs)
                }
                .font(.dsSubhead)
                Text("Free standard shipping. Taxes calculated at checkout.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }
            .padding(QSpace.margin)
        }
        .qCanvasBackground()
        .foregroundStyle(QPalette.ink)
        .qBottomActionBar {
            Button("Keep shopping") { activeSheet = nil }
                .buttonStyle(.qPrimary)
        }
    }

    private static func money(_ amount: Double) -> String {
        amount.formatted(.currency(code: "USD").locale(Locale(identifier: "en_US")))
    }
}

fileprivate enum SneakerSheet: String, Identifiable {
    case sizes, bag
    var id: String { rawValue }
}

fileprivate struct SneakerArtwork: View {
    var body: some View {
        Canvas { context, size in
            let scale = size.width / 400
            context.scaleBy(x: scale, y: scale)
            context.translateBy(x: 8, y: 5)

            let ground = Path(ellipseIn: CGRect(x: 43, y: 278, width: 312, height: 20))
            context.fill(ground, with: .color(QPalette.ink.opacity(0.055)))

            var outsole = Path()
            outsole.move(to: CGPoint(x: 35, y: 248))
            outsole.addCurve(to: CGPoint(x: 354, y: 250), control1: CGPoint(x: 125, y: 264), control2: CGPoint(x: 284, y: 272))
            outsole.addQuadCurve(to: CGPoint(x: 362, y: 268), control: CGPoint(x: 367, y: 254))
            outsole.addCurve(to: CGPoint(x: 44, y: 273), control1: CGPoint(x: 293, y: 294), control2: CGPoint(x: 117, y: 295))
            outsole.addQuadCurve(to: CGPoint(x: 35, y: 248), control: CGPoint(x: 29, y: 267))
            outsole.closeSubpath()
            context.fill(outsole, with: .color(QPalette.ink2))

            var upper = Path()
            upper.move(to: CGPoint(x: 36, y: 238))
            upper.addQuadCurve(to: CGPoint(x: 49, y: 159), control: CGPoint(x: 37, y: 183))
            upper.addQuadCurve(to: CGPoint(x: 73, y: 154), control: CGPoint(x: 56, y: 142))
            upper.addCurve(to: CGPoint(x: 130, y: 169), control1: CGPoint(x: 90, y: 175), control2: CGPoint(x: 117, y: 186))
            upper.addLine(to: CGPoint(x: 158, y: 124))
            upper.addQuadCurve(to: CGPoint(x: 183, y: 128), control: CGPoint(x: 170, y: 113))
            upper.addCurve(to: CGPoint(x: 248, y: 205), control1: CGPoint(x: 201, y: 155), control2: CGPoint(x: 213, y: 191))
            upper.addCurve(to: CGPoint(x: 348, y: 230), control1: CGPoint(x: 282, y: 214), control2: CGPoint(x: 336, y: 206))
            upper.addQuadCurve(to: CGPoint(x: 355, y: 254), control: CGPoint(x: 362, y: 240))
            upper.addCurve(to: CGPoint(x: 36, y: 252), control1: CGPoint(x: 272, y: 275), control2: CGPoint(x: 95, y: 270))
            upper.closeSubpath()
            context.fill(upper, with: .color(QPalette.surface))
            context.stroke(upper, with: .color(QPalette.ink2.opacity(0.25)), lineWidth: 1)

            var heel = Path()
            heel.move(to: CGPoint(x: 42, y: 179))
            heel.addQuadCurve(to: CGPoint(x: 80, y: 175), control: CGPoint(x: 64, y: 162))
            heel.addLine(to: CGPoint(x: 125, y: 244))
            heel.addQuadCurve(to: CGPoint(x: 37, y: 240), control: CGPoint(x: 80, y: 253))
            heel.closeSubpath()
            context.fill(heel, with: .color(QPalette.ink2.opacity(0.17)))
            context.stroke(heel, with: .color(QPalette.ink2.opacity(0.22)), lineWidth: 1)

            var panel = Path()
            panel.move(to: CGPoint(x: 103, y: 198))
            panel.addLine(to: CGPoint(x: 151, y: 160))
            panel.addLine(to: CGPoint(x: 239, y: 215))
            panel.addLine(to: CGPoint(x: 213, y: 252))
            panel.addLine(to: CGPoint(x: 125, y: 246))
            panel.closeSubpath()
            context.fill(panel, with: .color(QPalette.ink2.opacity(0.08)))
            context.stroke(panel, with: .color(QPalette.ink2.opacity(0.24)), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

            for column in 0..<17 {
                for row in 0..<7 {
                    let horizontal = CGFloat(column) * 5 + 124
                    let vertical = CGFloat(row) * 5 + 204
                    if horizontal + vertical < 446 {
                        let perforation = Path(ellipseIn: CGRect(x: horizontal, y: vertical, width: 1.3, height: 1.3))
                        context.fill(perforation, with: .color(QPalette.ink2.opacity(0.3)))
                    }
                }
            }

            var toe = Path()
            toe.move(to: CGPoint(x: 241, y: 208))
            toe.addCurve(to: CGPoint(x: 348, y: 231), control1: CGPoint(x: 278, y: 216), control2: CGPoint(x: 332, y: 210))
            toe.addQuadCurve(to: CGPoint(x: 354, y: 251), control: CGPoint(x: 360, y: 241))
            toe.addLine(to: CGPoint(x: 281, y: 260))
            toe.addQuadCurve(to: CGPoint(x: 241, y: 208), control: CGPoint(x: 277, y: 224))
            context.fill(toe, with: .color(QPalette.ink2.opacity(0.12)))
            context.stroke(toe, with: .color(QPalette.ink2.opacity(0.25)), lineWidth: 1)

            var collar = Path()
            collar.move(to: CGPoint(x: 60, y: 158))
            collar.addQuadCurve(to: CGPoint(x: 124, y: 181), control: CGPoint(x: 89, y: 201))
            context.stroke(collar, with: .color(QPalette.ink2), style: StrokeStyle(lineWidth: 9, lineCap: .round))

            var stripe = Path()
            stripe.move(to: CGPoint(x: 136, y: 204))
            stripe.addLine(to: CGPoint(x: 152, y: 193))
            stripe.addLine(to: CGPoint(x: 181, y: 218))
            stripe.addLine(to: CGPoint(x: 211, y: 200))
            stripe.addLine(to: CGPoint(x: 226, y: 210))
            stripe.addLine(to: CGPoint(x: 180, y: 242))
            stripe.closeSubpath()
            context.fill(stripe, with: .color(QPalette.ink2.opacity(0.65)))

            for lace in 0..<5 {
                let offset = CGFloat(lace) * 10
                var lacePath = Path()
                lacePath.move(to: CGPoint(x: 143 + offset, y: 156 + offset * 0.75))
                lacePath.addQuadCurve(to: CGPoint(x: 171 + offset, y: 145 + offset * 0.95), control: CGPoint(x: 160 + offset, y: 143 + offset * 0.8))
                context.stroke(lacePath, with: .color(QPalette.ink2.opacity(0.3)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                context.stroke(lacePath, with: .color(QPalette.surface), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }

            var midsole = Path()
            midsole.move(to: CGPoint(x: 36, y: 248))
            midsole.addCurve(to: CGPoint(x: 355, y: 250), control1: CGPoint(x: 128, y: 269), control2: CGPoint(x: 288, y: 271))
            midsole.addLine(to: CGPoint(x: 357, y: 265))
            midsole.addCurve(to: CGPoint(x: 40, y: 265), control1: CGPoint(x: 265, y: 287), control2: CGPoint(x: 121, y: 283))
            midsole.closeSubpath()
            context.fill(midsole, with: .color(QPalette.surface))
            context.stroke(midsole, with: .color(QPalette.ink2.opacity(0.25)), lineWidth: 1)

            for tread in 0..<22 {
                let horizontal = CGFloat(tread) * 13 + 54
                var groove = Path()
                groove.move(to: CGPoint(x: horizontal, y: 276))
                groove.addLine(to: CGPoint(x: horizontal - 2, y: 281))
                context.stroke(groove, with: .color(QPalette.surface2), lineWidth: 1)
            }
        }
        .rotationEffect(.degrees(-12))
        .padding(.horizontal, QSpace.xs)
    }
}

#Preview("Light") {
    S_detail().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_detail().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_detail().dynamicTypeSize(.accessibility2)
}
