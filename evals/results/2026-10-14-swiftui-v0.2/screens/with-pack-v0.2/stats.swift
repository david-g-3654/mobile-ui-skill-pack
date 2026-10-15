// Weekly running stats — Stats archetype (mobile-ui), default "Quiet" skin.
// Job: see how this week's running is going. Focal: the period distance hero.
// Primary action: none — the period control is the main interaction.

import SwiftUI
import Charts

// MARK: - Sample data

fileprivate struct Run: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let name: String
    let miles: Double
    let seconds: Int

    var paceSecondsPerMile: Int { Int(Double(seconds) / miles) }
}

fileprivate enum SampleRuns {
    /// (days ago, route, miles, minutes, seconds) — relative to today so the current week is always populated.
    private static let raw: [(Int, String, Double, Int, Int)] = [
        (0, "Riverside loop", 4.2, 37, 18),
        (2, "Intervals at the track", 5.1, 41, 52),
        (3, "Easy recovery", 3.1, 29, 40),
        (5, "Long run to the lighthouse", 9.6, 88, 5),
        (7, "Hill repeats, Cedar St", 4.8, 44, 31),
        (8, "Riverside loop", 4.2, 36, 47),
        (10, "Tempo, park perimeter", 6.0, 49, 12),
        (12, "Long run to the lighthouse", 10.4, 95, 38),
        (14, "Easy recovery", 3.0, 28, 55),
        (15, "Riverside loop", 4.2, 37, 2),
        (17, "Intervals at the track", 5.3, 43, 20),
        (19, "Long run, canal path", 8.7, 79, 44),
        (22, "Shakeout with Priya", 2.6, 25, 10),
        (23, "Tempo, park perimeter", 5.8, 48, 36),
        (26, "Long run, canal path", 8.1, 74, 9),
        (28, "Riverside loop", 4.2, 38, 1),
        (30, "Hill repeats, Cedar St", 4.5, 42, 48),
        (33, "Long run to the lighthouse", 9.2, 84, 27),
        (35, "Easy recovery", 3.4, 31, 50),
        (37, "Intervals at the track", 4.9, 40, 33),
        (40, "Long run, canal path", 7.6, 70, 2),
        (44, "Riverside loop", 4.2, 38, 26),
        (47, "Parkrun, Hollins Field", 3.1, 25, 41),
        (49, "Long run, canal path", 7.2, 66, 50),
    ]

    static let all: [Run] = {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return raw.compactMap { daysAgo, name, miles, minutes, seconds in
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: today),
                  let time = cal.date(byAdding: .hour, value: 7, to: day) else { return nil }
            return Run(date: time, name: name, miles: miles, seconds: minutes * 60 + seconds)
        }
        .sorted { $0.date > $1.date }
    }()

    static let weeklyGoal: Double = 20
}

// MARK: - Period model

fileprivate enum PeriodKind: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

fileprivate struct Bucket: Identifiable {
    let id: String        // unique x label, e.g. "Mon" or "8–14"
    let miles: Double
    let isFuture: Bool
    let isCurrent: Bool
}

fileprivate struct PeriodSummary {
    let title: String
    let buckets: [Bucket]
    let runs: [Run]
    let comparison: HeroMetric.Delta?
    let isCurrent: Bool

    var miles: Double { runs.reduce(0) { $0 + $1.miles } }
    var seconds: Int { runs.reduce(0) { $0 + $1.seconds } }
    var avgPace: Int? { miles > 0 ? Int(Double(seconds) / miles) : nil }
}

