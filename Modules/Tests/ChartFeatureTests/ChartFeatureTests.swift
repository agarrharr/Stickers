import ComposableArchitecture
import Foundation
import NonEmpty
import Testing

@testable import ChartFeature
import Models

@MainActor
struct ChartFeatureTests {
    func makeChart(
        name: String = "Chores",
        quickActions: IdentifiedArrayOf<QuickAction> = [],
        stickers: IdentifiedArrayOf<Sticker> = []
    ) -> Chart {
        Chart(
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
            $0.$chart.withLock { $0.stickers = [Sticker(imageName: "face-0")] }
        }
    }

    @Test
    func quickActionTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
        }
        let quickActionID = UUID(100)
        let chart = makeChart(
            quickActions: [QuickAction(name: "Chore", amount: 3)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(quickActionID)) {
            $0.$chart.withLock {
                $0.stickers = [
                    Sticker(imageName: "face-0"),
                    Sticker(imageName: "face-0"),
                    Sticker(imageName: "face-0"),
                ]
            }
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
            $0.$chart.withLock { $0.name = "Homework" }
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
            $0.$chart.withLock { $0.quickActions = [QuickAction(name: "", amount: 1)] }
        }
    }

    @Test
    func removeQuickAction() async {
        let chart = makeChart(
            quickActions: [QuickAction(name: "Chore", amount: 5)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.removeQuickAction(chart.id)) {
            $0.$chart.withLock { $0.quickActions = [] }
        }
    }

    @Test
    func quickActionNameChanged() async {
        let chart = makeChart(
            quickActions: [QuickAction(name: "Old", amount: 5)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionNameChanged(chart.id, "New")) {
            $0.$chart.withLock { $0.quickActions[0].name = "New" }
        }
    }

    @Test
    func quickActionAmountChanged() async {
        let chart = makeChart(
            quickActions: [QuickAction(name: "Chore", amount: 1)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionAmountChanged(chart.id, 10)) {
            $0.$chart.withLock { $0.quickActions[0].amount = 10 }
        }
    }
}
