import ComposableArchitecture
import NonEmpty
import Sharing
import SwiftUI

import StickerFeature

public struct Chart: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var name: String
    public var reward: Reward?
    public var behaviors: [Behavior]
    public var stickers: IdentifiedArrayOf<Sticker>
    public var stickerPack: StickerPack
    
    public init(id: UUID = UUID(), name: String, reward: Reward? = nil, behaviors: [Behavior], stickers: IdentifiedArrayOf<Sticker>, stickerPack: StickerPack) {
        self.id = id
        self.name = name
        self.reward = reward
        self.behaviors = behaviors
        self.stickers = stickers
        self.stickerPack = stickerPack
    }
}

public struct Reward: Codable, Equatable, Sendable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Behavior: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        amount: Int
    ) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared public var chart: Chart
        
        public init(chart: Shared<Chart>) {
            self._chart = chart
        }
    }

    public enum Action: Sendable {
        case addStickerButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addStickerButtonTapped:
                let sticker = state.chart.stickerPack.stickers.randomElement()!
                _ = state.$chart.withLock { $0.stickers.append(Sticker(imageName: sticker.imageName)) }
                return .none
            }
        }
    }

    public init() {}
}

public struct ChartView: View {
    var store: StoreOf<ChartFeature>
    
    public init(store: StoreOf<ChartFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(store.chart.stickers) { sticker in
                    StickerView(
                        store: Store(initialState: StickerFeature.State(sticker: sticker)) {
                            StickerFeature()
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(store.chart.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.addStickerButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
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

#Preview {
    NavigationStack {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(
                    chart: Shared(value: Chart(
                        id: UUID(),
                        name: "Chores",
                        reward: Reward(name: "Fishing rod"),
                        behaviors: [],
                        stickers: [
                            Sticker(imageName: "face-0"),
                            Sticker(imageName: "face-1"),
                            Sticker(imageName: "face-2"),
                            Sticker(imageName: "face-3"),
                            Sticker(imageName: "face-4"),
                            Sticker(imageName: "face-5"),
                            Sticker(imageName: "face-6"),
                            Sticker(imageName: "face-7")
                        ],
                        stickerPack: StickerPack(stickers: NonEmpty<[Sticker]>(Sticker(id: UUID(), imageName: "face-0")))
                    ))
                )
            ) {
                ChartFeature()
            }
        )
    }
}