fileprivate enum StatsCalendar {
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        return cal
    }

    static func summary(kind: PeriodKind, offset: Int, runs: [Run], now: Date = .now) -> PeriodSummary {
        switch kind {
        case .week: return week(offset: offset, runs: runs, now: now)
        case .month: return month(offset: offset, runs: runs, now: now)
        }
    }

    private static func runs(_ runs: [Run], in interval: DateInterval) -> [Run] {
        runs.filter { interval.contains($0.date) }.sorted { $0.date > $1.date }
    }

    private static func miles(_ runs: [Run], from start: Date, to end: Date) -> Double {
        runs.filter { $0.date >= start && $0.date < end }.reduce(0) { $0 + $1.miles }
    }

    private static func week(offset: Int, runs all: [Run], now: Date) -> PeriodSummary {
        let cal = calendar
        let today = cal.startOfDay(for: now)
        let thisWeek = cal.dateInterval(of: .weekOfYear, for: today)!
        let start = cal.date(byAdding: .day, value: -7 * offset, to: thisWeek.start)!
        let end = cal.date(byAdding: .day, value: 7, to: start)!
        let interval = DateInterval(start: start, end: end)
        let inWeek = runs(all, in: interval)

        let dayFormat = Date.FormatStyle().weekday(.abbreviated)
        let buckets: [Bucket] = (0..<7).map { i in
            let day = cal.date(byAdding: .day, value: i, to: start)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            return Bucket(id: day.formatted(dayFormat),
                          miles: miles(inWeek, from: day, to: next),
                          isFuture: day > today,
                          isCurrent: cal.isDate(day, inSameDayAs: today))
        }

        let rangeText = "\(start.formatted(.dateTime.month(.abbreviated).day()))–\(cal.date(byAdding: .day, value: 6, to: start)!.formatted(.dateTime.day()))"
        let title: String
        switch offset {
        case 0: title = "This week · \(rangeText)"
        case 1: title = "Last week · \(rangeText)"
        default: title = rangeText
        }

        // Compare like with like: mid-week, compare to the same point last week.
        let prevStart = cal.date(byAdding: .day, value: -7, to: start)!
        let elapsedEnd = offset == 0 ? cal.date(byAdding: .day, value: 1, to: today)! : end
        let span = elapsedEnd.timeIntervalSince(start)
        let prevMiles = miles(all, from: prevStart, to: prevStart.addingTimeInterval(span))
        let nowMiles = miles(inWeek, from: start, to: elapsedEnd)
        let comparison = delta(current: nowMiles, previous: prevMiles,
                               label: offset == 0 ? "vs this time last week" : "vs week before")

        return PeriodSummary(title: title, buckets: buckets, runs: inWeek,
                             comparison: comparison, isCurrent: offset == 0)
    }

    private static func month(offset: Int, runs all: [Run], now: Date) -> PeriodSummary {
        let cal = calendar
        let today = cal.startOfDay(for: now)
        let thisMonth = cal.dateInterval(of: .month, for: today)!
        let start = cal.date(byAdding: .month, value: -offset, to: thisMonth.start)!
        let interval = cal.dateInterval(of: .month, for: start)!
        let inMonth = runs(all, in: interval)
        let dayCount = cal.range(of: .day, in: .month, for: start)!.count

        var buckets: [Bucket] = []
        var firstDay = 1
        while firstDay <= dayCount {
            let lastDay = min(firstDay + 6, dayCount)
            let from = cal.date(byAdding: .day, value: firstDay - 1, to: start)!
            let to = cal.date(byAdding: .day, value: lastDay, to: start)!
            buckets.append(Bucket(id: "\(firstDay)–\(lastDay)",
                                  miles: miles(inMonth, from: from, to: to),
                                  isFuture: from > today,
                                  isCurrent: today >= from && today < to))
            firstDay += 7
        }

        let name = start.formatted(.dateTime.month(.wide))
        let title = offset == 0 ? "This month · \(name)" : start.formatted(.dateTime.month(.wide).year())

        let prevStart = cal.date(byAdding: .month, value: -1, to: start)!
        let elapsedDays = offset == 0 ? (cal.dateComponents([.day], from: start, to: today).day ?? 0) + 1 : dayCount
        let prevEnd = cal.date(byAdding: .day, value: elapsedDays, to: prevStart)!
        let prevMiles = miles(all, from: prevStart, to: prevEnd)
        let comparison = delta(current: inMonth.reduce(0) { $0 + $1.miles }, previous: prevMiles,
                               label: offset == 0 ? "vs this point last month" : "vs month before")

        return PeriodSummary(title: title, buckets: buckets, runs: inMonth,
                             comparison: comparison, isCurrent: offset == 0)
    }

    private static func delta(current: Double, previous: Double, label: String) -> HeroMetric.Delta? {
        guard previous > 0 else { return nil }
        let change = current - previous
        let text = "\(abs(change).formatted(.number.precision(.fractionLength(1)))) mi \(label)"
        return HeroMetric.Delta(text: text, isUp: change >= 0)
    }
}

// MARK: - Formatting

