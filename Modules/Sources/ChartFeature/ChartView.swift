import ComposableArchitecture
import SwiftUI

import StickerFeature

public struct Reward: Equatable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Behavior: Equatable, Identifiable, Sendable {
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
    public struct State: Equatable, Identifiable {
        public let id: UUID
        public var name: String
        public var reward: Reward?
        public var behaviors: [Behavior]
        public var stickers: IdentifiedArrayOf<StickerFeature.State>
        
        public init(
            id: UUID = UUID(),
            name: String,
            reward: Reward? = nil,
            behaviors: [Behavior] = [],
            stickers: IdentifiedArrayOf<StickerFeature.State>
        ) {
            self.id = id
            self.name = name
            self.reward = reward
            self.behaviors = behaviors
            self.stickers = stickers
        }
    }

    public enum Action: Sendable {
        case binding(BindingAction<State>)
        case stickers(IdentifiedActionOf<StickerFeature>)
        case view(ViewAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum ViewAction: Sendable {
            case addButtonTapped
            case redeemButtonTapped
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
                    state.stickers.append(StickerFeature.State(
                        sticker: Sticker(id: UUID(), systemName: "heart.fill")
                    ))
                    return .run { [state] send in
                        await send(.delegate(.onAddButtonTap(state.id)))
                    }
                case .redeemButtonTapped:
                    // TODO
                    return .none
                }
            case .delegate:
                return .none
            case .binding:
                return .none
            case .stickers:
                return .none
            }
        }
        .forEach(\.stickers, action: \.stickers) {
            StickerFeature()
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
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], spacing: 20) {
                    ForEach(store.scope(state: \.stickers, action: \.stickers), id: \.self) { store in
                        StickerView(store: store)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                    .frame(width: 20)
                Button {
                    store.send(.view(.redeemButtonTapped))
                } label: {
                    Image(systemName: "gift")
                        .accessibilityLabel("Redeem stickers")
                }
                
                Spacer()
                
                Button {
                    store.send(.view(.addButtonTapped))
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add sticker to \(store.name)")
                }
                Spacer()
                    .frame(width: 20)
            }
        }
    }
}

#Preview {
    Section {
        ChartView(
            store: Store(
                initialState: ChartFeature.State(
                    name: "Chores",
                    reward: Reward(name: "Fishing rod"),
                    stickers:
                        [
                            StickerFeature.State(sticker: Sticker(id: UUID(), systemName: "star.fill"))
                        ]
                )
            ) {
                ChartFeature()
            }
        )
    }
}
