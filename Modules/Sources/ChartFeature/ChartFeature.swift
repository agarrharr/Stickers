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
        case deleteAllStickersAlert
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public var chart: Chart
        var destination: Destination?
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
        case binding(BindingAction<State>)
        case deleteAllStickersButtonTapped
        case deleteAllStickersConfirmed
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
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Adding quick action")
                        ))
                    }
                }

            case .addStickerButtonTapped:
                let imageName = withRandomNumberGenerator { generator in
                    stickerPack.randomElement(using: &generator)!
                }
                let chartID = state.chart.id
                let database = database
                let syncEngine = syncEngine
                return .run { send in
                    do {
                        try await database.write { db in
                            guard try Chart.find(chartID).fetchOne(db) != nil else {
                                throw ChartMutationError.chartNoLongerExists
                            }
                            try Sticker.insert {
                                Sticker.Draft(
                                    chartID: chartID,
                                    imageName: imageName
                                )
                            }
                            .execute(db)
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Adding sticker")
                        ))
                    }
                }

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
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Deleting stickers")
                        ))
                    }
                }

            case let .nameChanged(name):
                let chartID = state.chart.id
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try Chart.find(chartID)
                                .update { $0.name = name }
                                .execute(db)
                        }
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Renaming chart")
                        ))
                    }
                }

            case let .quickActionAmountChanged(id, amount):
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try QuickAction.find(id)
                                .update { $0.amount = amount }
                                .execute(db)
                        }
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Updating quick action amount")
                        ))
                    }
                }

            case let .quickActionNameChanged(id, name):
                let database = database
                return .run { send in
                    do {
                        try await database.write { db in
                            try QuickAction.find(id)
                                .update { $0.name = name }
                                .execute(db)
                        }
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Renaming quick action")
                        ))
                    }
                }

            case let .quickActionTapped(quickActionID):
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
                            guard try Chart.find(chartID).fetchOne(db) != nil else {
                                throw ChartMutationError.chartNoLongerExists
                            }
                            guard let quickAction = try QuickAction.find(quickActionID).fetchOne(db)
                            else { return }
                            for imageName in maxImageNames.prefix(quickAction.amount) {
                                try Sticker.insert {
                                    Sticker.Draft(
                                        chartID: chartID,
                                        imageName: imageName
                                    )
                                }
                                .execute(db)
                            }
                        }
                        try await syncEngine.sendChanges()
                    } catch {
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Running quick action")
                        ))
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
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Removing quick action")
                        ))
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
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Sharing chart")
                        ))
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
                        await send(.syncFailed(
                            SyncDiagnostics.log(error: error, operation: "Synchronizing changes")
                        ))
                    }
                }
            }
        }
    }

    public init() {}
}

private enum ChartMutationError: LocalizedError {
    case chartNoLongerExists

    var errorDescription: String? {
        switch self {
        case .chartNoLongerExists:
            return "This chart no longer exists locally. It was likely deleted on another device. Return to Charts and reopen."
        }
    }
}
