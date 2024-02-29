import ComposableArchitecture
import Models
import StickersFeature
import SwiftUI

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var chart: Chart
        public var stickers: StickersFeature.State
        
        public init(
            id: UUID = UUID(),
            chart: Chart,
            stickers: StickersFeature.State
        ) {
            self.id = id
            self.chart = chart
            self.stickers = stickers
        }
    }

    public enum Action: Sendable {
        case binding(BindingAction<State>)
        case stickers(StickersFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.stickers, action: \.stickers) {
            StickersFeature()
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
        HStack {
            VStack {
                HStack {
                    Text(store.chart.name)
                    Spacer()
                }
                HStack {
                    StickersView(store: store.scope(state: \.stickers, action: \.stickers))
                    Spacer()
                }
            }
            Spacer()
        }
    }
}

#Preview {
    List {
        Section {
            ChartView(
                store: Store(
                    initialState: ChartFeature.State(
                        chart: Chart(
                            name: "Chores",
                            reward: Reward(name: "Fishing rod")
                        ),
                        stickers: StickersFeature.State(
                            stickers: [
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .large),
                                Sticker(size: .medium),
                                Sticker(size: .small),
                                Sticker(size: .small),
                                Sticker(size: .small),
                            ]
                        )
                    )
                ) {
                    ChartFeature()
                }
            )
        }
        
        Section {
            ChartView(
                store: Store(
                    initialState: ChartFeature.State(
                        chart: Chart(
                            name: "Chores",
                            reward: Reward(name: "Fishing rod")
                        ),
                        stickers: StickersFeature.State(
                            stickers: []
                        )
                    )
                ) {
                    ChartFeature()
                }
            )
        }
        
        Section {
            ChartView(
                store: Store(
                    initialState: ChartFeature.State(
                        chart: Chart(
                            name: "Chores"
                        ),
                        stickers: StickersFeature.State()
                    )
                ) {
                    ChartFeature()
                }
            )
        }
    }
}
