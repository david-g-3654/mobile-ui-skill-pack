// Screen.swift — Stats archetype (mobile-ui/references/screen-stats.md), default "Quiet" skin.
// Job: "see how far I ran this week". Focal: hero distance for the selected week (or tapped day).
// Primary action: none — the week stepper and bar selection are the interaction.
// Cut: a second chart for pace, the 2×2 stat grid, per-run icons.

import SwiftUI
import Charts

// MARK: - Model

fileprivate struct RunEntry: Identifiable {
    let id = UUID()
    let weekday: Int          // 0 = Mon … 6 = Sun
    let date: String          // "Wed, Oct 14"
    let kind: String          // "Tempo run"
    let km: Double
    let seconds: Int

    var paceSecondsPerKm: Int { Int(Double(seconds) / km) }
}

fileprivate struct RunWeek: Identifiable {
    let id = UUID()
    let title: String         // "This week"
    let range: String         // "Oct 12–18"
    let elapsedDays: Int      // days that have happened (7 for past weeks)
    let runs: [RunEntry]

    var totalKm: Double { runs.reduce(0) { $0 + $1.km } }
    var totalSeconds: Int { runs.reduce(0) { $0 + $1.seconds } }
    var avgPace: Int? { totalKm > 0 ? Int(Double(totalSeconds) / totalKm) : nil }

    func km(on weekday: Int) -> Double {
        runs.filter { $0.weekday == weekday }.reduce(0) { $0 + $1.km }
    }
}

fileprivate enum Weekday {
    static let short = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static let full = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
}

fileprivate enum Fmt {
    static func km(_ value: Double) -> String { String(format: "%.1f", value) }

    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    static func pace(_ secondsPerKm: Int) -> String {
        String(format: "%d'%02d\"", secondsPerKm / 60, secondsPerKm % 60)
    }
}

fileprivate let weeklyGoalKm: Double = 30

fileprivate let sampleWeeks: [RunWeek] = [
    RunWeek(title: "Sep 21–27", range: "Sep 21–27", elapsedDays: 7, runs: []),
    RunWeek(title: "Sep 28–Oct 4", range: "Sep 28–Oct 4", elapsedDays: 7, runs: [
        RunEntry(weekday: 0, date: "Mon, Sep 28", kind: "Easy run", km: 5.2, seconds: 1_872),
        RunEntry(weekday: 2, date: "Wed, Sep 30", kind: "Intervals 6×800", km: 7.4, seconds: 2_331),
        RunEntry(weekday: 4, date: "Fri, Oct 2", kind: "Recovery jog", km: 4.1, seconds: 1_587),
        RunEntry(weekday: 6, date: "Sun, Oct 4", kind: "Long run", km: 14.6, seconds: 5_212),
    ]),
    RunWeek(title: "Last week", range: "Oct 5–11", elapsedDays: 7, runs: [
        RunEntry(weekday: 1, date: "Tue, Oct 6", kind: "Easy run", km: 6.3, seconds: 2_249),
        RunEntry(weekday: 3, date: "Thu, Oct 8", kind: "Tempo run", km: 8.0, seconds: 2_536),
        RunEntry(weekday: 5, date: "Sat, Oct 10", kind: "Parkrun", km: 5.0, seconds: 1_395),
        RunEntry(weekday: 6, date: "Sun, Oct 11", kind: "Long run", km: 16.2, seconds: 5_913),
    ]),
    RunWeek(title: "This week", range: "Oct 12–18", elapsedDays: 3, runs: [
        RunEntry(weekday: 0, date: "Mon, Oct 12", kind: "Easy run", km: 6.8, seconds: 2_421),
        RunEntry(weekday: 1, date: "Tue, Oct 13", kind: "Hill repeats", km: 5.4, seconds: 2_042),
        RunEntry(weekday: 2, date: "Wed, Oct 14", kind: "Tempo run", km: 8.2, seconds: 2_538),
    ]),
]

// MARK: - Screen

struct S_stats: View {
    private let weeks: [RunWeek]
    private let isLoading: Bool

    @State private var weekIndex: Int
    @State private var selectedDay: String?

