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

        let charts = try database.read { db in
            try Chart.all.fetchAll(db)
        }
        #expect(charts.count == 1)
        #expect(charts[0].name == "Chores")

        let dbQuickActions = try database.read { db in
            try QuickAction.where { $0.chartID.eq(charts[0].id) }.fetchAll(db)
        }
        #expect(dbQuickActions.count == 1)
        #expect(dbQuickActions[0].name == "Take out trash")
        #expect(dbQuickActions[0].amount == 5)
    }

    @Test
    func chartTapped() async throws {
        let chartID = UUID(100)
        try database.write { db in
            try db.seed {
                Chart(id: chartID, name: "Chores")
            }
        }

        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(chartID)) {
            $0.path[id: 0] = ChartFeature.State(chartID: chartID)
        }
    }

    @Test
    func chartTappedWithInvalidID() async {
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(UUID(99))) {
            $0.path[id: 0] = ChartFeature.State(chartID: UUID(99))
        }
    }
}
