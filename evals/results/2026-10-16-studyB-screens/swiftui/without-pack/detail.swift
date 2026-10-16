import SwiftUI

fileprivate typealias DetailState<Value> = SwiftUI.State<Value>

struct S_detail: View {
    @DetailState private var selectedSize = "9"
    @DetailState private var selectedColor = 0
    @DetailState private var isFavorite = false
    @DetailState private var addedToBag = false
    @DetailState private var showSizeGuide = false

    private let ink = Color(red: 0.13, green: 0.17, blue: 0.14)
    private let sizes = ["7", "7.5", "8", "8.5", "9", "9.5", "10", "10.5", "11", "12"]
    private let colorNames = ["Moss / Chalk", "Clay / Cream", "Ink / Stone"]
    private let colorOptions: [Color] = [Color(red: 0.43, green: 0.49, blue: 0.35), Color(red: 0.65, green: 0.41, blue: 0.30), Color(red: 0.28, green: 0.32, blue: 0.35)]

    init() {}

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    productImage
                    productInfo
                    colorPicker
                    sizePicker
                    shipping
                    descriptionSection
                }
                .padding(.bottom, 24)
            }
            purchaseBar
        }
        .background(Color(red: 0.98, green: 0.975, blue: 0.96))
        .foregroundStyle(ink)
        .sheet(isPresented: $showSizeGuide) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Find your fit").font(.title2.bold())
                    Spacer()
                    Button { showSizeGuide = false } label: { Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.secondary) }
                }
                Text("The Trail 02 fits true to size. Between sizes? We recommend going half a size up.")
                HStack { Text("US MEN"); Spacer(); Text("EU"); Spacer(); Text("FOOT LENGTH") }.font(.caption.bold())
                ForEach([("8", "41", "26 cm"), ("9", "42", "27 cm"), ("10", "43", "28 cm"), ("11", "44", "29 cm")], id: \.0) { row in
                    HStack { Text(row.0); Spacer(); Text(row.1); Spacer(); Text(row.2) }
                    Divider()
                }
                Spacer()
            }.padding(28).presentationDetents([.medium])
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "arrow.left").font(.system(size: 19, weight: .medium)).hidden().overlay {
                Image(systemName: "square.grid.2x2").font(.system(size: 18, weight: .regular))
            }.accessibilityLabel("Collection")
            Spacer()
            Text("STRIDE").font(.system(size: 21, weight: .black, design: .rounded)).tracking(4)
            Spacer()
            Image(systemName: addedToBag ? "bag.fill" : "bag").font(.system(size: 20)).overlay(alignment: .topTrailing) {
                if addedToBag { Circle().fill(Color.orange).frame(width: 7, height: 7).offset(x: 3, y: -2) }
            }.accessibilityLabel(addedToBag ? "Shopping bag, one item" : "Shopping bag")
        }.padding(.horizontal, 25).frame(height: 60)
    }

    private var productImage: some View {
        ZStack(alignment: .top) {
            Color(red: 0.91, green: 0.92, blue: 0.87)
            VStack(spacing: 0) {
                HStack {
                    Text("THE EVERYDAY EXPLORER").font(.system(size: 9, weight: .semibold)).tracking(2)
                    Spacer()
                    Button { isFavorite.toggle() } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 19)).foregroundStyle(isFavorite ? Color(red: 0.65, green: 0.30, blue: 0.23) : ink)
                            .frame(width: 40, height: 40).background(.white.opacity(0.7), in: Circle())
                    }.accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }.padding(.horizontal, 20).padding(.top, 16)
                ZStack {
                    Text("TRAIL").font(.system(size: 89, weight: .black, design: .rounded)).tracking(-5).foregroundStyle(.white.opacity(0.45)).offset(y: -30)
                    SneakerIllustration(accent: colorOptions[selectedColor]).padding(.horizontal, 8).rotationEffect(.degrees(-12))
                }.frame(height: 225)
                HStack(spacing: 6) {
                    Capsule().fill(ink).frame(width: 19, height: 4)
                    Circle().fill(ink.opacity(0.2)).frame(width: 4, height: 4)
                    Circle().fill(ink.opacity(0.2)).frame(width: 4, height: 4)
                }.padding(.bottom, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(.horizontal, 14)
    }

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("NEW SEASON").font(.system(size: 10, weight: .bold)).tracking(1.6).foregroundStyle(Color(red: 0.42, green: 0.46, blue: 0.31))
                Spacer()
                Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(ink)
                Text("4.8").font(.system(size: 12, weight: .semibold))
                Text("(128 reviews)").font(.system(size: 11)).foregroundStyle(.secondary)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Trail 02").font(.system(size: 34, weight: .semibold)).tracking(-1.2)
                Spacer()
                Text("$145").font(.system(size: 24, weight: .medium)).tracking(-0.8)
            }
            Text("Made for the long way home.").font(.system(size: 14)).foregroundStyle(.secondary)
        }.padding(.horizontal, 24)
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("Color").fontWeight(.semibold)
                Text("—  \(colorNames[selectedColor])").foregroundStyle(.secondary)
            }.font(.system(size: 12))
            HStack(spacing: 12) {
                ForEach(colorOptions.indices, id: \.self) { index in
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedColor = index; addedToBag = false } } label: {
                        Circle().fill(colorOptions[index]).frame(width: 25, height: 25)
                            .padding(5)
                            .overlay(Circle().stroke(selectedColor == index ? ink : .clear, lineWidth: 1))
                    }.accessibilityLabel(colorNames[index]).accessibilityAddTraits(selectedColor == index ? .isSelected : [])
                }
            }
        }.padding(.horizontal, 24)
    }

    private var sizePicker: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("Select size").font(.system(size: 13, weight: .semibold))
                Text("US Men").font(.system(size: 11)).foregroundStyle(.secondary)
                Spacer()
                Button { showSizeGuide = true } label: {
                    HStack(spacing: 4) { Image(systemName: "ruler"); Text("Size guide").underline() }.font(.system(size: 11))
                }.tint(ink)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(sizes, id: \.self) { size in
                    Button { selectedSize = size; addedToBag = false } label: {
                        Text(size).font(.system(size: 13, weight: .medium)).frame(maxWidth: .infinity).frame(height: 43)
                            .foregroundStyle(selectedSize == size ? .white : ink)
                            .background(selectedSize == size ? ink : Color.clear, in: RoundedRectangle(cornerRadius: 4))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(ink.opacity(selectedSize == size ? 0 : 0.17), lineWidth: 1))
                    }.accessibilityAddTraits(selectedSize == size ? .isSelected : [])
                }
            }
        }.padding(.horizontal, 24)
    }

    private var shipping: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "shippingbox").font(.system(size: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text("Good things, delivered free.").font(.system(size: 12, weight: .semibold))
                Text("Free shipping & 30-day returns on every pair.").font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(Color(red: 0.93, green: 0.935, blue: 0.90), in: RoundedRectangle(cornerRadius: 6)).padding(.horizontal, 24)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            Text("A little wild. A lot of comfort.").font(.system(size: 18, weight: .semibold))
            Text("City streets to weekend detours. A breathable recycled mesh upper, soft suede overlays, and our cushioned everyday sole keep you moving naturally.")
                .font(.system(size: 13)).foregroundStyle(.secondary).lineSpacing(5)
            HStack(spacing: 7) {
                Image(systemName: "leaf")
                Text("Thoughtfully made with recycled materials")
            }.font(.system(size: 11)).padding(.top, 3)
        }.padding(.horizontal, 24)
    }

    private var purchaseBar: some View {
        Button {
            withAnimation(.spring(response: 0.3)) { addedToBag = true }
        } label: {
            HStack {
                Image(systemName: addedToBag ? "checkmark" : "bag").font(.system(size: 17))
                Spacer()
                Text(addedToBag ? "Added to bag · US \(selectedSize)" : "Add to bag").font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("$145").font(.system(size: 14, weight: .medium))
            }.foregroundStyle(.white).padding(.horizontal, 20).frame(height: 54)
                .background(ink, in: RoundedRectangle(cornerRadius: 5))
        }.padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 10)
            .background(Color(red: 0.98, green: 0.975, blue: 0.96).shadow(color: .black.opacity(0.04), radius: 12, y: -5))
    }
}

