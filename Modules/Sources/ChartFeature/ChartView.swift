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
            id: UUID,
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
                Text(store.chart.name)
                StickersView(store: store.scope(state: \.stickers, action: \.stickers))
            }
        }
    }
}

#Preview {
    ChartView(
        store: Store(
            initialState: ChartFeature.State(
                id: UUID(),
                chart: Chart(
                    id: UUID(),
                    name: "Chores",
                    reward: Reward(name: "Fishing rod")
                ),
                stickers: StickersFeature.State(
                    id: UUID(),
                    stickers: [
                        Sticker(id: UUID(), size: .large),
                        Sticker(id: UUID(), size: .large),
                        Sticker(id: UUID(), size: .large),
                        Sticker(id: UUID(), size: .medium),
                        Sticker(id: UUID(), size: .small),
                        Sticker(id: UUID(), size: .small),
                        Sticker(id: UUID(), size: .small),
                    ]
                )
            )
        ) {
            ChartFeature()
        }
    )
}
