import ComposableArchitecture
import Foundation
import NonEmpty
import Sharing

import Models
import StickerFeature

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared public var chart: Chart
        var showSettings = false

        public init(chart: Shared<Chart>) {
            self._chart = chart
        }
    }

    public enum Action: Sendable {
        case addStickerButtonTapped
        case quickActionTapped(QuickAction.ID)
        case settingsButtonTapped
        case settingsDismissed
        case nameChanged(String)
        case addQuickActionButtonTapped
        case removeQuickAction(QuickAction.ID)
        case quickActionNameChanged(QuickAction.ID, String)
        case quickActionAmountChanged(QuickAction.ID, Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addStickerButtonTapped:
                let sticker = stickerPack.randomElement()!
                _ = state.$chart.withLock { $0.stickers.append(Sticker(imageName: sticker.imageName)) }
                return .none

            case let .quickActionTapped(quickActionID):
                guard let quickAction = state.chart.quickActions.first(where: { $0.id == quickActionID }) else { return .none }
                state.$chart.withLock { chart in
                    for _ in 0..<quickAction.amount {
                        let sticker = stickerPack.randomElement()!
                        chart.stickers.append(Sticker(imageName: sticker.imageName))
                    }
                }
                return .none

            case .settingsButtonTapped:
                state.showSettings = true
                return .none

            case .settingsDismissed:
                state.showSettings = false
                return .none

            case let .nameChanged(name):
                state.$chart.withLock { $0.name = name }
                return .none

            case .addQuickActionButtonTapped:
                state.$chart.withLock { $0.quickActions.append(QuickAction(name: "", amount: 1)) }
                return .none

            case let .removeQuickAction(id):
                state.$chart.withLock { $0.quickActions.removeAll { $0.id == id } }
                return .none

            case let .quickActionNameChanged(id, name):
                state.$chart.withLock { chart in
                    if let index = chart.quickActions.firstIndex(where: { $0.id == id }) {
                        chart.quickActions[index].name = name
                    }
                }
                return .none

            case let .quickActionAmountChanged(id, amount):
                state.$chart.withLock { chart in
                    if let index = chart.quickActions.firstIndex(where: { $0.id == id }) {
                        chart.quickActions[index].amount = amount
                    }
                }
                return .none
            }
        }
    }

    public init() {}
}

public extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<Chart>>.Default {
    static var charts: Self {
        Self[.fileStorage(getChartsJSONURL()), default: []]
    }
}

func getAppSandboxDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func getChartsJSONURL() -> URL {
    getAppSandboxDirectory().appendingPathComponent("charts.json")
}
