import SwiftUI
import Charts

// MARK: - Model

fileprivate struct RunEntry: Identifiable {
    let id = UUID()
    let dayIndex: Int          // 0 = Monday
    let title: String
    let kind: RunKind
    let distanceKm: Double
    let durationSec: Int
    let elevationM: Int
    let avgHR: Int

    var paceSecPerKm: Double { Double(durationSec) / distanceKm }
}

fileprivate enum RunKind: String {
    case easy = "Easy"
    case tempo = "Tempo"
    case intervals = "Intervals"
    case long = "Long Run"
    case recovery = "Recovery"

    var symbol: String {
        switch self {
        case .easy: return "figure.run"
        case .tempo: return "speedometer"
        case .intervals: return "timer"
        case .long: return "road.lanes"
        case .recovery: return "leaf"
        }
    }

    var tint: Color {
        switch self {
        case .easy: return .green
        case .tempo: return .orange
        case .intervals: return .red
        case .long: return .blue
        case .recovery: return .teal
        }
    }
}

fileprivate struct WeekData: Identifiable {
    let id = UUID()
    let label: String
    let range: String
    let goalKm: Double
    let runs: [RunEntry]
    let previousTotalKm: Double

    var totalKm: Double { runs.reduce(0) { $0 + $1.distanceKm } }
    var totalSec: Int { runs.reduce(0) { $0 + $1.durationSec } }
    var totalElevation: Int { runs.reduce(0) { $0 + $1.elevationM } }
    var avgPace: Double { totalKm > 0 ? Double(totalSec) / totalKm : 0 }
    var longest: RunEntry? { runs.max { $0.distanceKm < $1.distanceKm } }
    var fastest: RunEntry? { runs.min { $0.paceSecPerKm < $1.paceSecPerKm } }

    func distance(on day: Int) -> Double {
        runs.filter { $0.dayIndex == day }.reduce(0) { $0 + $1.distanceKm }
    }
}

fileprivate enum Sample {
    static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    static let weeks: [WeekData] = [
        WeekData(
            label: "This Week", range: "Oct 13 – 19", goalKm: 40,
            runs: [
                RunEntry(dayIndex: 0, title: "Morning Easy", kind: .easy, distanceKm: 6.2, durationSec: 34 * 60 + 5, elevationM: 42, avgHR: 142),
                RunEntry(dayIndex: 1, title: "Track 6×800m", kind: .intervals, distanceKm: 8.4, durationSec: 41 * 60 + 30, elevationM: 12, avgHR: 161),
                RunEntry(dayIndex: 3, title: "Riverside Tempo", kind: .tempo, distanceKm: 10.0, durationSec: 47 * 60 + 48, elevationM: 58, avgHR: 158),
                RunEntry(dayIndex: 4, title: "Shakeout", kind: .recovery, distanceKm: 4.1, durationSec: 24 * 60 + 40, elevationM: 20, avgHR: 131),
            ],
            previousTotalKm: 36.8
        ),
        WeekData(
            label: "Last Week", range: "Oct 6 – 12", goalKm: 40,
            runs: [
                RunEntry(dayIndex: 0, title: "Recovery Jog", kind: .recovery, distanceKm: 5.0, durationSec: 30 * 60 + 12, elevationM: 18, avgHR: 128),
                RunEntry(dayIndex: 1, title: "Hill Repeats", kind: .intervals, distanceKm: 7.6, durationSec: 40 * 60 + 2, elevationM: 164, avgHR: 163),
                RunEntry(dayIndex: 3, title: "Lunch Easy", kind: .easy, distanceKm: 6.8, durationSec: 37 * 60 + 50, elevationM: 35, avgHR: 140),
                RunEntry(dayIndex: 5, title: "Park Tempo", kind: .tempo, distanceKm: 8.0, durationSec: 38 * 60 + 24, elevationM: 44, avgHR: 157),
                RunEntry(dayIndex: 6, title: "Sunday Long Run", kind: .long, distanceKm: 18.5, durationSec: 1 * 3600 + 46 * 60 + 10, elevationM: 210, avgHR: 147),
            ],
            previousTotalKm: 33.1
        ),
    ]
}