    init() {
        self.init(weeks: sampleWeeks, isLoading: false)
    }

    fileprivate init(weeks: [RunWeek], isLoading: Bool) {
        self.weeks = weeks
        self.isLoading = isLoading
        _weekIndex = State(initialValue: max(weeks.count - 1, 0))
    }

    private var week: RunWeek { weeks[weekIndex] }
    private var previousWeek: RunWeek? { weekIndex > 0 ? weeks[weekIndex - 1] : nil }
    private var isCurrentWeek: Bool { weekIndex == weeks.count - 1 }
    private var selectedWeekday: Int? { selectedDay.flatMap { Weekday.short.firstIndex(of: $0) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xxl) {
                    VStack(alignment: .leading, spacing: Space.xl) {
                        WeekStepper(
                            title: week.title,
                            range: week.range,
                            canGoBack: weekIndex > 0,
                            canGoForward: !isCurrentWeek,
                            onBack: { changeWeek(by: -1) },
                            onForward: { changeWeek(by: 1) }
                        )
                        hero
                        WeekChart(
                            week: week,
                            highlightDay: highlightDay,
                            selectedDay: $selectedDay
                        )
                        MetricRow(items: [
                            (Fmt.duration(week.totalSeconds), "time"),
                            (week.avgPace.map { Fmt.pace($0) } ?? "–", "avg pace /km"),
                            ("\(week.runs.count)", week.runs.count == 1 ? "run" : "runs"),
                        ])
                        .contentTransition(.numericText())
                    }

                    VStack(alignment: .leading, spacing: Space.sm) {
                        SectionHeader(title: "Runs")
                        RunList(runs: week.runs.reversed(), isCurrentWeek: isCurrentWeek)
                    }
                }
                .padding(.horizontal, Space.margin)
                .padding(.top, Space.xs)
                .padding(.bottom, Space.xxl)
                .redacted(reason: isLoading ? .placeholder : [])
                .shimmering(isActive: isLoading)
            }
            .canvasBackground()
            .navigationTitle("Running")
            .sensoryFeedback(.selection, trigger: selectedDay)
            .sensoryFeedback(.selection, trigger: weekIndex)
        }
        .tint(Palette.ink)
    }

    // MARK: Hero

    @ViewBuilder private var hero: some View {
        if let day = selectedWeekday {
            let runs = week.runs.filter { $0.weekday == day }
            HeroMetric(
                label: Weekday.full[day],
                value: Fmt.km(week.km(on: day)),
                suffix: "km",
                context: runs.first.map { "\($0.kind) · \(Fmt.duration($0.seconds))" } ?? "Rest day"
            )
        } else {
            HeroMetric(
                label: "Distance",
                value: Fmt.km(week.totalKm),
                suffix: "km",
                context: "of \(Int(weeklyGoalKm)) km goal",
                delta: weekDelta
            )
        }
    }

    private var weekDelta: HeroMetric.Delta? {
        guard let previousWeek, previousWeek.totalKm > 0, week.totalKm > 0 else { return nil }
        let change = (week.totalKm - previousWeek.totalKm) / previousWeek.totalKm
        let label = isCurrentWeek ? "vs all of last week" : "vs previous week"
        return .init(text: "\(Int((abs(change) * 100).rounded()))% \(label)", isUp: change >= 0)
    }

    /// The accent bar: the tapped day, else today (current week only).
    private var highlightDay: Int? {
        if let selectedWeekday { return selectedWeekday }
        return isCurrentWeek ? week.elapsedDays - 1 : nil
    }

    private func changeWeek(by step: Int) {
        withAnimation(Motion.snappy) {
            selectedDay = nil
            weekIndex = min(max(weekIndex + step, 0), weeks.count - 1)
        }
    }
}

// MARK: - Week stepper

