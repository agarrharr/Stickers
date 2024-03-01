import ComposableArchitecture
import Models
import SwiftUI

public enum StickerSize {
    case small
    case medium
    case large
}

public struct Sticker: Equatable, Identifiable {
    public var id: UUID
    public var size: StickerSize
    
    public init(id: UUID = UUID(), size: StickerSize) {
        self.id = id
        self.size = size
    }
}

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
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
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
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
            .onAppear {
                // Scroll all the way to the right
                value.scrollTo(store.stickers[store.stickers.count - 1].id, anchor: .trailing)
            }
        }
    }
}

#Preview {
    StickersView(
        store: Store(
            initialState: StickersFeature.State(
                stickers: [
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
            )) {
                StickersFeature()
            }
    )
}
