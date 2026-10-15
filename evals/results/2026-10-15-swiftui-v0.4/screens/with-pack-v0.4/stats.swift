// Screen.swift — Weekly running stats (mobile-ui archetype: Stats).
// Job: see how far I've run this week and whether I'm on track.
// Focal: the distance hero for the selected period. Primary action: none — the period control.
// Cutting: extra charts (pace, heart rate), badges, the 2×2 stat grid.
// Skin: default "Quiet" (no project tokens; user said "just build it").

import SwiftUI

// MARK: - Model

fileprivate struct StatsRun: Identifiable {
    let id = UUID()
    let title: String
    let dateText: String
    /// 0 = Monday … 6 = Sunday (week mode) or week-of-month index (month mode).
    let slot: Int
    let km: Double
    let seconds: Int
    /// Runs this row stands for (month rows summarise a week).
    var count: Int = 1
}

fileprivate enum StatsMode: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

fileprivate struct StatsPeriod {
    let title: String              // "This week, Oct 12–18"
    let accessibleTitle: String
    let labels: [(full: String, short: String)]
    let runs: [StatsRun]
    var highlighted: Int? = nil
    var goal: Double? = nil
    var goalLabel: String? = nil
    var context: String? = nil
    /// Signed percent change vs. a like-for-like earlier period, and what it compares to.
    var deltaPercent: Int? = nil
    var deltaBasis: String = ""
    var emptyMessage: String

    var totalKm: Double { runs.reduce(0) { $0 + $1.km } }
    var totalSeconds: Int { runs.reduce(0) { $0 + $1.seconds } }

    var bars: [QBar] {
        labels.indices.map { i in
            let km = runs.filter { $0.slot == i }.reduce(0) { $0 + $1.km }
            return QBar(label: labels[i].full, shortLabel: labels[i].short, value: km,
                        spokenValue: km == 0 ? "No run" : "\(km.formatted(.number.precision(.fractionLength(1)))) kilometres")
        }
    }

    var chartSummary: String {
        let parts = zip(labels, bars).map { label, bar in
            "\(label.full) \(bar.value.formatted(.number.precision(.fractionLength(0...1))))"
        }
        return "Kilometres, " + parts.joined(separator: ", ")
    }
}

// MARK: - Sample data (today is Thursday, Oct 15, 2026)

