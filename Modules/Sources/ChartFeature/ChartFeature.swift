import CloudKit
import ComposableArchitecture
import Foundation
import NonEmpty
import SQLiteData

import Models
import StickerFeature

public enum ViewMode: String, CaseIterable, Sendable {
    case grid = "Grid"
    case history = "History"
}

@Reducer
public struct ChartFeature {
    @CasePathable
    enum Destination: Equatable, Sendable {
        case addStickersForm
        case deleteAllStickersAlert
        case deleteBatchAlert
        case editBatchForm
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        var addStickersAmount = 1
        var addStickersNote = ""
        public var chart: Chart
        var deleteBatchID: StickerBatch.ID?
        var destination: Destination?
        var editBatchAmount = 1
        var editBatchDate = Date(timeIntervalSince1970: 0)
        var editBatchID: StickerBatch.ID?
        var editBatchNote = ""
        var sharedRecord: SharedRecord?
        var showSettings = false
        var syncErrorMessage: String?
        var viewMode: ViewMode = .grid

        public init(chart: Chart) {
            self.chart = chart
        }
    }

    public enum Action: BindableAction, Sendable {
        case addQuickActionButtonTapped
        case addStickerButtonTapped
        case addStickersConfirmed
        case addStickersDismissed
        case binding(BindingAction<State>)
        case deleteAllStickersButtonTapped
        case deleteAllStickersConfirmed
        case deleteBatchButtonTapped(StickerBatch.ID)
        case deleteBatchConfirmed
        case deleteBatchDismissed
        case editBatchButtonTapped(StickerBatch, stickerCount: Int)
        case editBatchConfirmed
        case editBatchDismissed
        case nameChanged(String)
        case quickActionAmountChanged(QuickAction.ID, Int)
        case quickActionNameChanged(QuickAction.ID, String)
        case quickActionTapped(QuickAction.ID)
        case removeQuickAction(QuickAction.ID)
        case settingsButtonTapped
        case settingsDismissed
        case shareButtonTapped
        case shareDismissed
        case shareResponse(SharedRecord)
        case syncErrorDismissed
        case syncFailed(String)
        case syncNowButtonTapped
    }

