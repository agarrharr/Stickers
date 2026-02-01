import ComposableArchitecture
import Foundation
import Testing

import AddChartFeature
@testable import ChartsFeature
import ChartFeature
import Models

@MainActor
struct ChartsFeatureTests {
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
    func addChartDelegateAddsChart() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.addChartButtonTapped) {
            $0.addChart = AddChartFeature.State()
        }

        let quickActions: IdentifiedArrayOf<QuickAction> = [
            QuickAction(id: UUID(99), name: "Take out trash", amount: 5)
        ]

        await store.send(.addChart(.presented(.delegate(.onChartAdded("Chores", .yellow, quickActions))))) {
            $0.$charts.withLock {
                $0 = [
                    Chart(
                        id: UUID(0),
                        name: "Chores",
                        quickActions: [QuickAction(id: UUID(99), name: "Take out trash", amount: 5)],
                        stickers: []
                    )
                ]
            }
            $0.addChart = nil
        }
    }

    @Test
    func chartTapped() async {
        let chartID = UUID(1)
        let chart = Chart(
            id: chartID,
            name: "Chores",
            quickActions: [],
            stickers: []
        )

        var state = ChartsFeature.State()
        state.$charts.withLock { $0.append(chart) }

        let store = TestStore(initialState: state) {
            ChartsFeature()
        }

        await store.send(.chartTapped(chartID)) {
            $0.path[id: 0] = ChartFeature.State(
                chart: Shared($0.$charts[id: chartID])!
            )
        }
    }

    @Test
    func chartTappedWithInvalidID() async {
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(UUID(99)))
    }
}