fileprivate struct SneakerIllustration: View {
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                Ellipse().fill(.black.opacity(0.17)).frame(width: width * 0.79, height: 15).blur(radius: 10).offset(y: height * 0.34)
                SneakerUpper().fill(Color(red: 0.78, green: 0.77, blue: 0.67))
                SneakerUpper().stroke(Color.black.opacity(0.2), lineWidth: 1)
                Path { path in
                    path.move(to: CGPoint(x: width * 0.12, y: height * 0.60))
                    path.addQuadCurve(to: CGPoint(x: width * 0.37, y: height * 0.38), control: CGPoint(x: width * 0.18, y: height * 0.36))
                    path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.58))
                    path.addLine(to: CGPoint(x: width * 0.29, y: height * 0.73))
                    path.closeSubpath()
                }.fill(accent)
                Path { path in
                    path.move(to: CGPoint(x: width * 0.67, y: height * 0.25))
                    path.addQuadCurve(to: CGPoint(x: width * 0.84, y: height * 0.20), control: CGPoint(x: width * 0.77, y: height * 0.36))
                    path.addLine(to: CGPoint(x: width * 0.92, y: height * 0.61))
                    path.addLine(to: CGPoint(x: width * 0.72, y: height * 0.69))
                    path.closeSubpath()
                }.fill(accent)
                Path { path in
                    path.move(to: CGPoint(x: width * 0.31, y: height * 0.64))
                    path.addLine(to: CGPoint(x: width * 0.43, y: height * 0.47))
                    path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.55))
                    path.addLine(to: CGPoint(x: width * 0.68, y: height * 0.37))
                    path.addLine(to: CGPoint(x: width * 0.73, y: height * 0.48))
                    path.addLine(to: CGPoint(x: width * 0.51, y: height * 0.69))
                    path.closeSubpath()
                }.fill(Color(red: 0.94, green: 0.93, blue: 0.85))
                ForEach(0..<5) { index in
                    let position = CGFloat(index)
                    Path { path in
                        path.move(to: CGPoint(x: width * (0.38 + position * 0.045), y: height * (0.40 - position * 0.034)))
                        path.addLine(to: CGPoint(x: width * (0.45 + position * 0.045), y: height * (0.48 - position * 0.034)))
                    }.stroke(Color(red: 0.95, green: 0.94, blue: 0.87), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
                SneakerSole().fill(Color(red: 0.91, green: 0.88, blue: 0.77))
                SneakerSole().stroke(Color(red: 0.58, green: 0.56, blue: 0.46), lineWidth: 1)
                Path { path in
                    path.move(to: CGPoint(x: width * 0.08, y: height * 0.78))
                    path.addQuadCurve(to: CGPoint(x: width * 0.94, y: height * 0.73), control: CGPoint(x: width * 0.50, y: height * 0.91))
                }.stroke( accent.opacity(0.9), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                ForEach(0..<18) { index in
                    let position = CGFloat(index)
                    Path { path in
                        let horizontal = width * (0.12 + position * 0.044)
                        path.move(to: CGPoint(x: horizontal, y: height * 0.78))
                        path.addLine(to: CGPoint(x: horizontal - 2, y: height * 0.82))
                    }.stroke(Color.black.opacity(0.13), lineWidth: 1)
                }
            }
        }.accessibilityLabel("Trail 02 sneaker with suede panels, cream laces and a sculpted sole")
    }
}

