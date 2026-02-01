import ComposableArchitecture
import Foundation
import NonEmpty
import Testing

@testable import ChartFeature

@MainActor
struct ChartFeatureTests {
    static func makeChart(
        id: UUID = UUID(0),
        name: String = "Chores",
        quickActions: [QuickAction] = [],
        stickers: IdentifiedArrayOf<Sticker> = []
    ) -> Chart {
        Chart(
            id: id,
            name: name,
            quickActions: quickActions,
            stickers: stickers
        )
    }

    @Test
    func addStickerButtonTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.addStickerButtonTapped) {
            $0.chart.stickers = [Sticker(id: UUID(0), imageName: "face-0")]
        }
    }

    @Test
    func quickActionTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let quickActionID = UUID(100)
        let chart = makeChart(
            quickActions: [QuickAction(id: quickActionID, name: "Chore", amount: 3)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(quickActionID)) {
            $0.chart.stickers = [
                Sticker(id: UUID(0), imageName: "face-0"),
                Sticker(id: UUID(1), imageName: "face-0"),
                Sticker(id: UUID(2), imageName: "face-0"),
            ]
        }
    }

    @Test
    func quickActionTappedWithInvalidID() async {
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(UUID(99)))
    }

    @Test
    func settingsButtonTapped() async {
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.settingsButtonTapped) {
            $0.showSettings = true
        }
    }

    @Test
    func settingsDismissed() async {
        let chart = makeChart()
        var state = ChartFeature.State(chart: Shared(value: chart))
        state.showSettings = true
        let store = TestStore(initialState: state) {
            ChartFeature()
        }

        await store.send(.settingsDismissed) {
            $0.showSettings = false
        }
    }

    @Test
    func nameChanged() async {
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.nameChanged("Homework")) {
            $0.chart.name = "Homework"
        }
    }

    @Test
    func addQuickActionButtonTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.addQuickActionButtonTapped) {
            $0.chart.quickActions = [QuickAction(id: UUID(0), name: "", amount: 1)]
        }
    }

    @Test
    func removeQuickAction() async {
        let quickActionID = UUID(1)
        let chart = makeChart(
            quickActions: [QuickAction(id: quickActionID, name: "Chore", amount: 5)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.removeQuickAction(quickActionID)) {
            $0.chart.quickActions = []
        }
    }

    @Test
    func quickActionNameChanged() async {
        let quickActionID = UUID(1)
        let chart = makeChart(
            quickActions: [QuickAction(id: quickActionID, name: "Old", amount: 5)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionNameChanged(quickActionID, "New")) {
            $0.chart.quickActions[0].name = "New"
        }
    }

    @Test
    func quickActionAmountChanged() async {
        let quickActionID = UUID(1)
        let chart = makeChart(
            quickActions: [QuickAction(id: quickActionID, name: "Chore", amount: 1)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionAmountChanged(quickActionID, 10)) {
            $0.chart.quickActions[0].amount = 10
        }
    }
}