fileprivate enum Fmt {
    static func duration(_ sec: Int) -> String {
        let h = sec / 3600, m = (sec % 3600) / 60, s = sec % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
    static func hoursMinutes(_ sec: Int) -> String {
        let h = sec / 3600, m = (sec % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
    static func pace(_ secPerKm: Double) -> String {
        let total = Int(secPerKm.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
    static func km(_ v: Double) -> String { String(format: "%.1f", v) }
    static func spokenPace(_ secPerKm: Double) -> String {
        let total = Int(secPerKm.rounded())
        return "\(total / 60) minutes \(total % 60) seconds per kilometer"
    }
}

// MARK: - Screen

struct S_stats: View {
    @State private var weekIndex = 0

    init() {}

    private var week: WeekData { Sample.weeks[weekIndex] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Week", selection: $weekIndex) {
                        ForEach(Sample.weeks.indices, id: \.self) { i in
                            Text(Sample.weeks[i].label).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)

                    GoalCard(week: week)
                    MetricGrid(week: week)
                    DailyChartCard(week: week)
                    HighlightsCard(week: week)
                    RunsSection(week: week)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .animation(.snappy, value: weekIndex)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Weekly Stats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share weekly summary")
                }
            }
        }
    }
}

// MARK: - Card container

fileprivate struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Goal

fileprivate struct GoalCard: View {
    let week: WeekData
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title) private var ringSize: CGFloat = 104

    private var progress: Double { min(week.totalKm / week.goalKm, 1) }
    private var delta: Double { week.totalKm - week.previousTotalKm }

    var body: some View {
        Card {
            let layout = typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 16))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 20))
            layout {
                ring
                VStack(alignment: .leading, spacing: 6) {
                    Text(week.range)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(Fmt.km(week.totalKm))
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        Text("km")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text(week.totalKm >= week.goalKm
                         ? "Goal reached — nice work!"
                         : "\(Fmt.km(week.goalKm - week.totalKm)) km to your \(Int(week.goalKm)) km goal")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    Label {
                        Text("\(delta >= 0 ? "+" : "")\(Fmt.km(delta)) km vs. prior week")
                    } icon: {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(delta >= 0 ? .green : .orange)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.accentColor.opacity(0.15), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [.cyan, .blue, .indigo], center: .center),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int((week.totalKm / week.goalKm * 100).rounded()))%")
                .font(.system(.headline, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: ringSize, height: ringSize)
        .accessibilityLabel("Goal progress \(Int((progress * 100).rounded())) percent")
    }
}

// MARK: - Metrics

fileprivate struct MetricGrid: View {
    let week: WeekData
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let columns = typeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        LazyVGrid(columns: columns, spacing: 12) {
            MetricTile(symbol: "clock.fill", tint: .purple, title: "Time",
                       value: Fmt.hoursMinutes(week.totalSec), unit: nil,
                       spoken: Fmt.hoursMinutes(week.totalSec))
            MetricTile(symbol: "gauge.with.needle.fill", tint: .orange, title: "Avg Pace",
                       value: Fmt.pace(week.avgPace), unit: "/km",
                       spoken: Fmt.spokenPace(week.avgPace))
            MetricTile(symbol: "figure.run", tint: .green, title: "Runs",
                       value: "\(week.runs.count)", unit: nil,
                       spoken: "\(week.runs.count) runs")
            MetricTile(symbol: "mountain.2.fill", tint: .brown, title: "Elevation",
                       value: "\(week.totalElevation)", unit: "m",
                       spoken: "\(week.totalElevation) meters")
        }
    }
}

fileprivate struct MetricTile: View {
    let symbol: String
    let tint: Color
    let title: String
    let value: String
    let unit: String?
    let spoken: String

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: symbol)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(tint)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    if let unit {
                        Text(unit)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(spoken)
    }
}

// MARK: - Chart

