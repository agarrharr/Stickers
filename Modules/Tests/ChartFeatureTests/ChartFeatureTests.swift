import ComposableArchitecture
import CustomDump
import Dependencies
import DependenciesTestSupport
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
@Suite(
    .dependencies {
        $0.uuid = .incrementing
        try $0.bootstrapDatabase()
//        try $0.defaultDatabase.write { db in
//            try db.seed {
//                
//            }
//        }
    }
)
struct ChartFeatureTests {
    @Dependency(\.defaultDatabase) var database

    @Test(
        .dependency(\.withRandomNumberGenerator, WithRandomNumberGenerator(LCRNG(seed: 0))),
        .dependency(\.date, .constant(Date(timeIntervalSince1970: 1_753_500_000)))
    )
    func addStickers() async throws {
        var gen = LCRNG(seed: 0)
        let expectedImageNames = (0..<3).map { _ in
            stickerPack.randomElement(using: &gen)!
        }

        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.addStickerButtonTapped) {
            $0.destination = .addStickersForm
        }
        await store.send(.binding(.set(\.addStickersAmount, 3))) {
            $0.addStickersAmount = 3
        }
        await store.send(.binding(.set(\.addStickersNote, "  Cleaned room  "))) {
            $0.addStickersNote = "  Cleaned room  "
        }
        await store.send(.addStickersConfirmed) {
            $0.destination = nil
        }
        await store.finish()

        let batches = try await database.read { db in
            try StickerBatch.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        expectNoDifference(batches, [
            StickerBatch(
                id: UUID(0),
                chartID: UUID(-1),
                note: "Cleaned room",
                createdAt: Date(timeIntervalSince1970: 1_753_500_000)
            ),
        ])

        let stickers = try await database.read { db in
            try Sticker.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        expectNoDifference(stickers, [
            Sticker(id: UUID(1), chartID: UUID(-1), imageName: expectedImageNames[0], batchID: UUID(0)),
            Sticker(id: UUID(2), chartID: UUID(-1), imageName: expectedImageNames[1], batchID: UUID(0)),
            Sticker(id: UUID(3), chartID: UUID(-1), imageName: expectedImageNames[2], batchID: UUID(0)),
        ])
    }

    @Test(
        .dependency(\.withRandomNumberGenerator, WithRandomNumberGenerator(LCRNG(seed: 0))),
        .dependency(\.date, .constant(Date(timeIntervalSince1970: 1_753_500_000)))
    )
    func addStickersWithoutNote() async throws {
        var gen = LCRNG(seed: 0)
        let expectedImageName = stickerPack.randomElement(using: &gen)!

        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.addStickerButtonTapped) {
            $0.destination = .addStickersForm
        }
        await store.send(.addStickersConfirmed) {
            $0.destination = nil
        }
        await store.finish()

        let batches = try await database.read { db in
            try StickerBatch.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        expectNoDifference(batches, [
            StickerBatch(
                id: UUID(0),
                chartID: UUID(-1),
                note: nil,
                createdAt: Date(timeIntervalSince1970: 1_753_500_000)
            ),
        ])

        let stickers = try await database.read { db in
            try Sticker.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        expectNoDifference(stickers, [
            Sticker(id: UUID(1), chartID: UUID(-1), imageName: expectedImageName, batchID: UUID(0)),
        ])
    }

    @Test
    func addStickersDismissed() async {
        var state = ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        state.destination = .addStickersForm
        let store = TestStore(initialState: state) {
            ChartFeature()
        }

        await store.send(.addStickersDismissed) {
            $0.destination = nil
        }
    }

    @Test(
        .dependency(\.withRandomNumberGenerator, WithRandomNumberGenerator(LCRNG(seed: 0))),
        .dependency(\.date, .constant(Date(timeIntervalSince1970: 1_753_500_000)))
    )
    func quickActionTapped() async throws {
        var gen = LCRNG(seed: 0)
        let expectedImageNames = (0..<99).map { _ in
            stickerPack.randomElement(using: &gen)!
        }

        let chartID = UUID(-1)
        let quickActionID = UUID(-1)
        try await database.write { db in
            try db.seed {
                Chart(id: chartID, name: "Chores")
                QuickAction(id: quickActionID, chartID: chartID, name: "Chore", amount: 3)
            }
        }

        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: chartID, name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(quickActionID))
        await store.finish()

        let batches = try await database.read { db in
            try StickerBatch.where { $0.chartID.eq(chartID) }.fetchAll(db)
        }
        expectNoDifference(batches, [
            StickerBatch(
                id: UUID(0),
                chartID: chartID,
                note: "Chore",
                createdAt: Date(timeIntervalSince1970: 1_753_500_000)
            ),
        ])

        let stickers = try await database.read { db in
            try Sticker.where { $0.chartID.eq(chartID) }.fetchAll(db)
        }
        expectNoDifference(stickers, [
            Sticker(id: UUID(1), chartID: chartID, imageName: expectedImageNames[0], batchID: UUID(0)),
            Sticker(id: UUID(2), chartID: chartID, imageName: expectedImageNames[1], batchID: UUID(0)),
            Sticker(id: UUID(3), chartID: chartID, imageName: expectedImageNames[2], batchID: UUID(0)),
        ])
    }

    @Test(
        .dependency(\.withRandomNumberGenerator, WithRandomNumberGenerator(LCRNG(seed: 0))),
        .dependency(\.date, .constant(Date(timeIntervalSince1970: 1_753_500_000)))
    )
    func quickActionTappedWithInvalidID() async throws {
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionTapped(UUID(99)))
        await store.finish()

        let stickers = try await database.read { db in
            try Sticker.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        #expect(stickers.isEmpty)

        let batches = try await database.read { db in
            try StickerBatch.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        #expect(batches.isEmpty)
    }

    @Test
    func settingsButtonTapped() async {
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.settingsButtonTapped) {
            $0.showSettings = true
        }
    }

    @Test
    func settingsDismissed() async {
        var state = ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        state.showSettings = true
        let store = TestStore(initialState: state) {
            ChartFeature()
        }

        await store.send(.settingsDismissed) {
            $0.showSettings = false
        }
    }

    @Test
    func nameChanged() async throws {
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.nameChanged("Homework")) {
            $0.chart.name = "Homework"
        }

        let chart = try await database.read { db in
            try Chart.find(UUID(-1)).fetchOne(db)
        }
        expectNoDifference(chart, Chart(id: UUID(-1), name: "Homework"))
    }

