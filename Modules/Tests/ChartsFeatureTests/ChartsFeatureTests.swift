import ComposableArchitecture
import NonEmpty
import Testing

@testable import ChartsFeature

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
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addChartButtonTapped) {
            $0.addChart = AddChartFeature.State()
        }

        let quickActions: IdentifiedArrayOf<QuickAction> = [
            QuickAction(id: UUID(0), name: "Take out trash", amount: 5)
        ]

        await store.send(.addChart(.presented(.delegate(.onChartAdded("Chores", .yellow, quickActions))))) {
            $0.charts = [
                Chart(
                    id: $0.charts.first!.id,
                    name: "Chores",
                    quickActions: [QuickAction(id: $0.charts.first!.quickActions.first!.id, name: "Take out trash", amount: 5)],
                    stickers: []
                )
            ]
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
                chart: Shared($0.$charts[id: chartID]!)
            )
        }
    }

    @Test
    func chartTappedWithInvalidID() async {
        let store = TestStore(initialState: ChartsFeature.State()) {
            ChartsFeature()
        }

        await store.send(.chartTapped(UUID(99)))
        // No state change expected
    }
}
