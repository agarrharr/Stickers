import ComposableArchitecture
import Dependencies
import DependenciesTestSupport
import Foundation
import Testing

import AddChartFeature
@testable import ChartsFeature
import ChartFeature
import Models

@MainActor
@Suite(
    .dependency(\.uuid, .incrementing)
)
struct ChartsFeatureTests {
    @Dependency(\.defaultDatabase) var database

    @Test
    func addChartButtonTapped() async {
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.addChartButtonTapped) {
            $0.addChart = AddChartFeature.State()
        }
    }

    @Test
    func addChartDelegateAddsChart() async throws {
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.addChartButtonTapped) {
            $0.addChart = AddChartFeature.State()
        }

        let quickActions: [QuickActionInput] = [
            QuickActionInput(id: UUID(99), name: "Take out trash", amount: 5)
        ]

        await store.send(.addChart(.presented(.delegate(.onChartAdded("Chores", .yellow, quickActions))))) {
            $0.addChart = nil
        }

        let charts = try await database.read { db in
            try Chart.all.fetchAll(db)
        }
        #expect(charts.count == 1)
        #expect(charts[0].name == "Chores")

        let dbQuickActions = try await database.read { db in
            try QuickAction.where { $0.chartID.eq(charts[0].id) }.fetchAll(db)
        }
        #expect(dbQuickActions.count == 1)
        #expect(dbQuickActions[0].name == "Take out trash")
        #expect(dbQuickActions[0].amount == 5)
    }

    @Test
    func chartTapped() async throws {
        let chart = Chart(id: UUID(100), name: "Chores")
        try await database.write { db in
            try db.seed {
                chart
            }
        }

        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(chart)) {
            $0.path[id: 0] = ChartFeature.State(chart: chart)
        }
    }

    @Test
    func chartTappedWithInvalidChart() async {
        let randomChart = Chart(id: UUID())
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(randomChart)) {
            $0.path[id: 0] = ChartFeature.State(chart: randomChart)
        }
    }
}