fileprivate enum StatsSample {
    static let days: [(full: String, short: String)] = [
        ("Mon", "M"), ("Tue", "T"), ("Wed", "W"), ("Thu", "T"), ("Fri", "F"), ("Sat", "S"), ("Sun", "S")
    ]
    static let weeksOfMonth: [(full: String, short: String)] = [
        ("Wk 1", "1"), ("Wk 2", "2"), ("Wk 3", "3"), ("Wk 4", "4"), ("Wk 5", "5")
    ]

    /// Oldest first; the last element is the current week.
    static let weeks: [StatsPeriod] = [
        StatsPeriod(
            title: "Sep 21–27", accessibleTitle: "Week of September 21",
            labels: days, runs: [],
            context: "Rest week",
            emptyMessage: "No runs this week"
        ),
        StatsPeriod(
            title: "Sep 28–Oct 4", accessibleTitle: "Week of September 28",
            labels: days,
            runs: [
                StatsRun(title: "Long run, river loop", dateText: "Sun, Oct 4", slot: 6, km: 12.6, seconds: 4_158),
                StatsRun(title: "Easy run", dateText: "Thu, Oct 1", slot: 3, km: 5.5, seconds: 1_782),
                StatsRun(title: "Hill repeats", dateText: "Wed, Sep 30", slot: 2, km: 7.0, seconds: 2_331),
                StatsRun(title: "Recovery jog", dateText: "Mon, Sep 28", slot: 0, km: 4.8, seconds: 1_699),
            ],
            highlighted: 6,
            context: "Back after a rest week",
            emptyMessage: "No runs this week"
        ),
        StatsPeriod(
            title: "Oct 5–11", accessibleTitle: "Week of October 5",
            labels: days,
            runs: [
                StatsRun(title: "Long run, Lakeshore path", dateText: "Sun, Oct 11", slot: 6, km: 14.2, seconds: 4_743),
                StatsRun(title: "Progression run", dateText: "Fri, Oct 9", slot: 4, km: 7.3, seconds: 2_234),
                StatsRun(title: "Track 6 × 800 m", dateText: "Wed, Oct 7", slot: 2, km: 6.8, seconds: 2_081),
                StatsRun(title: "Easy run", dateText: "Mon, Oct 5", slot: 0, km: 5.1, seconds: 1_668),
            ],
            highlighted: 6,
            deltaPercent: 12, deltaBasis: "vs. week before",
            emptyMessage: "No runs this week"
        ),
        StatsPeriod(
            title: "This week, Oct 12–18", accessibleTitle: "This week, October 12 to 18",
            labels: days,
            runs: [
                StatsRun(title: "Tempo intervals", dateText: "Today", slot: 3, km: 8.4, seconds: 2_637),
                StatsRun(title: "Easy run", dateText: "Tue, Oct 13", slot: 1, km: 6.2, seconds: 2_046),
            ],
            highlighted: 3,
            context: "of 30 km goal",
            // Mid-week: compare to the same point last week (Mon–Thu: 11.9 km), never the full week.
            deltaPercent: 23, deltaBasis: "vs. this point last week",
            emptyMessage: "No runs yet this week"
        ),
    ]

    static let months: [StatsPeriod] = [
        StatsPeriod(
            title: "September", accessibleTitle: "September 2026",
            labels: Array(weeksOfMonth.prefix(4)),
            runs: [
                StatsRun(title: "Sep 1–7", dateText: "4 runs", slot: 0, km: 18.7, seconds: 6_284, count: 4),
                StatsRun(title: "Sep 8–14", dateText: "5 runs", slot: 1, km: 26.2, seconds: 8_620, count: 5),
                StatsRun(title: "Sep 15–21", dateText: "5 runs", slot: 2, km: 31.0, seconds: 10_044, count: 5),
                StatsRun(title: "Sep 22–30", dateText: "4 runs", slot: 3, km: 22.4, seconds: 7_392, count: 4),
            ],
            highlighted: 2, goal: 30, goalLabel: "30 km goal",
            deltaPercent: 9, deltaBasis: "vs. August",
            emptyMessage: "No runs this month"
        ),
        StatsPeriod(
            title: "October so far", accessibleTitle: "October 2026 so far",
            labels: weeksOfMonth,
            runs: [
                StatsRun(title: "Oct 12–15", dateText: "2 runs", slot: 2, km: 14.6, seconds: 4_683, count: 2),
                StatsRun(title: "Oct 5–11", dateText: "4 runs", slot: 1, km: 33.4, seconds: 10_726, count: 4),
                StatsRun(title: "Oct 1–4", dateText: "2 runs", slot: 0, km: 18.1, seconds: 5_940, count: 2),
            ],
            highlighted: 2, goal: 30, goalLabel: "30 km goal",
            deltaPercent: 18, deltaBasis: "vs. this point in September",
            emptyMessage: "No runs yet this month"
        ),
    ]
}

// MARK: - Formatting

fileprivate enum StatsFormat {
    static func km(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }

    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%d:%02d", m, s)
    }

    static func pace(seconds: Int, km: Double) -> String {
        guard km > 0 else { return "–" }
        let perKm = Int((Double(seconds) / km).rounded())
        return String(format: "%d:%02d", perKm / 60, perKm % 60)
    }
}

// MARK: - Root

struct S_stats: View {
    init() {}

    var body: some View {
        NavigationStack {
            StatsContent(isLoading: false)
        }
        .tint(QPalette.ink)
    }
}

// MARK: - Screen

