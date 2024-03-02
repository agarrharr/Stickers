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

public struct Behavior: Equatable, Identifiable {
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

public struct Chart: Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var reward: Reward?
    public var behaviors: [Behavior]
    public var stickers: StickersFeature.State
    public var person: Person
    
    public init(
        id: UUID = UUID(),
        name: String,
        reward: Reward? = nil,
        behaviors: [Behavior] = [],
        stickers: StickersFeature.State = StickersFeature.State(),
        person: Person
    ) {
        self.id = id
        self.name = name
        self.reward = reward
        self.behaviors = behaviors
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
        case view(ViewAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addButtonTapped
        }
        @CasePathable
        public enum DelegateAction: Sendable {
            case onAddButtonTap(UUID)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .addButtonTapped:
                    return .run { [chart = state.chart] send in
                        await send(.delegate(.onAddButtonTap(chart.id)))
                    }
                }
            case .delegate:
                return .none
            case .binding:
                return .none
            case .stickers:
                return .none
            }
        }
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
        VStack {
            Spacer()
            HStack {
                Image(systemName: "person.circle")
                Text(store.chart.name)
                Spacer()
                Button {
                    store.send(.view(.addButtonTapped))
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add sticker to \(store.chart.name)")
                }
            }
            Spacer()
                .frame(height: 50)
            StickersView(store: store.scope(state: \.chart.stickers, action: \.stickers))
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
