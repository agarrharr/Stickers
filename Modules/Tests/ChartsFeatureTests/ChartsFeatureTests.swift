import ComposableArchitecture
import CustomDump
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
    .dependencies {
        $0.uuid = .incrementing
        try $0.bootstrapDatabase()
    }
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
        expectNoDifference(charts, [Chart(id: UUID(0), name: "Chores")])

        let dbQuickActions = try await database.read { db in
            try QuickAction.where { $0.chartID.eq(UUID(0)) }.fetchAll(db)
        }
        expectNoDifference(dbQuickActions, [
            QuickAction(id: UUID(1), chartID: UUID(0), name: "Take out trash", amount: 5),
        ])
    }

    @Test
    func chartTapped() async throws {
        let chart = Chart(id: UUID(-1), name: "Chores")
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
    func chartsDeleteRequested() async throws {
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
                Chart(id: UUID(-2), name: "Work")
            }
        }
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartsDeleteRequested(IndexSet(integer: 0)))

        let charts = try await database.read { db in
            try Chart.all.fetchAll(db)
        }
        expectNoDifference(charts, [Chart(id: UUID(-2), name: "Work")])
    }
}