fileprivate struct StatsContent: View {
    let isLoading: Bool

    @State private var mode: StatsMode = .week
    @State private var weekIndex = StatsSample.weeks.count - 1
    @State private var monthIndex = StatsSample.months.count - 1

    private var periods: [StatsPeriod] { mode == .week ? StatsSample.weeks : StatsSample.months }
    private var index: Int { mode == .week ? weekIndex : monthIndex }
    private var period: StatsPeriod { periods[index] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                VStack(alignment: .leading, spacing: QSpace.xs) {
                    Picker("Period", selection: $mode.animation(QMotion.snappy)) {
                        ForEach(StatsMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .sensoryFeedback(.selection, trigger: mode)

                    periodStepper
                }

                VStack(alignment: .leading, spacing: QSpace.xl) {
                    hero
                    chart
                }
                .redacted(reason: isLoading ? .placeholder : [])
                .qShimmering(isActive: isLoading)

                QMetricRow(items: [
                    (StatsFormat.duration(period.totalSeconds), "Time"),
                    (StatsFormat.pace(seconds: period.totalSeconds, km: period.totalKm), "Avg pace /km"),
                    ("\(period.runs.reduce(0) { $0 + $1.count })", "Runs"),
                ])
                .redacted(reason: isLoading ? .placeholder : [])

                history
            }
            .padding(.horizontal, QSpace.margin)
            .padding(.top, QSpace.xs)
            .padding(.bottom, QSpace.xxl)
        }
        .qCanvasBackground()
        .navigationTitle("Running")
    }

    // MARK: Period stepper

    private var periodStepper: some View {
        HStack(spacing: QSpace.xs) {
            Button {
                step(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: QMetrics.minTap, minHeight: QMetrics.minTap)
            }
            .disabled(index == 0)
            .accessibilityLabel(mode == .week ? "Previous week" : "Previous month")

            Text(period.title)
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .accessibilityLabel(period.accessibleTitle)

            Button {
                step(1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: QMetrics.minTap, minHeight: QMetrics.minTap)
            }
            .disabled(index == periods.count - 1)
            .accessibilityLabel(mode == .week ? "Next week" : "Next month")
        }
        .font(.dsBody.weight(.semibold))
        .sensoryFeedback(.selection, trigger: index)
    }

    private func step(_ delta: Int) {
        withAnimation(QMotion.snappy) {
            let next = min(max(index + delta, 0), periods.count - 1)
            if mode == .week { weekIndex = next } else { monthIndex = next }
        }
    }

    // MARK: Hero

    private var hero: some View {
        QHeroMetric(
            label: "Distance",
            value: StatsFormat.km(period.totalKm),
            suffix: "km",
            context: period.context,
            delta: period.deltaPercent.map {
                QHeroMetric.Delta(text: "\(abs($0))% \(period.deltaBasis)", isUp: $0 >= 0)
            }
        )
    }

    // MARK: Chart

    private var chart: some View {
        QBarChart(
            bars: period.bars,
            highlighted: period.runs.isEmpty ? nil : period.highlighted,
            goal: period.goal,
            goalLabel: period.goalLabel
        )
        .overlay {
            if period.runs.isEmpty {
                Text(period.emptyMessage)
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
                    .padding(.horizontal, QSpace.sm)
                    .padding(.vertical, QSpace.xs)
                    .background(QPalette.canvas, in: Capsule())
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(period.chartSummary)
    }

    // MARK: History

    private var history: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            QSectionHeader(title: mode == .week ? "Runs" : "Weeks")

            if period.runs.isEmpty {
                Text(mode == .week
                     ? "Runs you log or sync from your watch show up here."
                     : "Weekly totals show up here once you log a run.")
                    .font(.dsSubhead)
                    .foregroundStyle(QPalette.ink2)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(period.runs.enumerated()), id: \.element.id) { offset, run in
                        if offset > 0 { Divider().overlay(QPalette.hairline) }
                        QListRow(
                            title: run.title,
                            subtitle: "\(run.dateText) · \(StatsFormat.duration(run.seconds))"
                        ) {
                            HStack(alignment: .firstTextBaseline, spacing: QSpace.xxs) {
                                Text(StatsFormat.km(run.km))
                                    .font(.dsBody)
                                    .monospacedDigit()
                                    .foregroundStyle(QPalette.ink)
                                Text("km")
                                    .font(.dsFootnote)
                                    .foregroundStyle(QPalette.ink2)
                            }
                        }
                    }
                }
                .padding(.horizontal, QSpace.md)
                .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
                .redacted(reason: isLoading ? .placeholder : [])
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    S_stats()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    S_stats()
        .preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_stats()
        .dynamicTypeSize(.accessibility2)
}

#Preview("Loading") {
    NavigationStack { StatsContent(isLoading: true) }
        .tint(QPalette.ink)
}
