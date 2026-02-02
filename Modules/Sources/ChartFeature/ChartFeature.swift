import ComposableArchitecture
import Foundation
import NonEmpty
import SQLiteData

import Models
import StickerFeature

public struct ChartDataRequest: FetchKeyRequest {
    var chartID: Chart.ID

    public struct Value: Equatable, Sendable {
        var chart: Chart?
        var stickers: [Sticker] = []
        var quickActions: [QuickAction] = []
    }

    public func fetch(_ db: Database) throws -> Value {
        try Value(
            chart: Chart.find(chartID).fetchOne(db),
            stickers: Sticker.where { $0.chartID.eq(chartID) }.fetchAll(db),
            quickActions: QuickAction.where { $0.chartID.eq(chartID) }.fetchAll(db)
        )
    }
}

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var chartID: Chart.ID
        var chart: Chart?
        var stickers: [Sticker] = []
        var quickActions: [QuickAction] = []
        var isLoading = false
        
        var showSettings = false

        public init(chartID: Chart.ID) {
            self.chartID = chartID
        }
    }

    public enum Action: Sendable {
        case addStickerButtonTapped
        case chartDataResponse(ChartDataRequest.Value)
        case quickActionTapped(QuickAction.ID)
        case settingsButtonTapped
        case settingsDismissed
        case nameChanged(String)
        case addQuickActionButtonTapped
        case removeQuickAction(QuickAction.ID)
        case quickActionNameChanged(QuickAction.ID, String)
        case quickActionAmountChanged(QuickAction.ID, Int)
        case task
    }

    @Dependency(\.defaultDatabase) var database
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addStickerButtonTapped:
                let imageName = withRandomNumberGenerator { generator in
                    stickerPack.randomElement(using: &generator)!
                }
                let chartID = state.chartID
                let database = database
                return .run { _ in
                    try database.write { db in
                        try Sticker.insert {
                            Sticker.Draft(chartID: chartID, imageName: imageName)
                        }.execute(db)
                    }
                }
                
            case let .chartDataResponse(value):
                state.isLoading = false
                state.chart = value.chart
                state.stickers = value.stickers
                state.quickActions = value.quickActions
                
                return .none

            case let .quickActionTapped(quickActionID):
                let chartID = state.chartID
                let maxImageNames = withRandomNumberGenerator { generator in
                    (0..<99).map { _ in
                        stickerPack.randomElement(using: &generator)!
                    }
                }
                let database = database
                return .run { _ in
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

            case .settingsButtonTapped:
                state.showSettings = true
                return .none

            case .settingsDismissed:
                state.showSettings = false
                return .none

            case let .nameChanged(name):
                let chartID = state.chartID
                let database = database
                return .run { _ in
                    try database.write { db in
                        try Chart.find(chartID)
                            .update { $0.name = name }
                            .execute(db)
                    }
                }

            case .addQuickActionButtonTapped:
                let chartID = state.chartID
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
                    try database.write { db in
                        try QuickAction.find(id)
                            .update { $0.name = name }
                            .execute(db)
                    }
                }

            case let .quickActionAmountChanged(id, amount):
                let database = database
                return .run { _ in
                    try database.write { db in
                        try QuickAction.find(id)
                            .update { $0.amount = amount }
                            .execute(db)
                    }
                }
                
            case .task:
                state.isLoading = true
                let request = ChartDataRequest(chartID: state.chartID)
                
                let database = database
                return .run { send in
                    let value = try await database.read { db in
                        try request.fetch(db)
                    }
                    await send(.chartDataResponse(value))
                }
            }
        }
    }

    public init() {}
}
