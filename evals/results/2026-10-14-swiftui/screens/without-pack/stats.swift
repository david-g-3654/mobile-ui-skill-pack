import SwiftUI
import Charts

// MARK: - Models

fileprivate struct RunDay: Identifiable {
    let id = UUID()
    let day: String
    let distanceKm: Double
}

fileprivate struct RunEntry: Identifiable {
    let id = UUID()
    let title: String
    let dayLabel: String
    let distanceKm: Double
    let durationSec: Int
    let avgHeartRate: Int
    let symbol: String

    var paceSecPerKm: Int { Int(Double(durationSec) / distanceKm) }
}

fileprivate struct WeekData {
    let label: String
    let days: [RunDay]
    let runs: [RunEntry]
    let goalKm: Double
    let elevationM: Int
    let calories: Int
    let previousTotalKm: Double

    var totalKm: Double { days.reduce(0) { $0 + $1.distanceKm } }
    var totalDurationSec: Int { runs.reduce(0) { $0 + $1.durationSec } }
    var avgPaceSecPerKm: Int {
        let km = runs.reduce(0) { $0 + $1.distanceKm }
        return km > 0 ? Int(Double(totalDurationSec) / km) : 0
    }
    var longestKm: Double { runs.map(\.distanceKm).max() ?? 0 }
    var avgHeartRate: Int {
        guard !runs.isEmpty else { return 0 }
        return runs.reduce(0) { $0 + $1.avgHeartRate } / runs.count
    }
}

fileprivate enum Sample {
    static let thisWeek = WeekData(
        label: "Oct 7 – 13",
        days: [
            RunDay(day: "Mon", distanceKm: 6.2),
            RunDay(day: "Tue", distanceKm: 0),
            RunDay(day: "Wed", distanceKm: 8.4),
            RunDay(day: "Thu", distanceKm: 5.0),
            RunDay(day: "Fri", distanceKm: 0),
            RunDay(day: "Sat", distanceKm: 16.1),
            RunDay(day: "Sun", distanceKm: 4.3)
        ],
        runs: [
            RunEntry(title: "Long Run", dayLabel: "Sat, Oct 12", distanceKm: 16.1, durationSec: 5_712, avgHeartRate: 148, symbol: "figure.run"),
            RunEntry(title: "Recovery Jog", dayLabel: "Sun, Oct 13", distanceKm: 4.3, durationSec: 1_720, avgHeartRate: 131, symbol: "leaf.fill"),
            RunEntry(title: "Tempo Intervals", dayLabel: "Thu, Oct 10", distanceKm: 5.0, durationSec: 1_455, avgHeartRate: 167, symbol: "bolt.fill"),
            RunEntry(title: "Hill Repeats", dayLabel: "Wed, Oct 9", distanceKm: 8.4, durationSec: 2_940, avgHeartRate: 158, symbol: "mountain.2.fill"),
            RunEntry(title: "Easy Run", dayLabel: "Mon, Oct 7", distanceKm: 6.2, durationSec: 2_170, avgHeartRate: 139, symbol: "figure.run")
        ],
        goalKm: 40,
        elevationM: 412,
        calories: 2_684,
        previousTotalKm: 34.6
    )

    static let lastWeek = WeekData(
        label: "Sep 30 – Oct 6",
        days: [
            RunDay(day: "Mon", distanceKm: 5.1),
            RunDay(day: "Tue", distanceKm: 7.0),
            RunDay(day: "Wed", distanceKm: 0),
            RunDay(day: "Thu", distanceKm: 6.5),
            RunDay(day: "Fri", distanceKm: 0),
            RunDay(day: "Sat", distanceKm: 12.0),
            RunDay(day: "Sun", distanceKm: 4.0)
        ],
        runs: [
            RunEntry(title: "Recovery Jog", dayLabel: "Sun, Oct 6", distanceKm: 4.0, durationSec: 1_610, avgHeartRate: 129, symbol: "leaf.fill"),
            RunEntry(title: "Long Run", dayLabel: "Sat, Oct 5", distanceKm: 12.0, durationSec: 4_350, avgHeartRate: 146, symbol: "figure.run"),
            RunEntry(title: "Fartlek", dayLabel: "Thu, Oct 3", distanceKm: 6.5, durationSec: 2_080, avgHeartRate: 161, symbol: "bolt.fill"),
            RunEntry(title: "Easy Run", dayLabel: "Tue, Oct 1", distanceKm: 7.0, durationSec: 2_490, avgHeartRate: 138, symbol: "figure.run"),
            RunEntry(title: "Easy Run", dayLabel: "Mon, Sep 30", distanceKm: 5.1, durationSec: 1_810, avgHeartRate: 136, symbol: "figure.run")
        ],
        goalKm: 40,
        elevationM: 298,
        calories: 2_386,
        previousTotalKm: 31.2
    )

    static let weeks = [lastWeek, thisWeek]
}

