import ComposableArchitecture
import NonEmpty
import SwiftUI

public struct Sticker: Equatable {
    public var imageName: String
    
    public init(imageName: String) {
        self.imageName = imageName
    }
}

public struct StickerPack: Equatable {
    public var stickers: NonEmpty<[Sticker]>
}

public let defaultStickerPack = StickerPack(
    stickers: NonEmpty<[Sticker]>(
        Sticker(imageName: "0"),
        Sticker(imageName: "1"),
        Sticker(imageName: "2"),
        Sticker(imageName: "3"),
        Sticker(imageName: "4"),
        Sticker(imageName: "5"),
        Sticker(imageName: "6"),
        Sticker(imageName: "7"),
        Sticker(imageName: "8"),
        Sticker(imageName: "8"),
        Sticker(imageName: "10"),
        Sticker(imageName: "11"),
        Sticker(imageName: "12"),
        Sticker(imageName: "13"),
        Sticker(imageName: "14"),
        Sticker(imageName: "15"),
        Sticker(imageName: "16"),
        Sticker(imageName: "17"),
        Sticker(imageName: "18"),
        Sticker(imageName: "19"),
        Sticker(imageName: "20"),
        Sticker(imageName: "21"),
        Sticker(imageName: "22"),
        Sticker(imageName: "23")
    )
)

@Reducer
public struct StickerFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: UUID
        public var sticker: Sticker
        
        public init(id: UUID = UUID(), sticker: Sticker) {
            self.id = id
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
        Image(store.sticker.imageName, bundle: .module)
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
                sticker: defaultStickerPack.stickers.first
            )
        ) {
                StickerFeature()
                
            }
    )
}