fileprivate enum RunFormat {
    static func miles(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }

    static func pace(_ secondsPerMile: Int) -> String {
        "\(secondsPerMile / 60)'\(String(format: "%02d", secondsPerMile % 60))\""
    }

    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        return h > 0 ? "\(h):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
                     : "\(m):\(String(format: "%02d", s))"
    }

    static func totalTime(_ seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    static func day(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

// MARK: - Screen

fileprivate enum LoadPhase { case loading, loaded, failed }

struct S_stats: View {
    @State private var kind: PeriodKind = .week
    @State private var offset = 0
    @State private var selectedBucket: String?
    @State private var phase: LoadPhase = .loading

    private let runs = SampleRuns.all
    private let maxOffset = 6

    init() {}

    private var summary: PeriodSummary {
        StatsCalendar.summary(kind: kind, offset: offset, runs: runs)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch phase {
                case .failed:
                    EmptyState(title: "Couldn't load your runs",
                               message: "Check your connection and try again.",
                               systemImage: "wifi.slash") {
                        Button("Try again") { Task { await load() } }
                            .buttonStyle(.secondary)
                            .fixedSize()
                    }
                    .canvasBackground()
                case .loading, .loaded:
                    content
                }
            }
            .navigationTitle("Running")
            .navigationDestination(for: PeriodKind.self) { _ in
                AllRunsList(title: summary.title, runs: summary.runs)
            }
        }
        .tint(Palette.ink)
        .task { await load() }
    }

    private func load() async {
        phase = .loading
        try? await Task.sleep(for: .milliseconds(450))
        withAnimation(Motion.smooth) { phase = .loaded }
    }

    private var content: some View {
        let s = summary
        let isLoading = phase == .loading
        return ScrollView {
            VStack(alignment: .leading, spacing: Space.xxl) {
                VStack(alignment: .leading, spacing: Space.sm) {
                    Picker("Period", selection: $kind) {
                        ForEach(PeriodKind.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    PeriodStepper(title: s.title,
                                  canGoBack: offset < maxOffset,
                                  canGoForward: offset > 0,
                                  back: { step(1) },
                                  forward: { step(-1) })
                }

                VStack(alignment: .leading, spacing: Space.xl) {
                    hero(s)
                    WeekChart(buckets: s.buckets,
                              kind: kind,
                              goal: kind == .month ? SampleRuns.weeklyGoal : nil,
                              selection: $selectedBucket)
                }
                .redacted(reason: isLoading ? .placeholder : [])
                .shimmering(isActive: isLoading)

                MetricRow(items: [
                    (RunFormat.totalTime(s.seconds), "Time"),
                    (s.avgPace.map(RunFormat.pace) ?? "–", "Avg pace / mi"),
                    ("\(s.runs.count)", s.runs.count == 1 ? "Run" : "Runs"),
                ])
                .redacted(reason: isLoading ? .placeholder : [])

                history(s, isLoading: isLoading)
            }
            .padding(.horizontal, Space.margin)
            .padding(.top, Space.xs)
            .padding(.bottom, Space.xxl)
        }
        .canvasBackground()
        .refreshable { await load() }
        .sensoryFeedback(.selection, trigger: kind)
        .sensoryFeedback(.selection, trigger: offset)
        .onChange(of: kind) {
            offset = 0
            selectedBucket = nil
        }
    }

    private func step(_ by: Int) {
        withAnimation(Motion.snappy) {
            offset = min(max(offset + by, 0), maxOffset)
            selectedBucket = nil
        }
    }

    @ViewBuilder
    private func hero(_ s: PeriodSummary) -> some View {
        if let id = selectedBucket, let bucket = s.buckets.first(where: { $0.id == id }) {
            HeroMetric(label: kind == .week ? id : "Days \(id)",
                       value: RunFormat.miles(bucket.miles),
                       suffix: "mi",
                       context: bucket.miles == 0 ? (bucket.isFuture ? "Still ahead" : "Rest day") : nil)
        } else {
            let goalContext: String? = {
                guard kind == .week else { return nil }
                let left = SampleRuns.weeklyGoal - s.miles
                return left > 0 ? "\(RunFormat.miles(left)) mi to your \(Int(SampleRuns.weeklyGoal)) mi goal"
                                : "Weekly goal of \(Int(SampleRuns.weeklyGoal)) mi reached"
            }()
            HeroMetric(label: "Distance",
                       value: RunFormat.miles(s.miles),
                       suffix: "mi",
                       context: goalContext,
                       delta: s.comparison)
        }
    }

    @ViewBuilder
    private func history(_ s: PeriodSummary, isLoading: Bool) -> some View {
        let visible = Array(s.runs.prefix(5))
        VStack(alignment: .leading, spacing: Space.sm) {
            SectionHeader(title: "Runs")
            if visible.isEmpty {
                Text(s.isCurrent ? "No runs yet this \(kind == .week ? "week" : "month"). Your runs show up here after you finish one."
                                 : "No runs in this period.")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, run in
                        RunRow(run: run)
                        if index < visible.count - 1 {
                            Divider().overlay(Palette.hairline).padding(.leading, Space.md)
                        }
                    }
                }
                .background(Palette.surface, in: RoundedRectangle(cornerRadius: Radius.l, style: .continuous))
                .redacted(reason: isLoading ? .placeholder : [])

                if s.runs.count > visible.count {
                    NavigationLink(value: kind) {
                        Text("See all \(s.runs.count) runs")
                    }
                    .buttonStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - Period stepper

fileprivate struct PeriodStepper: View {
    let title: String
    let canGoBack: Bool
    let canGoForward: Bool
    let back: () -> Void
    let forward: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .frame(minWidth: Metrics.minTap, minHeight: Metrics.minTap)
            }
            .disabled(!canGoBack)
            .accessibilityLabel("Show previous period")

            Spacer(minLength: Space.xs)
            Text(title)
                .font(.dsSubhead)
                .foregroundStyle(Palette.ink2)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
            Spacer(minLength: Space.xs)

            Button(action: forward) {
                Image(systemName: "chevron.right")
                    .frame(minWidth: Metrics.minTap, minHeight: Metrics.minTap)
            }
            .disabled(!canGoForward)
            .accessibilityLabel("Show next period")
        }
        .font(.dsBody)
        .foregroundStyle(Palette.ink)
    }
}

// MARK: - Chart

fileprivate struct WeekChart: View {
    let buckets: [Bucket]
    let kind: PeriodKind
    let goal: Double?
    @Binding var selection: String?

    private var isEmpty: Bool { buckets.allSatisfy { $0.miles == 0 } }

    private func color(for bucket: Bucket) -> Color {
        if let selection { return bucket.id == selection ? Palette.accent : Palette.ink.opacity(0.2) }
        return bucket.isCurrent ? Palette.accent : Palette.ink.opacity(0.85)
    }

    var body: some View {
        Chart {
            ForEach(buckets) { bucket in
                BarMark(x: .value(kind == .week ? "Day" : "Days", bucket.id),
                        y: .value("Miles", bucket.miles),
                        width: .ratio(0.55))
                    .foregroundStyle(color(for: bucket))
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4, style: .continuous))
            }
            if let goal {
                RuleMark(y: .value("Goal", goal))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Palette.ink2)
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal \(Int(goal)) mi")
                            .font(.dsFootnote)
                            .foregroundStyle(Palette.ink2)
                    }
            }
        }
        .chartYScale(domain: 0...yMax)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(Palette.hairline)
                AxisValueLabel().font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel().font(.dsFootnote).foregroundStyle(Palette.ink2)
            }
        }
        .chartXSelection(value: $selection)
        .frame(height: 180)
        .overlay {
            if isEmpty {
                Text(kind == .week ? "No runs this week" : "No runs this month")
                    .font(.dsSubhead)
                    .foregroundStyle(Palette.ink2)
            }
        }
        .animation(Motion.snappy, value: selection)
        .accessibilityElement()
        .accessibilityLabel(kind == .week ? "Miles per day" : "Miles per week")
        .accessibilityValue(buckets.map { "\($0.id) \(RunFormat.miles($0.miles))" }.joined(separator: ", "))
    }

    private var yMax: Double {
        let top = max(buckets.map(\.miles).max() ?? 0, goal ?? 0)
        return max(top * 1.15, kind == .week ? 4 : 10)
    }
}