fileprivate struct SneakerUpper: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width * 0.06, y: height * 0.67))
        path.addCurve(to: CGPoint(x: width * 0.34, y: height * 0.43), control1: CGPoint(x: width * 0.05, y: height * 0.52), control2: CGPoint(x: width * 0.21, y: height * 0.53))
        path.addLine(to: CGPoint(x: width * 0.59, y: height * 0.22))
        path.addQuadCurve(to: CGPoint(x: width * 0.68, y: height * 0.27), control: CGPoint(x: width * 0.65, y: height * 0.15))
        path.addQuadCurve(to: CGPoint(x: width * 0.83, y: height * 0.18), control: CGPoint(x: width * 0.78, y: height * 0.42))
        path.addQuadCurve(to: CGPoint(x: width * 0.89, y: height * 0.29), control: CGPoint(x: width * 0.88, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.94, y: height * 0.65))
        path.addQuadCurve(to: CGPoint(x: width * 0.06, y: height * 0.71), control: CGPoint(x: width * 0.52, y: height * 0.87))
        path.closeSubpath()
        return path
    }
}

fileprivate struct SneakerSole: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width * 0.055, y: height * 0.65))
        path.addQuadCurve(to: CGPoint(x: width * 0.94, y: height * 0.63), control: CGPoint(x: width * 0.46, y: height * 0.80))
        path.addQuadCurve(to: CGPoint(x: width * 0.95, y: height * 0.75), control: CGPoint(x: width * 0.98, y: height * 0.69))
        path.addCurve(to: CGPoint(x: width * 0.065, y: height * 0.80), control1: CGPoint(x: width * 0.70, y: height * 0.87), control2: CGPoint(x: width * 0.14, y: height * 0.91))
        path.addQuadCurve(to: CGPoint(x: width * 0.055, y: height * 0.65), control: CGPoint(x: width * 0.02, y: height * 0.76))
        path.closeSubpath()
        return path
    }
}
