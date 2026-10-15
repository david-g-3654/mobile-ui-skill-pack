// Screen.swift — Stats archetype (mobile-ui/references/screen-stats.md).
// Job: "see how this week's running is going". Focal: the week's distance hero.
// Primary action: none — the week stepper and the bar selection are the interactions.
// Cutting: segmented Day/Month/Year control, goal ring, per-run splits (live behind each run).

import SwiftUI
import Charts

// MARK: - Model

fileprivate struct RunEntry: Identifiable {
    let id = UUID()
    /// 0 = Monday … 6 = Sunday, within its week.
    let dayIndex: Int
    let kilometers: Double
    let seconds: Int
    let name: String
    let route: String
}

fileprivate struct DayTotal: Identifiable {
    let dayIndex: Int
    let date: Date
    let kilometers: Double
    var id: Int { dayIndex }
    var shortName: String { date.formatted(.dateTime.weekday(.abbreviated)) }
    var longName: String { date.formatted(.dateTime.weekday(.wide)) }
}

fileprivate enum RunCalendar {
    static var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        return cal
    }()

    static var currentWeekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? calendar.startOfDay(for: .now)
    }

    /// Index of today inside the current week (0 = Monday).
    static var todayIndex: Int {
        let days = calendar.dateComponents([.day], from: currentWeekStart, to: calendar.startOfDay(for: .now)).day ?? 0
        return min(max(days, 0), 6)
    }

    static func weekStart(offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) ?? currentWeekStart
    }

    static func date(weekOffset: Int, dayIndex: Int) -> Date {
        calendar.date(byAdding: .day, value: dayIndex, to: weekStart(offset: weekOffset)) ?? .now
    }
}

fileprivate enum RunLog {
    /// Oldest week available in the sample log.
    static let oldestOffset = -3

    static func runs(weekOffset: Int) -> [RunEntry] {
        switch weekOffset {
        case 0:
            let all = [
                RunEntry(dayIndex: 0, kilometers: 6.2, seconds: 2170, name: "Easy run", route: "Canal path"),
                RunEntry(dayIndex: 2, kilometers: 9.6, seconds: 3164, name: "Tempo", route: "Track · 5 × 1 km"),
            ]
            return all.filter { $0.dayIndex <= RunCalendar.todayIndex }
        case -1:
            return [
                RunEntry(dayIndex: 0, kilometers: 5.1, seconds: 1925, name: "Recovery", route: "Canal path"),
                RunEntry(dayIndex: 2, kilometers: 10.4, seconds: 3492, name: "Intervals", route: "Track · 6 × 800 m"),
                RunEntry(dayIndex: 3, kilometers: 7.3, seconds: 2490, name: "Easy run", route: "Parkland loop"),
                RunEntry(dayIndex: 5, kilometers: 4.8, seconds: 1660, name: "Shakeout", route: "Old harbour"),
                RunEntry(dayIndex: 6, kilometers: 16.1, seconds: 5900, name: "Long run", route: "Riverside loop"),
            ]
        case -2:
            return [
                RunEntry(dayIndex: 1, kilometers: 8.0, seconds: 2815, name: "Steady run", route: "Hill reps, Beacon Rd"),
                RunEntry(dayIndex: 3, kilometers: 6.6, seconds: 2300, name: "Easy run", route: "Parkland loop"),
                RunEntry(dayIndex: 6, kilometers: 14.2, seconds: 5103, name: "Long run", route: "Riverside loop"),
            ]
        default:
            return [] // Rest week: no runs logged.
        }
    }
}

// MARK: - Formatting

fileprivate enum RunFormat {
    static func km(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }

    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    static func totalTime(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(String(format: "%02d", m))m" : "\(m)m"
    }

    static func pace(seconds: Int, kilometers: Double) -> String {
        guard kilometers > 0 else { return "–" }
        let perKm = Int((Double(seconds) / kilometers).rounded())
        return "\(perKm / 60)'\(String(format: "%02d", perKm % 60))\""
    }

    static func range(weekOffset: Int) -> String {
        let start = RunCalendar.weekStart(offset: weekOffset)
        let end = RunCalendar.date(weekOffset: weekOffset, dayIndex: 6)
        let startText = start.formatted(.dateTime.month(.abbreviated).day())
        let sameMonth = RunCalendar.calendar.isDate(start, equalTo: end, toGranularity: .month)
        let endText = sameMonth ? end.formatted(.dateTime.day()) : end.formatted(.dateTime.month(.abbreviated).day())
        return "\(startText)–\(endText)"
    }

    static func weekTitle(_ offset: Int) -> String {
        switch offset {
        case 0: return "This week"
        case -1: return "Last week"
        default: return "\(-offset) weeks ago"
        }
    }
}