// MARK: - Rows

fileprivate struct RunRow: View {
    let run: Run

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.sm) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(run.name)
                    .font(.dsBody)
                    .foregroundStyle(Palette.ink)
                Text("\(RunFormat.day(run.date)) · \(RunFormat.pace(run.paceSecondsPerMile)) /mi")
                    .font(.dsFootnote)
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: Space.xs)
            VStack(alignment: .trailing, spacing: Space.xxs) {
                Text("\(RunFormat.miles(run.miles)) mi")
                    .font(.dsBody)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink)
                Text(RunFormat.duration(run.seconds))
                    .font(.dsFootnote)
                    .monospacedDigit()
                    .foregroundStyle(Palette.ink2)
            }
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
        .frame(minHeight: 64)
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct AllRunsList: View {
    let title: String
    let runs: [Run]

    var body: some View {
        List {
            Section {
                ForEach(runs) { run in
                    RunRow(run: run)
                        .listRowInsets(EdgeInsets())
                        .surfaceRow()
                }
            } header: {
                Text(title).overlineStyle()
            }
        }
        .listStyle(.insetGrouped)
        .canvasBackground()
        .navigationTitle("All runs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Light") { S_stats() }
#Preview("Dark") { S_stats().preferredColorScheme(.dark) }
#Preview("Large text") { S_stats().dynamicTypeSize(.accessibility2) }
