import ComposableArchitecture
import SwiftUI

import Models
import StickersFeature

public struct Reward: Equatable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Chart: Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var reward: Reward?
    public var stickers: StickersFeature.State
    public var person: Person
    
    public init(id: UUID = UUID(), name: String, reward: Reward? = nil, stickers: StickersFeature.State, person: Person) {
        self.id = id
        self.name = name
        self.reward = reward
        self.stickers = stickers
        self.person = person
    }
}

@Reducer
public struct ChartFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var chart: Chart
        
        public init(
            id: UUID = UUID(),
            chart: Chart
        ) {
            self.id = id
            self.chart = chart
        }
    }

    public enum Action: Sendable {
        case binding(BindingAction<State>)
        case stickers(StickersFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.chart.stickers, action: \.stickers) {
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
                Spacer()
                HStack {
                    Image(systemName: "person.circle")
                    Text(store.chart.name)
                    Spacer()
                }
                Spacer()
                    .frame(height: 50)
                StickersView(store: store.scope(state: \.chart.stickers, action: \.stickers))
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
                            reward: Reward(name: "Fishing rod"),
                            stickers: StickersFeature.State(
                                stickers: [
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .large),
                                    Sticker(size: .medium),
                                    Sticker(size: .small),
                                    Sticker(size: .small),
                                    Sticker(size: .small),
                                ]
                            ),
                            person: Person(name: "Blob")
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
                            reward: Reward(name: "Fishing rod"),
                            stickers: StickersFeature.State(
                                stickers: []
                            ),
                            person: Person(name: "Blob")
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
                            stickers: StickersFeature.State(),
                            person: Person(name: "Blob")
                        )
                    )
                ) {
                    ChartFeature()
                }
            )
        }
    }
}
