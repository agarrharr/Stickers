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
        var sharedRecord: SharedRecord?
        var showSettings = false
        var viewMode: ViewMode = .grid
        var destination: Destination?

        public init(chart: Chart) {
            self.chart = chart
        }
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case addStickerButtonTapped
        case quickActionTapped(QuickAction.ID)
        case settingsButtonTapped
        case settingsDismissed
        case shareButtonTapped
        case shareResponse(SharedRecord)
        case shareDismissed
        case nameChanged(String)
        case addQuickActionButtonTapped
        case removeQuickAction(QuickAction.ID)
        case quickActionNameChanged(QuickAction.ID, String)
        case quickActionAmountChanged(QuickAction.ID, Int)
        case deleteAllStickersButtonTapped
        case deleteAllStickersConfirmed
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

            case .addStickerButtonTapped:
                let imageName = withRandomNumberGenerator { generator in
                    stickerPack.randomElement(using: &generator)!
                }
                let chartID = state.chart.id
                let database = database
                return .run { _ in
                    withErrorReporting {
                        try database.write { db in
                            try Sticker.insert {
                                Sticker.Draft(chartID: chartID, imageName: imageName)
                            }.execute(db)
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
                let database = database
                return .run { _ in
                    withErrorReporting {
                        try database.write { db in
                            guard let quickAction = try QuickAction.find(quickActionID).fetchOne(db)
                            else { return }
                            for imageName in maxImageNames.prefix(quickAction.amount) {
                                try Sticker.insert {
                                    Sticker.Draft(chartID: chartID, imageName: imageName)
                                }.execute(db)
                            }
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
                        print("Share error: \(error)")
                    }
                }

            case let .shareResponse(sharedRecord):
                state.sharedRecord = sharedRecord
                return .none

            case .shareDismissed:
                state.sharedRecord = nil
                return .none

            case let .nameChanged(name):
                let chartID = state.chart.id
                let database = database
                return .run { _ in
                    try await database.write { db in
                        try Chart.find(chartID)
                            .update { $0.name = name }
                            .execute(db)
                    }
                }
                
            case .addQuickActionButtonTapped:
                let chartID = state.chart.id
                let database = database
                return .run { _ in
                    try database.write { db in
                        try QuickAction.insert {
                            QuickAction.Draft(chartID: chartID)
                        }.execute(db)
                    }
                }

            case let .removeQuickAction(id):
                let database = database
                return .run { _ in
                    try database.write { db in
                        try QuickAction.find(id)
                            .delete()
                            .execute(db)
                    }
                }

            case let .quickActionNameChanged(id, name):
                let database = database
                return .run { _ in
                    try await database.write { db in
                        try QuickAction.find(id)
                            .update { $0.name = name }
                            .execute(db)
                    }
                }

            case let .quickActionAmountChanged(id, amount):
                let database = database
                return .run { _ in
                    try await database.write { db in
                        try QuickAction.find(id)
                            .update { $0.amount = amount }
                            .execute(db)
                    }
                }

            case .deleteAllStickersButtonTapped:
                state.destination = .deleteAllStickersAlert
                return .none

            case .deleteAllStickersConfirmed:
                state.destination = nil
                let chartID = state.chart.id
                let database = database
                return .run { _ in
                    withErrorReporting {
                        try database.write { db in
                            try Sticker
                                .where { $0.chartID.eq(chartID) }
                                .delete()
                                .execute(db)
                        }
                    }
                }

//            case .task:
//                state.isLoading = true
//                let request = ChartDataRequest(chartID: state.chartID)
//                
//                let database = database
//                return .run { send in
//                    let value = try await database.read { db in
//                        try request.fetch(db)
//                    }
//                    await send(.chartDataResponse(value))
//                }
            }
        }
    }

    public init() {}
}