fileprivate struct WeekStepper: View {
    let title: String
    let range: String
    let canGoBack: Bool
    let canGoForward: Bool
    let onBack: () -> Void
    let onForward: () -> Void

    var body: some View {
        HStack(spacing: Space.xs) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .frame(width: Metrics.minTap, height: Metrics.minTap)
                    .contentShape(Rectangle())
            }
            .disabled(!canGoBack)
            .accessibilityLabel("Show previous week")

            Spacer(minLength: 0)
            VStack(spacing: 2) {
                Text(title).font(.dsHeadline).foregroundStyle(Palette.ink)
                if title != range {
                    Text(range).font(.dsFootnote).foregroundStyle(Palette.ink2)
                }
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)

            Button(action: onForward) {
                Image(systemName: "chevron.right")
                    .frame(width: Metrics.minTap, height: Metrics.minTap)
                    .contentShape(Rectangle())
            }
            .disabled(!canGoForward)
            .accessibilityLabel("Show next week")
        }
        .font(.dsBody.weight(.semibold))
        .foregroundStyle(Palette.ink)
        .frame(minHeight: Metrics.rowMinHeight)
        .background(Palette.surface, in: Capsule())
    }
}

// MARK: - Chart

fileprivate struct WeekChart: View {
    let week: RunWeek
    let highlightDay: Int?
    @Binding var selectedDay: String?

    private var maxKm: Double {
        max((0..<7).map { week.km(on: $0) }.max() ?? 0, 10)
    }

    var body: some View {
        Chart {
            ForEach(0..<7, id: \.self) { day in
                BarMark(
                    x: .value("Day", Weekday.short[day]),
                    y: .value("Kilometres", week.km(on: day)),
                    width: .ratio(0.55)
                )
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4, style: .continuous))
                .foregroundStyle(barColor(for: day))
                .accessibilityLabel(Weekday.full[day])
                .accessibilityValue(day < week.elapsedDays || week.elapsedDays == 7
                    ? "\(Fmt.km(week.km(on: day))) kilometres"
                    : "Upcoming")
            }
        }
        .chartXSelection(value: $selectedDay)
        .chartYScale(domain: 0...(maxKm * 1.1))
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine().foregroundStyle(Palette.hairline)
                AxisValueLabel {
                    if let km = value.as(Double.self) {
                        Text("\(Int(km))").font(.dsFootnote).foregroundStyle(Palette.ink2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day.prefix(1)).font(.dsFootnote).foregroundStyle(Palette.ink2)
                    }
                }
            }
        }
        .overlay {
            if week.runs.isEmpty {
                Text("No runs this week")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
                    .padding(.bottom, Space.xl)
            }
        }
        .frame(height: 200)
        .accessibilityLabel("Kilometres per day")
    }

    private func barColor(for day: Int) -> Color {
        if day == highlightDay { return Palette.accent }
        if week.elapsedDays < 7 && day >= week.elapsedDays { return Palette.surface2 }
        return Palette.ink.opacity(0.85)
    }
}

// MARK: - Run list

fileprivate struct RunList: View {
    let runs: [RunEntry]
    let isCurrentWeek: Bool

    var body: some View {
        if runs.isEmpty {
            Text(isCurrentWeek
                 ? "Runs you record this week show up here."
                 : "No runs logged that week. Rest weeks count too.")
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
                .frame(maxWidth: .infinity, minHeight: Metrics.rowMinHeight, alignment: .leading)
        } else {
            VStack(spacing: 0) {
                ForEach(runs) { run in
                    ListRow(
                        title: run.kind,
                        subtitle: "\(run.date) · \(Fmt.duration(run.seconds)) · \(Fmt.pace(run.paceSecondsPerKm)) /km"
                    ) {
                        Text("\(Fmt.km(run.km)) km")
                            .font(.dsBody)
                            .monospacedDigit()
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(.horizontal, Space.md)
                    if run.id != runs.last?.id {
                        Divider().overlay(Palette.hairline).padding(.leading, Space.md)
                    }
                }
            }
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
        }
    }
}

// MARK: - Previews

#Preview("Light") { S_stats() }
#Preview("Dark") { S_stats().preferredColorScheme(.dark) }
#Preview("Loading") { S_stats(weeks: sampleWeeks, isLoading: true) }
#Preview("Large text") { S_stats().dynamicTypeSize(.accessibility2) }