fileprivate struct DailyChartCard: View {
    let week: WeekData
    @State private var selectedDay: String?
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 180

    private var dailyAvg: Double { week.totalKm / 7 }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Daily Distance")
                        .font(.headline)
                    Spacer()
                    if let selectedDay, let i = Sample.days.firstIndex(of: selectedDay) {
                        Text("\(selectedDay): \(Fmt.km(week.distance(on: i))) km")
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                    } else {
                        Text("Avg \(Fmt.km(dailyAvg)) km/day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Chart {
                    ForEach(Array(Sample.days.enumerated()), id: \.offset) { i, day in
                        BarMark(
                            x: .value("Day", day),
                            y: .value("Distance", week.distance(on: i))
                        )
                        .foregroundStyle(
                            (selectedDay == nil || selectedDay == day)
                                ? AnyShapeStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                                : AnyShapeStyle(Color.blue.opacity(0.25))
                        )
                        .cornerRadius(6)
                        .accessibilityLabel(day)
                        .accessibilityValue("\(Fmt.km(week.distance(on: i))) kilometers")
                    }
                    RuleMark(y: .value("Average", dailyAvg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.secondary)
                }
                .chartXSelection(value: $selectedDay)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) { Text("\(Int(v))") }
                        }
                    }
                }
                .frame(height: chartHeight)
            }
        }
    }
}

// MARK: - Highlights

fileprivate struct HighlightsCard: View {
    let week: WeekData

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("Highlights")
                    .font(.headline)
                if let longest = week.longest {
                    HighlightRow(symbol: "trophy.fill", tint: .yellow,
                                 title: "Longest Run",
                                 detail: "\(Fmt.km(longest.distanceKm)) km · \(Sample.days[longest.dayIndex])")
                }
                Divider()
                if let fastest = week.fastest {
                    HighlightRow(symbol: "bolt.fill", tint: .orange,
                                 title: "Fastest Pace",
                                 detail: "\(Fmt.pace(fastest.paceSecPerKm)) /km · \(fastest.title)")
                }
                Divider()
                HighlightRow(symbol: "flame.fill", tint: .red,
                             title: "Active Days",
                             detail: "\(Set(week.runs.map(\.dayIndex)).count) of 7 days")
            }
        }
    }
}

fileprivate struct HighlightRow: View {
    let symbol: String
    let tint: Color
    let title: String
    let detail: String
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 32

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: iconSize, height: iconSize)
                .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Text(detail).font(.body.weight(.semibold))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Runs

fileprivate struct RunsSection: View {
    let week: WeekData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Runs")
                .font(.title3.weight(.bold))
                .padding(.leading, 4)
            VStack(spacing: 0) {
                ForEach(Array(week.runs.reversed().enumerated()), id: \.element.id) { i, run in
                    if i > 0 { Divider().padding(.leading, 16) }
                    RunRow(run: run)
                }
            }
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

fileprivate struct RunRow: View {
    let run: RunEntry
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .body) private var badge: CGFloat = 40

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if !typeSize.isAccessibilitySize {
                Image(systemName: run.kind.symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: badge, height: badge)
                    .background(run.kind.tint.gradient, in: Circle())
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(run.title)
                    .font(.body.weight(.semibold))
                Text("\(Sample.days[run.dayIndex]) · \(run.kind.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(run.kind.tint)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) { stats }
                    VStack(alignment: .leading, spacing: 2) { stats }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(run.title), \(Sample.days[run.dayIndex]), \(run.kind.rawValue)")
        .accessibilityValue("\(Fmt.km(run.distanceKm)) kilometers in \(Fmt.hoursMinutes(run.durationSec)), pace \(Fmt.spokenPace(run.paceSecPerKm)), average heart rate \(run.avgHR)")
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder private var stats: some View {
        Label("\(Fmt.km(run.distanceKm)) km", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
        Label(Fmt.duration(run.durationSec), systemImage: "clock")
        Label("\(Fmt.pace(run.paceSecPerKm))/km", systemImage: "speedometer")
        Label("\(run.avgHR) bpm", systemImage: "heart")
    }
}

#Preview {
    S_stats()
}