    @Test
    func addQuickActionButtonTapped() async throws {
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.addQuickActionButtonTapped)

        let quickActions = try await database.read { db in
            try QuickAction.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        expectNoDifference(quickActions, [
            QuickAction(id: UUID(0), chartID: UUID(-1), name: "", amount: 1),
        ])
    }

    @Test
    func removeQuickAction() async throws {
        let quickActionID = UUID(-1)
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
                QuickAction(id: quickActionID, chartID: UUID(-1), name: "Chore", amount: 5)
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.removeQuickAction(quickActionID))

        let quickActions = try await database.read { db in
            try QuickAction.where { $0.chartID.eq(UUID(-1)) }.fetchAll(db)
        }
        #expect(quickActions.isEmpty)
    }

    @Test
    func quickActionNameChanged() async throws {
        let quickActionID = UUID(-1)
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
                QuickAction(id: quickActionID, chartID: UUID(-1), name: "Old", amount: 5)
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionNameChanged(quickActionID, "New"))

        let qa = try await database.read { db in
            try QuickAction.find(quickActionID).fetchOne(db)
        }
        expectNoDifference(qa, QuickAction(id: UUID(-1), chartID: UUID(-1), name: "New", amount: 5))
    }

    @Test
    func quickActionAmountChanged() async throws {
        let quickActionID = UUID(-1)
        try await database.write { db in
            try db.seed {
                Chart(id: UUID(-1), name: "Chores")
                QuickAction(id: quickActionID, chartID: UUID(-1), name: "Chore", amount: 1)
            }
        }
        let store = TestStore(
            initialState: ChartFeature.State(chart: Chart(id: UUID(-1), name: "Chores"))
        ) {
            ChartFeature()
        }

        await store.send(.quickActionAmountChanged(quickActionID, 10))

        let qa = try await database.read { db in
            try QuickAction.find(quickActionID).fetchOne(db)
        }
        expectNoDifference(qa, QuickAction(id: UUID(-1), chartID: UUID(-1), name: "Chore", amount: 10))
    }
}
