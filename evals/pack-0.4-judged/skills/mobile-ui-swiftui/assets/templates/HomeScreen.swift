// HomeScreen.swift — Home/dashboard archetype (mobile-ui/references/screen-home.md).
// Job: "see what's left to spend". Focal: hero balance. Primary: none (add lives in the toolbar).
// Copy and sample data here are examples for a fictional app — reuse the structure, write your own words.

import SwiftUI

struct Bill: Identifiable {
    let id = UUID()
    let name: String
    let due: String
    let amount: String
    let systemImage: String
}

struct HomeScreen: View {
    var isLoading = false
    var bills: [Bill] = Bill.samples

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: QSpace.xxl) {
                    VStack(alignment: .leading, spacing: QSpace.xl) {
                        QHeroMetric(
                            label: "Left to spend",
                            value: "2,140",
                            prefix: "$",
                            suffix: ".50",
                            context: "12 days to go",
                            delta: .init(text: "$86 under", isUp: false, upIsGood: false)
                        )
                        QMetricRow(items: [
                            ("$1,284", "spent"),
                            ("$107", "per day"),
                            ("62%", "of budget"),
                        ])
                    }

                    VStack(alignment: .leading, spacing: QSpace.sm) {
                        QSectionHeader(title: "Up next", actionTitle: "See all") {}
                        if bills.isEmpty {
                            Text("No bills due this month.")
                                .font(.dsSubhead)
                                .foregroundStyle(QPalette.ink2)
                                .frame(maxWidth: .infinity, minHeight: QMetrics.rowMinHeight, alignment: .leading)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(bills) { bill in
                                    QListRow(title: bill.name, subtitle: bill.due, systemImage: bill.systemImage) {
                                        Text(bill.amount)
                                            .font(.dsBody)
                                            .monospacedDigit()
                                            .foregroundStyle(QPalette.ink)
                                    }
                                    .padding(.horizontal, QSpace.md)
                                    if bill.id != bills.last?.id {
                                        Divider().overlay(QPalette.hairline).padding(.leading, 56)
                                    }
                                }
                            }
                            .background(QPalette.surface, in: RoundedRectangle(cornerRadius: QRadius.l, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, QSpace.margin)
                .padding(.top, QSpace.xs)
                .padding(.bottom, QSpace.xxl)
                .redacted(reason: isLoading ? .placeholder : [])
                .qShimmering(isActive: isLoading)
            }
            .qCanvasBackground()
            .navigationTitle("September")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add expense")
                }
            }
            .tint(QPalette.ink)
        }
    }
}

extension Bill {
    static let samples: [Bill] = [
        .init(name: "Rent", due: "Due Thursday", amount: "−$1,450.00", systemImage: "house"),
        .init(name: "Spotify Family", due: "Sep 18", amount: "−$16.99", systemImage: "music.note"),
        .init(name: "Blue Bottle Coffee subscription", due: "Sep 21", amount: "−$38.40", systemImage: "cup.and.saucer"),
    ]
}

#Preview("Light") { HomeScreen() }
#Preview("Dark") { HomeScreen().preferredColorScheme(.dark) }
#Preview("Loading") { HomeScreen(isLoading: true) }
#Preview("Large text") { HomeScreen().dynamicTypeSize(.accessibility2) }