// MARK: - Formatting

fileprivate enum Fmt {
    static func km(_ v: Double) -> String { String(format: "%.1f", v) }
    static func pace(_ sec: Int) -> String { String(format: "%d:%02d", sec / 60, sec % 60) }
    static func duration(_ sec: Int) -> String {
        let h = sec / 3600, m = (sec % 3600) / 60, s = sec % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }
    static func durationLong(_ sec: Int) -> String {
        let h = sec / 3600, m = (sec % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}

// MARK: - Screen

struct S_stats: View {
    @State private var weekIndex: Int = Sample.weeks.count - 1
    @State private var selectedDay: String?

    init() {}

    private var week: WeekData { Sample.weeks[weekIndex] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    weekSwitcher
                    HeroCard(week: week)
                    ChartCard(week: week, selectedDay: $selectedDay)
                    metricsGrid
                    runsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("This Week")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "square.and.arrow.up") }
                        .accessibilityLabel("Share weekly summary")
                }
            }
        }
        .tint(.orange)
    }

    private var weekSwitcher: some View {
        HStack {
            Button {
                withAnimation(.snappy) { weekIndex -= 1; selectedDay = nil }
            } label: {
                Image(systemName: "chevron.left").frame(width: 44, height: 44)
            }
            .disabled(weekIndex == 0)
            .accessibilityLabel("Previous week")

            Spacer()
            VStack(spacing: 2) {
                Text(weekIndex == Sample.weeks.count - 1 ? "Current week" : "Previous week")
                    .font(.caption).foregroundStyle(.secondary)
                Text(week.label).font(.headline)
            }
            Spacer()

            Button {
                withAnimation(.snappy) { weekIndex += 1; selectedDay = nil }
            } label: {
                Image(systemName: "chevron.right").frame(width: 44, height: 44)
            }
            .disabled(weekIndex == Sample.weeks.count - 1)
            .accessibilityLabel("Next week")
        }
        .padding(.top, 4)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            MetricTile(symbol: "stopwatch.fill", color: .blue, title: "Avg Pace", value: Fmt.pace(week.avgPaceSecPerKm), unit: "/km")
            MetricTile(symbol: "clock.fill", color: .purple, title: "Time", value: Fmt.durationLong(week.totalDurationSec), unit: "")
            MetricTile(symbol: "heart.fill", color: .red, title: "Avg Heart Rate", value: "\(week.avgHeartRate)", unit: "bpm")
            MetricTile(symbol: "mountain.2.fill", color: .green, title: "Elevation", value: "\(week.elevationM)", unit: "m")
            MetricTile(symbol: "flame.fill", color: .orange, title: "Calories", value: week.calories.formatted(), unit: "kcal")
            MetricTile(symbol: "arrow.up.right", color: .teal, title: "Longest Run", value: Fmt.km(week.longestKm), unit: "km")
        }
    }

    private var runsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Runs").font(.title3.bold())
                Spacer()
                Text("\(week.runs.count) activities").font(.subheadline).foregroundStyle(.secondary)
            }
            VStack(spacing: 0) {
                ForEach(Array(week.runs.enumerated()), id: \.element.id) { idx, run in
                    RunRow(run: run)
                    if idx < week.runs.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.top, 8)
    }
}

