import ComposableArchitecture
import Dependencies
import Foundation
import NonEmpty
import Testing

@testable import ChartFeature
import Models
import StickerFeature

private struct LCRNG: RandomNumberGenerator, @unchecked Sendable {
    var seed: UInt64
    mutating func next() -> UInt64 {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return seed
    }
}

@MainActor
struct ChartFeatureTests {
    func makeChart(
        id: UUID = UUID(0),
        name: String = "Chores",
        quickActions: IdentifiedArrayOf<QuickAction> = [],
        stickers: IdentifiedArrayOf<Sticker> = []
    ) -> Chart {
        Chart(id: id, name: name, quickActions: quickActions, stickers: stickers)
    }

    @Test
    func addStickerButtonTapped() async {
        var gen = LCRNG(seed: 0)
        let expectedImageName = stickerPack.randomElement(using: &gen)!.imageName

        prepareDependencies {
            $0.uuid = .incrementing
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 0))
        }
        let chart = makeChart()
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.addStickerButtonTapped) {
            $0.$chart.withLock {
                $0.stickers = [Sticker(id: UUID(0), imageName: expectedImageName)]
            }
        }
    }

    @Test
    func quickActionTapped() async {
        prepareDependencies {
            $0.uuid = .incrementing
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 0))
        }
        var gen = LCRNG(seed: 0)
        let expectedImageNames = (0..<3).map { _ in
            stickerPack.randomElement(using: &gen)!.imageName
        }

        let chart = makeChart(
            quickActions: [QuickAction(name: "Chore", amount: 3)]
        )
        let store = TestStore(
            initialState: ChartFeature.State(chart: Shared(value: chart))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(chart.quickActions[0].id)) {
            $0.$chart.withLock {
                $0.stickers = [
                    Sticker(id: UUID(1), imageName: expectedImageNames[0]),
                    Sticker(id: UUID(2), imageName: expectedImageNames[1]),
                    Sticker(id: UUID(3), imageName: expectedImageNames[2]),
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
            $0.$chart.withLock { $0.quickActions = [QuickAction(id: UUID(0), name: "", amount: 1)] }
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
            $0.$chart.withLock { $0.quickActions = [] }
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
            $0.$chart.withLock { $0.quickActions[0].name = "New" }
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
            $0.$chart.withLock { $0.quickActions[0].amount = 10 }
        }
    }
}
