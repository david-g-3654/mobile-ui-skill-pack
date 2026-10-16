import SwiftUI

struct S_stats: View {
    private var weekState = SwiftUI.State<Int>(initialValue: 0)
    private var tabState = SwiftUI.State<Int>(initialValue: 1)
    private var dayState = SwiftUI.State<Int>(initialValue: 5)
    private var selectedWeek: Int {
        get { weekState.wrappedValue }
        nonmutating set { weekState.wrappedValue = newValue }
    }
    private var selectedTab: Int {
        get { tabState.wrappedValue }
        nonmutating set { tabState.wrappedValue = newValue }
    }
    private var selectedDay: Int {
        get { dayState.wrappedValue }
        nonmutating set { dayState.wrappedValue = newValue }
    }

    init() {}

    private let ink = Color(red: 0.12, green: 0.20, blue: 0.17)
    private let green = Color(red: 0.24, green: 0.40, blue: 0.28)
    private let lime = Color(red: 0.81, green: 0.91, blue: 0.43)
    private let weeks: [[Double]] = [[5.2, 0, 7.4, 4.8, 0, 10.2, 4.8], [4.2, 6.1, 0, 5.4, 0, 8.6, 3.2], [5, 0, 6.8, 4.2, 3.5, 9.1, 0]]
    private var distances: [Double] { weeks[selectedWeek] }
    private var total: Double { distances.reduce(0, +) }
    private var weekLabel: String { ["Sep 16 – 22, 2024", "Sep 9 – 15, 2024", "Sep 2 – 8, 2024"][selectedWeek] }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    header
                    weekPicker
                    distanceCard
                    metrics
                    activity
                    goalCard
                }
                .padding(.horizontal, 24)
                .padding(.top, 17)
                .padding(.bottom, 25)
            }
            bottomBar
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.93))
        .foregroundStyle(ink)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 7) {
                Text("YOUR RUNNING, IN FOCUS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(green)
                Text("Weekly stats")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .tracking(-1.4)
            }
            Spacer()
            Image(systemName: "figure.run")
                .font(.system(size: 23, weight: .medium))
                .frame(width: 48, height: 48)
                .background(lime, in: Circle())
        }
    }

    private var weekPicker: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedWeek = min(2, selectedWeek + 1) }
            } label: {
                Image(systemName: "chevron.left").frame(width: 36, height: 36)
            }
            .disabled(selectedWeek == 2)
            Spacer()
            VStack(spacing: 4) {
                Text(selectedWeek == 0 ? "THIS WEEK" : "PREVIOUS WEEK")
                    .font(.system(size: 9, weight: .bold)).tracking(1.8)
                    .foregroundStyle(green)
                Text(weekLabel).font(.system(size: 14, weight: .semibold))
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedWeek = max(0, selectedWeek - 1) }
            } label: {
                Image(systemName: "chevron.right").frame(width: 36, height: 36)
            }
            .disabled(selectedWeek == 0)
        }
        .font(.system(size: 12, weight: .semibold))
        .tint(ink)
    }

    private var distanceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Total distance", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.75))
            .padding(.bottom, 14)
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text(total, format: .number.precision(.fractionLength(1)))
                    .font(.system(size: 59, weight: .medium, design: .rounded))
                    .tracking(-3)
                    .contentTransition(.numericText())
                Text("km").font(.system(size: 23, weight: .regular)).foregroundStyle(.white.opacity(0.65))
                Spacer()
            }
            HStack(spacing: 5) {
                Image(systemName: "arrow.up.right")
                Text("17%") .fontWeight(.semibold)
                Text("vs. last week").foregroundStyle(.white.opacity(0.6))
            }
            .font(.system(size: 11))
            .foregroundStyle(lime)
            .padding(.top, 5)
            .padding(.bottom, 22)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(distances.enumerated()), id: \.offset) { index, distance in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { selectedDay = index }
                    } label: {
                        VStack(spacing: 8) {
                            Text(distance == 0 ? "" : String(format: "%.1f", distance))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(selectedDay == index ? lime : .white.opacity(0.6))
                            RoundedRectangle(cornerRadius: 5)
                                .fill(selectedDay == index ? lime : Color.white.opacity(distance == 0 ? 0.10 : 0.23))
                                .frame(height: max(5, distance * 7.2))
                            Text(["M", "T", "W", "T", "F", "S", "S"][index])
                                .font(.system(size: 10, weight: selectedDay == index ? .bold : .medium))
                                .foregroundStyle(selectedDay == index ? lime : .white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][index]), \(distance, specifier: "%.1f") kilometers")
                    .accessibilityAddTraits(selectedDay == index ? .isSelected : [])
                }
            }
            .frame(height: 115, alignment: .bottom)
        }
        .padding(23)
        .background(ink, in: RoundedRectangle(cornerRadius: 25))
        .foregroundStyle(.white)
    }

    private var metrics: some View {
        HStack(spacing: 10) {
            metric("timer", value: selectedWeek == 0 ? "3h 08m" : "2h 39m", title: "Moving time")
            metric("speedometer", value: selectedWeek == 0 ? "5′48″" : "5′47″", title: "Avg. pace /km")
            metric("figure.run", value: "\(distances.filter { $0 > 0 }.count)", title: "Total runs")
        }
    }

    private func metric(_ symbol: String, value: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).font(.system(size: 16, weight: .regular)).foregroundStyle(green)
            VStack(alignment: .leading, spacing: 6) {
                Text(value).font(.system(size: 21, weight: .semibold, design: .rounded)).minimumScaleFactor(0.7).lineLimit(1)
                Text(title).font(.system(size: 10)).foregroundStyle(ink.opacity(0.55)).lineLimit(1).minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 13)
        .padding(.vertical, 17)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 17))
    }

    private var activity: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("The week's highlights").font(.system(size: 19, weight: .semibold, design: .rounded)).tracking(-0.5)
                Spacer()
                Text("\(distances.filter { $0 > 0 }.count) RUNS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced)).tracking(1).foregroundStyle(green)
            }
            HStack(spacing: 14) {
                Image(systemName: "mountain.2")
                    .font(.system(size: 23, weight: .light))
                    .frame(width: 51, height: 55)
                    .background(Color(red: 0.89, green: 0.91, blue: 0.84), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Saturday long run").font(.system(size: 14, weight: .semibold))
                    Text("\(selectedWeek == 0 ? "Sep 21" : selectedWeek == 1 ? "Sep 14" : "Sep 7") · Riverside trail")
                        .font(.system(size: 11)).foregroundStyle(ink.opacity(0.5))
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(distances[5], specifier: "%.1f") km").font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("LONGEST RUN").font(.system(size: 7, weight: .bold)).tracking(0.7).foregroundStyle(green)
                }
            }
        }
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("A little further. A little stronger.").font(.system(size: 13, weight: .semibold))
                    Text("\(max(0, 40 - total), specifier: "%.1f") km to your weekly goal")
                        .font(.system(size: 11)).foregroundStyle(ink.opacity(0.6))
                }
                Spacer(minLength: 4)
                Image(systemName: "flag.checkered").font(.system(size: 19)).foregroundStyle(green)
            }
            GeometryReader { geometry in
                Capsule().fill(ink.opacity(0.09))
                    .overlay(alignment: .leading) {
                        Capsule().fill(green).frame(width: geometry.size.width * min(total / 40, 1))
                    }
            }
            .frame(height: 5)
            HStack {
                Text("WEEKLY GOAL").tracking(1)
                Spacer()
                Text("\(Int(total / 40 * 100))% of 40 km")
            }
            .font(.system(size: 9, weight: .medium)).foregroundStyle(green)
        }
        .padding(18)
        .background(Color(red: 0.89, green: 0.92, blue: 0.81), in: RoundedRectangle(cornerRadius: 19))
    }

    private var bottomBar: some View {
        HStack {
            tab("house", title: "Home", index: 0)
            Spacer()
            tab("chart.bar.xaxis", title: "Stats", index: 1)
            Spacer()
            tab("figure.run.circle", title: "Run", index: 2)
            Spacer()
            tab("person.crop.circle", title: "You", index: 3)
        }
        .padding(.horizontal, 34)
        .padding(.top, 14)
        .padding(.bottom, 7)
        .background(.white)
        .overlay(alignment: .top) { Rectangle().fill(ink.opacity(0.07)).frame(height: 0.5) }
        .sheet(isPresented: Binding(get: { selectedTab != 1 }, set: { if !$0 { selectedTab = 1 } })) {
            VStack(spacing: 20) {
                Image(systemName: selectedTab == 2 ? "figure.run" : selectedTab == 0 ? "sun.max" : "person.crop.circle")
                    .font(.system(size: 44)).foregroundStyle(green)
                Text(selectedTab == 2 ? "Ready for your next run?" : selectedTab == 0 ? "Your week, at a glance" : "Your running journey")
                    .font(.title2.bold())
                Text(selectedTab == 2 ? "Head outside and make your next kilometer count." : "Keep showing up. Every run is progress.")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                Button("Back to weekly stats") { selectedTab = 1 }
                    .buttonStyle(.borderedProminent).tint(green)
            }
            .padding(30)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func tab(_ symbol: String, title: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 20, weight: selectedTab == index ? .semibold : .regular))
                Text(title).font(.system(size: 9, weight: selectedTab == index ? .bold : .medium))
            }
            .foregroundStyle(selectedTab == index ? green : ink.opacity(0.38))
            .frame(width: 40)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
    }
}
