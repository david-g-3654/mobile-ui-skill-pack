import SwiftUI
import Charts

struct S_stats: View {
    @State private var period = 0
    @State private var selectedDay: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    init() {}

    private var week: RunningWeek { RunningWeek.samples[period] }
    private var selectedIndex: Int? {
        guard let selectedDay, let index = Int(selectedDay), week.distances.indices.contains(index) else { return nil }
        return index
    }
    private var distance: Double {
        selectedIndex.map { week.distances[$0] } ?? week.total
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    periodControl
                    distanceSection
                    summary
                    runLog
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.sm)
                .padding(.bottom, QSpace.xxl)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .qCanvasBackground()
            .navigationTitle("Running")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: "My running week, \(week.dates): \(week.total.formatted(.number.precision(.fractionLength(1)))) km across \(week.runs.count) runs.") {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share weekly stats")
                }
            }
        }
        .tint(QPalette.ink)
        .sensoryFeedback(.selection, trigger: period)
        .onChange(of: period) { _, _ in selectedDay = nil }
    }

    private var periodControl: some View {
        VStack(alignment: .leading, spacing: QSpace.md) {
            Picker("Running week", selection: $period) {
                Text("This week").tag(0)
                Text("Last week").tag(1)
            }
            .pickerStyle(.segmented)
            Text(week.dates)
                .font(.dsSubhead)
                .foregroundStyle(QPalette.ink2)
        }
    }

    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: QSpace.md) {
            VStack(alignment: .leading, spacing: QSpace.xxs) {
                HStack {
                    Text(selectedIndex.map { "\(RunningWeek.days[$0]) distance" } ?? "Weekly distance")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                    Spacer(minLength: QSpace.xs)
                    if selectedIndex != nil {
                        Button("Show week") { selectedDay = nil }
                            .font(.dsSubhead)
                            .frame(minHeight: QMetrics.minTap)
                    }
                }
                HStack(alignment: .firstTextBaseline, spacing: QSpace.xs) {
                    QHeroText(text: distance.formatted(.number.precision(.fractionLength(1))), size: 72)
                        .contentTransition(.numericText())
                    Text("km")
                        .font(.dsSubhead)
                        .foregroundStyle(QPalette.ink2)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(selectedIndex.map { RunningWeek.days[$0] } ?? "Weekly") distance, \(distance.formatted()) kilometres")
            }

            QBarChart(
                bars: week.distances.indices.map { index in
                    QBar(label: RunningWeek.days[index], shortLabel: String(RunningWeek.days[index].prefix(1)),
                         value: week.distances[index], spokenValue: "\(week.distances[index].formatted()) kilometres")
                },
                highlighted: selectedIndex ?? week.highlight
            )
            .chartYScale(domain: 0...14)
            .chartYAxis {
                AxisMarks(position: .trailing, values: [0, 7, 14]) { _ in
                    AxisGridLine().foregroundStyle(QPalette.hairline)
                    AxisValueLabel().font(.dsFootnote).foregroundStyle(QPalette.ink2)
                }
            }
            .chartXSelection(value: $selectedDay)
            .accessibilityLabel("Daily running distance, \(week.dates)")

            VStack(alignment: .leading, spacing: QSpace.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Weekly goal")
                    Spacer(minLength: QSpace.xs)
                    Text("\(week.total.formatted(.number.precision(.fractionLength(1)))) / 35 km")
                        .monospacedDigit()
                }
                .font(.dsFootnote)
                .foregroundStyle(QPalette.ink2)
                GeometryReader { geometry in
                    Capsule().fill(QPalette.surface2)
                        .overlay(alignment: .leading) {
                            Capsule().fill(QPalette.accent)
                                .frame(width: geometry.size.width * min(week.total / 35, 1))
                        }
                }
                .frame(height: QSpace.xxs)
                .accessibilityHidden(true)
                Text(period == 0 ? "10.4 km to go. Room for a weekend run." : "A steady week. Just 2.6 km shy of your goal.")
                    .font(.dsFootnote)
                    .foregroundStyle(QPalette.ink2)
            }
        }
        .animation(reduceMotion ? nil : QMotion.snappy, value: period)
        .animation(reduceMotion ? nil : QMotion.snappy, value: selectedDay)
    }

    private var summary: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.md))
            : AnyLayout(HStackLayout(alignment: .top, spacing: QSpace.md))
        return layout {
            metric(week.movingTime, label: "Moving time")
            metric(week.pace, label: "Avg pace / km")
            metric("\(week.runs.count)", label: "Runs")
        }
        .padding(.vertical, QSpace.lg)
        .overlay(alignment: .top) { Divider().overlay(QPalette.hairline) }
        .overlay(alignment: .bottom) { Divider().overlay(QPalette.hairline) }
    }

    private func metric(_ value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: QSpace.xxs) {
            Text(value).font(.dsHeadline).monospacedDigit().foregroundStyle(QPalette.ink)
            Text(label).font(.dsFootnote).foregroundStyle(QPalette.ink2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var runLog: some View {
        VStack(alignment: .leading, spacing: QSpace.sm) {
            Text("Run log")
                .font(.dsHeadline)
                .foregroundStyle(QPalette.ink)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                ForEach(week.runs) { run in
                    NavigationLink {
                        RunningDetail(run: run)
                    } label: {
                        runRow(run)
                    }
                    .buttonStyle(.plain)
                    if run.id != week.runs.last?.id {
                        Divider().overlay(QPalette.hairline)
                    }
                }
            }
        }
    }

    private func runRow(_ run: RunningEntry) -> some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: QSpace.xs))
            : AnyLayout(HStackLayout(alignment: .center, spacing: QSpace.md))
        return layout {
            VStack(alignment: .leading, spacing: QSpace.xxs) {
                Text(run.name).font(.dsHeadline).foregroundStyle(QPalette.ink)
                Text("\(run.date) · \(run.duration)")
                    .font(.dsFootnote).foregroundStyle(QPalette.ink2)
            }
            Spacer(minLength: 0)
            HStack(spacing: QSpace.sm) {
                Text("\(run.distance.formatted(.number.precision(.fractionLength(1)))) km")
                    .font(.dsSubhead).monospacedDigit().foregroundStyle(QPalette.ink)
                Image(systemName: "chevron.right")
                    .font(.dsFootnote).foregroundStyle(QPalette.ink2)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, QSpace.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

fileprivate struct RunningEntry: Identifiable {
    let id: Int
    let name: String
    let date: String
    let distance: Double
    let duration: String
    let pace: String
}

fileprivate struct RunningWeek {
    let dates: String
    let distances: [Double]
    let movingTime: String
    let pace: String
    let highlight: Int
    let runs: [RunningEntry]

    var total: Double { distances.reduce(0, +) }
    static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static let samples: [RunningWeek] = [
        .init(dates: "12–18 October 2026", distances: [6.2, 0, 8, 0, 10.4, 0, 0],
              movingTime: "2h 22m", pace: "5′48″", highlight: 4,
              runs: [
                .init(id: 3, name: "River loop", date: "Fri, 16 Oct", distance: 10.4, duration: "1h 02m", pace: "5′58″"),
                .init(id: 2, name: "Midweek tempo", date: "Wed, 14 Oct", distance: 8, duration: "42m 48s", pace: "5′21″"),
                .init(id: 1, name: "Easy morning", date: "Mon, 12 Oct", distance: 6.2, duration: "37m 48s", pace: "6′06″")
              ]),
        .init(dates: "5–11 October 2026", distances: [5.4, 0, 7.8, 6, 0, 13.2, 0],
              movingTime: "3h 10m", pace: "5′53″", highlight: 5,
              runs: [
                .init(id: 7, name: "Saturday long run", date: "Sat, 10 Oct", distance: 13.2, duration: "1h 20m", pace: "6′04″"),
                .init(id: 6, name: "Neighborhood miles", date: "Thu, 8 Oct", distance: 6, duration: "35m 30s", pace: "5′55″"),
                .init(id: 5, name: "Tempo intervals", date: "Wed, 7 Oct", distance: 7.8, duration: "41m 36s", pace: "5′20″"),
                .init(id: 4, name: "Recovery run", date: "Mon, 5 Oct", distance: 5.4, duration: "33m 30s", pace: "6′12″")
              ])
    ]
}

fileprivate struct RunningDetail: View {
    let run: RunningEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QSpace.xxl) {
                Text(run.date).font(.dsSubhead).foregroundStyle(QPalette.ink2)
                VStack(alignment: .leading, spacing: QSpace.xxs) {
                    QHeroText(text: run.distance.formatted(.number.precision(.fractionLength(1))))
                    Text("kilometres").font(.dsSubhead).foregroundStyle(QPalette.ink2)
                }
                QMetricRow(items: [(run.duration, "Moving time"), (run.pace, "Avg pace / km")])
            }
            .padding(QSpace.margin)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .qCanvasBackground()
        .navigationTitle(run.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    S_stats().preferredColorScheme(.light)
}

#Preview("Dark") {
    S_stats().preferredColorScheme(.dark)
}

#Preview("Large text") {
    S_stats().dynamicTypeSize(.accessibility2)
}
