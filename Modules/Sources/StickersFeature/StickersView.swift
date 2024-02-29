import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct StickersFeature {
    @ObservableState
    public struct State: Equatable {
        public var stickers: IdentifiedArrayOf<Sticker>
        
        public init(stickers: IdentifiedArrayOf<Sticker> = []) {
            self.stickers = stickers
        }
    }
    
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
    }
    
    public init() {}
}

public struct StickersView: View {
    var store: StoreOf<StickersFeature>
    
    public init(store: StoreOf<StickersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        LazyHGrid(rows: [GridItem(.fixed(20))], content: {
            ForEach(store.stickers, id: \.id) { sticker in
                switch sticker.size {
                case .large:
                    Image(systemName: "star.circle")
                        .font(.largeTitle)
                case .medium:
                    Image(systemName: "star.circle")
                        .font(.title2)
                case .small:
                    Image(systemName: "star.circle")
                        .font(.body)
                }
            }
        })
    }
}

#Preview {
    StickersView(
        store: Store(
            initialState: StickersFeature.State(
                stickers: [
                    Sticker(size: .large),
                    Sticker(size: .large),
                    Sticker(size: .medium),
                    Sticker(size: .small),
                    Sticker(size: .small),
                    Sticker(size: .small),
                ]
            )) {
                StickersFeature()
            }
    )
}
