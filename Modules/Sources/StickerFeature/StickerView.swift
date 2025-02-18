import ComposableArchitecture
@preconcurrency import NonEmpty
import SwiftUI

public struct Sticker: Identifiable, Equatable, Sendable, Codable {
    public var id: UUID
    public var imageName: String
    
    public init(id: UUID = UUID(), imageName: String) {
        self.id = id
        self.imageName = imageName
    }
}

public struct StickerPack: Equatable, Sendable, Codable {
    public var stickers: NonEmpty<[Sticker]>
    
    public init(stickers: NonEmpty<[Sticker]>) {
        self.stickers = stickers
    }
}

public let defaultStickerPack = StickerPack(
    stickers: NonEmpty<[Sticker]>(
        Sticker(imageName: "face-0"),
        Sticker(imageName: "face-1"),
        Sticker(imageName: "face-2"),
        Sticker(imageName: "face-3"),
        Sticker(imageName: "face-4"),
        Sticker(imageName: "face-5"),
        Sticker(imageName: "face-6"),
        Sticker(imageName: "face-7"),
        Sticker(imageName: "face-8"),
        Sticker(imageName: "face-8"),
        Sticker(imageName: "face-10"),
        Sticker(imageName: "face-11"),
        Sticker(imageName: "face-12"),
        Sticker(imageName: "face-13"),
        Sticker(imageName: "face-14"),
        Sticker(imageName: "face-15"),
        Sticker(imageName: "face-16"),
        Sticker(imageName: "face-17"),
        Sticker(imageName: "face-18"),
        Sticker(imageName: "face-19"),
        Sticker(imageName: "face-20"),
        Sticker(imageName: "face-21"),
        Sticker(imageName: "face-22"),
        Sticker(imageName: "face-23")
    )
)

public let catStickerPack = StickerPack(
    stickers: NonEmpty<[Sticker]>(
        Sticker(imageName: "cat-0"),
        Sticker(imageName: "cat-1"),
        Sticker(imageName: "cat-2"),
        Sticker(imageName: "cat-3"),
        Sticker(imageName: "cat-4"),
        Sticker(imageName: "cat-5"),
        Sticker(imageName: "cat-6"),
        Sticker(imageName: "cat-7"),
        Sticker(imageName: "cat-8")
    )
)

@Reducer
public struct StickerFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var sticker: Sticker
        
        public init(sticker: Sticker) {
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
            .frame(width: 60, height: 60)
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