// MARK: - Screen

struct S_stats: View {
    @State private var weekOffset = 0
    @State private var selectedDay: String?
    @State private var isLoading = true

    init() {}

    private var runs: [RunEntry] { RunLog.runs(weekOffset: weekOffset) }

    private var days: [DayTotal] {
        (0..<7).map { index in
            DayTotal(
                dayIndex: index,
                date: RunCalendar.date(weekOffset: weekOffset, dayIndex: index),
                kilometers: runs.filter { $0.dayIndex == index }.reduce(0) { $0 + $1.kilometers }
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    VStack(alignment: .leading, spacing: QSpace.xl) {
                        WeekStepper(
                            title: "\(RunFormat.weekTitle(weekOffset)) · \(RunFormat.range(weekOffset: weekOffset))",
                            canGoBack: weekOffset > RunLog.oldestOffset,
                            canGoForward: weekOffset < 0,
                            onBack: { changeWeek(by: -1) },
                            onForward: { changeWeek(by: 1) }
                        )
                        DistanceHero(
                            value: heroValue,
                            context: heroContext,
                            delta: selectedTotal == nil ? delta : nil
                        )
                        WeeklyBarChart(
                            days: days,
                            highlightIndex: highlightIndex,
                            selectedDay: $selectedDay
                        )
                        QMetricRow(items: [
                            (RunFormat.totalTime(totalSeconds), "time"),
                            (RunFormat.pace(seconds: totalSeconds, kilometers: totalKm), "avg pace /km"),
                            ("\(runs.count)", runs.count == 1 ? "run" : "runs"),
                        ])
                    }

                    RunHistory(runs: runs, weekOffset: weekOffset)
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xs)
                .padding(.bottom, QSpace.xxl)
                .redacted(reason: isLoading ? .placeholder : [])
                .qShimmering(isActive: isLoading)
                .allowsHitTesting(!isLoading)
            }
            .qCanvasBackground()
            .navigationTitle("Running")
            .sensoryFeedback(.selection, trigger: selectedDay)
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(QMotion.smooth) { isLoading = false }
            }
        }
        .tint(QPalette.ink)
    }

    // MARK: Derived values

    private var totalKm: Double { runs.reduce(0) { $0 + $1.kilometers } }
    private var totalSeconds: Int { runs.reduce(0) { $0 + $1.seconds } }

    private var selectedTotal: DayTotal? {
        guard let selectedDay else { return nil }
        return days.first { $0.shortName == selectedDay }
    }

    /// Selected bar wins; otherwise today in the current week; otherwise nothing.
    private var highlightIndex: Int? {
        if let selectedTotal { return selectedTotal.dayIndex }
        return weekOffset == 0 ? RunCalendar.todayIndex : nil
    }

    private var heroValue: String {
        RunFormat.km(selectedTotal?.kilometers ?? totalKm)
    }

    private var heroContext: String {
        if let selectedTotal {
            let dateText = selectedTotal.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
            return selectedTotal.kilometers > 0 ? dateText : "\(dateText) · rest day"
        }
        if runs.isEmpty { return "No runs logged" }
        if previousComparableKm == 0 { return "No runs the week before" }
        return weekOffset == 0 ? "vs this time last week" : "vs the week before"
    }

    /// Like-for-like: the current week compares against the same days of last week.
    private var previousComparableKm: Double {
        let previous = RunLog.runs(weekOffset: weekOffset - 1)
        let cutoff = weekOffset == 0 ? RunCalendar.todayIndex : 6
        return previous.filter { $0.dayIndex <= cutoff }.reduce(0) { $0 + $1.kilometers }
    }

    private var delta: DistanceHero.Delta? {
        guard !runs.isEmpty, previousComparableKm > 0 else { return nil }
        let change = (totalKm - previousComparableKm) / previousComparableKm
        let percent = Int((abs(change) * 100).rounded())
        return .init(text: "\(percent)%", isUp: change >= 0)
    }

    private func changeWeek(by step: Int) {
        selectedDay = nil
        withAnimation(QMotion.snappy) { weekOffset += step }
    }
}

// MARK: - Week stepper

