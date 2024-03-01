import ComposableArchitecture
import SwiftUI

@Reducer
public struct AddStickerFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Sendable {
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
    public init() {}
}

public struct AddStickerView: View {
    var store: StoreOf<AddStickerFeature>
    
    public init(store: StoreOf<AddStickerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Add sticker")
    }
}

#Preview {
    AddStickerView(
        store: Store(
            initialState: AddStickerFeature.State()
        ) {
            AddStickerFeature()
        }
    )
}
