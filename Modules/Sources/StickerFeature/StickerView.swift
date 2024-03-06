import ComposableArchitecture
import SwiftUI

public struct Sticker: Equatable, Identifiable {
    public var id: UUID
    public var systemName: String
    
    public init(id: UUID, systemName: String) {
        self.id = id
        self.systemName = systemName
    }
}

struct StickerPack: Equatable {
    var stickers: [Sticker]
}

let defaultStickerPack = StickerPack(
    stickers: [
        Sticker(id: UUID(), systemName: "star.fill"),
        Sticker(id: UUID(), systemName: "sun.max.fill"),
        Sticker(id: UUID(), systemName: "moon.fill"),
        Sticker(id: UUID(), systemName: "rainbow"),
        Sticker(id: UUID(), systemName: "face.smiling.inverse"),
        Sticker(id: UUID(), systemName: "cat.fill"),
        Sticker(id: UUID(), systemName: "dog.fill"),
    ]
)

@Reducer
public struct StickerFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID
        public var sticker: Sticker
        
        public init(sticker: Sticker) {
            self.id = sticker.id
            self.sticker = sticker
        }
    }
    
    public enum Action: Sendable {
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
    public init() {}
}

public struct StickerView: View {
    var store: StoreOf<StickerFeature>
    
    public init(store: StoreOf<StickerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Image(systemName: store.sticker.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(.yellow)
    }
}

#Preview {
    StickerView(
        store: Store(
            initialState: StickerFeature.State(
                sticker: defaultStickerPack.stickers[0]
            )
        ) {
                StickerFeature()
                
            }
    )
}