fileprivate struct WeekStepper: View {
    let title: String
    let canGoBack: Bool
    let canGoForward: Bool
    let onBack: () -> Void
    let onForward: () -> Void

    var body: some View {
        HStack(spacing: QSpace.xs) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .frame(width: QMetrics.minTap, height: QMetrics.minTap)
            }
            .disabled(!canGoBack)
            .accessibilityLabel("Show previous week")

            Text(title)
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .contentTransition(.numericText())

            Button(action: onForward) {
                Image(systemName: "chevron.right")
                    .frame(width: QMetrics.minTap, height: QMetrics.minTap)
            }
            .disabled(!canGoForward)
            .accessibilityLabel("Show next week")
        }
        .font(.dsBody)
        .padding(.horizontal, -QSpace.xs)
    }
}

// MARK: - Hero

fileprivate struct DistanceHero: View {
    let value: String
    let context: String
    let delta: Delta?

    struct Delta {
        let text: String
        let isUp: Bool
        var color: Color { isUp ? QPalette.positive : QPalette.negative }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.xs) {
            HStack(alignment: .firstTextBaseline, spacing: QSpace.xs) {
                QHeroText(text: value, size: 64)
                    .contentTransition(.numericText())
                    .animation(QMotion.snappy, value: value)
                Text("km")
                    .font(.dsTitle)
                    .foregroundStyle(QPalette.ink2)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: QSpace.xs) { contextLine }
                VStack(alignment: .leading, spacing: QSpace.xxs) { contextLine }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var contextLine: some View {
        if let delta {
            Label(delta.text, systemImage: delta.isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.dsSubhead.weight(.semibold))
                .foregroundStyle(delta.color)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(delta.isUp ? "Up \(delta.text)" : "Down \(delta.text)")
        }
        Text(context)
            .font(.dsSubhead)
            .foregroundStyle(QPalette.ink2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Chart

fileprivate struct WeeklyBarChart: View {
    let days: [DayTotal]
    let highlightIndex: Int?
    @Binding var selectedDay: String?

    private var isEmpty: Bool { days.allSatisfy { $0.kilometers == 0 } }

    var body: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", day.shortName),
                y: .value("Kilometers", day.kilometers),
                width: .ratio(0.55)
            )
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: QSpace.xxs, topTrailingRadius: QSpace.xxs, style: .continuous))
            .foregroundStyle(day.dayIndex == highlightIndex ? QPalette.accent : QPalette.ink.opacity(0.85))
            .accessibilityLabel(day.longName)
            .accessibilityValue(day.kilometers > 0 ? "\(RunFormat.km(day.kilometers)) kilometers" : "Rest day")
        }
        .chartYScale(domain: 0...max(days.map(\.kilometers).max() ?? 0, 10))
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine().foregroundStyle(QPalette.hairline)
                AxisValueLabel {
                    if let km = value.as(Double.self) {
                        Text("\(Int(km))").font(.dsFootnote).foregroundStyle(QPalette.ink2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name).font(.dsFootnote).foregroundStyle(QPalette.ink2)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedDay)
        .overlay {
            if isEmpty {
                Text("No runs this week")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .padding(.bottom, QSpace.xl)
            }
        }
        .frame(height: 180)
        .accessibilityLabel("Kilometers per day")
    }
}

// MARK: - History

fileprivate struct RunHistory: View {
    let runs: [RunEntry]
    let weekOffset: Int

    var body: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            QSectionHeader(title: "Runs")
            if runs.isEmpty {
                Text("Rest week. Runs you log or sync from your watch show up here.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .frame(maxWidth: .infinity, minHeight: QMetrics.rowMinHeight, alignment: .leading)
            } else {
                let ordered = runs.sorted { $0.dayIndex > $1.dayIndex }
                VStack(spacing: 0) {
                    ForEach(ordered) { run in
                        QListRow(title: run.name, subtitle: subtitle(for: run)) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(RunFormat.km(run.kilometers)) km")
                                    .font(.dsBody)
                                    .foregroundStyle(QPalette.ink)
                                Text(RunFormat.duration(run.seconds))
                                    .font(.dsSubhead)
                                    .foregroundStyle(QPalette.ink2)
                            }
                            .monospacedDigit()
                        }
                        .padding(.horizontal, QSpace.md)
                        if run.id != ordered.last?.id {
                            Divider().overlay(QPalette.hairline).padding(.leading, QSpace.md)
                        }
                    }
                }
                .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
            }
        }
    }

    private func subtitle(for run: RunEntry) -> String {
        let date = RunCalendar.date(weekOffset: weekOffset, dayIndex: run.dayIndex)
        return "\(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())) · \(run.route)"
    }
}

// MARK: - Previews

#Preview("Light") { S_stats() }
#Preview("Dark") { S_stats().preferredColorScheme(.dark) }
#Preview("Large text") { S_stats().dynamicTypeSize(.accessibility2) }