    @Dependency(\.date) var date
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.defaultSyncEngine) var syncEngine
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .addQuickActionButtonTapped:
                let chartID = state.chart.id
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            guard try Chart.find(chartID).fetchOne(db) != nil else {
                                throw ChartMutationError.chartNoLongerExists
                            }
                            try QuickAction.insert {
                                QuickAction.Draft(chartID: chartID)
                            }
                            .execute(db)
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Adding quick action") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .addStickerButtonTapped:
                state.addStickersAmount = 1
                state.addStickersNote = ""
                state.destination = .addStickersForm
                return .none

            case .addStickersConfirmed:
                state.destination = nil
                let amount = min(max(state.addStickersAmount, 1), 99)
                let note = state.addStickersNote.trimmingCharacters(in: .whitespacesAndNewlines)
                let imageNames = withRandomNumberGenerator { generator in
                    (0..<amount).map { _ in
                        stickerPack.randomElement(using: &generator)!
                    }
                }
                let chartID = state.chart.id
                let createdAt = date.now
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            guard try Chart.find(chartID).fetchOne(db) != nil else {
                                throw ChartMutationError.chartNoLongerExists
                            }
                            let batchID = try StickerBatch.insert {
                                StickerBatch.Draft(
                                    chartID: chartID,
                                    note: note.isEmpty ? nil : note,
                                    createdAt: createdAt
                                )
                            }
                            .returning(\.id)
                            .fetchOne(db)
                            for imageName in imageNames {
                                try Sticker.insert {
                                    Sticker.Draft(
                                        chartID: chartID,
                                        imageName: imageName,
                                        batchID: batchID
                                    )
                                }
                                .execute(db)
                            }
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Adding stickers") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .addStickersDismissed:
                state.destination = nil
                return .none

            case .deleteAllStickersButtonTapped:
                state.destination = .deleteAllStickersAlert
                return .none

            case .deleteAllStickersConfirmed:
                state.destination = nil
                let chartID = state.chart.id
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            try Sticker
                                .where { $0.chartID.eq(chartID) }
                                .delete()
                                .execute(db)
                            try StickerBatch
                                .where { $0.chartID.eq(chartID) }
                                .delete()
                                .execute(db)
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Deleting stickers") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case let .deleteBatchButtonTapped(batchID):
                state.deleteBatchID = batchID
                state.destination = .deleteBatchAlert
                return .none

            case .deleteBatchConfirmed:
                state.destination = nil
                guard let batchID = state.deleteBatchID else { return .none }
                state.deleteBatchID = nil
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            try Sticker
                                .where { $0.batchID.eq(batchID) }
                                .delete()
                                .execute(db)
                            try StickerBatch.find(batchID)
                                .delete()
                                .execute(db)
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Deleting sticker group") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .deleteBatchDismissed:
                state.deleteBatchID = nil
                state.destination = nil
                return .none

            case let .editBatchButtonTapped(batch, stickerCount):
                state.editBatchID = batch.id
                state.editBatchAmount = min(max(stickerCount, 1), 99)
                state.editBatchNote = batch.note ?? ""
                state.editBatchDate = batch.createdAt
                state.destination = .editBatchForm
                return .none

            case .editBatchConfirmed:
                state.destination = nil
                guard let batchID = state.editBatchID else { return .none }
                state.editBatchID = nil
                let amount = min(max(state.editBatchAmount, 1), 99)
                let note = state.editBatchNote.trimmingCharacters(in: .whitespacesAndNewlines)
                let createdAt = state.editBatchDate
                let chartID = state.chart.id
                let maxImageNames = withRandomNumberGenerator { generator in
                    (0..<99).map { _ in
                        stickerPack.randomElement(using: &generator)!
                    }
                }
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            guard try StickerBatch.find(batchID).fetchOne(db) != nil else {
                                throw ChartMutationError.batchNoLongerExists
                            }
                            try StickerBatch.find(batchID)
                                .update {
                                    $0.note = #bind(note.isEmpty ? nil : note)
                                    $0.createdAt = #bind(createdAt)
                                }
                                .execute(db)
                            let existingStickers = try Sticker
                                .where { $0.batchID.eq(batchID) }
                                .fetchAll(db)
                            if amount < existingStickers.count {
                                for sticker in existingStickers.suffix(existingStickers.count - amount) {
                                    try Sticker.find(sticker.id)
                                        .delete()
                                        .execute(db)
                                }
                            } else if amount > existingStickers.count {
                                for imageName in maxImageNames.prefix(amount - existingStickers.count) {
                                    try Sticker.insert {
                                        Sticker.Draft(
                                            chartID: chartID,
                                            imageName: imageName,
                                            batchID: batchID
                                        )
                                    }
                                    .execute(db)
                                }
                            }
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Editing sticker group") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .editBatchDismissed:
                state.editBatchID = nil
                state.destination = nil
                return .none

            case let .nameChanged(name):
                state.chart.name = name
                let chartID = state.chart.id
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try Chart.find(chartID)
                                .update { $0.name = #bind(name) }
                                .execute(db)
                        }
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Renaming chart") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case let .quickActionAmountChanged(id, amount):
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try QuickAction.find(id)
                                .update { $0.amount = #bind(amount) }
                                .execute(db)
                        }
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Updating quick action amount") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case let .quickActionNameChanged(id, name):
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try QuickAction.find(id)
                                .update { $0.name = #bind(name) }
                                .execute(db)
                        }
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Renaming quick action") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case let .quickActionTapped(quickActionID):
                let chartID = state.chart.id
                let maxImageNames = withRandomNumberGenerator { generator in
                    (0..<99).map { _ in
                        stickerPack.randomElement(using: &generator)!
                    }
                }
                let createdAt = date.now
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            guard try Chart.find(chartID).fetchOne(db) != nil else {
                                throw ChartMutationError.chartNoLongerExists
                            }
                            guard let quickAction = try QuickAction.find(quickActionID).fetchOne(db)
                            else { return }
                            let note = quickAction.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            let batchID = try StickerBatch.insert {
                                StickerBatch.Draft(
                                    chartID: chartID,
                                    note: note.isEmpty ? nil : note,
                                    createdAt: createdAt
                                )
                            }
                            .returning(\.id)
                            .fetchOne(db)
                            for imageName in maxImageNames.prefix(quickAction.amount) {
                                try Sticker.insert {
                                    Sticker.Draft(
                                        chartID: chartID,
                                        imageName: imageName,
                                        batchID: batchID
                                    )
                                }
                                .execute(db)
                            }
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Running quick action") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case let .removeQuickAction(id):
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            try QuickAction.find(id)
                                .delete()
                                .execute(db)
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Removing quick action") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .settingsButtonTapped:
                state.showSettings = true
                return .none

            case .settingsDismissed:
                state.showSettings = false
                return .none

            case .shareButtonTapped:
                let chartID = state.chart.id
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await syncEngine.sendChanges()
                        guard let chart = try await database.read({ db in
                            try Chart.find(chartID).fetchOne(db)
                        }) else { return }
                        let sharedRecord = try await syncEngine.share(record: chart) {
                            $0[CKShare.SystemFieldKey.title] = chart.name
                        }
                        await send(.shareResponse(sharedRecord))
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Sharing chart") {
                            await send(.syncFailed(message))
                        }
                    }
                }

            case .shareDismissed:
                state.sharedRecord = nil
                return .none

            case let .shareResponse(sharedRecord):
                state.sharedRecord = sharedRecord
                return .none

            case .syncErrorDismissed:
                state.syncErrorMessage = nil
                return .none

            case let .syncFailed(message):
                state.syncErrorMessage = message
                return .none

            case .syncNowButtonTapped:
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await syncEngine.syncChanges()
                    } catch {
                        if let message = SyncDiagnostics.log(error: error, operation: "Synchronizing changes") {
                            await send(.syncFailed(message))
                        }
                    }
                }
            }
        }
    }

    public init() {}
}

private enum ChartMutationError: LocalizedError {
    case batchNoLongerExists
    case chartNoLongerExists

    var errorDescription: String? {
        switch self {
        case .batchNoLongerExists:
            return "This group of stickers no longer exists locally. It was likely deleted on another device."
        case .chartNoLongerExists:
            return "This chart no longer exists locally. It was likely deleted on another device. Return to Charts and reopen."
        }
    }
}