// MARK: - Hero

fileprivate struct HeroCard: View {
    let week: WeekData

    private var progress: Double { min(week.totalKm / week.goalKm, 1) }
    private var deltaPct: Double {
        guard week.previousTotalKm > 0 else { return 0 }
        return (week.totalKm - week.previousTotalKm) / week.previousTotalKm * 100
    }

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Distance").font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(Fmt.km(week.totalKm))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("km").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: deltaPct >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(Int(abs(deltaPct).rounded()))% vs prior week")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(deltaPct >= 0 ? .green : .red)

                Text(week.totalKm >= week.goalKm
                     ? "Goal reached — nice work!"
                     : "\(Fmt.km(week.goalKm - week.totalKm)) km to your \(Int(week.goalKm)) km goal")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
            ZStack {
                Circle().stroke(Color.orange.opacity(0.18), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(colors: [.orange, .pink, .orange], center: .center),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(Int((week.totalKm / week.goalKm * 100).rounded()))%")
                        .font(.headline.monospacedDigit())
                    Text("of goal").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(width: 96, height: 96)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(Int((week.totalKm / week.goalKm * 100).rounded())) percent of weekly goal")
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Chart

fileprivate struct ChartCard: View {
    let week: WeekData
    @Binding var selectedDay: String?

    private var dailyAvg: Double {
        let active = week.days.filter { $0.distanceKm > 0 }
        return active.isEmpty ? 0 : active.reduce(0) { $0 + $1.distanceKm } / Double(active.count)
    }

    private var selected: RunDay? { week.days.first { $0.day == selectedDay } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Distance").font(.headline)
                    if let s = selected {
                        Text(s.distanceKm > 0 ? "\(s.day): \(Fmt.km(s.distanceKm)) km" : "\(s.day): Rest day")
                            .font(.subheadline).foregroundStyle(.orange)
                    } else {
                        Text("Avg \(Fmt.km(dailyAvg)) km per run day")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("\(week.days.filter { $0.distanceKm > 0 }.count)/7 days")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15), in: Capsule())
                    .foregroundStyle(.orange)
            }

            Chart {
                ForEach(week.days) { d in
                    BarMark(
                        x: .value("Day", d.day),
                        y: .value("Distance", d.distanceKm)
                    )
                    .cornerRadius(6)
                    .foregroundStyle(
                        (selectedDay == nil || selectedDay == d.day)
                        ? AnyShapeStyle(LinearGradient(colors: [.orange, .pink], startPoint: .bottom, endPoint: .top))
                        : AnyShapeStyle(Color.orange.opacity(0.25))
                    )
                }
                RuleMark(y: .value("Average", dailyAvg))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text("avg").font(.caption2).foregroundStyle(.secondary)
                    }
            }
            .chartXSelection(value: $selectedDay)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { v in
                    AxisGridLine()
                    AxisValueLabel {
                        if let km = v.as(Double.self) { Text("\(Int(km))") }
                    }
                }
            }
            .frame(height: 200)
            .animation(.snappy, value: week.label)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Metric tile

fileprivate struct MetricTile: View {
    let symbol: String
    let color: Color
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: symbol).foregroundStyle(color)
                Text(title).foregroundStyle(.secondary)
            }
            .font(.subheadline.weight(.medium))
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(.title2.bold()).monospacedDigit()
                if !unit.isEmpty {
                    Text(unit).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Run row

fileprivate struct RunRow: View {
    let run: RunEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: run.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.orange.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(run.title).font(.body.weight(.semibold))
                Text("\(run.dayLabel) · \(Fmt.pace(run.paceSecPerKm)) /km · \(run.avgHeartRate) bpm")
                    .font(.caption).foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Fmt.km(run.distanceKm)) km").font(.body.weight(.semibold)).monospacedDigit()
                Text(Fmt.duration(run.durationSec)).font(.caption).foregroundStyle(.secondary).monospacedDigit()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}
